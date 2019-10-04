///---------------------------------------------------------------------------------------
//  FILE:    RTEffect_KnockDownThem.uc
//  AUTHOR:  Aleosiss
//  DATE:    5 March 2016
//  PURPOSE: Knock Them Down crit damage calculation
//---------------------------------------------------------------------------------------
//	Knock Them Down Effect
//---------------------------------------------------------------------------------------
class RTEffect_KnockThemDown extends X2Effect_Persistent config(RisingTides);

var int DAMAGE_INCREMENT;
var float CRITDMG_INCREMENT;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState) {
	local float ExtraDamage, CritModifier;
	local UnitValue UnitVal;
	local int CritDamageIncrement;

	if(Attacker.GetUnitValue('RT_KnockThemDownVal', UnitVal)) {
		ExtraDamage = UnitVal.fValue;
		ExtraDamage *= DAMAGE_INCREMENT;
	}

	CritDamageIncrement = 1;

	if (AppliedData.AbilityResultContext.HitResult == eHit_Crit) {
		CritModifier = UnitVal.fValue * CRITDMG_INCREMENT;
		ExtraDamage = (CurrentDamage + ExtraDamage) * (1 + CritModifier);
		ExtraDamage -= CurrentDamage;
	}

	if(`RTS.CheckAbilityActivated(AbilityState.GetMyTemplateName(), eChecklist_SniperShots)) {
		return int(ExtraDamage);
	}

	return 0;
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints) {
	local UnitValue UnitVal;

	SourceUnit.GetUnitValue('RT_KnockThemDownVal', UnitVal);

	if(`RTS.CheckAbilityActivated(kAbility.GetMyTemplateName(), eChecklist_SniperShots)) {
		SourceUnit.SetUnitFloatValue('RT_KnockThemDownVal', UnitVal.fValue + 1, eCleanup_BeginTurn);
		return false;
	}

	if(`RTS.CheckAbilityActivated(kAbility.GetMyTemplateName(), eChecklist_FreeActions)) {
		return false;
	}

	SourceUnit.SetUnitFloatValue('RT_KnockThemDownVal', 0, eCleanup_BeginTurn);
	return false;
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	DAMAGE_INCREMENT = 1
}
