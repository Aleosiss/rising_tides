//
// Robotic units use hack defense in the place of will for mental psi attacks and defense for physical ones
// Also Friendly Units should be deadeye nigga

// 

class RTAbilityToHitCalc_StatCheck_UnitVsUnit extends X2AbilityToHitCalc_StatCheck_UnitVsUnit;

var bool bPhysical;

function int GetAttackValue(XComGameState_Ability kAbility, StateObjectReference TargetRef)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
	return UnitState.GetCurrentStat(AttackerStat);
}

function int GetDefendValue(XComGameState_Ability kAbility, StateObjectReference TargetRef)
{
	local XComGameState_Unit UnitState, SourceUnitState;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(TargetRef.ObjectID));
	SourceUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));

	if(SourceUnitState.IsFriendlyUnit(UnitState))
		return 0;

	if(!UnitState.IsRobotic()) return UnitState.GetCurrentStat(DefenderStat);
	else if(bPhysical) return UnitState.GetCurrentStat(eStat_HackDefense);
	else return UnitState.GetCurrentStat(eStat_Defense);
}

function string GetAttackString() { return class'X2TacticalGameRulesetDataStructures'.default.m_aCharStatLabels[AttackerStat]; }
function string GetDefendString() { return class'X2TacticalGameRulesetDataStructures'.default.m_aCharStatLabels[DefenderStat]; }

DefaultProperties
{
	AttackerStat = eStat_PsiOffense
	DefenderStat = eStat_Will
}