class RTUIScreen_ProgramFactionInfo extends UIScreen config(ProgramFaction);

var UIPanel Container;
var UIBGBox PanelBG;
var UIBGBox FullBG;
var UIBGBox BGOutline;

var UIX2PanelHeader TitleHeader;
var UIImage HadleyImage;
var UIBGBox HadleyOutline;
var RTUICounter FavorCounter;

var UIVerticalProgressBar QuestlineTrackerBar;
var UIBGBox QuestlineTrackerOutline;
var UIBGBox QuestlineTrackerBarSectionLine1, QuestlineTrackerBarSectionLine2, QuestlineTrackerBarSectionLine3, QuestlineTrackerBarSectionLine4;

var RTUIInfoBox StageOne;
var localized String m_strStageOneTitle;
var localized String m_strStageOneDescription;
var localized String m_strStageOneRewardTitle;
var localized String m_strStageOneRewardDescription;
var config String m_strStageOneImage;
var config String m_strStageOneRewardImage;

var RTUIInfoBox StageTwo;
var localized String m_strStageTwoTitle;
var localized String m_strStageTwoDescription;
var localized String m_strStageTwoRewardTitle;
var localized String m_strStageTwoRewardDescription;
var config String m_strStageTwoImage;
var config String m_strStageTwoRewardImage;

var RTUIInfoBox StageThree;
var localized String m_strStageThreeTitle;
var localized String m_strStageThreeDescription;
var localized String m_strStageThreeRewardTitle;
var localized String m_strStageThreeRewardDescription;
var config String m_strStageThreeImage;
var config String m_strStageThreeRewardImage;

var RTUIInfoBox StageFour;
var localized String m_strStageFourTitle;
var localized String m_strStageFourDescription;
var localized String m_strStageFourRewardTitle;
var localized String m_strStageFourRewardDescription;
var config String m_strStageFourImage;
var config String m_strStageFourRewardImage;

var int iStatIconSize;
var int horizontalMargin;
var int horizontalPadding;
var int weaponPanelPadding;
var int bottomMargin;

var string PrimaryColor;
var string TextColor;
var string HeaderColor;
var string SecondaryColor;

var localized string m_strProgramFactionInfoHeaderText;
var localized string m_strProgramFactionInfoDescriptionText;

var localized string m_strProgramFactionInfoCounterTitle;
var localized string m_strProgramFactionInfoCounterDescriptionText;
var localized string m_strProgramFavorAvailable;
var localized string m_strProgramFavorUnavailable;

