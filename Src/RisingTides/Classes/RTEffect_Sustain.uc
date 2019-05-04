class RTEffect_Sustain extends X2Effect_Sustain config(RisingTides);

function bool PreDeathCheck(XComGameState NewGameState, XComGameState_Unit UnitState, XComGameState_Effect EffectState)
{
	local X2EventManager EventMan;

	UnitState.SetUnitFloatValue(default.SustainUsed, 1, eCleanup_BeginTactical);
	UnitState.SetCurrentStat(eStat_HP, 1);
	EventMan = `XEVENTMGR;
	EventMan.TriggerEvent(default.SustainEvent, UnitState, UnitState, NewGameState);
	return true;
}

DefaultProperties
{
	EffectName="RTSustain"
	SustainUsed="RTSustainUsed"
	SustainEvent = "RTSustainTriggered"
	SustainTriggeredEvent="RTSustainSuccess"
}