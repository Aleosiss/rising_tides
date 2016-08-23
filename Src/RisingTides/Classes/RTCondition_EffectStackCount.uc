class RTCondition_EffectStackCount extends X2Condition;

var name StackingEffect;
var int iMinimumStacks, iMaximumStacks;


event name CallMeetsCondition(XComGameState_BaseObject kTarget) {
    local StateObjectReference EffectRef;
    local XComGameState_Unit    TargetUnitState;
    local XComGameState_Effect  EffectState;
    local XComHistory           History;

    TargetUnitState = XComGameState_Unit(kTarget);
    if(TargetUnitState == none) {
        return 'AA_NotAUnit';
    }

    History = `XCOMHISTORY;
    foreach TargetUnitState.AffectedByEffects(EffectRef) {
        EffectState = History.GetGameStateForObjectID(EffectRef.ObjectID);
        if(!EffectState.GetX2Effect().EffectName != StackingEffect)
            	continue;
	if(EffectState.DuplicateResponse != eDupe_Refresh || !EffectState.bStackOnRefresh)
		return 'AA_NotStackableEffect';
        if(iMinimumStacks > 0 && EffectState.iStacks < iMinimumStacks)
            	return 'AA_NotEnoughStacks';
        if(iMaximumStacks > 0 && EffectState.iStacks > iMaximumStacks)
        	return 'AA_TooManyStacks';
    }

    return 'AA_Success';
}
