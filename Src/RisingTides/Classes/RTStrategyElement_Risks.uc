class RTStrategyElement_Risks extends X2StrategyElement_DefaultCovertActionRisks config(ProgramFaction);

static function array <X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Risks;

    Risks.AddItem(CreateTemplarDiscoveryRiskTemplate());
    Risks.AddItem(CreateTemplarAmbushRiskTemplate());

    return Risks;
}

static function X2DataTemplate CreateTemplarDiscoveryRiskTemplate()
{
    local X2CovertActionRiskTemplate Template;

    `CREATE_X2TEMPLATE(class'X2CovertActionRiskTemplate', Template, 'CovertActionRisk_TemplarDiscovery');
    Template.IsRiskAvailableFn = none;
    Template.ApplyRiskFn = none;
    Template.RiskPopupFn = SoldierCapturedPopup;

    return Template;
}

static function X2DataTemplate CreateTemplarAmbushRiskTemplate()
{
    local X2CovertActionRiskTemplate Template;

    `CREATE_X2TEMPLATE(class'X2CovertActionRiskTemplate', Template, 'CovertActionRisk_TemplarAmbush');
    Template.IsRiskAvailableFn = none;
    Template.ApplyRiskFn = none;
    Template.bBlockOtherRisks = true;

    return Template;
}