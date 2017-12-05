class RTStrategyElement_SitReps extends X2SitRep config(ProgramFaction);

var config array<name> SitReps;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local X2SitRepTemplate Template;
	local name SitRepName;

	foreach default.SitReps(SitRepName)
	{
		`CREATE_X2TEMPLATE(class'X2SitRepTemplate', Template, SitRepName);
		ModifySitrepTemplate(Template);
		Templates.AddItem(Template);
	}

	return Templates;
}

static function ModifySitrepTemplate(out X2SitRepTemplate Template)
{
	DisableStrategyLayerSITREPGeneration(Template);
}

static function DisableStrategyLayerSITREPGeneration(out X2SitRepTemplate Template)
{
	Template.StrategyReqs.SpecialRequirementsFn = DisableStrategy;
}

static function bool DisableStrategy()
{
	return false;
}