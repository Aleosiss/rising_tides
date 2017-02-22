// This is an Unreal Script

class RTEffect_ExtendEffectDuration extends X2Effect_Persistent;

var bool bSelfBuff;
var name AbilityToExtendName;
var name EffectToExtendName;
var int iDurationExtension;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
    local RTGameState_Effect RTEffectState;
	local Object EffectObj, FilterObj;

	EventMgr = `XEVENTMGR;
    RTEffectState = RTGameState_Effect(EffectGameState);
  
	EffectObj = RTEffectState;
	FilterObj = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	if(!bSelfBuff)
		EventMgr.RegisterForEvent(EffectObj, 'AbilityActivated', RTEffectState.ExtendEffectDuration, ELD_OnStateSubmitted);
	else 
		EventMgr.RegisterForEvent(EffectObj, 'AbilityActivated', RTEffectState.ExtendEffectDuration, ELD_OnStateSubmitted, , FilterObj);
}

DefaultProperties
{
	GameStateEffectClass = class'RTGameState_Effect'
	DuplicateResponse = eDupe_Ignore
}