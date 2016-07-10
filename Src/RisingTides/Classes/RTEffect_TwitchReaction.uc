class RTEffect_TwitchReaction extends X2Effect_CoveringFire;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
    local RTGameState_TwitchEffect TwitchEffectState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;
    TwitchEffectState = RTGameState_TwitchEffect(EffectGameState);
  
	EffectObj = TwitchEffectState;

	EventMgr.RegisterForEvent(EffectObj, 'AbilityActivated', TwitchEffectState.TwitchFireCheck, ELD_OnStateSubmitted,,,true);
}

DefaultProperties
{
	GameStateEffectClass = class'RTGameState_TwitchEffect'
	DuplicateResponse = eDupe_Ignore
	AbilityToActivate = "TwitchReactionShot"
	GrantActionPoint = "overwatch"
}