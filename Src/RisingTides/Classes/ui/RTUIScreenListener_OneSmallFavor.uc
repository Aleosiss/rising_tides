// This is an Unreal Script
class RTUIScreenListener_OneSmallFavor extends UIScreenListener config(ProgramFaction);

var private string 					CheckboxWeakRef;
var private string 					MissionWeakRef;
var int								MissionId;
var bool							bDebugging;
var bool							bHasSeenOSFTutorial;
var bool							bHasSeenProgramScreenTutorial;

var config array<name> 				FatLaunchButtonMissionTypes;
var config float 					OSFCheckboxDistortOnClickDuration;

var private name 					DelegateHolderName;

defaultproperties
{
	// Leaving this assigned to none will cause every screen to trigger its signals on this class
	ScreenClass = none;
	DelegateHolderName = '';
}


event OnInit(UIScreen Screen)
{
	local RTGameState_ProgramFaction Program;
	
	if(UIStrategyMap(Screen) != none) {
		Program = RTGameState_ProgramFaction(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'RTGameState_ProgramFaction'));
		if(Program == none) {
			return;
		}

		if(!Program.bMetXCom) {
			return;
		}

		if(!bHasSeenOSFTutorial) {
			Program.HandleOSFTutorial();
			bHasSeenOSFTutorial = Program.bOSF_FirstTimeDisplayed;
		}
		else if(!bHasSeenProgramScreenTutorial) {
			Program.HandleProgramScreenTutorial();
			bHasSeenProgramScreenTutorial = Program.bPIS_FirstTimeDisplayed;
		}
	}

	if(UIMission(Screen) == none) {
		return;
	}

	if(Screen.IsA('UIMission_Infiltrated')) {
		return;
	}

	bDebugging = false;
	AddOneSmallFavorSelectionCheckBox(SetMissionScreen(UIMission(Screen)));
}

event OnRemoved(UIScreen Screen) {
	local UISquadSelect ss;

	`RTLOG("Screen removed: " $ Screen.Class);

	if(UISquadSelect(Screen) != none) {
		`RTLOG("UISquadSelect detected, cleaning up!");
		ss = UISquadSelect(Screen);
		// If the mission was launched, we don't want to clean up the XCGS_MissionSite
		if(!ss.bLaunched) {
			if(MissionId != 0) {
				`RTLOG("Attempting to remove OSF");
				RemoveOneSmallFavorSitrep(XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(MissionId)));
			}
			MissionId = 0;
		}
		ManualGC();
	}

	if(UIStrategyMap(Screen) != none) {
		// Just avoiding a RedScreen here, not necessarily a useful check
		`RTLOG("UIStrategyMap detected, cleaning up!");
		if(MissionId != 0) {
			RemoveOneSmallFavorSitrep(XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(MissionId)));	
		}

		MissionId = 0;
		ManualGC();
	}
}	

simulated function ManualGC() {
	`RTLOG("ManualGC called!");
	HandleInput(false);
	MissionWeakRef = "";
	CheckboxWeakRef = "";
}

simulated function AddOneSmallFavorSelectionCheckBox(UIScreen Screen) {
	local UIMission MissionScreen;
	local RTGameState_ProgramFaction Program;

	MissionScreen = GetMissionScreen();
	if(MissionScreen == none) {
		return;
	}
	
	Program = RTGameState_ProgramFaction(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'RTGameState_ProgramFaction'));
	if(Program == none) {
		return;
	}

	if(!Program.bMetXCom) {
		return;
	}

	// immediately execute the init code if we're somehow late to the initialization party
	if(MissionScreen.ConfirmButton.bIsVisible) {
		if(MissionScreen.ConfirmButton.bIsInited && MissionScreen.ConfirmButton.bIsVisible) {
			OnConfirmButtonInited(MissionScreen.ConfirmButton);
		} else {
			// otherwise add the button to the init delegates
			MissionScreen.ConfirmButton.AddOnInitDelegate(OnConfirmButtonInited);	
		}
	}
	// immediately execute the init code if we're somehow late to the initialization party
	else if(MissionScreen.Button1.bIsVisible) {
		if(MissionScreen.Button1.bIsInited) {
			OnConfirmButtonInited(MissionScreen.Button1);
		} else {
			// otherwise add the button to the init delegates
			MissionScreen.Button1.AddOnInitDelegate(OnConfirmButtonInited);	
		}
	}
	
	else {
		`RTLOG("Could not find a confirm button for the mission!", true);
	}
}

