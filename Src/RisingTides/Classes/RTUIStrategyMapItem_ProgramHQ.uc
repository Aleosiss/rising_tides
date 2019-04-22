class RTUIStrategyMapItem_ProgramHQ extends UIStrategyMapItem_ResistanceHQ;

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