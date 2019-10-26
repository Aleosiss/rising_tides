class RTUIAlert extends UIAlert;

var localized string strTemplarAmbushDescription;
var localized string strTemplarAmbushStr1;
var localized string strTemplarAmbushStr2;
var localized string strTemplarAmbushStr3;
var localized string strTemplarAmbushHeader;
var localized string strTemplarAmbushBegin;

var localized string m_strTemplarQuestlineFailedHeader;
var localized string m_strTemplarQuestlineFailedTitle;
var localized string m_strTemplarQuestlineFailedDescription;

var localized string m_strTemplarQuestlineAdvancedHeader;
var localized string m_strTemplarQuestlineAdvancedTitle;
var localized string m_strTemplarQuestlineAdvancedBody;

var localized string m_strTemplarQuestlineCompleteHeader;
var localized string m_strTemplarQuestlineCompleteTitle;
var localized string m_strTemplarQuestlineCompleteBody;

var localized string m_strHighCovenAssaultAvailableBody;
var localized string m_strHighCovenAssaultAvailableImage;
	

defaultProperties
{
	Width=1000
	Height=500
}


simulated function BuildAlert()
{
	`RTLOG("Building Alert: " $ eAlertName);
	BindLibraryItem();
	switch( eAlertName ) {
		case 'RTAlert_HighCovenAssaultAvailable':
			BuildHighCovenAssaultAvailableAlert();
			break;
		case 'RTAlert_TemplarQuestlineComplete':
			BuildTemplarQuestlineCompleteAlert();
			break;
		case 'RTAlert_TemplarQuestlineAdvanced':
			BuildTemplarQuestlineAdvancedAlert();
			break;
		case 'RTAlert_TemplarQuestlineFailed':
			BuildTemplarQuestlineFailedAlert();
			break;
		case 'RTAlert_TemplarAmbush':
			BuildTemplarAmbushAlert();
			break;
		case 'RTAlert_Test':
			BuildTestingAlert();
			break;
		default:
			AddBG(MakeRect(0, 0, 1000, 500), eUIState_Normal).SetAlpha(0.75f);
			break;
	}

	// Set up the navigation *after* the alert is built, so that the button visibility can be used. 
	RefreshNavigation();
	if (!Movie.IsMouseActive())
	{
		Navigator.Clear();
	}
}

simulated function Name GetLibraryID() {
	//This gets the Flash library name to load in a panel. No name means no library asset yet. 
	switch( eAlertName )
	{
		case 'RTAlert_TemplarAmbush':					return 'Alert_ChosenSplash';
		case 'RTAlert_TemplarQuestlineFailed':			return 'Alert_AlienSplash';
		case 'RTAlert_TemplarQuestlineAdvanced':		return 'Alert_XComGeneric';
		case 'RTAlert_TemplarQuestlineComplete':		return 'Alert_XComGeneric';
		case 'RTAlert_HighCovenAssaultAvailable':		return 'Alert_SpecialPOI';
	
		default:
			return '';
	}
}

simulated function BuildTemplarQuestlineFailedAlert() {


	BuildAlienSplashAlert(m_strTemplarQuestlineFailedHeader, m_strTemplarQuestlineFailedTitle, m_strTemplarQuestlineFailedDescription, m_strMissionExpiredImage, m_strOK, "");
	
	//Unused in this alert. 
	Button2.DisableNavigation(); 
	Button2.Hide();
}

simulated function BuildTemplarAmbushAlert() {
	local XComGameState_ResistanceFaction FactionState;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	FactionState = XComGameState_ResistanceFaction(History.GetGameStateForObjectID(
		class'X2StrategyGameRulesetDataStructures'.static.GetDynamicIntProperty(DisplayPropertySet, 'FactionRef')));

	// Save camera
	XComHQPresentationLayer(Movie.Pres).CAMSaveCurrentLocation();
	bAlertTransitionsToMission = true;

	if (LibraryPanel == none)
	{
		`RedScreen("RTUI Problem with the alerts! Couldn't find LibraryPanel for current eAlertName: " $ eAlertName);
		return;
	}
	
	BuildChosenSplashAlert(
		strTemplarAmbushHeader,																								// header
		strTemplarAmbushStr1,																								// chosen type line
		strTemplarAmbushStr2,																								// chosen name line
		strTemplarAmbushStr3,																								// chosen nick line
		class'UIUtilities_Text'.static.GetColoredText(strTemplarAmbushDescription, eUIState_Header),						// body of the message
		m_strChosenAmbushImage,																								// the picture
		strTemplarAmbushBegin,																								// confirm string
		"");																												// cancel string

	BuildChosenIcon(FactionState.GetFactionIcon());
}

