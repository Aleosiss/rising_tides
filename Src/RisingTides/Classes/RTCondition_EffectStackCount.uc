class RTCondition_EffectStackCount extends X2Condition;

var name StackingEffect;
var int iMinimumStacks, iMaximumStacks;
var bool bRequireEffect;


event name CallMeetsCondition(XComGameState_BaseObject kTarget) {
    local StateObjectReference EffectRef;
    local XComGameState_Unit    TargetUnitState;
    local XComGameState_Effect  EffectState;
    local XComGameStateHistory           History;
	local bool bFoundEffect;

    TargetUnitState = XComGameState_Unit(kTarget);
    if(TargetUnitState == none) {
        return 'AA_NotAUnit';
    }

	bFoundEffect = false;
    History = `XCOMHISTORY;
    foreach TargetUnitState.AffectedByEffects(EffectRef) {
	    EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
	    if(EffectState.GetX2Effect().EffectName != StackingEffect)
		    continue;
		bFoundEffect = true;
	    if(EffectState.GetX2Effect().DuplicateResponse != eDupe_Refresh || !EffectState.GetX2Effect().bStackOnRefresh)
		    return 'AA_NotStackableEffect';
	    if(iMinimumStacks > 0 && EffectState.iStacks < iMinimumStacks)
		    return 'AA_NotEnoughStacks';
	    if(iMaximumStacks > 0 && EffectState.iStacks > iMaximumStacks)
		    return 'AA_TooManyStacks';
	    return 'AA_Success';
    }
	if(!bFoundEffect && bRequireEffect) {
		return 'AA_MissingRequiredEffect';
	} else {
		return 'AA_Success';
	}
}

defaultproperties
{
	iMinimumStacks = -1
	iMaximumStacks = -1
	bRequireEffect = true
}
