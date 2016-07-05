class RTEffect_TimeStopMaster extends X2Effect_PersistentStatChange;

var bool bWasPreviouslyTrue;


simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	  local XComGameState_TimerData TimerState;

	  TimerState = XComGameState_TimerData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_TimerData'));

	  bWasPreviouslyFalse = TimerState.bStopTime;
	  if(!TimerState.bStopTime) {
		TimerState.bStopTime = true;
	  }


}

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
  local XComGameState_AIReinforcementSpawner OldSpawnerState, NewSpawnerState;


  foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_AIReinforcementSpawner', OldSpawnerState) {
    NewSpawnerState = XComGameState_AIReinforcementSpawner(NewGameState.CreateStateObject(class'XComGameState_AIReinforcementSpawner', OldSpawnerState.ObjectID));
    ++NewSpawnerState.Countdown;
    NewGameState.AddStateObject(NewSpawnerState);
  }
  return false;
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	 local XComGameState_TimerData TimerState;

	  TimerState = XComGameState_TimerData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_TimerData'));

	  if(!bWasPreviouslyTrue) {
		TimerState.bStopTime = false;
	  }
}