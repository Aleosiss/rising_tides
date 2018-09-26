//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_RisingTides.uc
//
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the
//  player creates a new campaign or loads a saved game.
//
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_RisingTides extends X2DownloadableContentInfo config(RisingTides);

var bool bDebuggingEnabled;
var config int MajorVer;
var config int MinorVer;
var config int PatchVer;

defaultproperties
{
	bDebuggingEnabled = true;
}

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame() {
	class'RTGameState_ProgramFaction'.static.InitFaction();
}

static event OnLoadedSavedGameToStrategy() {
	class'RTGameState_ProgramFaction'.static.InitFaction();
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState) {
	class'RTGameState_ProgramFaction'.static.InitFaction(StartState);
}


static event OnPostTemplatesCreated()
{
	`if (`notdefined(FINAL_RELEASE)) 
		class'RTHelpers'.static.RTLog("This is not a final release!");
	`endif

	MakePsiAbilitiesInterruptable();
	AddProgramFactionCovertActions();
	AddProgramAttachmentTemplates();
}

/// <summary>
/// Called just before the player launches into a tactical a mission while this DLC / Mod is installed.
/// </summary>
static event OnPreMission(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local RTGameState_ProgramFaction ProgramState;
	
	ProgramState = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	ProgramState.PreMissionUpdate(NewGameState, MissionState);
}

/// <summary>
/// Called when the player completes a mission while this DLC / Mod is installed.
/// </summary>
static event OnPostMission()
{

}

/// <summary>
/// Called after the player exits the post-mission sequence while this DLC / Mod is installed.
/// </summary>
static event OnExitPostMissionSequence()
{
	local XComGameState NewGameState;
	local RTGameState_ProgramFaction ProgramState, Program;
	local XComGameState_BattleData BattleData;

	Program = class'RTHelpers'.static.GetProgramState(NewGameState);
	if(Program.bShouldPerformPostMissionCleanup) {
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Cleanup Program Operatives from XCOMHQ!");
		ProgramState = class'RTHelpers'.static.GetNewProgramState(NewGameState);
		ProgramState.PerformPostMissionCleanup(NewGameState);

		`GAMERULES.SubmitGameState(NewGameState);

		BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
		if(BattleData.bLocalPlayerWon) {
			// This method creates and submits two new xcgs's
			ProgramState.TryIncreaseInfluence();
		}
	}
}

/// <summary>
/// Calls DLC specific popup handlers to route messages to correct display functions
/// </summary>
// credit RealityMachina
static function bool DisplayQueuedDynamicPopup(DynamicPropertySet PropertySet)
{
	if (PropertySet.PrimaryRoutingKey == 'UIAlert_ProgramLevelup')
	{
		CallUIFactionPopup(PropertySet);
		return true;
	}

	if(PropertySet.PrimaryRoutingKey == 'UIAlert_OSFFirstTime') {
		class'RTGameState_ProgramFaction'.static.DisplayFirstTimePopup();
		return true;
	}

	return false;
}

