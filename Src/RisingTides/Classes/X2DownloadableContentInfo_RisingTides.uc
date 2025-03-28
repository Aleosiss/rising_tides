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

var RTModVersion Version;
var config bool bShouldRemoveHelmets;
var config array<name> TemplarUnitNames;
var config bool MindWrackKillsRulers;
var config bool HostileTemplarFocusUIEnabled;
var config bool TemplarFocusVisualizationPatchEnabled;
var config bool UseOldOTSGFX;
var config array<name> ProgramTechs;

var config array<name> NewAbilityAvailabilityCodes;
var localized array<String> NewAbilityAvailabilityStrings;

// weak ref to the screen (I just copied this from RJ and don't know if it's really necessary)
var config String screen_path;

var String BuildTimestamp;

var array<int> MutuallyExclusiveProgramOperativeRanks;

var array<name> NEGATED_ENV_DAMAGE_ABILITIES;

defaultproperties
{
	Version=(Major=2, Minor=2, Patch=4)
	BuildTimestamp="1742862051"
	MutuallyExclusiveProgramOperativeRanks=(6,7)
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
	HandleModUpdate();
	if(AddProgramTechs()) {
		ReshowProgramDroneRewardPopup();
	}
}

private static function HandleModUpdate() {
	local RTGameState_ProgramFaction ProgramState;
	local XComGameState NewGameState;

	ProgramState = `RTS.GetProgramState();
	if(ProgramState == none) {
		return;
	}
	
	if(!ProgramState.CompareVersion(GetVersionInt())) {
		return;
	}

	`RTLOG("New version of the mod found: \nOld Version: " $ ProgramState.GetCurrentVersion() $ "\nNew Version: " $ GetVersionInt());
	NewGameState = `CreateChangeState("Mod version updated!");
	ProgramState = `RTS.GetNewProgramState(NewGameState);
	RegenerateProgramIconIfNecessary(ProgramState);
	ProgramState.UpdateVersion(GetVersionInt());

	`GAMERULES.SubmitGameState(NewGameState);
}

private function static RegenerateProgramIconIfNecessary(out RTGameState_ProgramFaction NewProgramState) {
	local StackedUIIconData IconData, EmptyIconData;

	IconData = NewProgramState.GetFactionIcon();
	if(IconData.Images[0] != NewProgramState.GetMyTemplate().FactionIconInformation_Layer0[0]) {
		NewProgramState.FactionIconData = NewProgramState.GetMyTemplate().GenerateFactionIcon();
		return;
	}
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState) {
	class'RTGameState_ProgramFaction'.static.InitFaction(StartState);
}


static event OnPostTemplatesCreated()
{
	`RTLOG("OnPostTemplatesCreated");
	`if (`notdefined(FINAL_RELEASE)) 
		`RTLOG("This is not a final release!");
	`endif

	`RTLOG("Script package loaded. Version: " $ GetVersionString());
	`RTLOG("Build Timestamp: [" $ default.BuildTimestamp $ "]");

	MakeProgramOperativeAbilitiesMutuallyExclusive();
	MakePsiAbilitiesInterruptable();
	MakeAbilitiesNotTurnEndingForTimeStandsStill();
	AddProgramFactionCovertActions();
	AddProgramAttachmentTemplates();
	PatchTemplarCharacterTemplatesForAI();
	UpdateAbilityAvailabilityStrings();
	if(default.TemplarFocusVisualizationPatchEnabled) {
		PatchTemplarFocusVisualization();
	}
	
	//PrintProgramItemUpgradeTemplates();
	//PrintAbilityTemplates();
}

