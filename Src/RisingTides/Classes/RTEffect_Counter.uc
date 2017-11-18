// 2017-7-14: A year later. Why the fuck does this class even exist? What was I thinking, in some kind of sleep-deprived haze?
class RTEffect_Counter extends X2Effect_Persistent;

var name CounterUnitValName, TriggerEventName;
var bool bShouldTriggerEvent;

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication, XComGameState_Player Player)
{
	local XComGameState_Unit	CounterUnit, CounterSourceUnit;
	local UnitValue				UnitVal;

	CounterUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	CounterSourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	if(!CounterUnit.GetUnitValue(CounterUnitValName, UnitVal)) {
		// `RedScreenOnce("Rising Tides: " @ EffectName @ " unable to find the CounterValue, aborting countdown...");
		return super.OnEffectTicked(ApplyEffectParameters, kNewEffectState, NewGameState, FirstApplication, Player);
	}
	CounterUnit.GetUnitValue(CounterUnitValName, UnitVal); 	// I still don't know if the above method actually populates the out param
															// in the if statement so this a fallback

	if(UnitVal.fValue < 0) {
		// this is the case that the counter is done counting
		return super.OnEffectTicked(ApplyEffectParameters, kNewEffectState, NewGameState, FirstApplication, Player);
	}

	if(UnitVal.fValue == 0) {
		if(bShouldTriggerEvent) { // sometimes the effect trigger looks for the counter instead of the other way around
			`XEVENTMGR.TriggerEvent(TriggerEventName, CounterUnit, CounterSourceUnit, NewGameState);
			//`LOG("Rising Tides: " @ TriggerEventName @ " Counter triggered!");
		}
	}

	CounterUnit.SetUnitFloatValue(CounterUnitValName, UnitVal.fValue - 1, eCleanup_BeginTactical);
	return super.OnEffectTicked(ApplyEffectParameters, kNewEffectState, NewGameState, FirstApplication, Player);
}