static function CallUIFactionPopup(const out DynamicPropertySet PropertySet)
{
	local XComGameState_ResistanceFaction FactionState;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		if (FactionState.GetMyTemplateName() == 'Faction_Program')
		{
				`HQPRES.UIFactionPopup(FactionState, true);	
				break;
		}
	}
}

simulated static funtion AddProgramAttachmentTemplates() {
	class'RTItem'.static.AddProgramAttachmentTemplates();
}

simulated static function AddProgramFactionCovertActions() {
	class'RTStrategyElement_CovertActions'.static.AddFactionToGeneratedTemplates();
}

simulated static function MakePsiAbilitiesInterruptable() {
	local array<name> AbilityTemplateNames, PsionicTemplateNames;
	local name AbilityTemplateName;
	local X2AbilityTemplate AbilityTemplate;
	local array<X2AbilityTemplate> AbilityTemplates;
	local X2AbilityTemplateManager AbilityTemplateMgr;
	local int i;

	class'RTHelpers'.static.RTLog("Patching Psionic Abilities...");
	for(i = 0; i < class'RTHelpers'.default.PsionicAbilities.Length; ++i) {
		PsionicTemplateNames.AddItem(class'RTHelpers'.default.PsionicAbilities[i]);
	}

	AbilityTemplateMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityTemplateMgr.GetTemplateNames(AbilityTemplateNames);
	foreach AbilityTemplateNames(AbilityTemplateName) {
		AbilityTemplates.Length = 0;
		if(PsionicTemplateNames.Find(AbilityTemplateName) == INDEX_NONE) {
				continue;
		}

		AbilityTemplateMgr.FindAbilityTemplateAllDifficulties(AbilityTemplateName, AbilityTemplates);
		foreach AbilityTemplates(AbilityTemplate) {
				if(AbilityTemplate.PostActivationEvents.Find(class'RTAbility_GhostAbilitySet'.default.UnitUsedPsionicAbilityEvent) == INDEX_NONE) {
					AbilityTemplate.PostActivationEvents.AddItem(class'RTAbility_GhostAbilitySet'.default.UnitUsedPsionicAbilityEvent);
				}

				if(AbilityTemplate.BuildInterruptGameStateFn == none) {
					AbilityTemplate.BuildInterruptGameStateFn = class'X2Ability'.static.TypicalAbility_BuildInterruptGameState;
				}
		}
	}
}

static function bool DebuggingEnabled() {
	return default.bDebuggingEnabled;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---BEGIN COMMANDS----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

exec function RT_PrintResistanceFactionNames() {
	local XComGameStateHistory 					History;
	local XComGameState_ResistanceFaction 		Faction;
	local object 								obj;

	if(!DebuggingEnabled()) {
		return;
	}

	History = `XCOMHISTORY;

	class'RTHelpers'.static.RTLog("printing faction names...", false);
	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', Faction) {
		if(Faction != none) {
			`LOG(Faction.GetMyTemplateName());
		}
	}
}

exec function RT_PrintProgramFactionInformation(optional bool bShouldPrintFullInfo = false, optional bool bShouldPrintAllFields = false) {
	local XComGameStateHistory 				History;
	local RTGameState_ProgramFaction 		Faction;

	History = `XCOMHISTORY;

	class'RTHelpers'.static.RTLog("Gathering Debug Information for the Program...");
	Faction = class'RTHelpers'.static.GetProgramState();

	if(bShouldPrintFullInfo) {
		class'RTHelpers'.static.RTLog(Faction.ToString(bShouldPrintAllFields), , true);
		return;
	}

	class'RTHelpers'.static.RTLog("Printing Golden Path covert actions for the Program...");
	class'RTHelpers'.static.PrintGoldenPathActionsForFaction(Faction);

	class'RTHelpers'.static.RTLog("Printing Standard covert actions for the Program...");
	class'RTHelpers'.static.PrintCovertActionsForFaction(Faction);

	class'RTHelpers'.static.RTLog("Printing Rival Chosen for the Program...");
	class'RTHelpers'.static.RTLog("" $ XComGameState_AdventChosen(History.GetGameStateForObjectID(Faction.RivalChosen.ObjectID)).GetChosenClassName());

	class'RTHelpers'.static.RTLog("Printing Misc Information for the Program...");
	class'RTHelpers'.static.PrintMiscInfoForFaction(Faction);


}

exec function RT_TriggerEvent(name EventID) {
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: RT_TriggerEvent" $ EventID);

	`XEVENTMGR.TriggerEvent(EventID, none, none, NewGameState);

	if (NewGameState.GetNumGameStateObjects() > 0) {
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	} else
		`XCOMHISTORY.CleanupPendingGameState(NewGameState);
}

exec function RT_DebugModVersion() {
	class'RTHelpers'.static.RTLog("Mod Version is: " $ default.MajorVer $ "." $ default.MinorVer $ "." $ default.PatchVer);
}

exec function RT_ToggleCustomDebugOutput() {
    class'UIDebugStateMachines'.static.GetThisScreen().ToggleVisible();
}

exec function RT_PrintPerkContentsForXCom() {
    class'UIDebugStateMachines'.static.PrintOutPerkContentsForXComUnits();
}

exec function RT_PrintLoadedPerkContents() {
    class'UIDebugStateMachines'.static.PrintOutLoadedPerkContents();
}

exec function RT_TryForceAppendAbilityPerks(name AbilityName) {
	class'UIDebugStateMachines'.static.TryForceAppendAbilityPerks(AbilityName);
}

exec function RT_TryForceCachePerkContent(name AbilityName) {
	class'UIDebugStateMachines'.static.TryForceCachePerkContent(AbilityName);
}

exec function RT_TryForceBuildPerkContentCache() {
	class'UIDebugStateMachines'.static.TryForceBuildPerkContentCache();
}

exec function RT_ForceLoadPerkOnToUnit(name AbilityName) {
	class'UIDebugStateMachines'.static.TryForceBuildPerkContentCache();
	class'UIDebugStateMachines'.static.TryForceCachePerkContent(AbilityName);
	class'UIDebugStateMachines'.static.TryForceAppendAbilityPerks(AbilityName);
}

exec function RT_PrintAppearence(int ObjectID) {
	local XComGameState_Unit UnitState;
	local TAppearance a;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ObjectID));
	if(UnitState == none) {
		class'RTHelpers'.static.RTLog("UnitState was null for PrintAppearance!");
		return;
	}	

	a = UnitState.kAppearance;
	`LOG(a.nmHead);
	`LOG(a.iGender);
	`LOG(a.iRace);
	`LOG(a.nmHaircut);
	`LOG(a.iHairColor);
	`LOG(a.iFacialHair);
	`LOG(a.nmBeard);
	`LOG(a.iSkinColor);
	`LOG(a.iEyeColor);
	`LOG(a.nmFlag);
	`LOG(a.iVoice);
	`LOG(a.iAttitude);
	`LOG(a.iArmorDeco);
	`LOG(a.iArmorTint);
	`LOG(a.iArmorTintSecondary);
	`LOG(a.iWeaponTint);
	`LOG(a.iTattooTint);
	`LOG(a.nmWeaponPattern);
	`LOG(a.nmPawn);
	`LOG(a.nmTorso);
	`LOG(a.nmArms);
	`LOG(a.nmLegs);
	`LOG(a.nmHelmet);
	`LOG(a.nmEye);
	`LOG(a.nmTeeth);
	`LOG(a.nmFacePropLower);
	`LOG(a.nmFacePropUpper);
	`LOG(a.nmPatterns);
	`LOG(a.nmVoice);
	`LOG(a.nmLanguage);
	`LOG(a.nmTattoo_LeftArm);
	`LOG(a.nmTattoo_RightArm);
	`LOG(a.nmScars);
	`LOG(a.nmTorso_Underlay);
	`LOG(a.nmArms_Underlay);
	`LOG(a.nmLegs_Underlay);
	`LOG(a.nmFacePaint);
	`LOG(a.nmLeftArm);
	`LOG(a.nmRightArm);
	`LOG(a.nmLeftArmDeco);
	`LOG(a.nmRightArmDeco);
	`LOG(a.nmLeftForearm);
	`LOG(a.nmRightForearm);
	`LOG(a.nmThighs);
	`LOG(a.nmShins);
	`LOG(a.nmTorsoDeco);
	`LOG(a.bGhostPawn);
}

exec function RT_ActivateOneSmallFavor() {
	local RTGameState_ProgramFaction	ProgramState;
	local XComGameState					NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Force One Small Favor!");
	ProgramState = class'RTHelpers'.static.GetNewProgramState(NewGameState);

	ProgramState.MakeOneSmallFavorAvailable();
	
	`GAMERULES.SubmitGameState(NewGameState);
}

