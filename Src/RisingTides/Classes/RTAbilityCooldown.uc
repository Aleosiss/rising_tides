//---------------------------------------------------------------------------------------
//  FILE:    RTAbilityCooldown.uc
//
//
//---------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------
class RTAbilityCooldown extends X2AbilityCooldown;

simulated function int GetNumTurns(XComGameState_Ability kAbility, XComGameState_BaseObject AffectState, XComGameState_Item AffectWeapon, XComGameState NewGameState)
{
	if (XComGameState_Unit(AffectState).IsUnitAffectedByEffectName('RTEffect_PsionicSurge'))	  {
		return 0;
	}
	return iNumTurns;
}

DefaultProperties
{
	iNumTurns = 4
}
