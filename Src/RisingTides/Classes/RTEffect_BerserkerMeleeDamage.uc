class RTEffect_BerserkerMeleeDamage extends X2Effect_ApplyWeaponDamage;

var int iBaseBladeDamage, iBaseBladeCritDamage, iBaseBladeDamageSpread, iAcidicBladeShred;
var float fHiddenBladeCritModifier;

function WeaponDamageValue GetBonusEffectDamageValue(XComGameState_Ability AbilityState, XComGameState_Item SourceWeapon, StateObjectReference TargetRef) {
    local WeaponDamageValue ReturnDamageValue;
    local XComGameState_Unit AttackerUnitState;
    local bool bHasAcidBlade, bHasPsionicBlade, bHasHiddenBlade;

    AttackerUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));
    if((AttackerUnitState != none)) {
          bHasAcidBlade = AttackerUnitState.HasSoldierAbility('RTAcidicBlade');
          bHasPsionicBlade = AttackerUnitState.HasSoldierAbility('RTPsionicBlade');
          bHasHiddenBlade = AttackerUnitState.HasSoldierAbility('RTHiddenBlade');
          
          if(bHasAcidBlade)
              return CreateAcidicBladeDamageEffect(ReturnDamageValue, TargetRef);
          if(bHasPsionicBlade)
              return CreatePsionicBladeDamageEffect(ReturnDamageValue, TargetRef);
          if(bHasHiddenBlade && AttackerUnitState.IsConcealed())
              return CreateHiddenBladeDamageEffect(ReturnDamageValue, TargetRef);
          
    }
    return CreateNormalBladeDamageEffect(ReturnDamageValue, TargetRef);
}


simulated WeaponDamageValue CreateAcidicBladeDamageEffect(WeaponDamageValue ReturnDamageValue, StateObjectReference TargetRef) {

    ReturnDamageValue = CreateNormalBladeDamageEffect(ReturnDamageValue, TargetRef);
    ReturnDamageValue.Shred = iAcidBladeOnHitShred;

    return ReturnDamageValue;
}

simulated WeaponDamageValue CreatePsionicBladeDamageEffect(WeaponDamageValue ReturnDamageValue, StateObjectReference TargetRef) {

    ReturnDamageValue = CreateNormalBladeDamageEffect(ReturnDamageValue, TargetRef);
    ReturnDamageValue.Pierce = 999; // i have no idea how psionic damage interacts with the armor system, this should work
    ReturnDamageValue.DamageType = 'Psi';
    return ReturnDamageValue;
}

simulated WeaponDamageValue CreateHiddenBladeDamageEffect(WeaponDamageValue ReturnDamageValue, StateObjectReference TargetRef) {

    ReturnDamageValue = CreateNormalBladeDamageEffect(ReturnDamageValue, TargetRef);
    ReturnDamageValue.Crit += (ReturnDamageValue.Crit / fHiddenBladeCritModifier);    

    return ReturnDamageValue;
}

simulated WeaponDamageValue CreateNormalBladeDamageEffect(WeaponDamageValue ReturnDamageValue, StateObjectReference TargetRef) {
    
    ReturnDamageValue.Damage = iBaseBladeDamage;
    ReturnDamageValue.Crit = iBaseBladeCritDamage;
    ReturnDamageValue.Spread = iBaseBladeSpread;

    return ReturnDamageValue;
}