class RTEffect_TimeStopMaster extends X2Effect_PersistentStatChange;

var bool bShouldPauseTimer;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local Object EffectObj;
	local RTGameState_Effect RTEffectState;

	EventMgr = `XEVENTMGR;
	RTEffectState = RTGameState_Effect(EffectGameState);
	EffectObj = RTEffectState;

	// Register for the required events

	// Check when anything spawns.
	EventMgr.RegisterForEvent(EffectObj, 'OnUnitBeginPlay', RTEffectState.RTApplyTimeStop, ELD_OnStateSubmitted, 80);
}

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	m_aStatChanges.Length = 0;

	// Could you, Madoka? Could you see me in my stopped time?
	// Uh, no...
	// Oh.
	AddPersistentStatChange(eStat_DetectionModifier, 1);
	ToggleWOTCSpawns(NewGameState, false);

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication, XComGameState_Player Player)
{
	DelayReinforcementSpawners(NewGameState);
	DelayTimer(NewGameState);
	return true;
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	//ModifyTimer(!bShouldPauseTimer);
	ToggleWOTCSpawns(NewGameState, true);
	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);
}

simulated function DelayReinforcementSpawners(XComGameState NewGameState) {
	local XComGameState_AIReinforcementSpawner OldSpawnerState, NewSpawnerState;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	foreach History.IterateByClassType(class'XComGameState_AIReinforcementSpawner', OldSpawnerState) {
		NewSpawnerState = XComGameState_AIReinforcementSpawner(NewGameState.CreateStateObject(OldSpawnerState.class, OldSpawnerState.ObjectID));
		NewGameState.AddStateObject(NewSpawnerState);
		NewSpawnerState.Countdown += 1;
	}

}

simulated function DelayTimer(XComGameState NewGameState) {
	local XComGameState_UiTimer OldUiTimer, NewUiTimer;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	//update the mission timer, if there is one
	OldUiTimer = XComGameState_UITimer(History.GetSingleGameStateObjectForClass(class 'XComGameState_UITimer', true));
	if (OldUiTimer != none) {
		NewUiTimer = XComGameState_UITimer(NewGameState.CreateStateObject(class 'XComGameState_UITimer', OldUiTimer.ObjectID));
		NewGameState.AddStateObject(NewUiTimer);

		NewUiTimer.TimerValue += 1; // hardcoded to one, since it is called every turn and would extend the timer instead of delay
		if(NewUiTimer.TimerValue > 3) // the 3 value is hard-coded into the kismet mission maps, so we hard-code it here as well {
			NewUiTimer.UiState = Normal_Blue;
	}
}

simulated function ToggleWOTCSpawns(XComGameState NewGameState, bool ShouldSpawn) {
	local XComGameState_BattleData Data;

	Data = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	Data = XComGameState_BattleData(NewGameState.ModifyStateObject(class'XComGameState_BattleData', Data.ObjectID));

	Data.bChosenSpawningDisabledViaKismet = !ShouldSpawn;
	Data.bLostSpawningDisabledViaKismet = !ShouldSpawn;
}

defaultproperties
{
	GameStateEffectClass = class'RTGameState_Effect'
}
