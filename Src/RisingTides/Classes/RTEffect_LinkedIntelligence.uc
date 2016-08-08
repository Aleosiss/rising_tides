class RTEffect_LinkedIntelligence extends X2Effect_CoveringFire;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
    local RTGameState_LinkedEFfect LinkedEffectState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;
    LinkedEffectState = RTGameState_LinkedEffect(EffectGameState);
  
	EffectObj = LinkedEffectState;

	EventMgr.RegisterForEvent(EffectObj, 'AbilityActivated', LinkedEffectState.LinkedFireCheck, ELD_OnStateSubmitted);
}

DefaultProperties
{
	GameStateEffectClass = class'RTGameState_LinkedEffect'
	DuplicateResponse = eDupe_Ignore
	GrantActionPoint = "overwatch"
}
