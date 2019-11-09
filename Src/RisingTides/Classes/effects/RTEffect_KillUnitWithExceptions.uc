class RTEffect_KillUnitWithExceptions extends X2Effect_ApplyWeaponDamage config(RisingTides);

var array< delegate <KillUnitExceptionFn> > Exceptions;

// Ignore 0 if returned.
delegate int KillUnitExceptionFn(XComgameState_Unit TargetUnit);

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnit;
	local delegate<KillUnitExceptionFn> Exception;
	local int KillAmount;
	local int i;

	TargetUnit = XComGameState_Unit(kNewTargetState);
	KillAmount = 0; 

	if((TargetUnit != none) && !TargetUnit.IsDead())
	{
		foreach Exceptions(Exception) {
			KillAmount += Exception(TargetUnit);
		}
		
		// if we didn't find an exception
		if(KillAmount == 0) {
			KillAmount = TargetUnit.GetCurrentStat(eStat_HP) + TargetUnit.GetCurrentStat(eStat_ShieldHP);
		}
		
		TargetUnit.TakeEffectDamage(self, KillAmount, 0, 0, ApplyEffectParameters, NewGameState, false, false);
	}
}

static function int AlienRulerExceptionHandler(XComGameState_Unit TargetUnitState) {
	if(`CONFIG.MindWrackKillsRulers) {
		return 0;
	}

	if(`RTS.IsUnitAlienRuler(TargetUnitState)) {
		return TargetUnitState.GetMaxStat(eStat_HP) / 4;
	}
}

defaultproperties
{
	bIgnoreBaseDamage = true;
}