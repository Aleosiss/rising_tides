class RTStrategyElement_ProgramFaction extends X2StrategyElement config(ProgramFaction);

var config array<name> Factions;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local X2ResistanceFactionTemplate Template;
	local name FactionName;

	foreach default.Factions(FactionName)
	{
		`CREATE_X2TEMPLATE(class'RTProgramFactionTemplate', Template, FactionName);
        class'RTHelpers'.static.RTLog("Adding the Program Faction Template...", false);
		Templates.AddItem(Template);
	}

	return Templates;
}
