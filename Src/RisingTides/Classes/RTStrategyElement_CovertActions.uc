// This is an Unreal Script
class RTStrategyElement_CovertActions extends X2StrategyElement_DefaultCovertActions config (ProgramFaction);


static function AddFactionToGeneratedTemplates() {
	local array<name> CovertActionNames;
	local X2StrategyElementTemplateManager Manager;
	local array<X2CovertActionTemplate> CovertActionTemplates;
	local array<X2DataTemplate>			DataTemplates;
	local X2DataTemplate				IteratorTemplate;
	local X2CovertActionTemplate		TestTemplate;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	`LOG("Rising Tides: Adding faction Program to covert action CovertActionNarrative_FindFaction...");
	Manager.FindDataTemplateAllDifficulties('CovertAction_FindFaction', DataTemplates);	
	AddFactionToCovertActionNarratives(DataTemplates, 'CovertActionNarrative_FindFaction_Program');

	`LOG("Rising Tides: Adding faction Program to covert action CovertAction_FindFarthestFaction...");
	Manager.FindDataTemplateAllDifficulties('CovertAction_FindFarthestFaction', DataTemplates);	
	AddFactionToCovertActionNarratives(DataTemplates, 'CovertActionNarrative_FindFaction_Program');

	`LOG("Rising Tides: Adding faction Program to covert action CovertAction_RemoveDoom...");
	Manager.FindDataTemplateAllDifficulties('CovertAction_RemoveDoom', DataTemplates);	
	AddFactionToCovertActionNarratives(DataTemplates, 'CovertActionNarrative_RemoveDoom_Program');

	`LOG("Rising Tides: Adding faction Program to covert action CovertAction_RecruitEngineer...");
	Manager.FindDataTemplateAllDifficulties('CovertAction_RecruitEngineer', DataTemplates);	
	AddFactionToCovertActionNarratives(DataTemplates, 'CovertActionNarrative_RecruitEngineer_Program');

	`LOG("Rising Tides: Adding faction Program to covert action CovertAction_BreakthroughTech...");
	Manager.FindDataTemplateAllDifficulties('CovertAction_BreakthroughTech', DataTemplates);	
	AddFactionToCovertActionNarratives(DataTemplates, 'CovertActionNarrative_BreakthroughTech_Program');
	
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