simulated function BuildTemplarQuestlineAdvancedAlert() {
	// Send over to flash
	LibraryPanel.MC.BeginFunctionOp("UpdateData");
	LibraryPanel.MC.QueueString(m_strTemplarQuestlineAdvancedHeader); // Header (ATTENTION)
	LibraryPanel.MC.QueueString(m_strTemplarQuestlineAdvancedTitle); // Title
	LibraryPanel.MC.QueueString(m_strTemplarQuestlineAdvancedBody); // Body
	LibraryPanel.MC.QueueString(""); // Button 0
	LibraryPanel.MC.QueueString(m_strOK); // Button 1
	LibraryPanel.MC.EndOp();
	Button2.SetGamepadIcon(class'UIUtilities_Input'.static.GetAdvanceButtonIcon());

	Button1.Hide(); 
	Button1.DisableNavigation();
}

simulated function BuildTemplarQuestlineCompleteAlert() {
	// Send over to flash
	LibraryPanel.MC.BeginFunctionOp("UpdateData");
	LibraryPanel.MC.QueueString(m_strTemplarQuestlineCompleteHeader); // Header (ATTENTION)
	LibraryPanel.MC.QueueString(m_strTemplarQuestlineCompleteTitle); // Title
	LibraryPanel.MC.QueueString(m_strTemplarQuestlineCompleteBody); // Body
	LibraryPanel.MC.QueueString(""); // Button 0
	LibraryPanel.MC.QueueString(m_strOK); // Button 1
	LibraryPanel.MC.EndOp();
	Button2.SetGamepadIcon(class'UIUtilities_Input'.static.GetAdvanceButtonIcon());

	Button1.Hide(); 
	Button1.DisableNavigation();
}

