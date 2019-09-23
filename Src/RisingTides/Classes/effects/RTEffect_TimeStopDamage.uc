class RTEffect_TimeStopDamage extends X2Effect_ApplyWeaponDamage
	config(RisingTides);

function WeaponDamageValue GetBonusEffectDamageValue(XComGameState_Ability AbilityState, XComGameState_Unit SourceUnit, XComGameState_Item SourceWeapon, StateObjectReference TargetRef)
{
	local RTGameState_TimeStopEffect TimeStopEffectState;
	local XComGameState_Unit TargetUnitState;
	local WeaponDamageValue ReturnDamageValue;


	TargetUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(TargetRef.ObjectID));
	TimeStopEffectState = RTGameState_TimeStopEffect(TargetUnitState.GetUnitAffectedByEffectState(class'RTAbility_MarksmanAbilitySet'.default.TimeStopEffectName));

	if(TimeStopEffectState != none) {
		// And thus, time resumes...
		ReturnDamageValue = TimeStopEffectState.GetFinalDamageValue();
	}


	return ReturnDamageValue;
}

DefaultProperties
{
	bAllowFreeKill=false
	bIgnoreBaseDamage=true
}
