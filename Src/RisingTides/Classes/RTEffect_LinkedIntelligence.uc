class RTEffect_LinkedIntelligence extends X2Effect_CoveringFire;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
    local RTGameState_LinkedEFfect LinkedEffectState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;
    LinkedEffectState = RTGameState_LinkedEffect(EffectGameState);
  
	EffectObj = LinkedEffectState;

	EventMgr.RegisterForEvent(EffectObj, 'RTOverwatchShot', LinkedEffectState.LinkedFireCheck, ELD_OnVisualizationBlockCompleted);
	EventMgr.RegisterForEvent(EffectObj, 'TwitchReactionShot', LinkedEffectState.LinkedFireCheck, ELD_OnVisualizationBlockCompleted);
	EventMgr.RegisterForEvent(EffectObj, 'OverwatchShot', LinkedEffectState.LinkedFireCheck, ELD_OnVisualizationBlockCompleted);
}

DefaultProperties
{
	GameStateEffectClass = class'RTGameState_LinkedEffect'
	DuplicateResponse = eDupe_Ignore
	AbilityToActivate = "RTTwitchReactionShot"
	GrantActionPoint = "overwatch"
}
