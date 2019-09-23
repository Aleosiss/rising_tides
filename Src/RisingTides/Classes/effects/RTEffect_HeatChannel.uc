class RTEffect_HeatChannel extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local RTGameState_Effect HeatEffectState;
	local Object EffectObj, FilterObj;

	EventMgr = `XEVENTMGR;
	HeatEffectState = RTGameState_Effect(EffectGameState);

	EffectObj = HeatEffectState;
	FilterObj = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, class'RTAbility'.default.UnitUsedPsionicAbilityEvent, HeatEffectState.HeatChannelCheck, ELD_OnStateSubmitted, , FilterObj);
}

DefaultProperties
{
	GameStateEffectClass = class'RTGameState_Effect'
	DuplicateResponse = eDupe_Ignore
}
