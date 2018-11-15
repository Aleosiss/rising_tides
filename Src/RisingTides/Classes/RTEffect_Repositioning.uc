class RTEffect_Repositioning extends X2Effect_Persistent config(RisingTides);

var name DefaultEventName;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local RTGameState_Effect EffectState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;
	EffectState = RTGameState_Effect(EffectGameState);

	EffectObj = EffectState;

	EventMgr.RegisterForEvent(EffectObj, DefaultEventName, EffectState.HandleRepositioning, ELD_OnStateSubmitted);
	EventMgr.RegisterForEvent(EffectObj, 'RetainConcealmentOnActivation', HandleRetainConcealment, ELD_OnStateSubmitted);
}

function EventListenerReturn HandleRetainConcealment(Object EventData, Object EventSource, XComGameState GameState, name EventID)
{
    local RTGameState_Effect RTEffectState;
    local XComLWTuple Tuple;
    local bool bShouldRetainConcealment;
    local XComGameStateContext_Ability ActivatedAbilityStateContext;
    local XComGameState_Unit UnitState;
    local XComGameStateHistory History;

    Tuple = XComLWTuple(EventData);
    ActivatedAbilityStateContext = XComGameStateContext_Ability(EventSource);

    if(Tuple == none || ActivatedAbilityStateContext == none)
    {
        `RTLOG("One of the event objectives for RTE_Repositioning::HandleRetainConcealment was invalid!", true, false);
        return ELR_NoInterrupt;
    }

    UnitState = XComGameState_Unit(ActivatedAbilityStateContext.InputContext.SourceObject);
    if(UnitState == none)
    {
        `RTLOG("what", true, false);
        return ELR_NoInterrupt;
    }

    History = `XCOMHISTORY;
    foreach UnitState.AffectedByEffects(EffectRef) {
        RTEffectState = RTGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID);
        if(RTEffectState == none)
        {
            continue;
        }

        if(RTEffectState.bRepositioningActive) {
            Tuple.Data[0].b = true;
            return ELR_NoInterrupt;
        }
    }

    return ELR_NoInterrupt;
}


defaultproperties
{
    DefaultEventName = 'RepositioningEventName'
    GameStateEffectClass = class'RTGameState_Effect'
}
