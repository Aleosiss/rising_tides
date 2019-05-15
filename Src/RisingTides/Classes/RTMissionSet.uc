class RTMissionSet extends X2MissionSet config(ProgramFaction);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2MissionTemplate> Templates;

	//`RTLOG("Building missions!");

	Templates.AddItem(AddMissionTemplate('RT_TemplarAmbush'));
	Templates.AddItem(AddMissionTemplate('RT_TemplarHighCovenAssault'));

	return Templates;
}

static protected function X2MissionTemplate AddMissionTemplate(name missionName)
{
	//`RTLOG("" $ missionName);
	return super.AddMissionTemplate(missionName);
}
