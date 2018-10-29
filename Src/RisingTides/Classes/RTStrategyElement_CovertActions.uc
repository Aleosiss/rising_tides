// This is an Unreal Script
class RTStrategyElement_CovertActions extends X2StrategyElement_DefaultCovertActions config (ProgramFaction);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> CovertActions;

	// Find Faction Templates
	CovertActions.AddItem(CreateFindProgramFactionTemplate());
	CovertActions.AddItem(CreateFindProgramFarAwayFactionTemplate());

	// TODO: Hunt Templars
	CovertActions.AddItem(CreateHuntTemplarsP1Template());
	CovertActions.AddItem(CreateHuntTemplarsP2Template());
	CovertActions.AddItem(CreateHuntTemplarsP3Template());

	return CovertActions;
}

//---------------------------------------------------------------------------------------
// FIND FACTION
//-------------------------------------------------     --------------------------------------
static function X2DataTemplate CreateFindProgramFactionTemplate() {
	local X2CovertActionTemplate Template;
	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'CovertAction_FindProgramFaction');

	Template.ChooseLocationFn = ChooseFactionRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";
	Template.bGoldenPath = true;

	Template.bDisplayRequiresAvailable = true;

	Template.Narratives.AddItem('CovertActionNarrative_FindFaction_Program');

	Template.Slots.AddItem(_CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.Slots.AddItem(_CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));

	Template.Risks.AddItem('CovertActionRisk_SoldierWounded');

	Template.Rewards.AddItem('Reward_RTProgram_FindFaction');

	return Template;
}

//---------------------------------------------------------------------------------------
// FIND FARTHEST FACTION
//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateFindProgramFarAwayFactionTemplate() {
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'CovertAction_FindProgramFarAwayFaction');

	Template.ChooseLocationFn = ChooseFactionRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";
	Template.bGoldenPath = true;

	Template.bDisplayRequiresAvailable = true;

	Template.Narratives.AddItem('CovertActionNarrative_FindFaction_Program');

	Template.Slots.AddItem(_CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot', 3));
	Template.Slots.AddItem(_CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));

	Template.Risks.AddItem('CovertActionRisk_SoldierWounded');

	Template.Rewards.AddItem('Reward_RTProgram_FindFarthestFaction');

	return Template;
}

static function AddFactionToGeneratedTemplates() {
	//local array<name> CovertActionNames;
	local X2StrategyElementTemplateManager Manager;
	//local array<X2CovertActionTemplate> CovertActionTemplates;
	//local array<X2DataTemplate>			DataTemplates;
	//local X2DataTemplate				IteratorTemplate;
	//local X2CovertActionTemplate		TestTemplate;
	local array<X2StrategyElementTemplate> AllActionTemplates;
	local X2StrategyElementTemplate DataTemplate;
	local X2CovertActionTemplate ActionTemplate;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	AllActionTemplates = Manager.GetAllTemplatesOfClass(class'X2CovertActionTemplate');

	foreach AllActionTemplates(DataTemplate)
	{
		ActionTemplate = X2CovertActionTemplate(DataTemplate);
		if (ActionTemplate != none) //valid template, so we start  adding our narratives
		{
			if(ActionTemplate.DataName == 'CovertAction_RecruitScientist')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_RecruitScientist_Program');

			if(ActionTemplate.DataName == 'CovertAction_RecruitEngineer')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_RecruitEngineer_Program');

			if(ActionTemplate.DataName == 'CovertAction_GatherSupplies')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_GatherSupplies_Program');

			if(ActionTemplate.DataName == 'CovertAction_GatherIntel')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_GatherIntel_Program');

			if(ActionTemplate.DataName == 'CovertAction_IncreaseIncome')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_IncreaseIncome_Program');

			if(ActionTemplate.DataName == 'CovertAction_RemoveDoom')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_RemoveDoom_Program');

			if(ActionTemplate.DataName == 'CovertAction_ImproveComInt')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_ImproveComInt_Program');

			if(ActionTemplate.DataName == 'CovertAction_FormSoldierBond')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_FormSoldierBond_Program');

			if(ActionTemplate.DataName == 'CovertAction_ResistanceContact')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_ResistanceContact_Program');

			if(ActionTemplate.DataName == 'CovertAction_SharedAbilityPoints')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_SharedAbilityPoints_Program');

			if(ActionTemplate.DataName == 'CovertAction_BreakthroughTech')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_BreakthroughTech_Program');

			if(ActionTemplate.DataName == 'CovertAction_SuperiorWeaponUpgrade')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_SuperiorWeaponUpgrade_Program');

			if(ActionTemplate.DataName == 'CovertAction_SuperiorPCS')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_SuperiorPCS_Program');

			if(ActionTemplate.DataName == 'CovertAction_AlienLoot')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_AlienLoot_Program');

			if(ActionTemplate.DataName == 'CovertAction_FacilityLead')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_FacilityLead_Program');

			if(ActionTemplate.DataName == 'CovertAction_ResistanceCard')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_ResistanceCard_Program');

			if(ActionTemplate.DataName == 'CovertAction_RevealChosenMovements')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_RevealChosenMovements_Program');

			if(ActionTemplate.DataName == 'CovertAction_RevealChosenStrengths')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_RevealChosenStrengths_Program');

			if(ActionTemplate.DataName == 'CovertAction_RevealChosenStronghold')
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_RevealChosenStronghold_Program');
		}
	}
}

