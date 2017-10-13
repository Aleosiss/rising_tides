class RTSitRepEffects extends X2SitRepEffect config(ProgramFaction);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	// Squad Size Effects
	Templates.AddItem(RTCreateOneSmallFavorEffectTemplate('RTOneSmallFavor_Size1', 1));
	Templates.AddItem(RTCreateOneSmallFavorEffectTemplate('RTOneSmallFavor_Size2', 2));
	Templates.AddItem(RTCreateOneSmallFavorEffectTemplate('RTOneSmallFavor_Size3', 3));
	Templates.AddItem(RTCreateOneSmallFavorEffectTemplate('RTOneSmallFavor_Size4', 4));
	Templates.AddItem(RTCreateOneSmallFavorEffectTemplate('RTOneSmallFavor_Size5', 5));
	Templates.AddItem(RTCreateOneSmallFavorEffectTemplate('RTOneSmallFavor_Size6', 6));


	return Templates;
}


static function X2SitRepEffectTemplate RTCreateOneSmallFavorEffectTemplate(name TemplateName, int _SquadSize)
{
	local RTSitRep_OneSmallFavor Template;

	`CREATE_X2TEMPLATE(class'RTSitRep_OneSmallFavor', Template, 'TemplateName');

	Template.MaxSquadSize = _SquadSize;

	return Template;
}
