class RTEffect_LinkedIntelligence extends X2Effect_CoveringFire;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local RTGameState_Effect LinkedEffectState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;
	LinkedEffectState = RTGameState_Effect(EffectGameState);

	EffectObj = LinkedEffectState;

	EventMgr.RegisterForEvent(EffectObj, 'AbilityActivated', LinkedEffectState.LinkedFireCheck, ELD_OnStateSubmitted);
}

DefaultProperties
{
	GameStateEffectClass = class'RTGameState_Effect'
	DuplicateResponse = eDupe_Ignore
	GrantActionPoint = "overwatch"
}
