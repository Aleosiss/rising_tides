class RTStrategyElement_Risks extends X2StrategyElement_DefaultCovertActionRisks config(Gameboard);

static function array <X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Risks;

	Risks.AddItem(CreateTemplarAmbushRiskTemplate());
	Risks.AddItem(CreateSoldierShakenRiskTemplate());

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

	`RTLOG("Creating Templar Ambush!");

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

		MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('RTMissionSource_TemplarAmbush'));

		MissionState = RTGameState_MissionSiteTemplarAmbush(NewGameState.CreateNewStateObject(class'RTGameState_MissionSiteTemplarAmbush'));
		MissionState.CovertActionRef = ActionState.GetReference();
		MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true);
		MissionState.ResistanceFaction = ActionState.Faction;
	}
}

static function X2DataTemplate CreateSoldierShakenRiskTemplate() {
	local X2CovertActionRiskTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionRiskTemplate', Template, 'CovertActionRisk_SoldierShaken');
	
	Template.FindTargetFn = ChooseRandomSoldierWithExclusions;
	Template.ApplyRiskFn = ApplySoldierShaken;
	Template.RiskPopupFn = SoldierShakenPopup;

	return Template;
}

static function ApplySoldierShaken(XComGameState NewGameState, XComGameState_CovertAction ActionState, optional StateObjectReference TargetRef)
{
	local XComGameState_Unit UnitState;
	local float MinShakenWill;
	
	if (TargetRef.ObjectID != 0)
	{
		UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', TargetRef.ObjectID));
		if (UnitState == none) {
			`RTLOG("Did not recieve or find a UnitState for ApplySoldierShaken!", true, false);
			return;
		}

		if(!UnitState.bIsShaken && !UnitState.bIsShakenRecovered) {
			MinShakenWill = UnitState.GetMinWillForMentalState(eMentalState_Shaken);

			UnitState.SetCurrentStat(eStat_Will, MinShakenWill);
			UnitState.UpdateMentalState();

			UpdateWillRecoveryProjectForUnit(NewGameState, UnitState);
		}
	}
}

static function UpdateWillRecoveryProjectForUnit(XComGameState NewGameState, XComGameState_Unit NewUnitState) {
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersProjectRecoverWill WillProject;
	// First remove existing recover will project if there is one.
	History = `XCOMHISTORY;
	XComHQ = GetAndAddXComHQ(NewGameState);

	foreach History.IterateByClassType(class'XComGameState_HeadquartersProjectRecoverWill', WillProject)
	{
		if(WillProject.ProjectFocus == NewUnitState.GetReference())
		{
			XComHQ.Projects.RemoveItem(WillProject.GetReference());
			NewGameState.RemoveStateObject(WillProject.ObjectID);
			break;
		}
	}

	// Add new will recover project
	WillProject = XComGameState_HeadquartersProjectRecoverWill(NewGameState.CreateNewStateObject(class'XComGameState_HeadquartersProjectRecoverWill'));
	WillProject.SetProjectFocus(NewUnitState.GetReference(), NewGameState);
	XComHQ.Projects.AddItem(WillProject.GetReference());
}

static function SoldierShakenPopup(XComGameState_CovertAction ActionState, StateObjectReference TargetRef)
{
	`HQPRES.UISoldierShaken(XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(TargetRef.ObjectID)));
}

//---------------------------------------------------------------------------------------
static function XComGameState_HeadquartersXCom GetAndAddXComHQ(XComGameState NewGameState)
{
	local XComGameState_HeadquartersXCom XComHQ;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}

	if (XComHQ == none)
	{
		XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	}

	return XComHQ;
}