function OnConfirmButtonInited(UIPanel Panel) {
	local UIMission MissionScreen;
	local bool bReadOnly;
	local RTGameState_ProgramFaction Program;
	local UIButton Button;
	local UICheckbox Checkbox;
	local float PosX, PosY;
	local string strCheckboxDesc;
	local UIDelegateHolder DelegateHolder;

	MissionScreen = GetMissionScreen();
	if(MissionScreen == none) {
		`RedScreen("Error, parent is not of class 'UIMission'");
		return;
	}

	Program = RTGameState_ProgramFaction(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'RTGameState_ProgramFaction'));
	Button = UIButton(Panel);
	if(Button == none) {
		`RTLOG("This isn't a button!");
	}

	// the checkbox shouldn't be clickable if the favor isn't available
	bReadOnly = !(Program.IsOneSmallFavorAvailable() == eAvailable);
	if(!bReadOnly) {
		bReadOnly = `RTS.IsInvalidMission(MissionScreen.GetMission().GetMissionSource().DataName);
		if(bReadOnly) {
			`RTLOG("This MissionSource is invalid!", false, false);
			return; // don't even make the checkbox in this case...
		}
	}

	if(bReadOnly) {
		strCheckboxDesc = class'RTGameState_ProgramFaction'.default.OSFCheckboxUnavailable;
	} else {
		strCheckboxDesc = class'RTGameState_ProgramFaction'.default.OSFCheckboxAvailable;
	}

	GetPositionByMissionType(MissionScreen.GetMission().GetMissionSource().DataName, PosX, PosY);

	Checkbox = CreateCheckbox();
	Checkbox.InitCheckbox('OSFActivateCheckbox', , false, OnCheckboxChange, bReadOnly)
		.SetSize(Button.Height, Button.Height)
		.OriginTopLeft()
		.SetPosition(PosX, PosY)
		.SetColor(class'UIUtilities_Colors'.static.ColorToFlashHex(Program.GetMyTemplate().FactionColor))
		.SetTooltipText(strCheckboxDesc, , , 10, , , true, 0.0f);
	`RTLOG("Created a checkbox at position " $ PosX $ " x and " $ PosY $ " y for ScreenClass " $ MissionScreen.Class);
	HandleInput(true);

	// Modify the OnLaunchButtonClicked Delegate
	if(Button != none) {
		DelegateHolder = Button.Spawn(class'UIDelegateHolder', Button);
		DelegateHolder.InitPanel(DelegateHolderName);
		DelegateHolder.Hide();
		DelegateHolder.SetPosition(-100, -100);

		`RTLOG("Replacing:" @ string(Button.OnClickedDelegate) @ "with" @ string(DelegateHolder.OriginalOnClickedDelegate));

		DelegateHolder.OriginalDelegate = Button.OnClickedDelegate;
		Button.OnClickedDelegate = ModifiedLaunchButtonClicked;
	} else {
		`RTLOG("Panel was not a button?", true);
	}
}

function ModifiedLaunchButtonClicked(UIButton Button) {
	local UIDelegateHolder DelegateHolder;

	DelegateHolder = UIDelegateHolder(Button.GetChild(DelegateHolderName));
	if(DelegateHolder == none) {
			`RTLOG("ERROR: Modified OSF Launch Button had no original button delegate", true, true);

		return;
	}

	MissionId = GetMissionScreen().GetMission().GetReference().ObjectID;
	if(MissionId == 0) {
		`RTLOG("ERROR: Modified OSF Launch Button had no Mission GameState", true, true);
	}
	AddOneSmallFavorSitrep(XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(MissionId)));
	DelegateHolder.CallDelegate(Button);
}

simulated function OnCheckboxChange(UICheckbox checkboxControl)
{
	GetMissionScreen().Movie.Pres.StartDistortUI(default.OSFCheckboxDistortOnClickDuration);
}

simulated function bool AddOneSmallFavorSitrep(XComGameState_MissionSite MissionState) {
	local RTGameState_ProgramFaction			Program;
	local XComGameState							NewGameState;
	local XComGameState_HeadquartersXCom		XComHQ; //because the game stores a copy of mission data and this is where its stored in
	local XComGameStateHistory					History;

	History = `XCOMHISTORY;
	Program = RTGameState_ProgramFaction(History.GetSingleGameStateObjectForClass(class'RTGameState_ProgramFaction'));
	if(Program == none) {
		return false;
	}

	if(!bDebugging) {
		if(Program.IsOneSmallFavorAvailable() != eAvailable) {
			return false;
		}
	
		if(!GetCheckbox().bChecked) {
			return false;
		}

		`RTLOG("Adding One Small Favor due to it being available and the checkbox activated!");
	} else {
		`RTLOG("Adding One Small Favor via debug override!"); 
	}

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	if(MissionState.GeneratedMission.SitReps.Find('RTOneSmallFavor') != INDEX_NONE) {
		`RTLOG("This map already has the One Small Favor tag!", true);
		return false;
	}
	
	if(`RTS.IsInvalidMission(MissionState.GetMissionSource().DataName)) {
		`RTLOG("This mission is invalid!", true);
		return false;
	}

	if(MissionState.TacticalGameplayTags.Find('RTOneSmallFavor') != INDEX_NONE) {
		`RTLOG("This mission is already tagged for one small favor!");
		return false;
	}

	NewGameState = `CreateChangeState("Rising Tides: Cashing in One Small Favor");
	Program = RTGameState_ProgramFaction(NewGameState.ModifyStateObject(Program.class, Program.ObjectID));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(XComHQ.class, XComHQ.ObjectID));
	MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));

	MissionState.TacticalGameplayTags.AddItem('RTOneSmallFavor');
	if(Program.CashOneSmallFavorForMission(NewGameState, MissionState)) { // we're doing it boys
		ModifyOneSmallFavorSitrepForGeneratedMission(Program, MissionState, true);
		ModifyMissionData(XComHQ, MissionState);
	} else {
		return false;
	}

	if (NewGameState.GetNumGameStateObjects() > 0) {
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	} else {
		`RTLOG("Warning: One Small Favor activated but didn't add any objects to the GameState?!", true);
		History.CleanupPendingGameState(NewGameState);
	}

	return true;
}

