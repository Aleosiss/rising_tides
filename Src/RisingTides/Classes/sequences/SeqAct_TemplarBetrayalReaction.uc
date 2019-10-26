class SeqAct_TemplarBetrayalReaction extends SequenceAction;

var() ETeam DestinationTeam;
var protected SeqVar_GameStateList List;
var localized String m_strTemplarBetraylReactionBanner;

event Activated()
{
	local array<StateObjectReference>	UnitRefs;
	local XComGameStateHistory			History;
	local StateObjectReference			UnitRef;
	local XComGameState_Unit			UnitState;
	local XComGameState_Player			DestinationPlayer;
	local XComGameState					NewGameState;

	History = `XCOMHISTORY;

	UnitRefs = GetXComSquad();
	DestinationPlayer = GetDestinationPlayer(DestinationTeam);
	if(DestinationPlayer == none) {
		return;
	}

	NewGameState = `CreateChangeState("SeqAct_TemplarBetrayalReaction");
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

		SwapTeams(NewGameState, UnitState, DestinationPlayer.GetReference());
	}

	XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = TemplarBetrayalReaction_BuildVisualization;
	`TACTICALRULES.SubmitGameState(NewGameState);
	
	OutputLinks[0].bHasImpulse = true;
}

protected function SwapTeams(XComGameState NewGameState, XComGameState_Unit UnitState, StateObjectReference PlayerStateRef) {
	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
	UnitState.SetControllingPlayer(PlayerStateRef);
	UnitState.OnSwappedTeams(PlayerStateRef);

	// Give the switched unit action points so they are ready to go
	UnitState.GiveStandardActionPoints();
}


protected function array<StateObjectReference> GetXComSquad() {
	`RTLOG("GetXComSquad");

	List = none;
	foreach LinkedVariables(class'SeqVar_GameStateList', List, "Game State List") {
		break;
	}

	if(List == none) {
		`RTLOG("No SeqVar_GameStateList attached to " $ string(name), true, false);
	}

	return List.GameStates;
}


simulated function TemplarBetrayalReaction_BuildVisualization(XComGameState VisualizeGameState) {
	local VisualizationActionMetadata ActionMetadata, PerUnitTrack, EmptyTrack;
	local XComGameStateHistory History;
	local XComGameStateContext Context;
	local X2Action_CentralBanner BannerAction;
	local XComGameState_Unit UnitState;
	local X2Action_UpdateUI UIUpdateAction;
	local X2Action_RevealArea RevealAreaAction;
	local X2Action_CameraLookAt LookAtAction;
	local X2Action_StartStopSound SoundAction;
	local X2Action_Delay DelayAction;
	local bool bTemplarsOnMission;
	local TTile TileLocation;
	local Vector WorldLocation;

	History = `XCOMHISTORY;
	Context = VisualizeGameState.GetContext();

	// my brain is smooth
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState) {
		// get this flag explicitly, but we also have a valid UnitState at this point
		bTemplarsOnMission = true;
		break;
	}

	if(!bTemplarsOnMission) {
		return;
	}

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
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState) {
		PerUnitTrack = EmptyTrack;
		PerUnitTrack.StateObject_OldState = History.GetGameStateForObjectID(UnitState.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
		PerUnitTrack.StateObject_NewState = History.GetGameStateForObjectID(UnitState.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex);
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
	ObjName="Templar Betryal Reaction"
	bCallHandler = false
	DestinationTeam = eTeam_Alien

	bConvertedForReplaySystem=true
	bCanBeUsedForGameplaySequence=true

	bAutoActivateOutputLinks = true
	OutputLinks(0)=(LinkDesc="Out")

	VariableLinks(0)=(ExpectedType=class'SeqVar_GameStateList',LinkDesc="Game State List",bWriteable=true,MinVars=1,MaxVars=1)
}