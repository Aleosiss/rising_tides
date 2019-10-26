class RTGameState_MissionSiteTemplarHighCoven extends XComGameState_MissionSiteOutsideRegions config(RisingTides);

var bool bGeneratedFromDebugCommand;

function MissionSelected()
{
	local XComHQPresentationLayer Pres;
	local RTUIMission_TemplarHighCovenAssault kScreen;

	Pres = `HQPRES;

	// Show the Templar Coven Assault mission
	if (!Pres.ScreenStack.GetCurrentScreen().IsA('RTUIMission_TemplarHighCovenAssault'))
	{
		kScreen = Pres.Spawn(class'RTUIMission_TemplarHighCovenAssault');
		kScreen.MissionRef = GetReference();
		Pres.ScreenStack.Push(kScreen);
	}

	if (`GAME.GetGeoscape().IsScanning())
	{
		Pres.StrategyMap2D.ToggleScan();
	}
}

function SelectSquad()
{
	local XComGameState NewGameState;
	local RTGameState_ProgramFaction ProgramState;

	NewGameState = `CreateChangeState("Trigger Event: Templar High Coven Assault Squad Select");

	// Adjust gear
	ProgramState = `RTS.GetNewProgramState(NewGameState);
	ProgramState.AdjustProgramGearLevel(NewGameState);

	`XEVENTMGR.TriggerEvent('RT_TemplarHighAssaultMissionSquadSelect', self, self, NewGameState);
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	Super.SelectSquad();
}

function string GetUIButtonIcon()
{
	return "img:///UILibrary_DLC3Images.MissionIcon_Tower";
}

function SetMissionData(X2RewardTemplate MissionReward, bool bUseSpecifiedLevelSeed, int LevelSeedOverride, optional array<string> ExcludeFamilies)
{
	`RTLOG("Calling SetMissionData for RTGameState_MissionSiteTemplarHighCoven!");
	`RTLOG("Source: " $ Source);
	super.SetMissionData(MissionReward, bUseSpecifiedLevelSeed, LevelSeedOverride, ExcludeFamilies);
}

