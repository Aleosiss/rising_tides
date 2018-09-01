// This is an Unreal Script
class RTCondition_UnfurlTheVeil extends X2Condition;

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
	local XComGamestateHistory History;
	local XComGameState_Unit IteratorState;
	local array<XComGameState_Unit> ActivatedUnits;

	History = `XCOMHISTORY;
	// only available if all activated enemies are affected by OTS
	foreach History.IterateByClassType(class'XComGameState_Unit', IteratorState) {
		if(IteratorState.GetTeam() == XComGameState_Unit(kSource).GetTeam()) {
			continue;
		}

		if(IteratorState.GetCurrentStat(eStat_AlertLevel) > 0) {
			ActivatedUnits.AddItem(IteratorState);
		}
	}

	foreach ActivatedUnits(IteratorState) {
		if(IteratorState.AffectedByEffectNames.Find(class'RTAbility_GathererAbilitySet'.default.OverTheShoulderEffectName) == INDEX_NONE) {
			return false;
		}
	}
	return true;
}