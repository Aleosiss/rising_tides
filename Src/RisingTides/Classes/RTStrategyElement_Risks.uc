class RTStrategyElement_Risks extends X2StrategyElement_DefaultCovertActionRisks config(ProgramFaction);

static function array <X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Risks;

    Risks.AddItem(CreateTemplarAmbushRiskTemplate());

    return Risks;
}

static function X2DataTemplate CreateTemplarAmbushRiskTemplate()
{
    local X2CovertActionRiskTemplate Template;

    `CREATE_X2TEMPLATE(class'X2CovertActionRiskTemplate', Template, 'CovertActionRisk_TemplarAmbush');
    Template.ApplyRiskFn = CreateTemplarAmbush;
    Template.bBlockOtherRisks = true;

    return Template;
}

static function CreateTemplarAmbush(XComGameState NewGameState, XComGameState_CovertAction ActionState, optional StateObjectReference TargetRef)
{
	local XComGameState_HeadquartersResistance ResHQ;
	local RTGameState_MissionSiteTemplarAmbush MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward RewardState;
	local X2StrategyElementTemplateManager StratMgr;
	local X2RewardTemplate RewardTemplate;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;

	ResHQ = XComGameState_HeadquartersResistance(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));
	if (ResHQ.CanCovertActionsBeAmbushed()) // If a Covert Action was supposed to be ambushed, but now the Order is active, don't spawn the mission
	{
		StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
		ActionState.bAmbushed = true; // Flag the Action as being ambushed so it cleans up properly and doesn't give rewards
		ActionState.bNeedsAmbushPopup = true; // Set up for the Ambush popup
		RegionState = ActionState.GetWorldRegion();

		MissionRewards.Length = 0;
		RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_None')); // rewards are given by the X2MissionSourceTemplate
		RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
		MissionRewards.AddItem(RewardState);

		MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_TemplarAmbush'));

		MissionState = RTGameState_MissionSiteTemplarAmbush(NewGameState.CreateNewStateObject(class'RTGameState_MissionSiteTemplarAmbush'));
		MissionState.CovertActionRef = ActionState.GetReference();
		MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true);
		MissionState.ResistanceFaction = ActionState.Faction;
	}
}