simulated function BuildHighCovenAssaultAvailableAlert() {
	local XComGameStateHistory History;
	local XGParamTag ParamTag;
	local XComGameState_PointOfInterest POIState;
	local TAlertPOIAvailableInfo kInfo;

	History = `XCOMHISTORY;
	POIState = XComGameState_PointOfInterest(History.GetGameStateForObjectID(
		class'X2StrategyGameRulesetDataStructures'.static.GetDynamicIntProperty(DisplayPropertySet, 'POIRef')));

	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.StrValue0 = POIState.GetResistanceRegionName();

	kInfo.zoomLocation = POIState.Get2DLocation();
	kInfo.strTitle = m_strPOITitle; // Unused
	kInfo.strLabel = m_strPOILabel; // Unused
	kInfo.strBody = m_strHighCovenAssaultAvailableBody;
	kInfo.strImage = m_strHighCovenAssaultAvailableImage;
	kInfo.strReport = POIState.GetDisplayName();
	kInfo.strReward = POIState.GetRewardDescriptionString();
	kInfo.strRewardIcon = POIState.GetRewardIconString();
	kInfo.strDurationLabel = m_strPOIDuration;
	kInfo.strDuration = class'UIUtilities_Text'.static.GetTimeRemainingString(POIState.GetNumScanHoursRemaining());
	kInfo.strInvestigate = m_strPOIInvestigate;
	kInfo.strIgnore = m_strNotNow;
	kInfo.strFlare = m_strPOIFlare; // Unused
	kInfo.strUIIcon = POIState.GetUIButtonIcon();
	kInfo.eColor = eUIState_Normal;
	kInfo.clrAlert = MakeLinearColor(0.75f, 0.75f, 0, 1);

	BuildPointOfInterestAvailableAlert(kInfo);
}

simulated function BuildTestingAlert()
{
	BuildPanel();
}

simulated function BuildPanel() {
	local UIBGBox LibraryBackgroundColor;
	local UIBGBox LibraryBackground;
	

	LibraryPanel = Spawn(class'UIPanel', self);
	LibraryPanel.bAnimateOnInit = false;
	LibraryPanel.InitPanel('TemplarAmbushAlertContainer');
	LibraryPanel.Width = Width;
	LibraryPanel.Height = Height;
	LibraryPanel.SetPosition((Movie.UI_RES_X - LibraryPanel.Width) / 2, (Movie.UI_RES_Y - LibraryPanel.Height) / 2);

	// Black
	LibraryBackgroundColor = Spawn(class'UIBGBox', LibraryPanel);
	LibraryBackgroundColor.InitBG('', 0, 0, LibraryPanel.Width, LibraryPanel.Height);

	LibraryBackground = Spawn(class'UIBGBox', LibraryPanel);
	LibraryBackground.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	LibraryBackground.InitBG('theBG', 0, 0, LibraryPanel.Width, LibraryPanel.Height);

	if( `ISCONTROLLERACTIVE)
	{
		LibraryPanel.DisableNavigation();
	}
	else
	{
		LibraryPanel.SetSelectedNavigation();
		LibraryPanel.bCascadeSelection = true;
	}

	ButtonGroup = Spawn(class'UIPanel', LibraryPanel);
	ButtonGroup.bAnimateOnInit = false;
	ButtonGroup.bCascadeFocus = false;
	ButtonGroup.InitPanel('ButtonGroup', '');
	if( `ISCONTROLLERACTIVE)
	{
		ButtonGroup.DisableNavigation();
	}
	else
	{
		ButtonGroup.SetSelectedNavigation();
		ButtonGroup.bCascadeSelection = true;
		ButtonGroup.Navigator.LoopSelection = true; 
	}

	Button1 = Spawn(class'UIButton', ButtonGroup);
	if( `ISCONTROLLERACTIVE)
	{
		Button1.InitButton('Button0', "", OnConfirmClicked, eUIButtonStyle_HOTLINK_WHEN_SANS_MOUSE);
	}
	else
	{
		Button1.InitButton('Button0', "", OnConfirmClicked);
		//Button1.SetSelectedNavigation(); //will cause the button to highlight on initial open of the screen. 
	}

	Button1.bAnimateOnInit = false;

	if( `ISCONTROLLERACTIVE)
	{
		Button1.SetGamepadIcon(class'UIUtilities_Input'.static.GetAdvanceButtonIcon());
		Button1.OnSizeRealized = OnButtonSizeRealized;
		Button1.SetX(-150.0 / 2.0);
		Button1.SetY(-Button1.Height / 2.0);
		//Button1.DisableNavigation();
	}
	else
	{
		Button1.SetResizeToText(false);
	}

	Button2 = Spawn(class'UIButton', ButtonGroup);
	if( `ISCONTROLLERACTIVE)
	   Button2.InitButton('Button1', "", OnCancelClicked, eUIButtonStyle_HOTLINK_WHEN_SANS_MOUSE);
	else
		Button2.InitButton('Button1', "", OnCancelClicked, );

	Button2.bAnimateOnInit = false;

	if( `ISCONTROLLERACTIVE)
	{
		Button2.SetGamepadIcon(class'UIUtilities_Input'.static.GetBackButtonIcon());
		Button2.OnSizeRealized = OnButtonSizeRealized;
		Button2.SetX(-150.0 / 2.0);
		Button2.SetY(Button2.Height / 2.0);
		//Button2.DisableNavigation();
	}
	else
	{
		Button2.SetResizeToText(false);
	}
	//TODO: bsteiner: remove this when the strategy map handles it's own visibility
	if( `HQPRES.StrategyMap2D != none )
		`HQPRES.StrategyMap2D.Hide();
}