exec function RT_GenerateProgramCards() {
	local RTGameState_ProgramFaction	ProgramState;
	local XComGameState					NewGameState;
	local int							idx;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Add Program Faction Cards!");
	ProgramState = class'RTHelpers'.static.GetNewProgramState(NewGameState);

	for(idx = 0; idx < 7; idx++)
	{
		ProgramState.GenerateNewPlayableCard(NewGameState);
	}

	`GAMERULES.SubmitGameState(NewGameState);
}

exec function RT_DebugActiveOperatives() {
	local RTGameState_ProgramFaction		ProgramState;
	local StateObjectReference				IteratorRef;
	local XComGameStateHistory				History;
	local XComGameState_Unit				UnitState;

	ProgramState = class'RTHelpers'.static.GetProgramState();
	History = `XCOMHISTORY;
	
	class'RTHelpers'.static.RTLog("Printing Active Operatives...");
	foreach ProgramState.Active(IteratorRef) {
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(IteratorRef.ObjectID));
		class'RTHelpers'.static.RTLog( "Found Ghost Operative " $ UnitState.GetFullName() $ 
								", with ObjectID " $ UnitState.GetReference().ObjectID $
								", and CharacterTemplateName " $ UnitState.GetMyTemplateName()
							);
	}

}

exec function RT_AddProgramOperativeToXCOMCrew() {
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Unit UnitState;
	local bool bFoundAtLeastOne;

	History = `XCOMHISTORY;
	bFoundAtLeastOne = false;
	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if(UnitState.GetMyTemplateName() == 'RTGhostMarksman' || UnitState.GetMyTemplateName() == 'RTGhostBerserker' || UnitState.GetMyTemplateName() == 'RTGhostGatherer')
		{
			`LOG("Rising Tides: Found a " $ UnitState.GetMyTemplateName() $ ", adding them to XCOM!");
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: CHEAT: AddSPECTREToCrew");
			UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
			XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
			XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
			XComHQ.AddToCrew(NewGameState, UnitState);
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
			bFoundAtLeastOne = true;
		}
	}

	if(!bFoundAtLeastOne)
		`LOG("Rising Tides: Did not find any active operatives!");
}

exec function RT_PrintCrew()
{
	local XComGameState_HeadquartersXCom XComHQ;
	local int idx;
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local string CrewString;

	History = `XCOMHISTORY;
	
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	`LOG("Logging XCOM Crew...");
	CrewString = "\nXCom Crew";

	for(idx = 0; idx < XComHQ.Crew.Length; idx++)
	{
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(XComHQ.Crew[idx].ObjectID));

		if(UnitState != none)
		{
			CrewString $= "\n" $ UnitState.GetName(eNameType_Full) @ "ObjectID:" @ UnitState.ObjectID;
		}
	}

	`LOG(CrewString);
}

