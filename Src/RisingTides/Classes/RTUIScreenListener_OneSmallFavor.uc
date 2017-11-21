// This is an Unreal Script
class RTUIScreenListener_OneSmallFavor extends UIScreenListener;

var UICheckbox 	cb;
var UIMission	ms;
var bool		bDebugging;

delegate OldOnClickedDelegate(UIButton Button);

event OnInit(UIScreen Screen)
{
	if(UIMission(Screen) == none) {
		return;
	}
	bDebugging = true;

	ms = UIMission(Screen);
	AddOneSmallFavorSelectionCheckBox(UIMission(Screen));
}

// This event is triggered after a screen receives focus
event OnReceiveFocus(UIScreen Screen)
{
	if(UIMission(Screen) == none) {
		return;
	}
	
	//AddOneSmallFavorSelectionCheckBox(UIMission(Screen));
	
}

event OnRemoved(UIScreen Screen) {
	local UIMission EmptyScreen;
	local UICheckbox EmptyCheckbox;

	if(UIMission(Screen) == none) {
		return;
	}
	
	ManualGC();
}	

simulated function ManualGC() {
	OldOnClickedDelegate = none;
	ms = none;
	cb = none;
}

simulated function AddOneSmallFavorSelectionCheckBox(UIScreen Screen) {
	local UIMission MissionScreen;
	local RTGameState_ProgramFaction Program;

	MissionScreen = UIMission(Screen);
	if(MissionScreen == none) {
		return;
	}
	
	Program = RTGameState_ProgramFaction(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'RTGameState_ProgramFaction'));
	if(Program == none) {
		return;
	}

	if(MissionScreen.ConfirmButton.bIsInited) {
		OnConfirmButtonInited(MissionScreen.ConfirmButton);
	} else {
		MissionScreen.ConfirmButton.AddOnInitDelegate(OnConfirmButtonInited);	
	}
}

function ModifiedConfirmButtonClicked(UIButton Button) {
	AddOneSmallFavorSitrep(ms);
	OldOnClickedDelegate(Button);
}

function OnConfirmButtonInited(UIPanel Panel) {
	local UIMission MissionScreen;
	local bool bReadOnly;
	local RTGameState_ProgramFaction Program;

	MissionScreen = ms;
	if(MissionScreen == none) {
		`RedScreen("Error, parent is not of class 'UIMission'");
		return;
	}
	// Make the checkbox
	Program = RTGameState_ProgramFaction(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'RTGameState_ProgramFaction'));
	bReadOnly = !Program.bOneSmallFavorAvailable;
	if(!bReadOnly) {
		bReadOnly = CheckIsInvalidMission(MissionScreen.GetMission().GetMissionSource());
		if(bReadOnly) {
			class'RTHelpers'.static.RTLog("This MissionSource is invalid!", true);
		}
	}

	cb = MissionScreen.Spawn(class'UICheckbox', MissionScreen);	
	cb.InitCheckbox('OSFActivateCheckbox', "", false, , bReadOnly).SetTextStyle(class'UICheckbox'.const.STYLE_TEXT_TO_THE_LEFT);	
	cb.SetSize(32, 32);
	cb.SetPosition(Panel.MC.GetNum("_x") - 56, Panel.MC.GetNum("_y"));

	// Modify the OnButtonClicked Delegate
	OldOnClickedDelegate = MissionScreen.ConfirmButton.OnClickedDelegate;
	MissionScreen.ConfirmButton.OnClickedDelegate = ModifiedConfirmButtonClicked;
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

	if(!bDebugging) {
		if(!Program.bOneSmallFavorAvailable) {
			return false;
		}
	
		if(!cb.bChecked) {
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
	ModifyOneSmallFavorSitrepForGeneratedMission(Program, MissionState, true);

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

simulated function bool RemoveOneSmallFavorSitrep(UIMission MissionScreen) {
	local RTGameState_ProgramFaction			Program;
	local XComGameState_MissionSite				MissionState;
	local XComGameState							NewGameState;
	local GeneratedMissionData					MissionData;
	local XComGameState_HeadquartersXCom		XComHQ; //because the game stores a copy of mission data and this is where its stored in
	local XComGameStateHistory					History;
	local int									iNumOperativesInSquad;

	History = `XCOMHISTORY;
	Program = RTGameState_ProgramFaction(History.GetSingleGameStateObjectForClass(class'RTGameState_ProgramFaction'));

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	MissionState = MissionScreen.GetMission();
	if(MissionState.GeneratedMission.SitReps.Find('RTOneSmallFavor') != INDEX_NONE) {
		MissionState.GeneratedMission.SitReps.RemoveItem('RTOneSmallFavor');
	}

	if(MissionState.TacticalGameplayTags.Find('RTOneSmallFavor') != INDEX_NONE) {
		MissionState.TacticalGameplayTags.RemoveItem('RTOneSmallFavor');
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: Uncashing in One Small Favor");
	Program = RTGameState_ProgramFaction(NewGameState.ModifyStateObject(Program.class, Program.ObjectID));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(XComHQ.class, XComHQ.ObjectID));
	MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));

	Program.UncashOneSmallFavor(NewGameState, MissionState);
	ModifyOneSmallFavorSitrepForGeneratedMission(Program, MissionState, false);

	ModifyMissionData(XComHQ, MissionState);

	if (NewGameState.GetNumGameStateObjects() > 0) {
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		MissionScreen.UpdateData();
	} else {
		History.CleanupPendingGameState(NewGameState);
	}

	return true;
}

simulated function bool CheckIsInvalidMission(X2MissionSourceTemplate Template) {
	return class'RTGameState_ProgramFaction'.default.InvalidMissionSources.Find(Template.DataName) != INDEX_NONE;
}

simulated function ModifyOneSmallFavorSitrepForGeneratedMission(RTGameState_ProgramFaction Program, XComGameState_MissionSite MissionState, bool bAdd = true) {
	if(bAdd) { MissionState.GeneratedMission.SitReps.AddItem(Program.Deployed.AssociatedSitRepTemplateName); }
	else { MissionState.GeneratedMission.SitReps.RemoveItem(Program.Deployed.AssociatedSitRepTemplateName); }
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
