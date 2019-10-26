//---------------------------------------------------------------------------------------
//  FILE:    RTAbilityCost_ActionPoints.uc
//  AUTHOR:  Aleosiss
//  DATE:    6 March 2016
//  PURPOSE: Custom action point costs
//---------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------

class RTAbilityCost_SnapshotActionPoints extends X2AbilityCost_ActionPoints;

var bool bIgnore;

simulated function int GetPointCost(XComGameState_Ability AbilityState, XComGameState_Unit AbilityOwner)
{
	if (AbilityOwner.HasSoldierAbility('RTSnapshot') || AbilityOwner.IsUnitAffectedByEffectName('RTEffect_PsionicSurge'))
		return 1;
	else
		return super.GetPointCost(AbilityState, AbilityOwner);
}

simulated function bool ConsumeAllPoints(XComGameState_Ability AbilityState, XComGameState_Unit AbilityOwner)
{
	if(!bIgnore) {
		if (AbilityOwner.IsUnitAffectedByEffectName('RTEffect_PsionicSurge')) {
			return false;
		}
	}
	return super.ConsumeAllPoints(AbilityState, AbilityOwner);
}

DefaultProperties
{
	bIgnore = false
	bConsumeAllPoints = true
	iNumPoints = 2
}