static function MakeProgramOperativeAbilitiesMutuallyExclusive() {
	local X2SoldierClassTemplateManager ClassManager;
	local X2AbilityTemplateManager AbilityManager;
	local X2AbilityTemplate AbilityTemplate;
	local array<X2SoldierClassTemplate> Templates;
	local X2SoldierClassTemplate Template;
	local array<SoldierClassAbilitySlot> Slots;
	local SoldierClassAbilitySlot Slot;
	local array<name> Perks;
	local name Perk, Perk2, NotName;
	local int i;


	ClassManager = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Templates = ClassManager.GetAllSoldierClassTemplates();

	foreach Templates(Template) {
		if(InStr(Template.DataName, "RT_") == INDEX_NONE) {
			continue;
		}

		foreach default.MutuallyExclusiveProgramOperativeRanks(i) {
			Perks.Length = 0;
			Slots = Template.SoldierRanks[i].AbilitySlots;
			foreach Slots(Slot) {
				Perks.AddItem(Slot.AbilityType.AbilityName);
			}

			foreach Perks(Perk) {
				AbilityTemplate = AbilityManager.FindAbilityTemplate(Perk);
				foreach Perks(Perk2) {
					if(Perk == Perk2) {
						continue;
					}
					NotName = `RTS.ConcatName('NOT_', Perk2);
					if(AbilityTemplate.PrerequisiteAbilities.Find(NotName) == INDEX_NONE) {
						//`RTLOG("Making " $ Perk $ " mutually exclusive with " $ Perk2);
						AbilityTemplate.PrerequisiteAbilities.AddItem(NotName);
					} else {
						//`RTLOG(Perk $ " is already mutually exclusive with " $ Perk2);
					}
				}
			}
		}
	}

}

static function PatchTemplarFocusVisualization() {
	class'RTAbility_TemplarAbilitySet'.static.PatchTemplarFocusVisualization();
}

