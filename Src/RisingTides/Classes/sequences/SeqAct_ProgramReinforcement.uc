class SeqAct_ProgramReinforcement extends SequenceAction;

var() name SquadName;
var() vector SpawnPosition;
var XComGameState_AIGroup Group;
var protected SeqVar_GameStateList List; 

var() array<XComGameState_Unit> SpawnedUnits;

var private array<int> chosenSpawnPositionIndexes;
var private int chosenSpawnPositionIndex;

defaultproperties
{
	ObjName="Call in Program Reinforcements"
	ObjCategory="RisingTides"

	chosenSpawnPositionIndex = 0

	bConvertedForReplaySystem=true
	bCanBeUsedForGameplaySequence=true
	bAutoActivateOutputLinks=true

	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Input Location",PropertyName=SpawnLocation)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Actual Location",PropertyName=ActualSpawnLocation,bWriteable=true)
	VariableLinks(2)=(ExpectedType=class'SeqVar_GameGroup',LinkDesc="Group",PropertyName=Group)
	VariableLinks(3)=(ExpectedType=class'SeqVar_GameStateList',LinkDesc="Game State List",bWriteable=true,MinVars=1,MaxVars=1)
}

event Activated()
{
	local name LocalSquadName;

	if(SquadName == LocalSquadName) {
		`RTLOG("KISMET: SeqAct_ProgramReinforcement recieved no value for SquadName, defaulting to SPECTRE.");
		LocalSquadName = 'SPECTRE';
	} else {
		LocalSquadName = SquadName;
	}

	CallInProgramOperativeReinforcements(LocalSquadName);
}

function CallInProgramOperativeReinforcements(name LocalSquadName) {
	local array<RTGameState_Unit> OperativeStates;

	OperativeStates = GetOperatives(LocalSquadName);
	if(OperativeStates.Length == 0) {
		return;
	}

	AddOperativesToTactical(OperativeStates);
	AddOperativesToXComGroup(OperativeStates);
	AddOperativesToXComSquad(OperativeStates);
}

protected function AddOperativesToTactical(array<RTGameState_Unit> UnitStates) {
	local X2TacticalGameRuleset Rules;
	local Vector SpawnLocation;
	local XComGameState NewGameState;
	local XComGameState_Player PlayerState, IteratorPlayerState;
	local StateObjectReference ItemReference;
	local XComGameState_Item ItemState;
	local RTGameState_Unit UnitState;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	`RTLOG("AddOperativesToTactical");

	foreach History.IterateByClassType(class'XComGameState_Player', IteratorPlayerState) {
		if(IteratorPlayerState.GetTeam() == eTeam_XCom) {
			PlayerState = IteratorPlayerState;
		}
	}

	if(PlayerState == none) {
		`RTLOG("Could not find player state to assign operatives to, SeqAct_ProgramReinforcement may bug out.", true, false);
	}

	// create the history frame with the new tactical unit states
	NewGameState = `CreateChangeState(string(GetFuncName()));
	foreach UnitStates(UnitState) {
		if(UnitState == none) {
			`RTLOG("Recieved a null UnitState in AddOperativeToTactical!", true, true);
			continue;
		}
		SpawnLocation = SpawnPosition;
		// pick a floor point at random to spawn the unit at
		if(!ChooseSpawnLocation(SpawnLocation)) {
			`RTLOG("Couldn't find a location to spawn at in AddOperativeToTactical!", true, true);
			continue;
		}

		UnitState = RTGameState_Unit(NewGameState.ModifyStateObject(class'RTGameState_Unit', UnitState.ObjectID));
		`RTLOG("Adding " $ UnitState.GetName(eNameType_Nick) $ " to tactical!");

		UnitState.BeginTacticalPlay(NewGameState);   // this needs to be called explicitly since we're adding an existing state directly into tactical
		UnitState.SetVisibilityLocationFromVector(SpawnLocation);

		// assign the new unit to the player team
		UnitState.SetControllingPlayer(PlayerState.GetReference());

		// add item states. This needs to be done so that the visualizer sync picks up the IDs and creates their visualizers
		foreach UnitState.InventoryItems(ItemReference) {
			ItemState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', ItemReference.ObjectID));
			ItemState.BeginTacticalPlay(NewGameState); // this needs to be called explicitly since we're adding an existing state directly into tactical

			// add any cosmetic items that might exist
			ItemState.CreateCosmeticItemUnit(NewGameState);
		}

		// Give them a single action point ala scamper
		UnitState.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
	}

	// submit it
	Rules = `TACTICALRULES;
	XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = ProgramReinforcements_BuildVisualization;
	Rules.SubmitGameState(NewGameState);

	// make sure the visualizer has been created so self-applied abilities have a target in the world
	foreach UnitStates(UnitState) {
		//UnitState.FindOrCreateVisualizer(NewGameState);
	}

	// add abilities
	// Must happen after unit is submitted, or it gets confused about when the unit is in play or not 
	NewGameState = `CreateChangeState("Adding Operative Abilities");
	foreach UnitStates(UnitState) {
		`RTLOG("Initializing Unit Abilities for " $ UnitState.GetName(eNameType_Nick));
		UnitState = RTGameState_Unit(NewGameState.ModifyStateObject(class'RTGameState_Unit', UnitState.ObjectID));
		Rules.InitializeUnitAbilities(NewGameState, UnitState);
	}
	Rules.SubmitGameState(NewGameState);
}

protected static function array<RTGameState_Unit> GetOperatives(name LocalSquadName) {
	local RTGameState_PersistentGhostSquad SquadState;
	local array<RTGameState_Unit> OperativeStates, EmptyList;
	local StateObjectReference UnitRef;
	local RTGameState_Unit UnitState;
	local int LastStrategyStateIndex;
	local array<XComGameState_Unit> UnitsInPlay;
	local XComGameState_Unit UnitInPlay;
	local XComGameState StrategyState;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	LastStrategyStateIndex = History.FindStartStateIndex() - 1;
	if(LastStrategyStateIndex < 1) {
		`RTLOG("Couldn't find a StrategyStateIndex?!", true, false);
		return EmptyList;
	}

	// build a list of all units currently on the board, we will exclude them from consideration. Add non-xcom units as well
	// in case they are mind controlled or otherwise under the control of the enemy team
	foreach History.IterateByClassType(class'XComGameState_Unit', UnitInPlay) {
		UnitsInPlay.AddItem(UnitInPlay);
	}

	// grab the archived strategy state from the history and the headquarters object
	StrategyState = History.GetGameStateFromHistory(LastStrategyStateIndex, eReturnType_Copy, false);

	foreach StrategyState.IterateByClassType(class'RTGameState_PersistentGhostSquad', SquadState) {
		if(name(SquadState.GetName()) == LocalSquadName) {
			break;
		}
	}

	if(name(SquadState.GetName()) != LocalSquadName) {
		`RTLOG("SeqAct_ProgramReinforcement: Couldn't find " $ LocalSquadName);
		return EmptyList;
	}

	foreach SquadState.Operatives(UnitRef) {
		UnitState = RTGameState_Unit(StrategyState.GetGameStateForObjectID(UnitRef.ObjectID));
		if(UnitState == none) {
			`RTLOG("SeqAct_ProgramReinforcement: Couldn't find GameState for Operative StateObjectReference " $ UnitRef.ObjectID);
			continue;
		}
		
		if(UnitsInPlay.Find(UnitState) != INDEX_NONE) {
			`RTLOG("SeqAct_ProgramReinforcement: Program Operative was already in play?!", true, true);
			continue;
		}

		OperativeStates.AddItem(UnitState);
	}

	if(OperativeStates.Length < 1) {
		`RTLOG("Couldn't find any Operatives for squad " $ LocalSquadName);
		return EmptyList;
	}

	return OperativeStates;
}

// chooses a location for the unit to spawn in the spawn zone
protected function bool ChooseSpawnLocation(out Vector ChosenSpawnLocation) {
	local XComGroupSpawn SoldierSpawn, IteratorSoldierSpawn;
	local array<Vector> FloorPoints;
	local Vector EmptyVector;
	local float ClosestDistanceSquared, DistanceSquared;
	local int PositionIndex;

	if(SoldierSpawn == none) // check for test maps, just grab any spawn
	{
		foreach `XComGRI.AllActors(class'XComGroupSpawn', IteratorSoldierSpawn)
		{
			DistanceSquared = VSizeSq(ChosenSpawnLocation - IteratorSoldierSpawn.Location);
			if(DistanceSquared < ClosestDistanceSquared || SoldierSpawn == none)
			{
				SoldierSpawn = IteratorSoldierSpawn;
				ClosestDistanceSquared = DistanceSquared;
			}
		}
	}

	SoldierSpawn.GetValidFloorLocations(FloorPoints);
	if(FloorPoints.Length == 0)
	{
		return false;
	}
	else
	{
		// find pos. I don't think ValidFloorLocations can return a valid location because the units are spawned simultanuously
		/*while(!bFoundNewPos && count < 20) {
			count++;
			PositionIndex = `SYNC_RAND_STATIC(FloorPoints.Length);
			if(chosenSpawnPositionIndexes.Find(PositionIndex) != INDEX_NONE) {
				bFoundNewPos = true;
			}
		}*/
		ChosenSpawnLocation = FloorPoints[chosenSpawnPositionIndex];
		chosenSpawnPositionIndex++;

		if(ChosenSpawnLocation == EmptyVector) {
			PositionIndex = `SYNC_RAND_STATIC(FloorPoints.Length);
			ChosenSpawnLocation = FloorPoints[PositionIndex];
		}
		return true;
	}
}

simulated function ProgramReinforcements_BuildVisualization(XComGameState VisualizeGameState) {
	local XComGameStateHistory History;
	local VisualizationActionMetadata EmptyTrack, ActionMetadata, NewUnitActionMetadata;
	local StateObjectReference InteractingUnitRef;
	local X2Action_CameraLookAt LookAtAction;
	local XComGameState_Unit UnitState;
	local array<XComGameState_Unit> FreshlySpawnedUnitStates;
	local TTile SpawnedUnitTile;
	local X2Action_RevealArea RevealAreaAction;
	local XComWorldData WorldData;
	local X2Action_PlayEffect SpawnEffectAction;
	local X2Action_Delay RandomDelay;
	local float OffsetVisDuration;
	local array<X2Action>					LeafNodes;
	local XComContentManager ContentManager;
	local XComGameStateVisualizationMgr VisualizationMgr;
	local X2Action_MarkerNamed SyncAction;

	local XComGameStateContext Context;

	VisualizationMgr = `XCOMVISUALIZATIONMGR;
	ContentManager = `CONTENT;
	History = `XCOMHISTORY;
	Context = VisualizeGameState.GetContext();

	`RTLOG("Beginning Program Reinforcements visualization!");
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState) {
		`RTLOG("Found unit " $ UnitState.GetName(eNameType_Nick));
		FreshlySpawnedUnitStates.AddItem(UnitState);
	}
	InteractingUnitRef = FreshlySpawnedUnitStates[0].GetReference();

	// if any units spawned in as part of this action, visualize the spawning as part of this sequence
	if( FreshlySpawnedUnitStates.Length > 0 )
	{
		`RTLOG("Spawning Program Reinforcements!");
		WorldData = `XWORLD;

		ActionMetadata = EmptyTrack;
		ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
		ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
		ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

		LookAtAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		LookAtAction.UseTether = false;
		LookAtAction.LookAtObject = ActionMetadata.StateObject_NewState;
		LookAtAction.BlockUntilActorOnScreen = true;

		RevealAreaAction = X2Action_RevealArea(class'X2Action_RevealArea'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		RevealAreaAction.ScanningRadius = class'XComWorldData'.const.WORLD_StepSize * 5.0f;
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(InteractingUnitRef.ObjectID));
		UnitState.GetKeystoneVisibilityLocation(SpawnedUnitTile);
		RevealAreaAction.TargetLocation = WorldData.GetPositionFromTileCoordinates(SpawnedUnitTile);
		RevealAreaAction.bDestroyViewer = false;
		RevealAreaAction.AssociatedObjectID = InteractingUnitRef.ObjectID;

		SyncAction = X2Action_MarkerNamed(class'X2Action_MarkerNamed'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		SyncAction.SetName("SpawningStart");
		//SyncAction.AddInputEvent('Visualizer_AbilityHit');

		foreach FreshlySpawnedUnitStates(UnitState)
		{
			if( UnitState.GetVisualizer() == none )
			{
				UnitState.FindOrCreateVisualizer();
				UnitState.SyncVisualizer();

				//Make sure they're hidden until ShowSpawnedUnit makes them visible (SyncVisualizer unhides them)
				XGUnit(UnitState.GetVisualizer()).m_bForceHidden = true;
			}

			NewUnitActionMetadata = EmptyTrack;
			NewUnitActionMetadata.StateObject_OldState = None;
			NewUnitActionMetadata.StateObject_NewState = UnitState;
			NewUnitActionMetadata.VisualizeActor = History.GetVisualizer(UnitState.ObjectID);

			// if multiple units are spawning, apply small random delays between each
			if( UnitState != FreshlySpawnedUnitStates[0] )
			{
				RandomDelay = X2Action_Delay(class'X2Action_Delay'.static.AddToVisualizationTree(NewUnitActionMetadata, Context, false, SyncAction));
				OffsetVisDuration += 0.5f + `SYNC_FRAND(1) * 0.5f;
				RandomDelay.Duration = OffsetVisDuration;
			}
			
			X2Action_ShowSpawnedUnit(class'X2Action_ShowSpawnedUnit'.static.AddToVisualizationTree(NewUnitActionMetadata, Context, false, ActionMetadata.LastActionAdded));

			UnitState.GetKeystoneVisibilityLocation(SpawnedUnitTile);

			SpawnEffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(NewUnitActionMetadata, Context, false, ActionMetadata.LastActionAdded));
			SpawnEffectAction.EffectName = ContentManager.ChosenReinforcementsEffectPathName;
			SpawnEffectAction.EffectLocation = WorldData.GetPositionFromTileCoordinates(SpawnedUnitTile);
			SpawnEffectAction.bStopEffect = false;
		}

		RandomDelay = X2Action_Delay(class'X2Action_Delay'.static.AddToVisualizationTree(NewUnitActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		RandomDelay.Duration = 4.0f;

		VisualizationMgr.GetAllLeafNodes(VisualizationMgr.BuildVisTree, LeafNodes);

		RevealAreaAction = X2Action_RevealArea(class'X2Action_RevealArea'.static.AddToVisualizationTree(ActionMetadata, Context, false, none, LeafNodes));
		RevealAreaAction.bDestroyViewer = true;
		RevealAreaAction.AssociatedObjectID = InteractingUnitRef.ObjectID;
	} else {
		`RTLOG("Couldn't spawn in any units!");
	}
	`RTLOG("Ending Program Reinforcements visualization!");
}

protected function AddOperativesToXComGroup(array<RTGameState_Unit> OperativeStates) {
	local XComGameState NewGameState;
	local XComGameState_AIGroup PreviousGroupState;
	local RTGameState_Unit UnitState;

	`RTLOG("AddOperativesToXComGroup");

	NewGameState = `CreateChangeState("Assign Program Reinforcements to Group");
	foreach OperativeStates(UnitState) {
		if(UnitState == none) {
			continue;
		}
		UnitState = RTGameState_Unit(NewGameState.ModifyStateObject(class'RTGameState_Unit', UnitState.ObjectID));

		PreviousGroupState = UnitState.GetGroupMembership();
		
		if( PreviousGroupState != none )
			PreviousGroupState.RemoveUnitFromGroup(UnitState.ObjectID, NewGameState);
		
		Group.AddUnitToGroup(UnitState.ObjectID, NewGameState);
	}

	`GAMERULES.SubmitGameState(NewGameState);
}

protected function AddOperativesToXComSquad(array<RTGameState_Unit> OperativeStates) {
	local RTGameState_Unit UnitState;

	`RTLOG("AddOperativesToXComSquad");

	List = none;
	foreach LinkedVariables(class'SeqVar_GameStateList', List, "Game State List") {
		break;
	}

	if(List == none) {
		`RTLOG("No SeqVar_GameStateList attached to " $ string(name), true, false);
		return;
	}

	foreach OperativeStates(UnitState) {
		List.GameStates.AddItem(UnitState.GetReference());
	}
}