private static function AddFactionToCovertActionNarratives(array<X2DataTemplate> DataTemplates, name CovertActionNarrativeName) {
	local X2DataTemplate				IteratorTemplate;
	local X2CovertActionTemplate		TestTemplate;

	if(DataTemplates.Length > 0) {
		foreach DataTemplates(IteratorTemplate) {
			TestTemplate = X2CovertActionTemplate(IteratorTemplate);
			if(TestTemplate != none) {
				X2CovertActionTemplate(IteratorTemplate).Narratives.AddItem(CovertActionNarrativeName);
			}
		}
		DataTemplates.Length = 0;
	}
}

//---------------------------------------------------------------------------------------
// TEMPLAR QUEST CHAIN P1
//-------------------------------------------------     --------------------------------------
static function X2DataTemplate CreateHuntTemplarsP1Template() {
	local X2CovertActionTemplate Template;
	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'CovertAction_HuntTemplarsP1Template');

	Template.ChooseLocationFn = ChooseTemplarRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";
	Template.bGoldenPath = false;
	Template.bUnique = true;
	Template.RequiredFactionInfluence = eFactionInfluence_Respected;

	Template.Narratives.AddItem('CovertActionNarrative_HuntTemplarsP1_Program');

	// intel, 1 squaddie soldier, 1 scientist, 1 optional engineer
	Template.Slots.AddItem(_CreateDefaultSoldierSlot(class'RTStrategyElement_ProgramStaffSlots'.default.StaffSlotTemplateName, 1));
	Template.Slots.AddItem(_CreateDefaultStaffSlot('CovertActionScientistStaffSlot'));
	Template.Slots.AddItem(_CreateDefaultStaffSlot('CovertActionEngineerStaffSlot'));
	Template.OptionalCosts.AddItem(_CreateOptionalCostSlot('Intel', 25));

	Template.Risks.AddItem('Templar_Ambush');

	Template.Rewards.AddItem('RTReward_ProgramHuntTemplarsP1');

	return Template;
}

//---------------------------------------------------------------------------------------
// TEMPLAR QUEST CHAIN P2
//-------------------------------------------------     --------------------------------------
static function X2DataTemplate CreateHuntTemplarsP2Template() {
	local X2CovertActionTemplate Template;
	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'CovertAction_HuntTemplarsP2Template');

	Template.ChooseLocationFn = ChooseTemplarRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";
	Template.bGoldenPath = false;
	Template.bUnique = true;
	Template.RequiredFactionInfluence = eFactionInfluence_Influential;

	Template.Narratives.AddItem('CovertActionNarrative_HuntTemplarsP2_Program');

	// intel, 2 sergeant soldiers, 1 optional engineer
	Template.Slots.AddItem(_CreateDefaultSoldierSlot(class'RTStrategyElement_ProgramStaffSlots'.default.StaffSlotTemplateName, 3));
	Template.Slots.AddItem(_CreateDefaultSoldierSlot(class'RTStrategyElement_ProgramStaffSlots'.default.StaffSlotTemplateName, 3));
	Template.Slots.AddItem(_CreateDefaultStaffSlot('CovertActionEngineerStaffSlot'));
	Template.OptionalCosts.AddItem(_CreateOptionalCostSlot('Intel', 50));

	Template.Risks.AddItem('Templar_Ambush');

	Template.Rewards.AddItem('RTReward_ProgramHuntTemplarsP2');

	return Template;
}