// Courtesy of bountygiver
exec function TestPanel(int X, int Y, optional int Width = -1, optional int Height = -1, optional name PanelName = 'TestDebugPanel')
{
	local UIScreen Screen;
	local UIBGBox BGPanel;
	local UIPanel Panel;

	Screen = `SCREENSTACK.GetCurrentScreen();

	Panel = Screen.GetChildByName(PanelName, false);
	if(Width == -1 || Height == -1) {
		Width = 32;
		Height = 32;
	}

	if (Panel != none)
	{
		Panel.SetPosition(X, Y);
		Panel.SetSize(Width, Height);
	}
	else
	{
		BGPanel = Screen.Spawn(class'UIBGBox', Screen);
		BGPanel.InitBG(PanelName, X, Y, Width, Height);
		BGPanel.SetBGColor("FF0000");
		BGPanel.AnimateIn(0);
	}
}

exec function DestroyTestPanel(optional name PanelName = 'TestDebugPanel') {
	local UIScreen Screen;
	local UIBGBox BGPanel;

	Screen = `SCREENSTACK.GetCurrentScreen();

	BGPanel = UIBGBox(Screen.GetChildByName(PanelName, false));
	BGPanel.Remove();
}

exec function ReportTestPanelLocation(optional name PanelName = 'TestDebugPanel') {
	local UIScreen Screen;
	local UIPanel TestPanel;
	local string MissionType, LogOutput;
	local float PosX, PosY;
	local StateObjectReference MissionRef;

	Screen = `SCREENSTACK.GetCurrentScreen();

	TestPanel = Screen.GetChildByName(PanelName, false);
	PosX = TestPanel.MC.GetNum("_x");
	PosY = TestPanel.MC.GetNum("_y");

	if(UIMission(Screen) != none) {
		MissionType = string(UIMission(Screen).GetMission().GetMissionSource().DataName);
		LogOutput = ("" $ PanelName $ " located at (" $ PosX $ ", " $ PosY $ ") for MissionType " $ MissionType);
		class'RTHelpers'.static.RTLog(LogOutput);

	} else {
		LogOutput = ("" $ PanelName $ " located at (" $ PosX $ ", " $ PosY $ ")");
		class'RTHelpers'.static.RTLog(LogOutput);

	}
}

exec function RT_DebugVisibilityAll() {	
	local XComGameState_Unit ItUnit;
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', ItUnit)
	{
		class'RTHelpers'.static.RTLog("" $ ItUnit.GetFullName());
		class'RTCondition_VisibleToPlayer'.static.IsTargetVisibleToLocalPlayer(ItUnit.GetReference(), , true);
	}
}

exec function RT_ForceVisibilityUpdatesAll() {
	local XComGameState_Unit ItUnit;
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState( "Cheat: Refresh Unit visualizers" );
	XComGameStateContext_ChangeContainer( NewGameState.GetContext() ).BuildVisualizationFn = ForceVisibilityUpdatesAll_BuildVisualization;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', ItUnit)
	{
		ItUnit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', ItUnit.ObjectID));
		ItUnit.bRequiresVisibilityUpdate = true;
	}

	`TACTICALRULES.SubmitGameState(NewGameState);

}

