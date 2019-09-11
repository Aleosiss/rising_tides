class SeqAct_ProgramReinforcement extends SequenceAction;

var() name SquadName;
var() name SpawnPosition;

defaultproperties
{
	ObjName="Call in Program Reinforcements"
	ObjCategory="RisingTides"

	bConvertedForReplaySystem=true
	bCanBeUsedForGameplaySequence=true
	bAutoActivateOutputLinks=true

	MinimumTilesFromLocation=-1
	MaximumTilesFromLocation=-1

	bConvertedForReplaySystem=true
	bCanBeUsedForGameplaySequence=true

	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Input Location",PropertyName=SpawnLocation)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Actual Location",PropertyName=ActualSpawnLocation,bWriteable=true)
}

event Activated()
{
	local name _SquadName;

	if(SquadName == _SquadName) {
		`RTLOG("KISMET: SeqAct_ProgramReinforcement recieved no value for SquadName, defaulting to SPECTRE.", true, true);
		_SquadName = 'SPECTRE';
	} else {
		_SquadName = SquadName;
	}

	CallInProgramOperativeReinforcements(_SquadName);
}

static function bool CallInProgramOperativeReinforcements(name SquadName) {
	local array<RTGameState_Unit> OperativeStates, EmptyList;
	local XComGameStateHistory History;
	local RTGameState_Unit IteratorUnitState;
	
	History = `XCOMHISTORY;

	OperativeStates = GetOperatives(SquadName, History);
	if(OperativeStates.Length == 0) {
		return false;
	}

	foreach OperativeStates(IteratorUnitState) {
		AddOperativeToTactical(IteratorUnitState, History);
	}
}

protected static function XComGameState_Unit AddOperativeToTactical(XComGameState_Unit UnitState, XComGameStateHistory History) {
	local X2TacticalGameRuleset Rules;
	local Vector SpawnLocation;
	local XComGameStateContext_TacticalGameRule NewGameStateContext;
	local XComGameState NewGameState;
	local XComGameState_Player PlayerState;
	local StateObjectReference ItemReference;
	local XComGameState_Item ItemState;

	if(UnitState == none) {
		`RTLOG("Recieved a null UnitState in AddOperativeToTactical!", true, true);
		return none;
	}

	// pick a floor point at random to spawn the unit at
	if(!ChooseSpawnLocation(SpawnLocation)) {
		`RTLOG("Couldn't find a location to spawn at in AddOperativeToTactical!", true, true);
		return none;
	}

	// create the history frame with the new tactical unit state
	NewGameStateContext = class'XComGameStateContext_TacticalGameRule'.static.BuildContextFromGameRule(eGameRule_UnitAdded);
	NewGameState = NewGameStateContext.ContextBuildGameState( );

	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
	UnitState.BeginTacticalPlay(NewGameState);   // this needs to be called explicitly since we're adding an existing state directly into tactical
	UnitState.SetVisibilityLocationFromVector(SpawnLocation);

	// assign the new unit to the human team
	foreach History.IterateByClassType(class'XComGameState_Player', PlayerState) {
		if(PlayerState.GetTeam() == eTeam_XCom) {
			UnitState.SetControllingPlayer(PlayerState.GetReference());
			break;
		}
	}

	// add item states. This needs to be done so that the visualizer sync picks up the IDs and creates their visualizers
	foreach UnitState.InventoryItems(ItemReference) {
		ItemState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', ItemReference.ObjectID));
		ItemState.BeginTacticalPlay(NewGameState);   // this needs to be called explicitly since we're adding an existing state directly into tactical

		// add any cosmetic items that might exist
		ItemState.CreateCosmeticItemUnit(NewGameState);
	}

	// submit it
	Rules = `TACTICALRULES;
	XComGameStateContext_TacticalGameRule(NewGameState.GetContext()).UnitRef = UnitState.GetReference();
	Rules.SubmitGameState(NewGameState);

	// add abilities
	// Must happen after unit is submitted, or it gets confused about when the unit is in play or not 
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Operative Abilities");
	Rules.InitializeUnitAbilities(NewGameState, UnitState);

	Rules.SubmitGameState(NewGameState);

	return UnitState;
}


protected static function array<RTGameState_Unit> GetOperatives(name SquadName, XComGameStateHistory History) {
	local RTGameState_ProgramFaction ProgramState;
	local RTGameState_PersistentGhostSquad SquadState;
	local array<RTGameState_Unit> OperativeStates, EmptyList;
	local StateObjectReference UnitRef;
	local RTGameState_Unit UnitState;
	local int LastStrategyStateIndex;
	local array<XComGameState_Unit> UnitsInPlay;
	local XComGameState_Unit UnitInPlay;
	local XComGameState StrategyState;

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
		if(name(SquadState.GetName()) == SquadName) {
			break;
		}
	}

	if(name(SquadState.GetName()) != SquadName) {
		`RTLOG("SeqAct_ProgramReinforcement: Couldn't find " $ SquadName);
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
		`RTLOG("Couldn't find any Operatives for squad " $ SquadName);
		return EmptyList;
	}

	return OperativeStates;
}

// chooses a location for the unit to spawn in the spawn zone
protected static function bool ChooseSpawnLocation(out Vector SpawnLocation)
{
	local XComParcelManager ParcelManager;
	local XComGroupSpawn SoldierSpawn;
	local array<Vector> FloorPoints;

	// attempt to find a place in the spawn zone for this unit to spawn in
	ParcelManager = `PARCELMGR;
	SoldierSpawn = ParcelManager.SoldierSpawn;

	if(SoldierSpawn == none) // check for test maps, just grab any spawn
	{
		foreach `XComGRI.AllActors(class'XComGroupSpawn', SoldierSpawn)
		{
			break;
		}
	}

	SoldierSpawn.GetValidFloorLocations(FloorPoints);
	if(FloorPoints.Length == 0)
	{
		return false;
	}
	else
	{
		SpawnLocation = FloorPoints[0];
		return true;
	}
}