//---------------------------------------------------------------------------------------
// TEMPLAR QUEST CHAIN P3
//-------------------------------------------------     --------------------------------------
static function X2DataTemplate CreateHuntTemplarsP3Template() {
	local X2CovertActionTemplate Template;
	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'CovertAction_HuntTemplarsP3Template');

	Template.ChooseLocationFn = ChooseTemplarRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";
	Template.bGoldenPath = false;
	Template.bUnique = true;
	Template.RequiredFactionInfluence = eFactionInfluence_MAX;

	Template.Narratives.AddItem('CovertActionNarrative_HuntTemplarsP3_Program');

	// 3 captain soldiers, 1 optional intel 
	Template.Slots.AddItem(_CreateDefaultSoldierSlot(class'RTStrategyElement_ProgramStaffSlots'.default.StaffSlotTemplateName, 5));
	Template.Slots.AddItem(_CreateDefaultSoldierSlot(class'RTStrategyElement_ProgramStaffSlots'.default.StaffSlotTemplateName, 5));
	Template.Slots.AddItem(_CreateDefaultSoldierSlot(class'RTStrategyElement_ProgramStaffSlots'.default.StaffSlotTemplateName, 5));
	Template.OptionalCosts.AddItem(_CreateOptionalCostSlot('Intel', 75));

	Template.Risks.AddItem('Templar_Discovery');

	Template.Rewards.AddItem('RTReward_ProgramHuntTemplarsP3');

	return Template;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---Slot Constructors--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
private static function CovertActionSlot _CreateDefaultSoldierSlot(name SlotName, optional int iMinRank, optional bool bRandomClass, optional bool bFactionClass) {
	local CovertActionSlot SoldierSlot;

	SoldierSlot.StaffSlot = SlotName;
	SoldierSlot.Rewards.AddItem('Reward_StatBoostHP');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostAim');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostMobility');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostDodge');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostWill');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostHacking');
	SoldierSlot.Rewards.AddItem('Reward_RankUp');
	SoldierSlot.iMinRank = iMinRank;
	SoldierSlot.bChanceFame = false;
	SoldierSlot.bRandomClass = bRandomClass;
	SoldierSlot.bFactionClass = bFactionClass;

	if (SlotName == 'CovertActionRookieStaffSlot')
	{
		SoldierSlot.bChanceFame = false;
	}

	return SoldierSlot;
}

private static function CovertActionSlot _CreateDefaultStaffSlot(name SlotName) {
	local CovertActionSlot StaffSlot;
	
	// Same as Soldier Slot, but no rewards
	StaffSlot.StaffSlot = SlotName;
	StaffSlot.bReduceRisk = false;
	
	return StaffSlot;
}

private static function CovertActionSlot _CreateDefaultOptionalSlot(name SlotName, optional int iMinRank, optional bool bFactionClass) {
	local CovertActionSlot OptionalSlot;

	OptionalSlot.StaffSlot = SlotName;
	OptionalSlot.bChanceFame = false;
	OptionalSlot.bReduceRisk = true;
	OptionalSlot.iMinRank = iMinRank;
	OptionalSlot.bFactionClass = bFactionClass;

	return OptionalSlot;
}

private static function StrategyCostReward _CreateOptionalCostSlot(name ResourceName, int Quantity) {
	local StrategyCostReward ActionCost;
	local ArtifactCost Resources;

	Resources.ItemTemplateName = ResourceName;
	Resources.Quantity = Quantity;
	ActionCost.Cost.ResourceCosts.AddItem(Resources);
	ActionCost.Reward = 'Reward_DecreaseRisk';
	
	return ActionCost;
}

static function ChooseTemplarRegion(XComGameState NewGameState, XComGameState_CovertAction ActionState, out array<StateObjectReference> ExcludeLocations) {
	local XComGameState_ResistanceFaction TemplarFaction;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', TemplarFaction) {
		if(TemplarFaction.GetMyTemplateName() == 'Faction_Templars') {
			ActionState.LocationEntity = TemplarFaction.HomeRegion;
			return;
		}
	}
}