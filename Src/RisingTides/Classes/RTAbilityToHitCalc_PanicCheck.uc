// This is an Unreal Script

class RTAbilityToHitCalc_PanicCheck extends X2AbilityToHitCalc_PanicCheck;

function int GetDefendValue(XComGameState_Ability kAbility, StateObjectReference TargetRef)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(TargetRef.ObjectID));

	if(UnitState.IsRobotic())
		return UnitState.GetCurrentStat(eStat_HackDefense);

	return UnitState.GetCurrentStat(eStat_Will);
}