static function PrintProgramItemUpgradeTemplates() {
	local X2WeaponUpgradeTemplate Template;
	local X2ItemTemplateManager ItemMgr;
	local array<X2WeaponUpgradeTemplate> Templates;
	local WeaponAttachment Attachment;

	// ClipSizeUpgrade_Sup
	// CritUpgrade_Sup

	ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Templates = ItemMgr.GetAllUpgradeTemplates();

	foreach Templates(Template) {
		switch(Template.DataName) {
			case 'RTCosmetic_Suppressor':
				`RTLOG("Printing all attachable weapons for cosmetic silencer");
				foreach Template.UpgradeAttachments(Attachment) {
					`RTLOG("" $ Attachment.ApplyToWeaponTemplate);
				}
				`RTLOG("-------------------------------------------------------");
				break;
		}
	}
}

static function PrintAbilityTemplates() {
	local array<name> AbilityTemplateNames;
	local name AbilityTemplateName;
	local X2AbilityTemplateManager AbilityTemplateMgr;

	`RTLOG("PrintAbilityTemplates");
	AbilityTemplateMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityTemplateMgr.GetTemplateNames(AbilityTemplateNames);
	foreach AbilityTemplateNames(AbilityTemplateName) {
		`RTLOG("" $ AbilityTemplateName);
	}
}

static function MakeAbilitiesNotTurnEndingForTimeStandsStill() {
	class'RTAbility_MarksmanAbilitySet'.static.MakeAbilitiesNotTurnEndingForTimeStandsStill();
}

static function PatchTemplarCharacterTemplatesForAI() {
	local X2CharacterTemplateManager	CharMgr;
	local X2CharacterTemplate			CharTemplate;
	local name							CharacterTemplateName;

	CharacterTemplateName = 'TemplarSoldier';

	// Get the Character Template Modify
	CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	// Access a specific Character Template.
	CharTemplate = CharMgr.FindCharacterTemplate(CharacterTemplateName);

	// If template was found
	if (CharTemplate != none) {
		if(CharTemplate.CharacterGroupName != '') {
			`RTLOG("Warning, CharacterGroupName for " $ CharacterTemplateName $ " was not empty, was " $ CharTemplate.CharacterGroupName, true, false);
		}
		CharTemplate.CharacterGroupName = 'RT_TemplarWarrior';

		if(CharTemplate.strBehaviorTree != "") {
			`RTLOG("Warning, strBehaviorTree for " $ CharacterTemplateName $ " was not empty, was " $ CharTemplate.strBehaviorTree, true, false);
		}
		CharTemplate.strBehaviorTree = "RTTemplarWarriorRoot";
	}
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
	//HandleDroneRecovery();
}

/// <summary>
/// Called after the player exits the post-mission sequence while this DLC / Mod is installed.
/// </summary>
static event OnExitPostMissionSequence()
{
	local XComGameState NewGameState;
	local RTGameState_ProgramFaction NewProgramState, ProgramState;
	local XComGameState_BattleData BattleData;
	local XComGameState_MissionSite MissionState;
	local XComGameStateHistory History;

	ProgramState = `RTS.GetProgramState();
	if(ProgramState.bShouldPerformPostMissionCleanup) {
		`RTLOG("Performing post-mission cleanup!");
		History = `XCOMHISTORY;
		BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
		MissionState = XComGameState_MissionSite(History.GetGameStateForObjectID(BattleData.m_iMissionID));

		NewGameState = `CreateChangeState("Cleanup Program Operatives from XCOMHQ!");
		NewProgramState = `RTS.GetNewProgramState(NewGameState);
		NewProgramState.PerformPostMissionCleanup(NewGameState, MissionState.GetReference());

		`GAMERULES.SubmitGameState(NewGameState);

		// Try to increase influence
		if(class'RTGameState_ProgramFaction'.static.IsOSFMission(MissionState)) {
			//`RTLOG("This was an OSF mission, trying to increase influence");
			// this method creates and submits NewGameStates, so we don't need to submit again
			NewProgramState.TryIncreaseInfluence();
		} else {
			//`RTLOG("This was NOT an OSF mission, not trying to increase influence");
		}
	} else {
		//`RTLOG("No need to perform post-mission cleanup.");
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

	//`RTLOG("Patching Psionic Abilities...");
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
	PrepTemplarUnitForBetrayal(UnitState, SetupData, StartState, PlayerState);
}


private static function PrepTemplarUnitForBetrayal(
	XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState) 
{
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local name AbilityName;
	local AbilitySetupData Data, EmptyData;
	local X2CharacterTemplate CharTemplate;

	if(UnitState.GetMyTemplateName() != 'TemplarSoldier') {
		return;
	}

	if(`TACTICALMISSIONMGR.ActiveMission.MissionName != 'RT_TemplarHighCovenAssault') {
		return;
	}
	
	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	foreach class'X2Ability_AlertMechanics'.default.AlertAbilitySet(AbilityName) {
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityName);
		if( AbilityTemplate != none 
			&&	(!AbilityTemplate.bUniqueSource || SetupData.Find('TemplateName', AbilityTemplate.DataName) == INDEX_NONE) 
			&& AbilityTemplate.ConditionsEverValidForUnit(UnitState, false) ) 
		{
			Data = EmptyData;
			Data.TemplateName = AbilityName;
			Data.Template = AbilityTemplate;
			SetupData.AddItem(Data);
		}
		else if (AbilityTemplate == none) {
			`RedScreen("AlertAbilitySet array specifies unknown ability:" @ AbilityName);
		}
	}
}

static function bool DebuggingEnabled() {
	return default.bDebuggingEnabled;
}

static function String GetDLCIdentifier() {
	return default.DLCIdentifier;
}

static function String GetVersionString() {
	local string s;
	
	s = string(default.Version.Major) $ "." $ string(default.Version.Minor) $ "." $ string(default.Version.Patch);

	return s;
}

static function int GetVersionInt(optional bool bIgnorePatches) {
	local int _MajorVer, _MinorVer, _PatchVer;

	_MajorVer = default.Version.Major;
	_MinorVer = default.Version.Minor;
	_PatchVer = default.Version.Patch;


	return (_MajorVer * 1000000) + (_MinorVer * 1000) + (_PatchVer);
}

static function RTModVersion GetModVersion() {
	return default.Version;
}

static function bool AddProgramTechs() {
	local XComGameStateHistory History;
	local XComGameState_Tech TechState;
	local XComGameState NewGameState;
	local X2StrategyElementTemplateManager TechMgr;
	local X2TechTemplate TechTemplate;
	local array<name> TemplatesToAdd;
	local name TemplateName;

	History = `XCOMHISTORY;
	TechMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	TemplatesToAdd = default.ProgramTechs;
	foreach History.IterateByClassType(class'XComGameState_Tech', TechState) {
		if(TemplatesToAdd.Find(TechState.GetMyTemplateName()) != INDEX_NONE) {
			TemplatesToAdd.RemoveItem(TechState.GetMyTemplateName());
		}
	}

	if(TemplatesToAdd.Length > 0) {
		NewGameState = `CreateChangeState("Adding Program Techs to in-progress campaign!");
		foreach TemplatesToAdd(TemplateName) {
			`RTLOG(TemplateName $ " was missing from the campaign. Adding it...");
			TechTemplate = X2TechTemplate(TechMgr.FindStrategyElementTemplate(TemplateName));
			if (TechTemplate.RewardDeck != '') {
				class'XComGameState_Tech'.static.SetUpTechRewardDeck(TechTemplate);
			}
			NewGameState.CreateNewStateObject(class'XComGameState_Tech', TechTemplate);
			
		}

		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		return true;
	}
	return false;
}

static function ReshowProgramDroneRewardPopup() {
	local DynamicPropertySet PropertySet;
	local XComGameState_Tech TechState;
	local XComGameStateHistory History;
	local RTGameState_ProgramFaction ProgramState;

	History = `XCOMHISTORY;

	ProgramState = `RTS.GetProgramState();
	if(!ProgramState.TemplarQuestlineSucceeded()) {
		`RTLOG("Templar Questline has not finished successfully. Not showing popup. Stage was " $ ProgramState.getTemplarQuestlineStage() $ ", and failure flag was set to " $ ProgramState.hasFailedTemplarQuestline(), false, true);
		return;
	}

	`RTLOG("ReshowProgramDroneRewardPopup called and passed validation. You should see a popup in Strategy.");

	foreach History.IterateByClassType(class'XComGameState_Tech', TechState) {
		if(TechState.GetMyTemplateName() == 'RTBuildProgramDrone') {
			break;
		}
	}

	// Program Drone Blueprints | eAlert_ProvingGroundProjectAvailable
	class'X2StrategyGameRulesetDataStructures'.static.BuildDynamicPropertySet(PropertySet, 'UIAlert', 'eAlert_ProvingGroundProjectAvailable', none, false, true, true, true);
	class'X2StrategyGameRulesetDataStructures'.static.AddDynamicStringProperty(PropertySet, 'SoundToPlay', "Geoscape_CrewMemberLevelledUp");
	class'X2StrategyGameRulesetDataStructures'.static.AddDynamicIntProperty(PropertySet, 'TechRef', TechState.ObjectID);
	`HQPRES.QueueDynamicPopup(PropertySet);
}


static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	local name Tag;

	Tag = name(InString);

	switch(Tag)
	{
		case 'CLOAKING_GENERATOR_RADIUS':
			OutString = string(class'RTAbility_ProgramDroneAbilitySet'.default.CLOAKING_PROTOCOL_RADIUS_METERS);
			return true;
		case 'RTREPOSITIONING_MAX_POSITIONS_SAVED':
			OutString = string(class'RTAbility_MarksmanAbilitySet'.default.REPOSITIONING_MAX_POSITIONS_SAVED);
			return true;
		case 'RTREPOSITIONING_TILE_DISTANCE':
			OutString = string(class'RTAbility_MarksmanAbilitySet'.default.REPOSITIONING_TILES_MOVED_REQUIREMENT);
			return true;
		case 'RTPRECISION_SHOT_CRIT_CHANCE':
			OutString = string(class'RTAbility_MarksmanAbilitySet'.default.HEADSHOT_CRIT_BONUS);
			return true;
		case 'RTPRECISION_SHOT_CRIT_DAMAGE':
			OutString = string(class'RTAbility_MarksmanAbilitySet'.default.HEADSHOT_CRITDMG_BONUS);
			return true;
		case 'RTPRECISION_SHOT_AIM_PENALITY':
			OutString = string(class'RTAbility_MarksmanAbilitySet'.default.HEADSHOT_AIM_MULTIPLIER);
			return true;
		case 'AGGRESSION_CRIT_PER_UNIT':
			OutString = string(class'RTAbility_MarksmanAbilitySet'.default.AGGRESSION_CRIT_PER_UNIT);
			return true;
		case 'AGGRESSION_MAX_CRIT':
			OutString = string(class'RTAbility_MarksmanAbilitySet'.default.AGGRESSION_UNITS_FOR_MAX_BONUS * class'RTAbility_MarksmanAbilitySet'.default.AGGRESSION_CRIT_PER_UNIT);
			return true;
		case 'KNOCK_THEM_DOWN_DAMAGE_GAIN':
			OutString = string(class'RTAbility_MarksmanAbilitySet'.default.KNOCKTHEMDOWN_DAMAGE_INCREMENT);
			return true;
		case 'KNOCK_THEM_DOWN_CRITDMG_GAIN':
			OutString = string(class'RTAbility_MarksmanAbilitySet'.default.KNOCKTHEMDOWN_CRITDMG_INCREMENT);
			return true;
	}

	return false;
}

