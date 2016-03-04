//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_Aggression.uc
//  AUTHOR:  Aleosiss
//  DATE:    3 March 2016
//  PURPOSE: Aggression crit calculation
//---------------------------------------------------------------------------------------
//	Aggresion
//---------------------------------------------------------------------------------------

class RTEffect_Aggression extends X2Effect_Persistent config(RTMarksman);

var localized string RTFriendlyName;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;
	local XComGameState_Item SourceWeapon;
	local array<StateObjectReference> VisibleUnits, SSVisibleUnits;
	local int crit_bonus, numUnits;

	//Get total number of enemy units visible to the UI
	class'X2TacticalVisibilityHelpers'.static.GetAllVisibleEnemyUnitsForUnit(Attacker.ObjectID, VisibleUnits);
	class'X2TacticalVisibilityHelpers'.static.GetAllSquadsightEnemiesForUnit(Attacker.ObjectID, SSVisibleUnits);
	numUnits = VisibleUnits.length + SSVisibleUnits.length;
	
	SourceWeapon = AbilityState.GetSourceWeapon();
	//Add bonus crit chance if we're using a weapon
	if (SourceWeapon != none)
	{
		ModInfo.ModType = eHit_Crit;
		ModInfo.Reason = RTFriendlyName;

		crit_bonus = 10 * numUnits;			
		if(crit_bonus < 30)
		{
			ModInfo.Value = crit_bonus;
		}
		else
		{
			ModInfo.Value = 30;
		}

		ShotModifiers.AddItem(ModInfo);
	}
}