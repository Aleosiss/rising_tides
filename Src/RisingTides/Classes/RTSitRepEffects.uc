class RTSitRepEffects extends X2SitRepEffect config(ProgramFaction);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	// Squad Size Effects
	Templates.AddItem(RTCreateOneSmallFavorSitrepEffect('RTOneSmallFavor_Size1', 1));
	Templates.AddItem(RTCreateOneSmallFavorSitrepEffect('RTOneSmallFavor_Size2', 2));
	Templates.AddItem(RTCreateOneSmallFavorSitrepEffect('RTOneSmallFavor_Size3', 3));
	Templates.AddItem(RTCreateOneSmallFavorSitrepEffect('RTOneSmallFavor_Size4', 4));
	Templates.AddItem(RTCreateOneSmallFavorSitrepEffect('RTOneSmallFavor_Size5', 5));
	Templates.AddItem(RTCreateOneSmallFavorSitrepEffect('RTOneSmallFavor_Size6', 6));


	return Templates;
}

static function X2SitRepEffectTemplate RTCreateOneSmallFavorSitrepEffect(name TemplateName, int _SquadSize) {
	local RTSitRepEffect_OneSmallFavor Template;

	`CREATE_X2TEMPLATE(class'RTSitRepEffect_OneSmallFavor', Template, 'TemplateName');

	Template.MaxSquadSize = _SquadSize;

	return Template;
}

static function X2SitRepEffectTemplate RTCreateProfessionalsHaveStandardsSitrepEffect(name TemplateName, int _DetectionMalus) {
	local 
}