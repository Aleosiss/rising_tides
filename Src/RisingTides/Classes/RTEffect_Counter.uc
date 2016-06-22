// This is an Unreal Script

class RTEffect_Counter extends X2Effect_Persistent;

var name CounterUnitValName, TriggerEventName;
var bool bShouldTriggerEvent;



simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
	local XComGameState_Unit	CounterUnit;
	local UnitValue				UnitVal;


	CounterUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	CounterUnit.GetUnitValue(CounterUnitValName, UnitVal);

	if(UnitVal.fValue < 1)
	{
		if(bShouldTriggerEvent)
		{
			`XEVENTMGR.TriggerEvent(TriggerEventName, CounterUnit, CounterUnit, NewGameState);
			`RedScreenOnce("Rising Tides: " @ TriggerEventName @ " Counter triggered!");
		}
		return super.OnEffectTicked(ApplyEffectParameters, kNewEffectState, NewGameState, FirstApplication);
	}
	else
		CounterUnit.SetUnitFloatValue(CounterUnitValName, UnitVal.fValue - 1, eCleanup_Never);

	return super.OnEffectTicked(ApplyEffectParameters, kNewEffectState, NewGameState, FirstApplication);
}