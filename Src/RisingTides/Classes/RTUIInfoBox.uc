class RTUIInfoBox extends UIPanel;

var UIBGBox BackgroundPanel;
var UIBGBox OutlinePanel;

var UIImage TheImage;
var UIText InfoBoxHeader;
var UIScrollingTextBox InfoBoxDescription;

var string PrimaryColor;
var string TextColor;
var string HeaderColor;
var string SecondaryColor;

var string CompletedColor;
var string LockedColor;

var int CountSize;

// --------------------------------------
defaultproperties
{
	CountSize = 84

	CompletedColor = "5CD16C"
	LockedColor = "828282"
}

simulated function InitColors(String newPrimaryColor, String newTextColor, String newHeaderColor, String newSecondaryColor) {
	PrimaryColor = newPrimaryColor;
	TextColor = newTextColor;
	HeaderColor = newHeaderColor;
	SecondaryColor = newSecondaryColor;
}

simulated function RTUIInfoBox InitInfoBox(name PanelName, float newWidth, float newHeight)
{
	local String strTextTemp;

	InitPanel(PanelName);
	
	BackgroundPanel = Spawn(class'UIBGBox', self);
	BackgroundPanel.LibID = class'UIUtilities_Controls'.const.MC_X2BackgroundShading;
	BackgroundPanel.InitBG('infoBG', 0, 0, newWidth, newHeight);

	OutlinePanel = Spawn(class'UIBGBox', self);
	OutlinePanel.InitBG('infoOutline', 0, 0, BackgroundPanel.Width - 4, BackgroundPanel.Height - 4);
	OutlinePanel.SetOutline(true, "0x" $ PrimaryColor);


	return self;
}

simulated function RTUIInfoBox SetLocked() {
	return self;
}

simulated function RTUIInfoBox SetAvailable() {
	return self;
}

simulated function RTUIInfoBox SetCompleted() {
	return self;
}

simulated function RTUIInfoBox ShowRewards() {
	return self;
}

simulated function RTUIInfoBox HideRewards() {
	return self;
}

