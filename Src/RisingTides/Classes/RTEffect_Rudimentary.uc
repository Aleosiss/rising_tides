// This is an Unreal Script

class RTEffect_Rudimentary extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
    local RTGameState_Effect RTEffectState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;
    RTEffectState = RTGameState_Effect(EffectGameState);
  
	EffectObj = RTEffectState;

	EventMgr.RegisterForEvent(EffectObj, 'AbilityActivated', RTEffectState.RTPsionicInterrupt, ELD_Immediate);
}

DefaultProperties
{
	GameStateEffectClass = class'RTGameState_Effect'
}


