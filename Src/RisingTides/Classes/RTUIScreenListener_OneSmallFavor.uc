// This is an Unreal Script
class RTUIScreenListener_OneSmallFavor extends UIScreenListener;

simulated function OnInit(UIScreen Screen)
{
	if(UIMission(Screen) != none) {
		AddOneSmallFavorSitrep(Screen);
	}
}

// This event is triggered after a screen receives focus
simulated function OnReceiveFocus(UIScreen Screen)
{
	if(UIMission(Screen) != none) {
		AddOneSmallFavorSitrep(Screen);
	}
}


simulated function AddOneSmallFavorSitrep(UIMission MissionScreen) {
	local RTGameState_ProgramFaction Program;
	local XComGameState_MissionSite MissionState;
	local XComGameState NewGameState;
	local GeneratedMissionData MissionData;
	local XComGameState_HeadquartersXCom	XComHQ; //because the game stores a copy of mission data and this is where its stored in
	local XComGameStateHistory History;
	local int iNumOperativesInSquad;


	History = `XCOMHISTORY;
	Program = RTGameState_ProgramFaction(History.GetSingleGameStateObjectForClass(class'RTGameState_ProgramFaction'));
	if(Program == none)
		return;

	if(Program.InfluenceScore < 2)
		return;

	if(!Program.bOneSmallFavorAvailable) {
		return;
	}

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	MissionState = MissionScreen.GetMission();
	if(MissionState.GeneratedMission.SitReps.Find('RTOneSmallFavor') != INDEX_NONE) {
		return;
	}

	if(CheckIsInvalidMission(MissionState.GetMissionSource())) {
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: Cashing in One Small Favor");
	Program = RTGameState_ProgramFaction(NewGameState.ModifyStateObject(Program.class, Program.ObjectID));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(XComHQ.class, XComHQ.ObjectID));
	MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));


	MissionState.TacticalGameplayTags.AddItem('RTOneSmallFavor');
	Program.CashOneSmallFavor(NewGameState, MissionState);
	AddOneSmallFavorSitrepEffectToGeneratedMission(Program);

	ModifyMissionData(XComHQ, MissionState);
	Program.bOneSmallFavorAvailable = false;

	if (NewGameState.GetNumGameStateObjects() > 0) {
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		MissionScreen.UpdateData();
	} else
		History.CleanupPendingGameState(NewGameState);

}

simulated function bool CheckIsInvalidMission(X2MissionSourceTemplate Template) {
	return class'RTGameState_ProgramFaction'.default.InvalidMissionNames.Find(Template.DataName) != INDEX_NONE;
}

simulated function AddOneSmallFavorSitrepEffectToGeneratedMission(RTGameState_ProgramFaction Program, XComGameState_MissionSite MissionState) {
	local int iNumOperativesInSquad;
	iNumOperativesInSquad = Program.Deployed.SquadMembers.Length;
	switch(iNumOperativesInSquad) {
		case 1:
			MissionState.GeneratedMission.SitReps.AddItem('RTOneSmallFavor_1');
		case 2:
			MissionState.GeneratedMission.SitReps.AddItem('RTOneSmallFavor_2');
		case 3:
			MissionState.GeneratedMission.SitReps.AddItem('RTOneSmallFavor_3');
		case 4:
			MissionState.GeneratedMission.SitReps.AddItem('RTOneSmallFavor_4');
		case 5:
			MissionState.GeneratedMission.SitReps.AddItem('RTOneSmallFavor_5');
		case 6:
			MissionState.GeneratedMission.SitReps.AddItem('RTOneSmallFavor_6');
		default:
			MissionState.GeneratedMission.SitReps.AddItem('RTOneSmallFavor_3');
	}
}

//---------------------------------------------------------------------------------------
function ModifyMissionData(XComGameState_HeadquartersXCom NewXComHQ, XComGameState_MissionSite NewMissionState)
{
	local int MissionDataIndex;

	MissionDataIndex = NewXComHQ.arrGeneratedMissionData.Find('MissionID', NewMissionState.GetReference().ObjectID);

	if(MissionDataIndex != INDEX_NONE)
	{
		NewXComHQ.arrGeneratedMissionData[MissionDataIndex] = NewMissionState.GeneratedMission;
	}
}

defaultproperties
{
	// Leaving this assigned to none will cause every screen to trigger its signals on this class
	ScreenClass = none;
}
