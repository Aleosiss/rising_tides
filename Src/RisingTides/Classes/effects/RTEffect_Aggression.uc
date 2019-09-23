//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_Aggression.uc
//  AUTHOR:  Aleosiss
//  DATE:    3 March 2016
//  PURPOSE: Aggression crit calculation
//---------------------------------------------------------------------------------------
//	Aggresion
//---------------------------------------------------------------------------------------

class RTEffect_Aggression extends X2Effect_Persistent config(RTMarksman);

var int iCritBonusPerUnit;
var int iUnitsForMaxBonus;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;
	local XComGameState_Item SourceWeapon;
	local array<StateObjectReference> VisibleUnits, SSVisibleUnits;
	local int crit_bonus, numUnits, max_bonus;

	//Get total number of enemy units visible to the UI
	class'X2TacticalVisibilityHelpers'.static.GetAllVisibleEnemyUnitsForUnit(Attacker.ObjectID, VisibleUnits);
	class'X2TacticalVisibilityHelpers'.static.GetAllSquadsightEnemiesForUnit(Attacker.ObjectID, SSVisibleUnits);
	numUnits = VisibleUnits.length + SSVisibleUnits.length;

	SourceWeapon = AbilityState.GetSourceWeapon();
	//Add bonus crit chance if we're using a weapon
	if (SourceWeapon != none)
	{
		ModInfo.ModType = eHit_Crit;
		ModInfo.Reason = AbilityState.GetMyTemplate().LocFriendlyName;

		crit_bonus = iCritBonusPerUnit * numUnits;
		max_bonus = iCritBonusPerUnit * iUnitsForMaxBonus;
		if(crit_bonus < max_bonus)
		{
			ModInfo.Value = crit_bonus;
		}
		else
		{
			ModInfo.Value = max_bonus;
		}

		ShotModifiers.AddItem(ModInfo);
	}
}
