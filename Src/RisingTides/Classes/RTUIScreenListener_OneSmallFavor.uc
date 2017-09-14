// This is an Unreal Script
class RTUIScreenListener_OneSmallFavor extends UIScreenListener;

simulated function OnInit(UIScreen Screen)
{
	if(UIMission(Screen) != none) {
		
	}
}

// This event is triggered after a screen receives focus
simulated function OnReceiveFocus(UIScreen Screen)
{
	if(UIMission(Screen) != none) {

	}
}


simulated function AddOneSmallFavorSitrep(UIMission MissionScreen) {	
	local RTGameState_ProgramFaction Program;
	local XComGameState_MissionSite MissionState;
	local XComGameState NewGameState;
	local GeneratedMissionData MissionData;
	local XComGameState_HeadquartersXCom	XComHQ; //because the game stores a copy of mission data and this is where its stored in
	local XComGameStateHistory History;


	History = `XCOMHISTORY;
	Program = RTGameState_ProgramFaction(History.GetSingleGameStateObjectForClass(class'RTGameState_ProgramFaction'));
	if(!Program.bOneSmallFavorAvailable) {
		return;
	}

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	MissionState = MissionScreen.GetMission();
	if(MissionState.GeneratedMission.SitReps.Find('RTOneSmallFavor') != INDEX_NONE) {
		return;
	}

	if(!CheckInvalidMission(MissionState.GetMissionSource())) {
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: Cashing in One Small Favor");
	Program = RTGameState_ProgramFaction(NewGameState.ModifyStateObject(Program.class, Program.ObjectID));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(XComHQ.class, XComHQ.ObjectID));
	MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));

	MissionState.GeneratedMission.SitReps.AddItem('RTOneSmallFavor');
	MissionState.TacticalGameplayTags.AddItem('RTOneSmallFavor');
	Program.bOneSmallFavorAvailable = false;
	Program.CashOneSmallFavor(NewGameState, MissionState);
	ModifyMissionData(XComHQ, MissionState);


	if (NewGameState.GetNumGameStateObjects() > 0) {
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		UIMission(Screen).UpdateData();
	} else
		History.CleanupPendingGameState(NewGameState);

}

simulated function bool CheckInvalidMission(X2MissionTemplate Template) {
	return true;
}

//---------------------------------------------------------------------------------------
function ModifyMissionData(XComGameState_HeadquartersXCom XComHQ, XComGameState_MissionSite MissionState)
{
	local int MissionDataIndex;

	MissionDataIndex = XComHQ.arrGeneratedMissionData.Find('MissionID', MissionState.GetReference().ObjectID);

	if(MissionDataIndex != INDEX_NONE)
	{
		XComHQ.arrGeneratedMissionData[MissionDataIndex] = MissionState.GeneratedMission;
	}
}

defaultproperties
{
	// Leaving this assigned to none will cause every screen to trigger its signals on this class
	ScreenClass = none;
}