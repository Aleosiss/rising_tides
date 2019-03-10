class RTUIScreenListener_ProgramFactionScreen extends UIScreenListener;

var UIButton b;
var localized String m_strProgramFactionButton;

event OnInit(UIScreen Screen)
{
	
	if(UIStrategyMap(Screen) != none) {
		`RTLOG("Loading Program Info Screen button...");
		ShowProgramFactionScreenButton(UIStrategyMap(Screen));
	}
}

event OnRemoved(UIScreen Screen) {
	if(UIStrategyMap(Screen) != none) {
		`RTLOG("Cleaning up Program Info Screen button...");
		ManualGC();
	}
}

simulated function ShowProgramFactionScreenButton(UIStrategyMap Screen) {
	local RTGameState_ProgramFaction ProgramState;
	local XComGameState_Haven HavenState;

	local UIStrategyMapItem MapItem;

	ProgramState = class'RTHelpers'.static.GetProgramState();
	if(!ProgramState.bMetXCom) {
		`RTLOG("Program hasn't met XCom, returning...");
		return;
	}

	HavenState = XComGameState_Haven(GetProgramScanningSite(Screen, ProgramState));
	if(HavenState == none) {
		return;
	}

	MapItem = `HQPRES.StrategyMap2D.GetMapItem(HavenState);

	b = Screen.Spawn(class'UIButton', MapItem);
	b.InitButton('RT_ProgramScreenButton', m_strProgramFactionButton, OnButtonClicked);
	b.SetSize(MapItem.Width, MapItem.Height);
	b.SetPosition(-90, 80);
}

simulated function OnButtonClicked(UIButton _button)
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
			`RTLOG("Found it...");
			return IteratorState;
		}
	}

	`RTLOG("Didn't find the Program's haven! Returning none!");
	return none;
	

}

simulated function ManualGC() {
	if(b != none) {
		b.Remove();
	}
	b = none;
}

defaultproperties
{
	// Leaving this assigned to none will cause every screen to trigger its signals on this class
	ScreenClass = none;
}
