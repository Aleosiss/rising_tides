class RTUIInfoBox extends UIPanel;

var UIBGBox BackgroundPanel;
var UIBGBox OutlinePanel;

var UIImage InfoBoxImage;
var UIBGBox ImageOutline;

var String DefaultImagePath;
var String RewardImagePath;

var UIX2PanelHeader InfoBoxHeader;
var UITextContainer InfoBoxDescription;

var UIButton Button;

var String DefaultTitle;
var String RewardTitle;

var String DefaultDescription;
var String RewardDescription;

var string PrimaryColor;
var string TextColor;
var string HeaderColor;
var string SecondaryColor;

var string CompletedColor;
var string LockedColor;

var String LockedImagePath;
var localized String m_strLockedTitle;
var localized String m_strLockedDescription;

var localized String m_strSwapToRewards;
var localized String m_strSwapFromRewards;

var int CountSize;
var bool bRewardsVisible;

// --------------------------------------
defaultproperties
{
	CountSize = 84

	CompletedColor = "5CD16C"
	LockedColor = "828282"
	DefaultImagePath = ""
	RewardImagePath = ""
}

simulated function InitText(String _defaultTitle, String _defaultDescription, String _rewardTitle, String _rewardDescription) {
	DefaultDescription = _defaultDescription;
	DefaultTitle = _defaultTitle;
	RewardDescription = _rewardDescription;
	RewardTitle = _rewardTitle;
}

simulated function InitImages(String _imagePath, String _rewardImagePath) {
	DefaultImagePath = _imagePath;
	RewardImagePath = _rewardImagePath;
}

simulated function InitColors(String newPrimaryColor, String newTextColor, String newHeaderColor, String newSecondaryColor) {
	PrimaryColor = newPrimaryColor;
	TextColor = newTextColor;
	HeaderColor = newHeaderColor;
	SecondaryColor = newSecondaryColor;
}

simulated function RTUIInfoBox InitInfoBox(name PanelName, float newWidth, float newHeight, optional int number)
{
	local int imageY;
	local name textContainerName;

	InitPanel(PanelName);

	SetSize(newWidth, newHeight);

	bRewardsVisible = false;
	
	BackgroundPanel = Spawn(class'UIBGBox', self);
	BackgroundPanel.LibID = class'UIUtilities_Controls'.const.MC_X2BackgroundShading;
	BackgroundPanel.InitBG('infoBG', 0, 0, newWidth, newHeight);

	OutlinePanel = Spawn(class'UIBGBox', self);
	OutlinePanel.InitBG('infoOutline', 0, 0, BackgroundPanel.Width - 4, BackgroundPanel.Height - 4);
	OutlinePanel.SetOutline(true, "0x" $ PrimaryColor);

	InfoBoxImage = Spawn(class'UIImage', self);
	InfoBoxImage.InitImage('infoImage', DefaultImagePath).SetSize(BackgroundPanel.Height - 24, BackgroundPanel.Height - 24);
	imageY = ((BackgroundPanel.Height - InfoBoxImage.Height) / 2);
	InfoBoxImage.SetPosition(8, imageY);

	ImageOutline = Spawn(class'UIBGBox', self);
	ImageOutline.InitBG('imageOutline', InfoBoxImage.X, InfoBoxImage.Y, InfoBoxImage.Width - 4, InfoBoxImage.Height - 4);
	ImageOutline.SetOutline(true, "0x" $ PrimaryColor);

	InfoBoxHeader = Spawn(class'UIX2PanelHeader', self);
	InfoBoxHeader.InitPanelHeader('', "initializing...", "");
	InfoBoxHeader.SetPosition(InfoBoxImage.X + InfoBoxImage.Width + 10, 4);
	InfoBoxHeader.SetHeaderWidth(BackgroundPanel.Width - InfoBoxHeader.X - 10);

	textContainerName = name('RT_InfoBoxDescription' $ number);

	InfoBoxDescription = Spawn(class'UITextContainer', self);
	InfoBoxDescription.InitTextContainer(textContainerName, "");
	InfoBoxDescription.SetPosition(InfoBoxHeader.X, InfoBoxHeader.Y + 40);
	InfoBoxDescription.SetSize(BackgroundPanel.Width - InfoBoxImage.Width - 40, InfoBoxImage.Height - 30);
	InfoBoxDescription.bAutoScroll = false;
	
	Button = Spawn(class'UIButton', self);
	Button.InitButton('RT_InfoBoxButton', "default", OnButtonClicked);
	Button.SetPosition(InfoBoxDescription.X + InfoBoxDescription.Width - 160, InfoBoxDescription.Y - 35);
	Button.SetSize(400, 30);
	Button.ShowBG(true);
	return self;
}

