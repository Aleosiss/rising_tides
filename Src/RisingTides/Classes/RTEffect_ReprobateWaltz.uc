class RTEffect_ReprobateWaltz extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{

	local X2EventManager EventMgr;
    local RTGameState_Effect WaltzEffectState;
	local Object EffectObj, FilterObj;

	EventMgr = `XEVENTMGR;
    WaltzEffectState = RTGameState_Effect(EffectGameState);

	EffectObj = WaltzEffectState;
	FilterObj = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'RTBerserkerKnifeAttack', WaltzEffectState.ReprobateWaltzCheck, ELD_OnStateSubmitted, 40, FilterObj);
}

DefaultProperties
{
	GameStateEffectClass = class'RTGameState_Effect'
}
