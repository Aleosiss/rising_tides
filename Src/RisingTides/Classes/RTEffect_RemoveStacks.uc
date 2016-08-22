class RTEffect_RemoveStacks extends X2Effect;

var name EffectNameToPurge;
var int iStacksToRemove;
var bool bCleanse;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
    local XComGameState_Effect EffectState, PurgedState;
    local StateObjectReference  EffectRef;
    local X2Effect_Persistent  PersistentEffectTemplate;
    local XComGameState_Unit  TargetUnitState;

    TargetUnitState = XComGameState_Unit(XComGameState_BaseUnit);
    if(TargetUnitState == none)
      return super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
    foreach TargetUnitState.AffectedByEffects(EffectRef) {
        EffectState = History.GetGameStateForObjectID(EffectRef);
        if(EffectState.GetMyTemplateName() != EffectNameToPurge)
            continue;
        if(EffectState.iStacks < 1) {
            `RedScreenOnce("Rising Tides: " @ EffectState.GetMyTemplateName() @ " already has no stacks!");
            return super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
        }
        if((EffectState.iStacks - iStacksToRemove) < 1) {
          EffectState.RemoveEffect(NewGameState, NewGameState, bCleanse);
        } else {
          PurgedState = NewGameState.CreateStateObject(EffectState.class, EffectState.ObjectID);
          PurgedState.iStacks -= iStacksToRemove;
          NewGameState.AddStateObject(PurgedState);
          //EffectState.iStacks -= iStacksToRemove;
        }
        break;
    }
    return super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}