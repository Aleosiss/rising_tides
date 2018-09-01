class RTEffect_GhostInTheShell extends X2Effect_Persistent;



function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local RTGameState_Effect GhostEffectState;
	local Object EffectObj, FilterObj;

	EventMgr = `XEVENTMGR;
	GhostEffectState = RTGameState_Effect(EffectGameState);

	EffectObj = GhostEffectState;
	FilterObj = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'AbilityActivated', GhostEffectState.GhostInTheShellCheck, ELD_OnStateSubmitted, 40, FilterObj);
}

DefaultProperties
{
	GameStateEffectClass = class'RTGameState_Effect'
}