simulated function bool RemoveOneSmallFavorSitrep(XComGameState_MissionSite MissionState) {
	local RTGameState_ProgramFaction			Program;
	local XComGameState							NewGameState;
	local XComGameState_HeadquartersXCom		XComHQ; //because the game stores a copy of mission data and this is where its stored in
	local XComGameStateHistory					History;

	History = `XCOMHISTORY;

	if(MissionState.GeneratedMission.SitReps.Find('RTOneSmallFavor') != INDEX_NONE
		&& MissionState.TacticalGameplayTags.Find('RTOneSmallFavor') != INDEX_NONE
	) {
		`RTLOG("Could not remove One Small Favor, the mission did not have the required tags!");
		return false;
	}
	
	Program = RTGameState_ProgramFaction(History.GetSingleGameStateObjectForClass(class'RTGameState_ProgramFaction'));

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	RemoveTag(MissionState.GeneratedMission.SitReps, 'RTOneSmallFavor');
	RemoveTag(MissionState.TacticalGameplayTags, 'RTOneSmallFavor');

	NewGameState = `CreateChangeState("Rising Tides: Uncashing in One Small Favor");
	Program = RTGameState_ProgramFaction(NewGameState.ModifyStateObject(Program.class, Program.ObjectID));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(XComHQ.class, XComHQ.ObjectID));
	MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));

	Program.UncashOneSmallFavorForMission(NewGameState, MissionState);
	ModifyOneSmallFavorSitrepForGeneratedMission(Program, MissionState, false);
	ModifyMissionData(XComHQ, MissionState);

	if (NewGameState.GetNumGameStateObjects() > 0) {
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		//MissionScreen.UpdateData();
	} else {
		History.CleanupPendingGameState(NewGameState);
	}

	return true;
}

private function RemoveTag(out array<name> Tags, name TagToRemove) {
	Tags.RemoveItem(TagToRemove);
}

simulated function ModifyOneSmallFavorSitrepForGeneratedMission(RTGameState_ProgramFaction Program, XComGameState_MissionSite MissionState, bool bAdd = true) {
	if(bAdd) { MissionState.GeneratedMission.SitReps.AddItem(Program.GetSquadForMission(MissionState.GetReference(), false).GetAssociatedSitRepTemplateName()); }
	else { MissionState.GeneratedMission.SitReps.RemoveItem(Program.GetSquadForMission(MissionState.GetReference(), false).GetAssociatedSitRepTemplateName()); }
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

simulated function PrintUIMissionButtonPositions(UIMission MissionScreen) {
	
}

simulated function GetPositionByMissionType(name MissionSource, out float PosX, out float PosY) {
	// WOTC missions have these really fat launch buttons
	if(default.FatLaunchButtonMissionTypes.Find(MissionSource) != INDEX_NONE) {
		PosX = -192;
		PosY = -30;
		if(MissionSource == 'MissionSource_ChosenStronghold') {
			PosX = -172;
		}
	} else {
		PosX = -98;
		PosY = -18;
	}

	if(MissionSource == 'MissionSource_GuerillaOp') {
		PosX = -198;
		PosY = 125;
	}
}

function HandleInput(bool bIsSubscribing)
{
	local delegate<UIScreenStack.CHOnInputDelegate> inputDelegate;
	inputDelegate = OnUnrealCommand;
	if(bIsSubscribing)
	{
		`SCREENSTACK.SubscribeToOnInput(inputDelegate);
	}
	else
	{
		`SCREENSTACK.UnsubscribeFromOnInput(inputDelegate);
	}
}

protected function bool OnUnrealCommand(int cmd, int arg)
{
	local UICheckbox Checkbox;

	if (cmd == class'UIUtilities_Input'.const.FXS_BUTTON_X && arg == class'UIUtilities_Input'.const.FXS_ACTION_RELEASE)
	{
		// Cannot open screen during flight
		if (class'XComEngine'.static.GetHQPres().StrategyMap2D.m_eUIState != eSMS_Flight)
		{
			// flip the checkbox
			Checkbox = GetCheckbox();
			if(Checkbox != none)
			{
				Checkbox.bChecked = !Checkbox.bChecked;
			}
			
		}
		return true;
	}
	return false;
}

private function UICheckbox CreateCheckbox()
{   
    local UICheckbox Checkbox;
	local UIMission MissionScreen;

	MissionScreen = GetMissionScreen();
    Checkbox = MissionScreen.Spawn(class'UICheckbox', MissionScreen.ButtonGroup);
    CheckboxWeakRef = PathName(Checkbox);
    return Checkbox;
}

private function UICheckbox GetCheckbox()
{   
    local UICheckbox Checkbox;

    if (CheckboxWeakRef != "")
    {
        Checkbox = UICheckbox(FindObject(CheckboxWeakRef, class'UICheckbox'));
        if (Checkbox != none)
        {
            return Checkbox;
        }
    }

	return none;
}


private function UIMission GetMissionScreen()
{   
    local UIMission MissionScreen;

    if (MissionWeakRef != "")
    {
        MissionScreen = UIMission(FindObject(MissionWeakRef, class'UIMission'));
        if (MissionScreen != none)
        {
            return MissionScreen;
        }
    }

	return none;
}

private function UIMission SetMissionScreen(UIMission Screen)
{
	MissionWeakRef = PathName(Screen);
	return Screen;
}
