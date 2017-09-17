class RTSitRepEffects extends X2SitRepEffect config(ProgramFaction);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	// Squad Size Effects
	Templates.AddItem(RTCreateOneSmallFavorEffectTemplate('RTOneSmallFavor_1', 1));
	Templates.AddItem(RTCreateOneSmallFavorEffectTemplate('RTOneSmallFavor_2', 2));
	Templates.AddItem(RTCreateOneSmallFavorEffectTemplate('RTOneSmallFavor_3', 3));
	Templates.AddItem(RTCreateOneSmallFavorEffectTemplate('RTOneSmallFavor_4', 4));
	Templates.AddItem(RTCreateOneSmallFavorEffectTemplate('RTOneSmallFavor_5', 5));
	Templates.AddItem(RTCreateOneSmallFavorEffectTemplate('RTOneSmallFavor_6', 6));


	return Templates;
}


static function X2SitRepEffectTemplate RTCreateOneSmallFavorEffectTemplate(name TemplateName, int _SquadSize)
{
	local X2SitRepEffect_SquadSize Template;

	`CREATE_X2TEMPLATE(class'RTSitRep_OneSmallFavor', Template, 'TemplateName');

	Template.MaxSquadSize = _SquadSize;

	return Template;
}
