class RTEffect_TimeStopMaster extends X2Effect_PersistentStatChange;

var bool bWasPreviouslyTrue;
var EDirectionType CachedTimerDirection;


simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnit;
	local XComGameState_TimerData TimerData, OldTimerData;
	local XComGameStateHistory		History;
	
	TargetUnit = XComGameState_Unit(kNewTargetState);
	
	// Could you, Madoka? Could you see me in my stopped time?
	// Uh, no...
	// Oh.
	AddPersistentStatChange(eStat_DetectionModifier, 1);
	
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}



simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
	local XComGameState_AIReinforcementSpawner OldSpawnerState, NewSpawnerState;
	local XComGameStateHistory		History;
  	
	History = `XCOMHISTORY;
	foreach History.IterateByClassType(class'XComGameState_AIReinforcementSpawner', OldSpawnerState) {
		NewSpawnerState = XComGameState_AIReinforcementSpawner(NewGameState.CreateStateObject(class'XComGameState_AIReinforcementSpawner', OldSpawnerState.ObjectID));
		NewSpawnerState.Countdown = OldSpawnerState.Countdown + 1;
		NewGameState.AddStateObject(NewSpawnerState);
	}							
	return false;
}	

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState); 	
}	   
