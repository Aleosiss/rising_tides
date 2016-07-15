//---------------------------------------------------------------------------------------
//  FILE:    RTGameState_TimeStopEffect.uc
//  AUTHOR:  Aleosiss  
//  DATE:    21 June 2016
//  PURPOSE: Extended GameState_Effect that holds damage taken value for the time stop
//---------------------------------------------------------------------------------------

class RTGameState_TimeStopEffect extends XComGameState_Effect config(RTGhost);

var array<WeaponDamageValue> PreventedDamageValues;
var WeaponDamageValue FinalDamageValue;
var bool bExplosive, bCrit;


simulated WeaponDamageValue GetFinalDamageValue() {
  foreach(WeaponDamageValue in PreventDamageValues) {
    
    FinalDamageValue.Damage += WeaponDamageValue.Damage;
    FinalDamageValue.Pierce += WeaponDamageValue.Pierce;
    FinalDamageValue.Rupture += WeaponDamageValue.Rupture;
    FinalDamageValue.Shred += WeaponDamageValue.Shred;
    
  }
  
  FinalDamageValue.Tag = 'TimeStopDamageEffect';
  FinalDamageValue.DamageType = PreventedDamageValues[0].DamageType;
    
  return FinalDamageValue;
}


