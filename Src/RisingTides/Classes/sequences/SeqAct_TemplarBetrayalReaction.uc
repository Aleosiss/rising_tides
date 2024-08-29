class SeqAct_TemplarBetrayalReaction extends SequenceAction;

var() ETeam DestinationTeam;
var protected SeqVar_GameStateList List;
//var protected SeqVar_GameStateObject SeqVarGameStateObject;
var localized String m_strTemplarBetraylReactionBanner;

event Activated()
{
	local array<StateObjectReference>	UnitRefs;
	local XComGameStateHistory			History;
	local StateObjectReference			UnitRef;
	local XComGameState_Unit			UnitState;
	local XComGameState_Player			DestinationPlayer, HumanPlayer;
	local XComGameState					NewGameState;
	local XComGameState					GameState;
	local array<XComGameState_Unit>		AffectedUnits;
	local XComGameState_AIGroup			NewAIGroup;

	local XComGameState_Unit			TemplarUnit;
	local XComGameState_Unit			SpottedUnit;
	local XComGameState_Unit			SpotterUnit;

	History = `XCOMHISTORY;

	UnitRefs = GetXComSquad();
	SpottedUnit = GetSpottedTemplarUnitFromKismet();
	SpotterUnit = GetSpotterFromKismet();
	if(SpottedUnit.GetTeam() == SpotterUnit.GetTeam()) {
		return;
	}

	// apparently kismet cannot keep its variables straight, or, more likely, I'm doing something wrong
	if(SpottedUnit.GetTeam() == eTeam_Alien) {
		TemplarUnit = SpottedUnit;
	} else {
		TemplarUnit = SpotterUnit;
	}

	DestinationPlayer = GetDestinationPlayer(DestinationTeam);
	HumanPlayer = GetDestinationPlayer(eTeam_XCom);
	if(DestinationPlayer == none) {
		return;
	}

	foreach UnitRefs(UnitRef) {
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));
		if(UnitState == none) {
			continue;
		}

		if(UnitState.GetTeam() == DestinationTeam) {
			continue;
		}

		if(UnitState.GetMyTemplateName() != 'TemplarSoldier') {
			continue;
		}

		AffectedUnits.AddItem(UnitState);
	}

	if(AffectedUnits.Length == 0) {
		return;
	}

	// creates a new game state
	UnitState.BreakConcealment(TemplarUnit);
	// creates (multiple?) new game state(s)
	class'XComGameState_Unit'.static.UnitAGainsKnowledgeOfUnitB(TemplarUnit, UnitState, NewGameState, eAC_SeesSpottedUnit, false);

	NewGameState = `CreateChangeState("Templar Betrayal Reaction: Swap Teams");
	foreach AffectedUnits(UnitState) {
		SwapTeams(NewGameState, UnitState, DestinationPlayer.GetReference(), TemplarUnit);
	}

	XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = TemplarBetrayalReaction_BuildVisualization;
	`TACTICALRULES.SubmitGameState(NewGameState);

	OutputLinks[0].bHasImpulse = true;
}

protected function SwapTeams(XComGameState NewGameState, XComGameState_Unit UnitState, StateObjectReference PlayerStateRef, XComGameState_Unit SpottedTemplarUnit) {
	local XComGameState_AIPlayerData kAIData;
	local XComGameState_Unit NewUnitState;

	NewUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
	NewUnitState.SetControllingPlayer(PlayerStateRef);
	NewUnitState.OnSwappedTeams(PlayerStateRef);

	// Give the switched unit action points so they are ready to go
	NewUnitState.GiveStandardActionPoints();

	kAIData = XComGameState_AIPlayerData(`XCOMHISTORY.GetGameStateForObjectID(SpottedTemplarUnit.GetAIPlayerDataID(false)));
	kAIData.UpdateForMindControlledUnit(NewGameState, NewUnitState, SpottedTemplarUnit.GetReference());
}

protected function array<StateObjectReference> GetXComSquad() {
	List = none;
	foreach LinkedVariables(class'SeqVar_GameStateList', List, "Game State List") {
		break;
	}

	if(List == none) {
		`RTLOG("No SeqVar_GameStateList attached to " $ string(name), true, false);
	}

	return List.GameStates;
}

protected function XComGameState_Unit GetSpottedTemplarUnitFromKismet() {
	local SeqVar_GameStateObject SeqVarGameStateObject;

	foreach LinkedVariables(class'SeqVar_GameStateObject', SeqVarGameStateObject, "Spotted Templar Unit") {
		break;
	}

	if(SeqVarGameStateObject == none) {
		`RTLOG("No SeqVar_GameStateObject attached to Spotted Templar Unit", true, false);
		return none;
	}

	return XComGameState_Unit(SeqVarGameStateObject.GetObject());
}

