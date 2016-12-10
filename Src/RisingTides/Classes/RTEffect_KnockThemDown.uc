///---------------------------------------------------------------------------------------
//  FILE:    RTEffect_KnockDownThem.uc
//  AUTHOR:  Aleosiss
//  DATE:    5 March 2016
//  PURPOSE: Knock Them Down crit damage calculation
//---------------------------------------------------------------------------------------
//	Knock Them Down Effect
//---------------------------------------------------------------------------------------
class RTEffect_KnockThemDown extends X2Effect_Persistent config(RisingTides);

	var float CRIT_DAMAGE_MODIFIER;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local float ExtraDamage, TOTAL_DMG_BONUS;
	local array<StateObjectReference> VisibleUnits, SSVisibleUnits;
	local int iNumUnits;
	

	//Check for crit
	if (AppliedData.AbilityResultContext.HitResult == eHit_Crit)
	{
		//Get total number of enemy units visible to the UI
		class'X2TacticalVisibilityHelpers'.static.GetAllVisibleEnemyUnitsForUnit(Attacker.ObjectID, VisibleUnits);
		class'X2TacticalVisibilityHelpers'.static.GetAllSquadsightEnemiesForUnit(Attacker.ObjectID, SSVisibleUnits);
		iNumUnits = VisibleUnits.length + SSVisibleUnits.length;
	
		TOTAL_DMG_BONUS = iNumUnits * CRIT_DAMAGE_MODIFIER;
		ExtraDamage = CurrentDamage * TOTAL_DMG_BONUS;
	}
	return int(ExtraDamage);
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
}
