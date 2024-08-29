class RTUIScreenListener_ProgramInfoScreenButton extends UIScreenListener;

/////////////////////
/// Adding button ///
/////////////////////

event OnInit(UIScreen Screen)
{
	local UIStrategyMap StrategyMap;
    local RTGameState_ProgramFaction ProgramState;

	StrategyMap = UIStrategyMap(Screen);
	if (StrategyMap == none) return;

    `RTLOG("Trying to Spawn a Program Info Screen Button!");
    ProgramState = `RTS.GetProgramState();
    if (ProgramState == none || !ProgramState.bMetXCom) return;

    `RTLOG("Found Correct Screen Type, adding!");
	AddProgramInfoScreenButton(StrategyMap);

	HandleInput(true);
}

///////////////////////////////////////////
/// Handling input (controller support) ///
///////////////////////////////////////////

event OnReceiveFocus(UIScreen screen)
{
	if (UIStrategyMap(Screen) == none) return;

	HandleInput(true);
}

event OnLoseFocus(UIScreen screen)
{
	if (UIStrategyMap(Screen) == none) return;
	
	HandleInput(false);
}

event OnRemoved(UIScreen screen)
{
	if (UIStrategyMap(Screen) == none) return;
	
	HandleInput(false);
}

function HandleInput(bool isSubscribing)
{
	local delegate<UIScreenStack.CHOnInputDelegate> inputDelegate;
	inputDelegate = OnUnrealCommand;

	if(isSubscribing)
	{
		`SCREENSTACK.SubscribeToOnInput(inputDelegate);
	}
	else
	{
		`SCREENSTACK.UnsubscribeFromOnInput(inputDelegate);
	}
}

static protected function bool OnUnrealCommand(int cmd, int arg)
{
	if (cmd == class'UIUtilities_Input'.const.FXS_BUTTON_Y && arg == class'UIUtilities_Input'.const.FXS_ACTION_RELEASE)
	{
		if (class'XComEngine'.static.GetHQPres().StrategyMap2D.m_eUIState != eSMS_Flight)
		{
			// Cannot open screen during flight
			class'RTUIUtilities'.static.ProgramInfoScreen();
		}

		return true;
	}

	return false;
}

simulated function AddProgramInfoScreenButton(UIStrategyMap Screen) {
	local RTUIImageButton Button;

	Button = Screen.Spawn(class'RTUIImageButton', Screen.StrategyMapHUD);
	Button.InitImageButton('RT_UIStrategyMap_ProgramInfoScreenButton', "img:///RisingTidesImagesPackage.vhs_program_icon_v2_border_grey", OnButtonClicked);
	Button.SetPosition(0, 0);
    Button.AnchorTopLeft();
}

simulated function OnButtonClicked(UIImage _button)
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
	
	class'RTUIUtilities'.static.ProgramInfoScreen();
}