// Setup Display Strings for new AbilityAvailabilityCodes (the localized strings that tell you why an ability fails a condition)
static function UpdateAbilityAvailabilityStrings()
{
    local X2AbilityTemplateManager    AbilityTemplateManager;
	local int                        i, idx;
	
	if(default.NewAbilityAvailabilityCodes.length != default.NewAbilityAvailabilityStrings.length) {
		`RTLOG("Misconfiguration, mismatch between NewAbilityAvailabilityCodes and NewAbilityAvailabilityStrings! Can't add AvailabilityCodes!", false, true);
		return;
	}

    AbilityTemplateManager = X2AbilityTemplateManager(class'Engine'.static.FindClassDefaultObject("XComGame.X2AbilityTemplateManager"));

    i = AbilityTemplateManager.AbilityAvailabilityCodes.Length - AbilityTemplateManager.AbilityAvailabilityStrings.Length;

    // If there are more codes than strings, insert blank strings to bring them to equal before adding our new codes
    if (i > 0)
    {
        for (idx = 0; idx < i; idx++)
        {
            AbilityTemplateManager.AbilityAvailabilityStrings.AddItem("");
        }
    }

    // If there are more strings than codes, cut off the excess before adding our new codes
    if (i < 0)
    {
        AbilityTemplateManager.AbilityAvailabilityStrings.Length = AbilityTemplateManager.AbilityAvailabilityCodes.Length;
    }

    // Append new codes and strings to the arrays
    for (idx = 0; idx < default.NewAbilityAvailabilityCodes.Length; idx++)
    {
        AbilityTemplateManager.AbilityAvailabilityCodes.AddItem(default.NewAbilityAvailabilityCodes[idx]);
        AbilityTemplateManager.AbilityAvailabilityStrings.AddItem(default.NewAbilityAvailabilityStrings[idx]);
    }
}

static function bool IsModLoaded(name DLCName)
{
    local int i;
    local XComOnlineEventMgr Mgr;

    Mgr = `ONLINEEVENTMGR;
    for (i = Mgr.GetNumDLC() - 1; i >= 0; i--) {
        if(Mgr.GetDLCNames(i) == DLCName) {
            return true;
        }
    }

	return false;
}
