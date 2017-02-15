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

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState) {
	local float ExtraDamage, TOTAL_DMG_BONUS;
	local UnitValue UnitVal;
	
	if(Attacker.GetUnitValue('RT_KnockThemDownVal', UnitVal)) {
		ExtraDamage = UnitVal.fValue;
	}
	
	
	return int(ExtraDamage);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints) {
	local UnitValue UnitVal;
	
	SourceUnit.GetUnitValue('RT_KnockThemDownVal', UnitVal);
	
	if(class'RTHelpers'.static.CheckAbilityActivated(kAbility.GetMyTemplateName(), eChecklist_SniperShots)) {
		SourceUnit.SetUnitFloatValue('RT_KnockThemDownVal', UnitVal.fValue + DAMAGE_INCREMENT, eCleanup_BeginTurn);
		return false;
	}

	if(class'RTHelpers'.static.CheckAbilityActivated(kAbility.GetMyTemplateName(), eChecklist_FreeActions)) {
		return false;
	}
	
	`LOG("Rising Tides: Knock Them Down: " @ kAbility.GetMyTemplateName() @ " broke the Knock Them Down chain!");
	SourceUnit.SetUnitFloatValue('RT_KnockThemDownVal', 0, eCleanup_BeginTurn);
		

	return false;
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	DAMAGE_INCREMENT = 1
}
