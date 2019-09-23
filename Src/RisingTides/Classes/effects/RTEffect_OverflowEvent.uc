// This is an Unreal Script

class RTEffect_OverflowEvent extends X2Effect_Persistent;


function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local Object EffectObj, FilterObj;
	local RTGameState_Effect RTEffectState;

	EventMgr = `XEVENTMGR;

	RTEffectState = RTGameState_Effect(EffectGameState);

	EffectObj = RTEffectState;
	FilterObj = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(RTEffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'KillMail', RTEffectState.RTOverkillDamageRecorder, ELD_OnStateSubmitted,,FilterObj);
}

defaultproperties
{
	GameStateEffectClass = class'RTGameState_Effect'
}
