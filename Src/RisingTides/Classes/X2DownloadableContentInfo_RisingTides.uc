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
var config array<name> ProgramTechs;

// weak ref to the screen (I just copied this from RJ and don't know if it's really necessary)
var config String screen_path;

defaultproperties
{
	Version=(Major=2, Minor=1, Patch=9)
}

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame() {
	`RTLOG("OnLoadedSavedGame");
	class'RTGameState_ProgramFaction'.static.InitFaction();
}

static event OnLoadedSavedGameToStrategy() {
	`RTLOG("OnLoadedSavedGameToStrategy");
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
	
	if(!ProgramState.CompareVersion(GetVersionInt(), true)) {
		return;
	}

	`RTLOG("New version of the mod found: \nOld Version: " $ ProgramState.GetCurrentVersion() $ "\nNew Version: " $ GetVersionInt());
	NewGameState = `CreateChangeState("Mod version updated, sending popup!");
	ProgramState = `RTS.GetNewProgramState(NewGameState);
	ProgramState.SetTemplarMissionSucceededFlag(true);
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

	`RTLOG("Script package loaded. Version: " $ GetVersionString());

	MakePsiAbilitiesInterruptable();
	MakeAbilitiesNotTurnEndingForTimeStandsStill();
	AddProgramFactionCovertActions();
	AddProgramAttachmentTemplates();
	PatchTemplarCharacterTemplatesForAI();
	if(default.TemplarFocusVisualizationPatchEnabled) {
		PatchTemplarFocusVisualization();
	}

	//PrintAbilityTemplates();
}

static function PatchTemplarFocusVisualization() {
	class'RTAbility_TemplarAbilitySet'.static.PatchTemplarFocusVisualization();
}

