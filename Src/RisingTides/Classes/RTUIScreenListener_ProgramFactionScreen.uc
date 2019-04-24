class RTUIScreenListener_ProgramFactionScreen extends UIScreenListener;
/*
var bool bExists;
var localized String m_strProgramFactionButton;
var name buttonName;

event OnInit(UIScreen Screen)
{
	if(UIStrategyMap(Screen) != none) {
		if(bExists) {
			`RTLOG("Program Info Screen button already present, returning...");
			return;
		}
		`RTLOG("Loading Program Info Screen button in OnInit...");
		ShowProgramFactionScreenButton(UIStrategyMap(Screen));
	}
}

event OnReceiveFocus(UIScreen Screen) {
	if(UIStrategyMap(Screen) != none) {
		if(bExists) {
			`RTLOG("Program Info Screen button already present, returning...");
			return;
		}
		`RTLOG("Loading Program Info Screen button in OnRecieveFocus...");
		ShowProgramFactionScreenButton(UIStrategyMap(Screen));
	}
}

event OnRemoved(UIScreen Screen) {
	if(UIStrategyMap(Screen) != none && bExists) {
		//`RTLOG("Cleaning up Program Info Screen button in OnRemoved...");
		//ManualGC(UIStrategyMap(Screen));
	}
}

event OnLoseFocus(UIScreen Screen) {
	if(UIStrategyMap(Screen) != none && bExists) {
		//`RTLOG("Cleaning up Program Info Screen button in OnLoseFocus...");
		//ManualGC(UIStrategyMap(Screen));
	}
}

simulated function ShowProgramFactionScreenButton(UIStrategyMap Screen) {
	local RTGameState_ProgramFaction ProgramState;
	local XComGameState_Haven HavenState;
	local UIStrategyMapItem_ResistanceHQ MapItem;

	ProgramState = `RTS.GetProgramState();
	if(!ProgramState.bMetXCom) {
		`RTLOG("Program hasn't met XCom, returning...");
		return;
	}

	HavenState = XComGameState_Haven(GetProgramScanningSite(Screen, ProgramState));
	if(HavenState == none) {
		return;
	}

	MapItem = UIStrategyMapItem_ResistanceHQ(`HQPRES.StrategyMap2D.GetMapItem(HavenState));
	if(MapItem == none) {
		`RTLOG("Couldn't find a MapItem for the Program!");
	}

	MapItem.ScanButton.SetButtonIcon(class'UIUtilities_Image'.const.MissionIcon_Resistance);
	MapItem.ScanButton.SetFactionDelegate(OnButtonClicked);
	MapItem.ScanButton.SetFactionTooltip(m_strProgramFactionButton);
	MapItem.ScanButton.bDirty = true;
	MapItem.ScanButton.Realize();
	//bExists = true;
}

simulated function OnButtonClicked()
{
	local UIScreen TempScreen;
	local XComHQPresentationLayer Pres;
	local UIScreenStack ScreenStack;

	Pres = `HQPres;

	ScreenStack = Pres.ScreenStack;
	TempScreen = ScreenStack.GetFirstInstanceOf(class'RTUIScreen_ProgramFactionInfo');
	if (TempScreen != none && ScreenStack.GetCurrentScreen() == TempScreen)
	{
		TempScreen.CloseScreen();
		return;
	}
	
	// don't show when paused or showing popups
	if (Pres.IsBusy())
	{
		`RTLOG("Pres is Busy, returning...");
		return;
	}
	
	TempScreen = GetProgramFactionInfoScreen();
	ScreenStack.Push(TempScreen, Pres.Get2DMovie());
	RTUIScreen_ProgramFactionInfo(TempScreen).PopulateData();
}

static function RTUIScreen_ProgramFactionInfo GetProgramFactionInfoScreen()
{
	local RTUIScreen_ProgramFactionInfo TempScreen;
	local XComPresentationLayerBase Pres;

	Pres = `PRESBASE;
	TempScreen = RTUIScreen_ProgramFactionInfo(FindObject(class'X2DownloadableContentInfo_RisingTides'.default.screen_path, class'RTUIScreen_ProgramFactionInfo'));
	if (Pres != none && TempScreen == none)
	{
		TempScreen = Pres.Spawn(class'RTUIScreen_ProgramFactionInfo', Pres);
		TempScreen.InitScreen(XComPlayerController(Pres.Owner), Pres.Get2DMovie());
		TempScreen.Movie.LoadScreen(TempScreen);
		class'X2DownloadableContentInfo_RisingTides'.default.screen_path = PathName(TempScreen);
	}
	return TempScreen;
}


simulated function XComGameState_ScanningSite GetProgramScanningSite(UIStrategyMap Screen, RTGameState_ProgramFaction ProgramState) {
	local XComGameState_ScanningSite IteratorState;

	foreach Screen.MissionItemUI.ScanSites(IteratorState) {
		if(ProgramState.FactionHQ == IteratorState.GetReference()) {
			return IteratorState;
		}
	}

	`RTLOG("Didn't find the Program's haven! Returning none!");
	return none;
	

}

simulated function ManualGC(UIStrategyMap Screen) {
	//local UIButton button;
	local UIScanButton button;
	bExists = false;

	//button = UIButton(Screen.GetChildByName(buttonName));
	button = UIScanButton(Screen.GetChildByName(buttonName));
	if(button != none) {
		button.Remove();
		button = none;
	}
}

defaultproperties
{
	// Leaving this assigned to none will cause every screen to trigger its signals on this class
	ScreenClass = none;

	buttonName = "RT_ProgramBriefingButton"
}
*/