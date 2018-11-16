class RTEffect_Repositioning extends X2Effect_Persistent config(RisingTides);

/**
 * Requires 2 seperate event listeners (by my calculations...)
 * 
 * 1. Update the list of firing positions whenever a shot is fired.
 * 2. Read the list of firing positions and override RetainConcealmentOnActivation when necessary.
*/



function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
    local RTGameState_Effect EffectState;
    local XComGameState_Unit UnitState;
    local Object EffectObj;
    local Object FilterObj;

	EventMgr = `XEVENTMGR;
    EffectState = RTGameState_Effect(EffectGameState);
    FilterObj = XComGameState_Unit(`XCOMHISTORY
                    .GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	EffectObj = EffectState;

	EventMgr.RegisterForEvent(EffectObj, 'UnitMoveFinished', EffectState.HandleRepositioning, ELD_OnStateSubmitted);
	EventMgr.RegisterForEvent(EffectObj, 'RetainConcealmentOnActivation', EffectState.HandleRetainConcealmentRepositioning, ELD_OnStateSubmitted);
}


defaultproperties
{
    EffectName = 'RTRepositioning'
    GameStateEffectClass = class'RTGameState_Effect'
}
