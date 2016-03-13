//---------------------------------------------------------------------------------------
//  FILE:    RTAbilityCost_SnapshotActionPoints.uc
//  AUTHOR:  Aleosiss
//  DATE:    6 March 2016
//  PURPOSE: Whether or not 
//---------------------------------------------------------------------------------------
//	If this unit has snapshot, you can shoot with only one point.
//---------------------------------------------------------------------------------------

class RTAbilityCost_SnapshotActionPoints extends X2AbilityCost_ActionPoints;

simulated function int GetPointCost(XComGameState_Ability AbilityState, XComGameState_Unit AbilityOwner)
{
	if (AbilityOwner.HasSoldierAbility('Snapshot'))
		return 1;
	else
		return 2;
}