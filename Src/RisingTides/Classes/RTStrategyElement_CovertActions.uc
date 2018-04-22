// This is an Unreal Script
class RTStrategyElement_CovertActions extends X2StrategyElement_DefaultCovertActions config (ProgramFaction);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> CovertActions;

	CovertActions.AddItem(CreateFindProgramFactionTemplate());
	CovertActions.AddItem(CreateFindProgramFarAwayFactionTemplate());

	return CovertActions;
}

//---------------------------------------------------------------------------------------
// FIND FACTION
//-------------------------------------------------     --------------------------------------
static function X2DataTemplate CreateFindProgramFactionTemplate()
{
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
static function X2DataTemplate CreateFindProgramFarAwayFactionTemplate()
{
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

private static function CovertActionSlot _CreateDefaultSoldierSlot(name SlotName, optional int iMinRank, optional bool bRandomClass, optional bool bFactionClass)
{
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


static function AddFactionToGeneratedTemplates() {
	local array<name> CovertActionNames;
	local X2StrategyElementTemplateManager Manager;
	local array<X2CovertActionTemplate> CovertActionTemplates;
	local array<X2DataTemplate>			DataTemplates;
	local X2DataTemplate				IteratorTemplate;
	local X2CovertActionTemplate		TestTemplate;
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
				ActionTemplate.Narratives.AddItem('CovertActionNarrative_RecruitEnginer_Program');

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

			if(ActionTemplate.DataName == 'CovertAction_RevealChosenMovement')
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
