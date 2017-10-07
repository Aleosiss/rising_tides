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

var bool bDebugOutputDisabled;

defaultproperties
{
	bDebugOutputDisabled = false;
}

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
	ModifyInitialFactionState(StartState);
}


static event OnPostTemplatesCreated()
{
	MakePsiAbilitiesInterruptable();
	AddProgramFactionCovertActions();
}

simulated static function ModifyInitialFactionState(XComGameState StartState) {
	local RTGameState_ProgramFaction Faction;

	foreach StartState.IterateByClassType(class'RTGameState_ProgramFaction', Faction) {
		if(Faction.GetMyTemplateName() == 'Faction_Program') { break; }
	}

	if(Faction == none) {
		class'RTHelpers'.static.RTLog("Could not find an ProgramFactionState in the start state!", true);
		return;
	}

	Faction = RTGameState_ProgramFaction(StartState.ModifyStateObject(class'RTGameState_ProgramFaction', Faction.ObjectID));
	Faction.ModifyGoldenPathActions(StartState);
}

exec function PrintResistanceFactionNames() {
	local XComGameStateHistory 					History;
	local XComGameState_ResistanceFaction 		Faction;
	local object 								obj;

	if(!DebuggingEnabled()) {
		return;
	}

	History = `XCOMHISTORY;

	`LOG("Rising Tides: printing faction names...");
	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', Faction) {
		//Faction = XComGameState_ResistanceFaction(obj);
		if(Faction != none) {
			`LOG(Faction.GetMyTemplateName());
		}
	}
}

exec function PrintProgramFactionInformation() {
	local XComGameStateHistory 				History;
	local RTGameState_ProgramFaction 		Faction;
	local StateObjectReference 				StateObjRef;
	local XComGameState_CovertAction 		CovertActionState;
	local X2CovertActionTemplate			CovertActionTemplate;

	History = `XCOMHISTORY;
	class'RTHelpers'.static.RTLog("Gathering Debug Information for the Program...");
	Faction = class'RTHelpers'.static.GetProgramState();

	class'RTHelpers'.static.RTLog("Printing Golden Path covert actions for the Program...");
	foreach Faction.GoldenPathActions(StateObjRef) {
		CovertActionState = XComGameState_CovertAction(History.GetGameStateForObjectID(StateObjRef.ObjectID));
		if(CovertActionState == none)
			continue;
		CovertActionTemplate = CovertActionState.GetMyTemplate();
		class'RTHelpers'.static.RTLog("" $ CovertActionTemplate.DataName);
	}
	
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


static function bool DebuggingEnabled() {
	return !default.bDebugOutputDisabled;
}
