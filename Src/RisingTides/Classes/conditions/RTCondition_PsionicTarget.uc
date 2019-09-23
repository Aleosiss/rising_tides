// This is an Unreal Script
class RTCondition_PsionicTarget extends X2Condition;

var bool bIgnoreRobotic;
var bool bIgnorePsionic;
var bool bIgnoreGHOSTs;
var bool bIgnoreDead;
var bool bIgnoreEnemies;
var bool bTargetAllies;
var bool bTargetCivilians;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) {
	if(CheckTarget(kTarget))
		return 'AA_Success';
	return 'AA_AbilityUnavailable';

}
event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource) {
	if(CheckTarget(kTarget, kSource))
		return 'AA_Success';
	return 'AA_AbilityUnavailable';
}

private function bool CheckTarget(XComGameState_BaseObject kTarget, optional XComGameState_BaseObject kSource) {
	local XComGameState_Unit TargetUnitState, SourceUnitState;

	TargetUnitState = XComGameState_Unit(kTarget);
	SourceUnitState = XComGameState_Unit(kSource);
	if(TargetUnitState == none) // I'm not sure if there are going to be any non-unit Psionic targets.
		return false;		// Will need to revisit if that changes.
								// Technopathy's hacking abilities won't use this condition.

	if(TargetUnitState.GetMyTemplate().bIsCosmetic) {
		return false;
	}

	if(bIgnorePsionic && TargetUnitState.IsPsionic()) {
		return false;
	}

	if(bIgnoreRobotic && TargetUnitState.IsRobotic()) {
		return false;
	}

	if(bIgnoreDead && TargetUnitState.IsDead())	{
		return false;
	}

	if(bIgnoreGHOSTs && TargetUnitState.AffectedByEffectNames.Find(class'RTAbility'.default.RTGhostTagEffectName) != INDEX_NONE) {
		return false;
	}

	if(!bTargetCivilians && TargetUnitState.GetMyTemplate().bIsCivilian) {
		return false;
	}

	if(kSource == none) { // MeetsCondition ends here
		return true;
	}

	if(!bTargetAllies && TargetUnitState.IsFriendlyUnit(SourceUnitState)) {
		return false;
	}

	if(bIgnoreEnemies && TargetUnitState.IsEnemyUnit(SourceUnitState)) {
		return false;
	}

	if(!SourceUnitState.HasSoldierAbility(class'RTAbility'.default.RTTechnopathyTemplateName) && TargetUnitState.IsRobotic()) { // Technopathy check
		return false;
	}

	return true;
}


defaultproperties
{
	bIgnoreDead = true
}