protected function XComGameState_Unit GetSpotterFromKismet() {
	local SeqVar_GameStateObject SeqVarGameStateObject;

	foreach LinkedVariables(class'SeqVar_GameStateObject', SeqVarGameStateObject, "Spotter Unit") {
		break;
	}

	if(SeqVarGameStateObject == none) {
		`RTLOG("No SeqVar_GameStateObject attached to Spotter Unit", true, false);
		return none;
	}

	return XComGameState_Unit(SeqVarGameStateObject.GetObject());
}


simulated function TemplarBetrayalReaction_BuildVisualization(XComGameState VisualizeGameState) {
	local VisualizationActionMetadata ActionMetadata, PerUnitTrack, EmptyTrack;
	local XComGameStateHistory History;
	local XComGameStateContext Context;
	local X2Action_CentralBanner BannerAction;
	local XComGameState_Unit UnitState, IteratorUnitState;
	local X2Action_UpdateUI UIUpdateAction;
	local X2Action_RevealArea RevealAreaAction;
	local X2Action_CameraLookAt LookAtAction;
	local X2Action_StartStopSound SoundAction;
	local X2Action_Delay DelayAction;
	local TTile TileLocation;
	local Vector WorldLocation;

	History = `XCOMHISTORY;
	Context = VisualizeGameState.GetContext();

	UnitState.GetKeystoneVisibilityLocation(TileLocation);
	WorldLocation = `XWORLD.GetPositionFromTileCoordinates(TileLocation);

	/************  Similar to the Will Roll Vis, but we just focus on the first unit because it's exactly the same result for all of them simultaneously  ************/
	// 1a) clear unnecessary HUD components
	UIUpdateAction = X2Action_UpdateUI(class'X2Action_UpdateUI'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	UIUpdateAction.UpdateType = EUIUT_SetHUDVisibility;
	UIUpdateAction.DesiredHUDVisibility.bMessageBanner = true;

	// 1b) Clear FOW around unit
	RevealAreaAction = X2Action_RevealArea(class'X2Action_RevealArea'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	RevealAreaAction.ScanningRadius = class'XComWorldData'.const.WORLD_StepSize * 5.0f;
	RevealAreaAction.TargetLocation = WorldLocation;
	RevealAreaAction.bDestroyViewer = false;
	RevealAreaAction.AssociatedObjectID = UnitState.ObjectID;

	// 1c) Focus camera on unit (wait until centered)
	LookAtAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	LookAtAction.LookAtLocation = WorldLocation;
	LookAtAction.BlockUntilActorOnScreen = true;
	LookAtAction.LookAtDuration = 10.0f;		// longer than we need - camera will be removed by tag below
	LookAtAction.TargetZoomAfterArrival = -0.7f;
	LookAtAction.CameraTag = 'WillTestCamera';
	LookAtAction.bRemoveTaggedCamera = false;

	// 2a) Raise Special Event overlay "Templar Betrayal"
	BannerAction = X2Action_CentralBanner(class'X2Action_CentralBanner'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	BannerAction.BannerText = default.m_strTemplarBetraylReactionBanner;
	BannerAction.BannerState = eUIState_Bad;

	// 2b) Trigger result audio FX
	SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	SoundAction.Sound = new class'SoundCue';
	// bad result sound
	SoundAction.Sound.AkEventOverride = AkEvent'SoundTacticalUI.TacticalUI_UnitFlagWarning';
	SoundAction.bIsPositional = false;
	SoundAction.vWorldPosition = WorldLocation;
	SoundAction.WaitForCompletion = false;

	// 2c) Swap the units to the enemy team
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', IteratorUnitState) {
		PerUnitTrack = EmptyTrack;
		PerUnitTrack.StateObject_OldState = History.GetGameStateForObjectID(IteratorUnitState.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
		PerUnitTrack.StateObject_NewState = History.GetGameStateForObjectID(IteratorUnitState.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex);
		class'X2Action_SwapTeams'.static.AddToVisualizationTree(PerUnitTrack, Context, false, SoundAction);
	}

	// 2d) Pause to let the user more time to release how bad they just fucked up
	DelayAction = X2Action_Delay(class'X2Action_Delay'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	DelayAction.bIgnoreZipMode = true;
	DelayAction.Duration = 3.0;
	
	// 3a) Lower Special Event overlay
	BannerAction = X2Action_CentralBanner(class'X2Action_CentralBanner'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	BannerAction.BannerText = "";
	
	// 3b) restore FOW
	RevealAreaAction = X2Action_RevealArea(class'X2Action_RevealArea'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	RevealAreaAction.bDestroyViewer = true;
	RevealAreaAction.AssociatedObjectID = UnitState.ObjectID;
	
	// 3c) release camera 
	LookAtAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	LookAtAction.CameraTag = 'WillTestCamera';
	LookAtAction.bRemoveTaggedCamera = true;

	// 3d) restore HUD components to previous vis state
	UIUpdateAction = X2Action_UpdateUI(class'X2Action_UpdateUI'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	UIUpdateAction.UpdateType = EUIUT_RestoreHUDVisibility;
}

protected function XComGameState_Player GetDestinationPlayer(ETeam team) {
	local XComGameStateHistory History;
	local XComGameState_Player PlayerState;

	History = `XCOMHISTORY;
	foreach History.IterateByClassType(class'XComGameState_Player', PlayerState) {
		if(PlayerState.GetTeam() == team) {
			return PlayerState;
		}
	}

	`RTLOG("Could not find PlayerState for SeqAct_TemplarBetrayalReaction, it may fail!", true, false);
	return none;
}

static event int GetObjClassVersion()
{
	return super.GetObjClassVersion() + 1;
}

defaultproperties
{
	ObjCategory="RisingTides"
	ObjName="Templar Betrayal Reaction"
	bCallHandler = false
	DestinationTeam = eTeam_Alien

	bConvertedForReplaySystem=true
	bCanBeUsedForGameplaySequence=true

	bAutoActivateOutputLinks = true
	OutputLinks(0)=(LinkDesc="Out")

	VariableLinks(0)=(ExpectedType=class'SeqVar_GameStateList',LinkDesc="Game State List",bWriteable=false,MinVars=1,MaxVars=1)
	VariableLinks(1)=(ExpectedType=class'SeqVar_GameStateObject',LinkDesc="Spotted Templar Unit", PropertyName=SpottedTemplarUnit)
	VariableLinks(2)=(ExpectedType=class'SeqVar_GameStateObject',LinkDesc="Spotter Unit", PropertyName=Spotter)
}