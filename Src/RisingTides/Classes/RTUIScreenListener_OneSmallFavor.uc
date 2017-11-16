// This is an Unreal Script
class RTUIScreenListener_OneSmallFavor extends UIScreenListener;

simulated function OnInit(UIScreen Screen)
{
	if(UIMission(Screen) != none) {
		AddOneSmallFavorSelectionCheckBox(UIMission(Screen));
	}
}

// This event is triggered after a screen receives focus
simulated function OnReceiveFocus(UIMission(Screen)
{
	if(UIMission(Screen) != none) {
		AddOneSmallFavorSelectionCheckBox(UIMission(Screen));
	}
}

simulated function AddOneSmallFavorSelectionCheckBox(UIMission Screen) {
	//TODO:: 
}

simulated function bool AddOneSmallFavorSitrep(UIMission MissionScreen) {
	local RTGameState_ProgramFaction			Program;
	local XComGameState_MissionSite				MissionState;
	local XComGameState							NewGameState;
	local GeneratedMissionData					MissionData;
	local XComGameState_HeadquartersXCom		XComHQ; //because the game stores a copy of mission data and this is where its stored in
	local XComGameStateHistory					History;
	local int									iNumOperativesInSquad;

	History = `XCOMHISTORY;
	Program = RTGameState_ProgramFaction(History.GetSingleGameStateObjectForClass(class'RTGameState_ProgramFaction'));
	if(Program == none) {
		return false;
	}

	if(!Program.bMetXCom) {
		return false;
	}

	if(!class'RTHelpers'.static.DebuggingEnabled()) {
		if(!Program.bOneSmallFavorAvailable) {
			return false;
		}
	
		if(!Program.bOneSmallFavorActivated) {
			return false;
		}

		class'RTHelpers'.static.RTLog("Adding One Small Favor SITREP due to it being available and activated!");
	} else { 
		class'RTHelpers'.static.RTLog("Adding One Small Favor SITREP via debug override!"); 
	}

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	MissionState = MissionScreen.GetMission();
	if(MissionState.GeneratedMission.SitReps.Find('RTOneSmallFavor') != INDEX_NONE) {
		class'RTHelpers'.static.RTLog("This map already has the One Small Favor tag!", true);
		return false;
	}

	if(CheckIsInvalidMission(MissionState.GetMissionSource())) {
		class'RTHelpers'.static.RTLog("This map is invalid!", true);
		return false;
	}

	if(MissionState.TacticalGameplayTags.Find('RTOneSmallFavor') != INDEX_NONE) {
		class'RTHelpers'.static.RTLog("This mission is already tagged for one small favor!");
		return false;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: Cashing in One Small Favor");
	Program = RTGameState_ProgramFaction(NewGameState.ModifyStateObject(Program.class, Program.ObjectID));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(XComHQ.class, XComHQ.ObjectID));
	MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));

	MissionState.TacticalGameplayTags.AddItem('RTOneSmallFavor');
	Program.CashOneSmallFavor(NewGameState, MissionState);
	AddOneSmallFavorSitrepToGeneratedMission(Program, MissionState);

	ModifyMissionData(XComHQ, MissionState);

	if (NewGameState.GetNumGameStateObjects() > 0) {
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		MissionScreen.UpdateData();
	} else {
		class'RTHelpers'.static.RTLog("Warning: One Small Favor activated but didn't add any objects to the GameState?!", true);
		History.CleanupPendingGameState(NewGameState);
	}

	return true;
}

simulated function bool CheckIsInvalidMission(X2MissionSourceTemplate Template) {
	return class'RTGameState_ProgramFaction'.default.InvalidMissionNames.Find(Template.DataName) != INDEX_NONE;
}

simulated function AddOneSmallFavorSitrepToGeneratedMission(RTGameState_ProgramFaction Program, XComGameState_MissionSite MissionState) {
	MissionState.GeneratedMission.SitReps.AddItem(Program.Deployed.AssociatedSitRepTemplateName);
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
