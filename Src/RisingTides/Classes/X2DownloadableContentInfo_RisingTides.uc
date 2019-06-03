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

var config bool bDebuggingEnabled;
var int MajorVer;
var int MinorVer;
var int PatchVer;
var config bool bShouldRemoveHelmets;
var config array<name> TemplarUnitNames;

// weak ref to the screen (I just copied this from RJ and don't know if it's really necessary)
var config String screen_path;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame() {
	class'RTGameState_ProgramFaction'.static.InitFaction();
}

static event OnLoadedSavedGameToStrategy() {
	HandleModUpdate();
}

private static function HandleModUpdate() {
	local RTGameState_ProgramFaction ProgramState;
	local XComGameState NewGameState;

	ProgramState = `RTS.GetProgramState();
	if(ProgramState == none) {
		return;
	}
	
	if(!ProgramState.CompareVersion(GetVersionInt(), true)) {
		return;
	}
	`RTLOG("New version of the mod found: \nOld Version: " $ ProgramState.GetCurrentVersion() $ "\nNew Version: " $ GetVersionInt());
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Mod version updated, sending popup!");
	ProgramState = `RTS.GetNewProgramState(NewGameState);
	ProgramState.CompareVersion(GetVersionInt());

	`GAMERULES.SubmitGameState(NewGameState);
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
		`RTLOG("This is not a final release!");
	`endif

	`RTLOG("Script package loaded.");

	MakePsiAbilitiesInterruptable();
	MakeAbilitiesNotTurnEndingForTimeStandsStill();
	AddProgramFactionCovertActions();
	AddProgramAttachmentTemplates();
	
}

static function MakeAbilitiesNotTurnEndingForTimeStandsStill() {
	class'RTAbility_MarksmanAbilitySet'.static.MakeAbilitiesNotTurnEndingForTimeStandsStill();
}

/// <summary>
/// Called just before the player launches into a tactical a mission while this DLC / Mod is installed.
/// </summary>
static event OnPreMission(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local RTGameState_ProgramFaction ProgramState;
	
	ProgramState = `RTS.GetNewProgramState(NewGameState);
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
	local RTGameState_ProgramFaction NewProgramState, ProgramState;
	local bool bShouldTryToIncreaseInfluence;
	//local XComGameState_BattleData BattleData;

	ProgramState = `RTS.GetProgramState();
	bShouldTryToIncreaseInfluence = ProgramState.isOneSmallFavorActivated();
	if(ProgramState.bShouldPerformPostMissionCleanup) {
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Cleanup Program Operatives from XCOMHQ!");
		NewProgramState = `RTS.GetNewProgramState(NewGameState);
		NewProgramState.PerformPostMissionCleanup(NewGameState);

		`GAMERULES.SubmitGameState(NewGameState);

		// Might be useful later, but for now disabled because losing one mission would make it impossible to gain more favors
		/*
		BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
		if(BattleData.bLocalPlayerWon) {
			// This method creates and submits two new xcgs's
			ProgramState.TryIncreaseInfluence();
		}
		*/

		// Try to increase influence
		if(bShouldTryToIncreaseInfluence) {
			NewProgramState.TryIncreaseInfluence();
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
		class'RTGameState_ProgramFaction'.static.DisplayOSFFirstTimePopup();
		return true;
	}

	if(PropertySet.PrimaryRoutingKey == 'UIAlert_PISFirstTime') {
		class'RTGameState_ProgramFaction'.static.DisplayPISFirstTimePopup();
		return true;
	}

	if(PropertySet.PrimaryRoutingKey == 'RTUIAlert') {
		CallAlert(PropertySet);
		return true;
	}

	return false;
}

static function CallAlert(const out DynamicPropertySet PropertySet)
{
	local RTUIAlert Alert;

	Alert = `HQPRES.Spawn(class'RTUIAlert', `HQPRES);
	Alert.DisplayPropertySet = PropertySet;
	Alert.eAlertName = PropertySet.SecondaryRoutingKey;

	`SCREENSTACK.Push(Alert);
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

simulated static function AddProgramAttachmentTemplates() {
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

	`RTLOG("Patching Psionic Abilities...");
	for(i = 0; i < `RTD.PsionicAbilities.Length; ++i) {
		PsionicTemplateNames.AddItem(`RTD.PsionicAbilities[i]);
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
				if(AbilityTemplate.PostActivationEvents.Find(class'RTAbility'.default.UnitUsedPsionicAbilityEvent) == INDEX_NONE) {
					AbilityTemplate.PostActivationEvents.AddItem(class'RTAbility'.default.UnitUsedPsionicAbilityEvent);
				}

				if(AbilityTemplate.BuildInterruptGameStateFn == none) {
					AbilityTemplate.BuildInterruptGameStateFn = class'X2Ability'.static.TypicalAbility_BuildInterruptGameState;
					if(AbilityTemplate.bSkipMoveStop) {
						AbilityTemplate.BuildInterruptGameStateFn = class'X2Ability'.static.TypicalMoveEndAbility_BuildInterruptGameState;
					}
				}
		}
	}
}

/// <summary>
/// Called from XComGameState_Unit:GatherUnitAbilitiesForInit after the game has built what it believes is the full list of
/// abilities for the unit based on character, class, equipment, et cetera. You can add or remove abilities in SetupData.
/// </summary>
static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	/*local AbilitySetupData IteratorData;

	if(default.TemplarUnitNames.Find(UnitState.GetMyTemplateName()) != INDEX_NONE)
	{
		`RTLOG("Initializing a Templar, printing their AbiltySetupData for debugging!");
		foreach SetupData(IteratorData) {
			`RTLOG("" $ IteratorData.TemplateName);
		}
	}*/
}

static function bool DebuggingEnabled() {
	return default.bDebuggingEnabled;
}

static function string GetDLCIdentifier() {
	return default.DLCIdentifier;
}

static function String GetVersionString() {
	local string s;
	
	s = string(default.MajorVer) $ "." $ string(default.MinorVer) $ "." $ string(default.PatchVer);

	return s;
}

static function int GetVersionInt() {
	return (default.MajorVer * 1000000) + (default.MinorVer * 1000) + (default.PatchVer);
}

static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	local array<Object>				AbilitySetArray;
	local Object					AbilitySetObject;
	local RTAbility					AbilitySet;


	AbilitySetArray = class'XComEngine'.static.GetClassDefaultObjects(class'RTAbility');
	foreach AbilitySetArray(AbilitySetObject)
	{
		AbilitySet = RTAbility(AbilitySetObject);
		if(AbilitySet.static.AbilityTagExpandHandler(InString, OutString)) {
			return true;
		} else {
			continue;
		}
	}

	return false;
}

defaultproperties
{
	MajorVer = 2
	MinorVer = 0
	PatchVer = 12
}