defaultproperties
{
	Width=1300
	Height=800

	iStatIconSize=24
	horizontalMargin=32
	horizontalPadding=48
	weaponPanelPadding=24
	bottomMargin=30

	bConsumeMouseEvents=true
	
	bIsPermanent=true
	bIsVisible=false

	PrimaryColor = "e8e8e8"
	TextColor = "e8e8e8"
	HeaderColor = "e8e8e8"
	SecondaryColor = "a51515"
}

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local int topRunningY, bottomRunningY, topMarginY;
	local int columnWidth;
	local int questlineTrackerBarSectionLineX, questlineTrackerBarSectionWidth;

	super.InitScreen(InitController, InitMovie, InitName);

	columnWidth = ((Width - horizontalPadding) / 2) - horizontalMargin;

	Container = Spawn(class'UIPanel', self).InitPanel();
	Container.Width = columnWidth;
	Container.Width = Width;
	Container.Height = Height;
	Container.SetPosition((Movie.UI_RES_X - Container.Width) / 2, (Movie.UI_RES_Y - Container.Height) / 2);
	
	// opaque black bg for style
	FullBG = Spawn(class'UIBGBox', Container);
	FullBG.InitBG('', 0, 0, Container.Width, Container.Height);
	FullBG.SetAlpha(95);

	BGOutline = Spawn(class'UIBGBox', Container);
	BGOutline.InitBG('', 0, 0, Container.Width - 4, Container.Height - 4);
	BGOutline.SetOutline(true, "0x" $ PrimaryColor);

	PanelBG = Spawn(class'UIBGBox', Container);
	PanelBG.LibID = class'UIUtilities_Controls'.const.MC_X2BackgroundShading;
	PanelBG.InitBG('', 0, 0, Container.Width, Container.Height);
	PanelBG.SetAlpha(95);

	topRunningY = 10;
	
	TitleHeader = Spawn(class'UIX2PanelHeader', Container);
	TitleHeader.InitPanelHeader('', "", "");
	TitleHeader.SetPosition(10, topRunningY);
	TitleHeader.SetHeaderWidth(Container.Width - TitleHeader.X - 10);
	topRunningY += TitleHeader.Height;

	HadleyImage = Spawn(class'UIImage', Container).InitImage();
	HadleyImage.LoadImage("img:///RisingTidesContentPackage.UIImages.program_portrait_hadley_rectangle");
	HadleyImage.SetSize(512, 256);
	HadleyImage.SetPosition(10, topRunningY - 10);

	HadleyOutline = Spawn(class'UIBGBox', Container);
	HadleyOutline.InitBG('RT_HadleyOutline', 10, topRunningY - 10, 512, 256);
	HadleyOutline.SetOutline(true, "0x" $ PrimaryColor);

	topMarginY = topRunningY - 20;
	topRunningY += HadleyOutline.Height;

	bottomRunningY = Container.Height - bottomMargin;

	QuestlineTrackerBarSectionLine1 = Spawn(class'UIBGBox', Container);
	QuestlineTrackerBarSectionLine2 = Spawn(class'UIBGBox', Container);
	QuestlineTrackerBarSectionLine3 = Spawn(class'UIBGBox', Container);
	QuestlineTrackerBarSectionLine4 = Spawn(class'UIBGBox', Container);

	QuestlineTrackerBar = Spawn(class'UIVerticalProgressBar', Container);
	// InitProgressBar(InitName, InitX, InitY, InitWidth, InitHeight, InitPercentFilled, InitFillColorState )
	QuestlineTrackerBar.InitProgressBar('RT_QuestlineTrackerBar', HadleyImage.X + HadleyImage.Width + 15 + 50, bottomRunningY - 15, 50, Container.Height - 125, 0);
	QuestlineTrackerBar.SetRotationDegrees(180);
	QuestlineTrackerBar.SetColor("0x" $ PrimaryColor);
	QuestlineTrackerBar.SetBGColor("0x" $ "828282"); // grey
	// 20 pixels higher, 30 pixels smaller

	QuestlineTrackerOutline = Spawn(class'UIBGBox', Container);
	QuestlineTrackerOutline.InitBG('RT_QuestlineTrackerOutline', QuestlineTrackerBar.X, QuestlineTrackerBar.Y, QuestlineTrackerBar.Width, QuestlineTrackerBar.Height - 4);
	QuestlineTrackerOutline.SetRotationDegrees(180);
	QuestlineTrackerOutline.SetOutline(true, "0x" $ SecondaryColor);

	questlineTrackerBarSectionLineX = QuestlineTrackerBar.X - QuestlineTrackerBar.Width;
	questlineTrackerBarSectionWidth = 150 + QuestlineTrackerBar.Width;

	QuestlineTrackerBarSectionLine1.InitBG('RT_QuestlineTrackerBarSection1', questlineTrackerBarSectionLineX, topMarginY + (170 * 1), questlineTrackerBarSectionWidth, 8);
	QuestlineTrackerBarSectionLine1.SetColor("0x" $ SecondaryColor);

	QuestlineTrackerBarSectionLine2.InitBG('RT_QuestlineTrackerBarSection2', questlineTrackerBarSectionLineX, topMarginY + (170 * 2), questlineTrackerBarSectionWidth, 8);
	QuestlineTrackerBarSectionLine2.SetColor("0x" $ SecondaryColor);

	QuestlineTrackerBarSectionLine3.InitBG('RT_QuestlineTrackerBarSection3', questlineTrackerBarSectionLineX, topMarginY + (170 * 3), questlineTrackerBarSectionWidth, 8);
	QuestlineTrackerBarSectionLine3.SetColor("0x" $ SecondaryColor);

	QuestlineTrackerBarSectionLine4.InitBG('RT_QuestlineTrackerBarSection4', questlineTrackerBarSectionLineX, topMarginY + (170 * 0) + (3 * 1), questlineTrackerBarSectionWidth, 8);
	QuestlineTrackerBarSectionLine4.SetColor("0x" $ SecondaryColor);

	QuestlineTrackerBarSectionLine1.MoveToHighestDepth();
	QuestlineTrackerBarSectionLine2.MoveToHighestDepth();
	QuestlineTrackerBarSectionLine3.MoveToHighestDepth();
	QuestlineTrackerBarSectionLine4.MoveToHighestDepth();

	FavorCounter = Spawn(class'RTUICounter', Container);
	FavorCounter.InitColors(PrimaryColor, TextColor, HeaderColor, SecondaryColor);
	FavorCounter.InitStrings(m_strProgramFavorAvailable, m_strProgramFavorUnavailable);
	FavorCounter.InitCounter('RT_OSFCounter', m_strProgramFactionInfoCounterTitle, m_strProgramFactionInfoCounterDescriptionText, 516, 410);
	FavorCounter.SetPosition(10, topRunningY);

	StageOne = Spawn(class'RTUIInfoBox', Container);
	StageOne.InitColors(PrimaryColor, TextColor, HeaderColor, SecondaryColor);
	StageOne.InitText(m_strStageOneTitle, m_strStageOneDescription, m_strStageOneRewardTitle, m_strStageOneRewardDescription);
	StageOne.InitImages(m_strStageOneImage, m_strStageOneRewardImage);
	StageOne.InitInfoBox('RT_ProgramInfoScreenStageOne', 700, 160, 1);
	StageOne.SetPosition(QuestlineTrackerBarSectionLine3.X + 4 + QuestlineTrackerBar.Width, QuestlineTrackerBarSectionLine3.Y + 11);
	
	StageTwo = Spawn(class'RTUIInfoBox', Container);
	StageTwo.InitColors(PrimaryColor, TextColor, HeaderColor, SecondaryColor);
	StageTwo.InitText(m_strStageTwoTitle, m_strStageTwoDescription, m_strStageTwoRewardTitle, m_strStageTwoRewardDescription);
	StageTwo.InitImages(m_strStageTwoImage, m_strStageTwoRewardImage);
	StageTwo.InitInfoBox('RT_ProgramInfoScreenStageTwo', 700, 160, 2);
	StageTwo.SetPosition(QuestlineTrackerBarSectionLine2.X + 4 + QuestlineTrackerBar.Width, QuestlineTrackerBarSectionLine2.Y + 11);
	
	StageThree = Spawn(class'RTUIInfoBox', Container);
	StageThree.InitColors(PrimaryColor, TextColor, HeaderColor, SecondaryColor);
	StageThree.InitText(m_strStageThreeTitle, m_strStageThreeDescription, m_strStageThreeRewardTitle, m_strStageThreeRewardDescription);
	StageThree.InitImages(m_strStageThreeImage, m_strStageThreeRewardImage);
	StageThree.InitInfoBox('RT_ProgramInfoScreenStageThree', 700, 160, 3);
	StageThree.SetPosition(QuestlineTrackerBarSectionLine1.X + 4 + QuestlineTrackerBar.Width, QuestlineTrackerBarSectionLine1.Y + 11);

	StageFour = Spawn(class'RTUIInfoBox', Container);
	StageFour.InitColors(PrimaryColor, TextColor, HeaderColor, SecondaryColor);
	StageFour.InitText(m_strStageFourTitle, m_strStageFourDescription, m_strStageFourRewardTitle, m_strStageFourRewardDescription);
	StageFour.InitImages(m_strStageFourImage, m_strStageFourRewardImage);
	StageFour.InitInfoBox('RT_ProgramInfoScreenStageFour', 700, 160, 4);
	StageFour.SetPosition(QuestlineTrackerBarSectionLine1.X + 4 + QuestlineTrackerBar.Width, QuestlineTrackerBarSectionLine1.Y - 158);
}

