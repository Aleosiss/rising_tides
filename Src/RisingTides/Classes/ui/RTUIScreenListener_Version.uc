class RTUIScreenListener_Version extends UIScreenListener config(RisingTides);

var config bool bEnableVersionDisplay;


var name VersionTextName;


defaultProperties
{
    VersionTextName = 'rtVersionText'
	ScreenClass = none
}

event OnInit(UIScreen Screen)
{
	if(UIShell(Screen) == none || !bEnableVersionDisplay) {
		return;
    }

	DisplayVersionText(UIShell(Screen));
}

event OnReceiveFocus(UIScreen Screen)
{
	if(UIShell(Screen) == none || !bEnableVersionDisplay) {
		return;
    }

	DisplayVersionText(UIShell(Screen));
}

function DisplayVersionText(UIShell ShellScreen)
{
	local string VersionString;
	local int i;
	local UIText VersionText;

	VersionString = "";
    VersionString $= " - " $ `DLCINFO.GetVersionString() $ ":" $ `CONFIG.BuildTimestamp;

	VersionText = UIText(ShellScreen.GetChildByName(VersionTextName, false));
	if (VersionText == none) {
		VersionText = ShellScreen.Spawn(class'UIText', ShellScreen);
		VersionText.InitText(VersionTextName);
		// This code aligns the version text to the Main Menu Ticker
		VersionText.AnchorBottomCenter();
		VersionText.SetY(-ShellScreen.TickerHeight + 10);
	}

	if (`ISCONTROLLERACTIVE) {
		VersionText.SetHTMLText(class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Input'.static.GetGamepadIconPrefix() 
								$ class'UIUtilities_Input'.const.ICON_RSCLICK_R3, 20, 20, -10) 
								@ VersionString, OnTextSizeRealized);
	}
	else {
		VersionText.SetHTMLText(VersionString, OnTextSizeRealized);
	}
}

function OnTextSizeRealized()
{
	local UIText VersionText;
	local UIShell ShellScreen;

	ShellScreen = UIShell(`SCREENSTACK.GetFirstInstanceOf(class'UIShell'));
	VersionText = UIText(ShellScreen.GetChildByName(VersionTextName));
	VersionText.SetX(-10 - VersionText.Width);
	// this makes the ticker shorter -- if the text gets long enough to interfere, it will automatically scroll
	ShellScreen.TickerText.SetWidth(ShellScreen.Movie.m_v2ScaledFullscreenDimension.X - VersionText.Width - 20);
}