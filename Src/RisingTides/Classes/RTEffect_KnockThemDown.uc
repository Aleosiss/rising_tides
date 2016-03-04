///---------------------------------------------------------------------------------------
//  FILE:    RTEffect_KnockDownThem.uc
//  AUTHOR:  Aleosiss
//  DATE:    5 March 2016
//  PURPOSE: Knock Them Down crit damage calculation
//---------------------------------------------------------------------------------------
//	Knock Them Down Effect
//---------------------------------------------------------------------------------------
class RTEffect_KnockThemDown extends X2Effect_Persistent config(RTMarksman);

	var config float CRIT_DAMAGE_MODIFIER;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage)
{
	local float ExtraDamage, TOTAL_DMG_BONUS;
	local array<StateObjectReference> VisibleUnits, SSVisibleUnits;
	local int numUnits;
	
	//Get total number of enemy units visible to the UI
	class'X2TacticalVisibilityHelpers'.static.GetAllVisibleEnemyUnitsForUnit(Attacker.ObjectID, VisibleUnits);
	class'X2TacticalVisibilityHelpers'.static.GetAllSquadsightEnemiesForUnit(Attacker.ObjectID, SSVisibleUnits);
	numUnits = VisibleUnits.length + SSVisibleUnits.length;
	
	TOTAL_DMG_BONUS = numUnits * CRIT_DAMAGE_MODIFIER;
	//Check for crit
	if (AppliedData.AbilityResultContext.HitResult == eHit_Crit)
	{
		ExtraDamage = CurrentDamage * TOTAL_DMG_BONUS;
	}
	`log("TOTAL_DMG_BONUS = ");
	`log(TOTAL_DMG_BONUS);
	`log("Extra Damage =");
	`log(ExtraDamage);
	return int(ExtraDamage);
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
}