static function ForceVisibilityUpdatesAll_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameState_Unit UnitState;
	local VisualizationActionMetadata BuildTrack;
	local X2Action_UpdateFOW FOWAction;
	local RTAction_ForceVisibility RTForceVisibilityAction_Reset;

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		BuildTrack.StateObject_NewState = UnitState;
		BuildTrack.StateObject_OldState = UnitState;
		
		//RTForceVisibilityAction_Reset = RTAction_ForceVisibility(class'RTAction_ForceVisibility'.static.AddToVisualizationTree(BuildTrack, VisualizeGameState.GetContext()));
		//RTForceVisibilityAction_Reset.bResetVisibility = true;

		class'X2Action_SyncVisualizer'.static.AddToVisualizationTree(BuildTrack, VisualizeGameState.GetContext());

		FOWAction = X2Action_UpdateFOW( class'X2Action_UpdateFOW'.static.AddToVisualizationTree( BuildTrack, VisualizeGameState.GetContext()) );
		FOWAction.ForceUpdate = true;
	}
}

exec function RT_TestUIPopup() {
	local string Title; 
	local string alertText;

	Title = "ALERT: One Small Favor";
	alertText = "The Program fields small squads of elite operatives. As a result of their alliance with XCOM, you may ask them to run a mission for you.\n NOTE: that this favor can only be called in once per month. \n \nCall in One Small Favor by toggling the white checkbox now shown on Mission Launch screens.";

	`PRESBASE.UITutorialBox(Title, alertText, "img:///RisingTidesContentPackage.UIImages.osf_tutorial");
}

exec function RT_ReduceSoldierCurrentWill(int MinusWill) {
	local XComTacticalController TacticalController;
	local XGUnit ActiveUnit;
	local XComGameState_Unit ActiveUnitState;
	local XComGameState NewGameState;
	// Pawn is the CURSOR in the Combat game
	TacticalController = XComTacticalController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController());

	if (TacticalController != none) {
		ActiveUnit = TacticalController.GetActiveUnit();
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState( "Cheat: Reduce Unit Will" );
		ActiveUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', ActiveUnit.ObjectID));
		ActiveUnitState.ModifyCurrentStat(eStat_Will, float(MinusWill));
		`TACTICALRULES.SubmitGameState(NewGameState);
	}
}

exec function RT_GetVisibilityStatusOfClosestUnitToCursor() {
	local XComGameState_Unit UnitState;
	local EForceVisibilitySetting ForceVisibleSetting;
	local XComTacticalCheatManager CheatsManager;

	CheatsManager = `CHEATMGR;

	UnitState = CheatsManager.GetClosestUnitToCursor();
	ForceVisibleSetting = UnitState.ForceModelVisible();
	class'RTHelpers'.static.RTLog(UnitState.GetFullName());
	class'RTHelpers'.static.RTLog("" $ ForceVisibleSetting);
}

exec function RT_ListAllSquadViewers(optional bool bDetailedInfo = false) {
	local XComGameState_SquadViewer XComSquadViewerState;
	local RTGameState_SquadViewer RTSquadViewerState;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_SquadViewer', XComSquadViewerState) {
		class'RTHelpers'.static.RTLOG("" $ "Found a SquadViewer: " $ XComSquadViewerState.ToString(bDetailedInfo), , true);
	}
}

exec function RT_ClearLog() {
	local int i;
	for(i = 0; i<50; i++) {
		class'RTHelpers'.static.RTLog(" ", false, true);
	}
}