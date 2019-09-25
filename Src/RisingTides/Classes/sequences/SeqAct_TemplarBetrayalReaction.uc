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
		if(UnitState != none) {
			if(UnitState.GetMyTemplateName() == 'TemplarSoldier') {
				SwapTeams(NewGameState, UnitState, DestinationPlayer.GetReference());
			}
		}
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
	local VisualizationActionMetadata ActionMetadata, EmptyTrack;
	local XComGameStateHistory History;
	local XComGameStateContext Context;
	local X2Action_CentralBanner BannerAction;
	local XComGameState_Unit UnitState;
	
	History = `XCOMHISTORY;
	Context = VisualizeGameState.GetContext();

	BannerAction = X2Action_CentralBanner(class'X2Action_CentralBanner'.static.AddToVisualizationTree(ActionMetadata, Context));
	BannerAction.BannerText = default.m_strTemplarBetraylReactionBanner;
	BannerAction.BannerState = eUIState_Bad;

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState) {
		ActionMetadata = EmptyTrack;
		ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(UnitState.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
		ActionMetadata.StateObject_NewState = History.GetGameStateForObjectID(UnitState.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex);
		class'X2Action_SwapTeams'.static.AddToVisualizationTree(ActionMetadata, Context, false, BannerAction);
	}
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