class RTEffect_HeatChannel extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
    local RTGameState_HeatChannel HeatEffectState;
	local Object EffectObj, FilterObj;

	EventMgr = `XEVENTMGR;
    HeatEffectState = RTGameState_HeatChannel(EffectGameState);
  
	EffectObj = HeatEffectState;
	FilterObj = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'UnitUsedPsionicAbility', HeatEffectState.HeatChannelCheck, ELD_OnStateSubmitted, , FilterObj);
}

DefaultProperties
{
	GameStateEffectClass = class'RTGameState_HeatChannel'
	DuplicateResponse = eDupe_Ignore
}