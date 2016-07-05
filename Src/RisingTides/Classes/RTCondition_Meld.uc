class RTCondition_MeldCondition extends X2Condition;

var bool bRequireTargetMelded, bRequireSourceMelded;


event CallMeetsCondition(XComGameState_BaseObject kTarget)  {
  local XComGameState_Unit TargetUnitState;

  TargetUnitState = XComGameState_Unit(kTarget);  

  if(!bRequireTargetMelded) {
      return 'AA_Success';
  }
  
  if(!TargetUnitState.IsAffectedBy('RTEffect_Meld')) {
      return 'AA_Failure';
  }

  return 'AA_Success';
}

event CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource) {
  local XComGameState_Unit SourceUnitState, TargetUnitState;

  SourceUnitState = XComGameState_Unit(kSource);
  TargetUnitState = XComGameState_Unit(kTarget);
 
  if(!bRequireSourceMelded) {
     return 'AA_Success';
  }
  
  if(!SourceUnitState.isAffectedBy('RTEffect_Meld') {
     return 'AA_Failure';
  }
  
  if(!bRequireTargetMelded) {
    return 'AA_Success';
  }

  if(!TargetUnitState.isAffectedBy('RTEffect_Meld') {
    return 'AA_Failure';
  }
  
  return 'AA_Success';
}

defaultproperties:
{
  bRequireTargetMelded=true;
  bRequireSourceMelded=true;
}