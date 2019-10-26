class RTUIStrategyMapItem_ProgramHQ extends UIStrategyMapItem_ResistanceHQ;

var localized String m_strProgramFactionButton;

simulated function UIStrategyMapItem InitMapItem(out XComGameState_GeoscapeEntity Entity)
{
	// Spawn the children BEFORE the super.Init because inside that super, it will trigger UpdateFlyoverText and other functions
	// which may assume these children already exist. 
		
	super(UIStrategyMapItem).InitMapItem(Entity);

	`RTLOG("Creating Program MapItem");

	ScanButton = Spawn(class'UIScanButton', self).InitScanButton();
	ScanButton.SetX(-30); //This location is to stop overlapping the 3D art.
	ScanButton.SetY(35);
	ScanButton.SetButtonIcon(class'UIUtilities_Image'.const.MissionIcon_Resistance);
	ScanButton.SetDefaultDelegate(OnDefaultClicked);
	ScanButton.SetFactionDelegate(OnButtonClicked);
	ScanButton.SetFactionTooltip(m_strProgramFactionButton);
	ScanButton.SetButtonType(eUIScanButtonType_ResHQ);
	//ScanButton.SetButtonType(eUIScanButtonType_Default);
	ScanButton.ShowScanIcon(true);
	ScanButton.MC.FunctionVoid("SetScanHintDefaultSelection" );
	ScanButton.OnSizeRealized = OnButtonSizeRealized;
	GenerateTooltip(MapPin_Tooltip);
	
	return self;
}

function UpdateFromGeoscapeEntity(const out XComGameState_GeoscapeEntity GeoscapeEntity)
{
	local string ScanTitle;
	local string ScanTimeValue;
	local string ScanTimeLabel;
	local string ScanInfo;
	local bool bAvengerLandedHere; 

	if( !bIsInited ) return; 

	//`RTLOG("MapItem_ProgramHQ UpdateFromGeoscapeEntity");

	super(UIStrategyMapItem).UpdateFromGeoscapeEntity(GeoscapeEntity);

	ScanTitle = GetHavenTitle();
	ScanTimeValue = "";
	ScanTimeLabel = "";
	ScanInfo = GetHavenScanDescription();
	
	bAvengerLandedHere = IsAvengerLandedHere();

	if( bAvengerLandedHere )
		ScanButton.Expand();
	else
	{
		ScanButton.DefaultState();
	}

	ScanButton.SetButtonIcon(class'UIUtilities_Image'.const.MissionIcon_Resistance);
	ScanButton.PulseFaction(false);
	ScanButton.SetText(ScanTitle, ScanInfo, ScanTimeValue, ScanTimeLabel);
	ScanButton.SetFactionDelegate(OnButtonClicked);
	ScanButton.SetFactionTooltip(m_strProgramFactionButton);
	ScanButton.AnimateIcon(`GAME.GetGeoscape().IsScanning() && IsAvengerLandedHere());
	ScanButton.Realize();
	if (bNeedsUpdate)
	{
		ScanButton.bExpandOnRealize = true;
		ScanButton.bDirty = true;
		ScanButton.Realize();
		if ( bAvengerLandedHere && bIsFocused) //bsg-jneal (8.31.16): only receive focus on the scan button if this map item is focused, fixes an incorrect focus state on init
		{
			ScanButton.OnReceiveFocus();
		}

		bNeedsUpdate = false;
	}

	CachedTooltipId = ScannerTooltipId;
	
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