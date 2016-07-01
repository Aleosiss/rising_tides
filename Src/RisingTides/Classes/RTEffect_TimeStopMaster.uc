class RTEffect_TimeStopMaster extends X2Effect_PersistentStatChange;

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