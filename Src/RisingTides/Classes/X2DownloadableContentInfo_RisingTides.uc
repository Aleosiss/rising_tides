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
var config int MajorVer;
var config int MinorVer;
var config int PatchVer;

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
		`RTLOG("This is not a final release!");
	`endif

	`RTLOG("Script package loaded.");

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

	Program = class'RTHelpers'.static.GetProgramState();
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