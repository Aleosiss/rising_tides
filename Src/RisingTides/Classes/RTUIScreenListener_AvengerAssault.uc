class RTUIScreenListener_AvengerAssault extends UIScreenListener config(ProgramFaction);

event OnRemoved(UIScreen Screen) {
	local XComGameState NewGameState;
	local RTGameState_MissionSiteAvengerAssault MissionState;
	local RTGameState_ProgramFaction Program;
	local X2MissionSourceTemplate MissionSource;
	local X2StrategyElementTemplateManager StratMgr;
	local X2RewardTemplate RewardTemplate;
	local XComGameState_Reward RewardState;
	local array<XComGameState_Reward> MissionRewards;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Launching Operation: Rising Tides");
	Program = class'RTHelpers'.static.GetNewProgramFaction(NewGameState);
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_None'));
	RewardState = RewardTemplate.CreateInstanceFromTemplate(StartState);
	MissionRewards.AddItem(RewardState);

	MissionState = RTGameState_MissionSiteAvengerAssault(NewGameState.CreateNewStateObject(class'RTGameState_MissionSiteAvengerAssault'));
	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_RTOperationRisingTides'));
	MissionState.BuildMission(MissionSource, `XCOMHQ.Location, `XCOMHQ.CurrentLocation, MissionRewards, true);
	Program.AssembleProgramSquad(NewGameState, MissionState, Program.Squads[0]);
	`GAMERULES.SubmitGameState(NewGameState);

	MissionState.StartMission();
}

defaultproperties
{
	// Leaving this assigned to none will cause every screen to trigger its signals on this class
	ScreenClass = class'UIEndGameStats';
}