simulated function OnButtonClicked(UIButton _button)
{
	if(bRewardsVisible) {
		HideRewards();
		bRewardsVisible = !bRewardsVisible;
	} else {
		ShowRewards();
		bRewardsVisible = !bRewardsVisible;
	}
}

simulated function RTUIInfoBox SetLocked() {
	HideRewards();

	InfoBoxHeader.SetText(m_strLockedTitle);
	InfoBoxHeader.MC.FunctionVoid("realize");
	InfoBoxDescription.SetText(m_strLockedDescription);
	InfoBoxImage.LoadImage(LockedImagePath);

	SetPanelColors(0);
	SetTextColors(0);

	Button.DisableButton(m_strLockedDescription);
	Button.SetText(m_strLockedTitle);
	return self;
}

simulated function RTUIInfoBox SetAvailable() {
	HideRewards();
	SetPanelColors(1);

	Button.DisableButton(m_strLockedDescription);
	Button.SetText(m_strLockedTitle);
	return self;
}

simulated function RTUIInfoBox SetCompleted() {
	HideRewards();
	SetPanelColors(2);

	Button.EnableButton();
	Button.SetText(`RTS.AddFontColor(m_strSwapToRewards, "0x" $ PrimaryColor));
	return self;
}

simulated function RTUIInfoBox ShowRewards() {
	InfoBoxHeader.SetText(RewardTitle);
	InfoBoxHeader.MC.FunctionVoid("realize");
	InfoBoxDescription.SetText(RewardDescription);
	InfoBoxImage.LoadImage(RewardImagePath);
	SetTextColors(2);

	Button.SetText(`RTS.AddFontColor(m_strSwapFromRewards, CompletedColor));
	return self;
}

simulated function RTUIInfoBox HideRewards() {
	InfoBoxHeader.SetText(DefaultTitle);
	InfoBoxHeader.MC.FunctionVoid("realize");
	InfoBoxDescription.SetText(DefaultDescription);
	InfoBoxImage.LoadImage(DefaultImagePath);
	SetTextColors(1);

	Button.SetText(`RTS.AddFontColor(m_strSwapToRewards, PrimaryColor));

	return self;
}

// 0 = locked
// 1 = program white
// 2 = cash money green
simulated function SetTextColors(int i) {
	switch(i) {
		case 0:
			InfoBoxHeader.SetColor("0x" $ LockedColor);
			InfoBoxDescription.SetColor("0x" $ LockedColor);
			break;
		case 1:
			InfoBoxHeader.SetColor(PrimaryColor);
			InfoBoxDescription.SetColor("0x" $ PrimaryColor);
			break;
		case 2:
			InfoBoxHeader.SetColor(CompletedColor);
			InfoBoxDescription.SetColor("0x" $ CompletedColor);
			break;
		default:
			InfoBoxHeader.SetColor(PrimaryColor);
			InfoBoxDescription.SetColor("0x" $ PrimaryColor);
			break;
	}
}

// 0 = locked
// 1 = program white
// 2 = cash money green
simulated function SetPanelColors(int i) {
	switch(i) {
		case 0:
			OutlinePanel.SetOutline(true, "0x" $ LockedColor);
			ImageOutline.SetOutline(true, "0x" $ LockedColor);
			break;
		case 1:
			OutlinePanel.SetOutline(true, "0x" $ PrimaryColor);
			ImageOutline.SetOutline(true, "0x" $ PrimaryColor);
			break;
		case 2:
			OutlinePanel.SetOutline(true, "0x" $ CompletedColor);
			ImageOutline.SetOutline(true, "0x" $ CompletedColor);
			break;
		default:
			OutlinePanel.SetOutline(true, "0x" $ PrimaryColor);
			ImageOutline.SetOutline(true, "0x" $ PrimaryColor);
			break;
	}
}
