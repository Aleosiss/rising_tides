class RTUICounter extends UIPanel;

var int Count;

var UIBGBox BackgroundPanel;
var UIBGBox OutlinePanel;
var UIText CountText;
var UIText CountTitleText;
var UIText CountTitleDescription;

var string PrimaryColor;
var string TextColor;
var string HeaderColor;
var string SecondaryColor;
var string CompletedColor;
var string FailedColor;
var string LockedColor;

var int CountSize;

var UIText AvailabilityText;
var string m_strProgramFavorAvailable;
var string m_strProgramFavorUnavailable;

// --------------------------------------
defaultproperties
{
	CountSize = 84
	CompletedColor = "5CD16C"
	LockedColor = "828282"
	FailedColor = "bf1e2e"
}

simulated function InitColors(String newPrimaryColor, String newTextColor, String newHeaderColor, String newSecondaryColor) {
	PrimaryColor = newPrimaryColor;
	TextColor = newTextColor;
	HeaderColor = newHeaderColor;
	SecondaryColor = newSecondaryColor;
}

simulated function InitStrings(string availableStr, string unavailableStr) {
	m_strProgramFavorAvailable = availableStr;
	m_strProgramFavorUnavailable = unavailableStr;
}

simulated function RTUICounter InitCounter(name PanelName, String TitleText, String TitleDescription, float newWidth, float newHeight)
{
	local String strTextTemp;

	InitPanel(PanelName);
	
	BackgroundPanel = Spawn(class'UIBGBox', self);
	BackgroundPanel.LibID = class'UIUtilities_Controls'.const.MC_X2BackgroundShading;
	BackgroundPanel.InitBG('counterBG', 0, 0, newWidth, newHeight);

	OutlinePanel = Spawn(class'UIBGBox', self);
	OutlinePanel.InitBG('counterOutline', 0, 0, BackgroundPanel.Width - 4, BackgroundPanel.Height - 4);
	OutlinePanel.SetOutline(true, "0x" $ PrimaryColor);

	CountText = Spawn(class'UIText', self);
	CountText.InitText('RT_CounterValue');
	CountText.OriginCenter();
	//CountText.AnchorCenter();
	CountText.SetSize(300, 300);
	CountText.SetPosition(105, 130);

	Count = -1;

	strTextTemp = class'UIUtilities_Text'.static.AddFontInfo("" $ Count, false, false, false, CountSize);
	strTextTemp = class'UIUtilities_Text'.static.AlignCenter(strTextTemp);
	strTextTemp = ColorText(strTextTemp, PrimaryColor);
	CountText.SetHtmlText(strTextTemp);
	
	CountTitleText = Spawn(class'UIText', self);
	CountTitleText.InitText('RT_CounterTitle');
	CountTitleText.OriginCenter();
	//CountTitleText.AnchorCenter();
	CountTitleText.SetSize(300, 300);
	CountTitleText.SetPosition(110, 50);

	strTextTemp = class'UIUtilities_Text'.static.AddFontInfo(TitleText, false, true);
	strTextTemp = class'UIUtilities_Text'.static.AlignCenter(strTextTemp);
	strTextTemp = ColorText(strTextTemp, PrimaryColor);
	CountTitleText.SetHtmlText(strTextTemp);

	CountTitleDescription = Spawn(class'UIText', self);
	CountTitleDescription.InitText('RT_CounterDescription');
	CountTitleDescription.OriginCenter();
	//CountTitleDescription.AnchorCenter();
	CountTitleDescription.SetSize(400, 100);
	CountTitleDescription.SetPosition(50, 250);

	strTextTemp = class'UIUtilities_Text'.static.AddFontInfo(TitleDescription, false);
	strTextTemp = class'UIUtilities_Text'.static.AlignCenter(strTextTemp);
	strTextTemp = ColorText(strTextTemp, PrimaryColor);
	CountTitleDescription.SetHtmlText(strTextTemp);

	AvailabilityText  = Spawn(class'UIText', self);
	AvailabilityText.InitText('RT_AvailabilityText');
	AvailabilityText.OriginCenter();
	//AvailabilityText.AnchorCenter();
	AvailabilityText.SetSize(400, 100);
	AvailabilityText.SetPosition(50, 375);

	strTextTemp = class'UIUtilities_Text'.static.AddFontInfo(m_strProgramFavorUnavailable, false);
	strTextTemp = class'UIUtilities_Text'.static.AlignCenter(strTextTemp);
	strTextTemp = ColorText(strTextTemp, FailedColor);
	AvailabilityText.SetHtmlText(strTextTemp);

	return self;
}


static function string ColorText(string strValue, string strColour)
{
	return "<font color='#" $ strColour $ "'>" $ strValue $ "</font>";
}

simulated function SetAvailable() {
	local String strTextTemp;

	OutlinePanel.SetOutline(true, "0x" $ CompletedColor);

	strTextTemp = class'UIUtilities_Text'.static.AddFontInfo(m_strProgramFavorAvailable, false);
	strTextTemp = class'UIUtilities_Text'.static.AlignCenter(strTextTemp);
	strTextTemp = ColorText(strTextTemp, CompletedColor);
	AvailabilityText.SetHtmlText(strTextTemp);
}

simulated function SetUnavailable(ERTProgramFavorAvailablity reason) {
	local String strTextTemp;

	OutlinePanel.SetOutline(true, "0x" $ FailedColor);

	strTextTemp = class'UIUtilities_Text'.static.AddFontInfo(`RTPS.GetLocalizationForAvailability(reason), false);
	strTextTemp = class'UIUtilities_Text'.static.AlignCenter(strTextTemp);
	strTextTemp = ColorText(strTextTemp, FailedColor);
	AvailabilityText.SetHtmlText(strTextTemp);
}


simulated function SetCounter(int newCount) {
	local String strTextTemp;

	if(Count != newCount) {
		Count = newCount;
		strTextTemp = class'UIUtilities_Text'.static.AddFontInfo("" $ Count, false, false, false, CountSize);
		strTextTemp = class'UIUtilities_Text'.static.AlignCenter(strTextTemp);
		if(Count < 2) {
			strTextTemp = ColorText(strTextTemp, SecondaryColor);
		} else {
			strTextTemp = ColorText(strTextTemp, PrimaryColor);
		}
		CountText.SetHtmlText(strTextTemp);
	}
}