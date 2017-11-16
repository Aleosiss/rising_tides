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

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	//class'RTHelpers'.static.RTLog("Adding faction Program to covert action CovertActionNarrative_FindFaction...");
	//Manager.FindDataTemplateAllDifficulties('CovertAction_FindFaction', DataTemplates);
	//AddFactionToCovertActionNarratives(DataTemplates, 'CovertActionNarrative_FindFaction_Program');

	//class'RTHelpers'.static.RTLog("Adding faction Program to covert action CovertAction_FindFarthestFaction...");
	//Manager.FindDataTemplateAllDifficulties('CovertAction_FindFarthestFaction', DataTemplates);
	//AddFactionToCovertActionNarratives(DataTemplates, 'CovertActionNarrative_FindFaction_Program');

	class'RTHelpers'.static.RTLog("Adding faction Program to covert action CovertAction_RemoveDoom...");
	Manager.FindDataTemplateAllDifficulties('CovertAction_RemoveDoom', DataTemplates);
	AddFactionToCovertActionNarratives(DataTemplates, 'CovertActionNarrative_RemoveDoom_Program');

	class'RTHelpers'.static.RTLog("Adding faction Program to covert action CovertAction_RecruitEngineer...");
	Manager.FindDataTemplateAllDifficulties('CovertAction_RecruitEngineer', DataTemplates);
	AddFactionToCovertActionNarratives(DataTemplates, 'CovertActionNarrative_RecruitEngineer_Program');

	class'RTHelpers'.static.RTLog("Adding faction Program to covert action CovertAction_BreakthroughTech...");
	Manager.FindDataTemplateAllDifficulties('CovertAction_BreakthroughTech', DataTemplates);
	AddFactionToCovertActionNarratives(DataTemplates, 'CovertActionNarrative_BreakthroughTech_Program');

	class'RTHelpers'.static.RTLog("Adding faction Program to covert action CovertAction_RevealChosenMovement...");
	Manager.FindDataTemplateAllDifficulties('CovertAction_RevealChosenMovement', DataTemplates);
	AddFactionToCovertActionNarratives(DataTemplates, 'CovertActionNarrative_RevealChosenMovements_Program');

	class'RTHelpers'.static.RTLog("Adding faction Program to covert action CovertAction_RevealChosenStrengths...");
	Manager.FindDataTemplateAllDifficulties('CovertAction_RevealChosenStrengths', DataTemplates);
	AddFactionToCovertActionNarratives(DataTemplates, 'CovertActionNarrative_RevealChosenStrengths_Program');

	class'RTHelpers'.static.RTLog("Adding faction Program to covert action CovertAction_RevealChosenStronghold...");
	Manager.FindDataTemplateAllDifficulties('CovertAction_RevealChosenStronghold', DataTemplates);
	AddFactionToCovertActionNarratives(DataTemplates, 'CovertActionNarrative_RevealChosenStronghold_Program');

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