private static function float CalculateQuestlineTrackerBarPercent(RTGameState_ProgramFaction ProgramState) {
	local float percent;
	local float barPercentPerStage, barPercentPerFavor;
	local int iInfluence, iNumberOfFavorsCalledIn, iTotalQuestlineStages, iTotalFavorsRequired, iMaxFavorsForVis;

	if(ProgramState.TemplarQuestlineSucceeded()) {
		return 1;
	} else {
		iInfluence = Int(ProgramState.GetInfluence());
		iTotalQuestlineStages = 4; // magic number
		barPercentPerStage = 100 / iTotalQuestlineStages;

		iNumberOfFavorsCalledIn = ProgramState.iNumberOfFavorsCalledIn;
		iMaxFavorsForVis = class'RTGameState_ProgramFaction'.default.iNumberOfFavorsRequiredToIncreaseInfluence;
		if(iNumberOfFavorsCalledIn > iMaxFavorsForVis) {
			iNumberOfFavorsCalledIn = iMaxFavorsForVis;
		}

		`RTLOG("Number of Favors called in: " $ ProgramState.iNumberOfFavorsCalledIn);
		`RTLOG("Actual number of favors being displayed: " $ iNumberOfFavorsCalledIn);
		`RTLOG("Program Influence (1-1 with bars filled): " $ iInfluence);
		`RTLOG("Program Influence (1-1 with bars filled): " $ ProgramState.GetInfluence());

		iTotalFavorsRequired = iTotalQuestlineStages * class'RTGameState_ProgramFaction'.default.iNumberOfFavorsRequiredToIncreaseInfluence;
		barPercentPerFavor = 100 / iTotalFavorsRequired;

		percent = float(min((iInfluence * barPercentPerStage) + (iNumberOfFavorsCalledIn * barPercentPerFavor), 100)) * 0.01;
		`RTLOG("Total Influence Bar progress: " $ percent);
		return percent;
	}
}

simulated function PopulateData()
{
	local RTGameState_ProgramFaction ProgramState;
	local int iQuestlineStage, iTotalFavors;
	local bool bFailed;

	ProgramState = `RTS.GetProgramState();
	if(ProgramState == none) {
		`RTLOG("Couldn't find a ProgramState to populate data from, returning!");
		return;
	}

	TitleHeader.SetText(m_strProgramFactionInfoHeaderText, m_strProgramFactionInfoDescriptionText);
	TitleHeader.MC.FunctionVoid("realize");

	QuestlineTrackerBar.SetPercent(CalculateQuestlineTrackerBarPercent(ProgramState));

	iQuestlineStage = ProgramState.getTemplarQuestlineStage();
	bFailed = ProgramState.hasFailedTemplarQuestline();
	iTotalFavors = ProgramState.GetNumFavorsAvailable();
	
	if(ProgramState.IsOneSmallFavorAvailable()) {
		iTotalFavors++; // this checks for the active favor waiting to be called in, which can only be set once per month via the card.
		FavorCounter.SetAvailable();
	} else {
		FavorCounter.SetUnavailable();
	}

	FavorCounter.SetCounter(iTotalFavors);
	FavorCounter.MC.FunctionVoid("realize");

	// There must be a better way, I'm just too tired and lazy to figure it out
	switch(iQuestlineStage) {
		case 0:
			if(!ProgramState.IsTemplarFactionMet()) {
				StageOne.SetLocked();
			} else {
				StageOne.SetAvailable();
			}

			StageTwo.SetLocked();
			StageThree.SetLocked();
			StageFour.SetLocked();
			break;
		case 1:
			if(bFailed) {
				StageOne.SetFailed();
				StageTwo.SetLocked();
			} else {
				StageOne.SetCompleted();
				StageTwo.SetAvailable();
			}

			StageThree.SetLocked();
			StageFour.SetLocked();
			break;
		case 2:
			StageOne.SetCompleted();
			if(bFailed) {
				StageTwo.SetFailed();
				StageThree.SetLocked();
			} else {
				StageTwo.SetCompleted();
				StageThree.SetAvailable();
			}

			StageFour.SetLocked();
			break;
		case 3:
			StageOne.SetCompleted();
			StageTwo.SetCompleted();
			if(bFailed) {
				StageThree.SetFailed();
				StageFour.SetLocked();
			} else {
				StageThree.SetCompleted();
				StageFour.SetAvailable();
			}
			break;
		case 4:
			StageOne.SetCompleted();
			StageTwo.SetCompleted();
			StageThree.SetCompleted();
			if(bFailed) {
				StageFour.SetFailed();
			} else {
				StageFour.SetCompleted();
			}
			break;
		default:
			StageOne.SetLocked();
			StageTwo.SetLocked();
			StageThree.SetLocked();
			StageFour.SetLocked();
	}

	SetColors();
	Show();
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;

	//`RTLOG("" $ GetFuncName());

	if( !CheckInputIsReleaseOrDirectionRepeat(cmd, arg) )
		return false;

	bHandled = true;
	switch( cmd )
	{
		// a lot of keys can close it
		case class'UIUtilities_Input'.const.FXS_KEY_SPACEBAR:
		case class'UIUtilities_Input'.const.FXS_BUTTON_B:
		case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
		case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
			CloseScreen();
			return true;
		default:
			bHandled = false;
			break;
	}

	// don't route through the navigator
	return bHandled;
}

simulated function Show()
{
	super.Show();
	Movie.InsertHighestDepthScreen(self);
	InputState = eInputState_Consume;
}

simulated function Hide()
{
	super.Hide();
	Movie.RemoveHighestDepthScreen(self);
	InputState = eInputState_None;
}

simulated function CloseScreen()
{
	super.CloseScreen();
	Hide();
}

simulated function AS_SetMCColor(string ClipPath, string HexColor)
{
	Movie.ActionScriptVoid("Colors.setColor");
}

simulated function SetColors()
{
	local string clr;

	clr = default.PrimaryColor;
	
	TitleHeader.SetColor(clr);

	AS_SetMCColor(PanelBG.MCPath$".topLines", clr);
	AS_SetMCColor(PanelBG.MCPath$".bottomLines", clr);
}

simulated function ColorPanel(UIPanel Panel, string _clr, string _textclr, string _headerclr)
{
	local int i;
	if (UIIcon(Panel) != none)
	{
		UIIcon(Panel).SetBGColor(_clr);
	}
	else if (UIText(Panel) != none)
	{
		Panel.SetColor((Panel.MCName == 'Title' || Panel.MCName == 'Title2') ? _headerclr : _textclr);
	}
	else if (UIScrollingText(Panel) != none || UIScrollbar(Panel) != none)
	{
		Panel.SetColor(_headerclr);
	}
	else
	{
		for (i = 0; i < Panel.ChildPanels.Length; i++)
		{
			ColorPanel(Panel.ChildPanels[i], _clr, _textclr, _headerclr);
		}
	}
}