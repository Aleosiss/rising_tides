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
	ToggleTimer(NewGameState, false);

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication, XComGameState_Player Player)
{
	DelayReinforcementSpawners(NewGameState);
	return true;
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	//ModifyTimer(!bShouldPauseTimer);
	ToggleWOTCSpawns(NewGameState, true);
	ToggleTimer(NewGameState, true);
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

simulated function ToggleTimer(XComGameState NewGameState, bool bResumeMissionTimer) {
	class'XComGameState_UITimer'.static.SuspendTimer(bResumeMissionTimer, NewGameState);
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