static function PrintAbilityTemplates() {
	local array<name> AbilityTemplateNames;
	local name AbilityTemplateName;
	local X2AbilityTemplateManager AbilityTemplateMgr;
	local X2AbilityCost Cost;

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
	local bool bShouldTryToIncreaseInfluence;
	//local XComGameState_BattleData BattleData;

	ProgramState = `RTS.GetProgramState();
	bShouldTryToIncreaseInfluence = ProgramState.isOneSmallFavorActivated();
	if(ProgramState.bShouldPerformPostMissionCleanup) {
		NewGameState = `CreateChangeState("Cleanup Program Operatives from XCOMHQ!");
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
	local int idx;

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
	local XComGameState NewGameState;

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

static function HandleDroneRecovery() {
/*
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Unit UnitState;
	local RTGameState_HeadquartersProjectHealProgramDrone HealProjectState;
	local XComGameState_FacilityXCom EngineeringState;
	local XComGameState_StaffSlot SlotState;
	local XComGameState_SparkManager SparkMgr;
	local XComGameState_PointOfInterest POIState;
	local StaffUnitInfo UnitInfo;
	local array<StateObjectReference> SoldiersToTransfer;
	local int idx, SlotIndex, NewBlocksRemaining, NewProjectPointsRemaining;
	local bool bHealProjectFound;


	if(!`RTS.GetProgramState().TemplarQuestlineSucceeded()) {
		return;
	}

	// If the unit is in the squad or was spawned from the avenger on the mission, add them to the SoldiersToTransfer array
	SoldiersToTransfer = XComHQ.Squad;
	for (idx = 0; idx < XComHQ.Crew.Length; idx++)
	{
		if (XComHQ.Crew[idx].ObjectID != 0)
		{
			UnitState = XComGameState_Unit(History.GetGameStateForObjectID(XComHQ.Crew[idx].ObjectID));
			if (UnitState.bSpawnedFromAvenger)
			{
				SoldiersToTransfer.AddItem(XComHQ.Crew[idx]);
			}
		}
	}

	for (idx = 0; idx < SoldiersToTransfer.Length; idx++)
		{
			if (SoldiersToTransfer[idx].ObjectID != 0)
			{
				UnitState = XComGameState_Unit(History.GetGameStateForObjectID(SoldiersToTransfer[idx].ObjectID));
				if (UnitState.GetMyTemplateName() == 'ProgramDrone')
				{
					// Update Spark healing projects and restart them if a Engineering repair slot is available
					if (!UnitState.IsDead() && !UnitState.bCaptured && (UnitState.IsInjured() || UnitState.GetStatus() == eStatus_Healing))
					{
						UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', SoldiersToTransfer[idx].ObjectID));
						UnitState.SetStatus(eStatus_Healing);

						// If the spark already had a healing project active, update it for their current health
						bHealProjectFound = false;
						foreach History.IterateByClassType(class'RTGameState_HeadquartersProjectHealProgramDrone', HealProjectState)
						{
							if (HealProjectState.ProjectFocus == UnitState.GetReference())
							{
								bHealProjectFound = true;
								NewBlocksRemaining = UnitState.GetBaseStat(eStat_HP) - UnitState.GetCurrentStat(eStat_HP);
								if (NewBlocksRemaining > HealProjectState.BlocksRemaining) // The unit was injured again, so update the time to heal
								{
									HealProjectState = RTGameState_HeadquartersProjectHealProgramDrone(NewGameState.ModifyStateObject(class'RTGameState_HeadquartersProjectHealProgramDrone', HealProjectState.ObjectID));

									do // Calculate new wound length again, but ensure it is greater than the previous time, since the unit is more injured
									{
										NewProjectPointsRemaining = HealProjectState.GetWoundPoints(UnitState);
									} until(NewProjectPointsRemaining > HealProjectState.ProjectPointsRemaining);

									HealProjectState.ProjectPointsRemaining = NewProjectPointsRemaining;
									HealProjectState.BlocksRemaining = NewBlocksRemaining;
									HealProjectState.PointsPerBlock = Round(float(NewProjectPointsRemaining) / float(NewBlocksRemaining));
									HealProjectState.BlockPointsRemaining = HealProjectState.PointsPerBlock;
									HealProjectState.UpdateWorkPerHour();
									HealProjectState.StartDateTime = `STRATEGYRULES.GameTime;
									HealProjectState.SetProjectedCompletionDateTime(HealProjectState.StartDateTime);
								}

								break;
							}
						}

						if (!bHealProjectFound) // An existing heal project was not found, so start one for this unit
						{
							HealProjectState = RTGameState_HeadquartersProjectHealProgramDrone(NewGameState.CreateNewStateObject(class'RTGameState_HeadquartersProjectHealProgramDrone'));
							HealProjectState.SetProjectFocus(UnitState.GetReference(), NewGameState);
							XComHQ.Projects.AddItem(HealProjectState.GetReference());
							HealProjectState.bForcePaused = true;
						}

						// Get the Engineering facility and staff the unit in it if there is an open slot
						EngineeringState = XComHQ.GetFacilityByName('Storage'); // Only one Engineering exists, so safe to do this
						if (EngineeringState != none)
						{
							for (SlotIndex = 0; SlotIndex < EngineeringState.StaffSlots.Length; ++SlotIndex)
							{
								//If this slot has not already been modified (filled) in this tactical transfer, check to see if it's valid
								SlotState = XComGameState_StaffSlot(NewGameState.GetGameStateForObjectID(EngineeringState.StaffSlots[SlotIndex].ObjectID));
								if (SlotState == None)
								{
									SlotState = EngineeringState.GetStaffSlot(SlotIndex);

									// If this is a valid soldier slot in Engineering, restaff the Spark to restart their healing project
									if (!SlotState.IsLocked() && SlotState.IsSlotEmpty() && SlotState.IsSoldierSlot())
									{
										UnitInfo.UnitRef = UnitState.GetReference();
										SlotState.FillSlot(UnitInfo, NewGameState);
										break;
									}
								}
							}
						}

						HealProjectState.OnPowerStateOrStaffingChange();
					}
				}
			}
		}

		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);


*/
}