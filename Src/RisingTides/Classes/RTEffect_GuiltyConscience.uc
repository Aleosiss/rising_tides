// This is an Unreal Script
class RTEffect_GuiltyConscience extends X2Effect_Persistent;

var int iTriggerThreshold;
var name GuiltyConscienceEventName;

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication) {
	local XComGameState_Unit TargetUnitState;
	local XComGameState_Unit SourceUnitState;

    
	if(GuiltyConscienceEventName == '') {
		`RedScreenOnce("Rising Tides: Someone forgot to set the GuiltyConscienceEventName...");
	}

	TargetUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	SourceUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	`LOG("Rising Tides: Guilty Conscience ticked" @ kNewEffectState.iStacks);
    if(kNewEffectState.iStacks >= iTriggerThreshold) {
        `LOG("Rising Tides: Guilty Conscience TRIGGERED on " @ TargetUnitState.GetFullName());
		`XEVENTMGR.TriggerEvent(GuiltyConscienceEventName, TargetUnitState, SourceUnitState, NewGameState);
        kNewEffectState.iStacks = 1;
    } else {
		kNewEffectState.iStacks++;
	}

    return super.OnEffectTicked(ApplyEffectParameters, kNewEffectState, NewGameState, FirstApplication);
}

defaultproperties
{
    GameStateEffectClass = class'RTGameState_Effect'
    iTriggerThreshold = 10
}
