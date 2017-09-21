//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_RisingTides.uc
//
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the
//  player creates a new campaign or loads a saved game.
//
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_RisingTides extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{
	//class'RTGameState_ProgramFaction'.static.SetUpProgramFaction(StartState);
}


static event OnPostTemplatesCreated()
{
	MakePsiAbilitiesInterruptable();
	AddProgramFactionCovertActions();
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

	// first unreserved index
	for(i = 26; i < class'RTHelpers'.default.PsionicAbilities.Length; ++i) {
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
