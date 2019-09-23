// This is an Unreal Script
class RTCondition_UnfurlTheVeil extends X2Condition;

// This is for a self-targeted effect, so the target is also the source.

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
	local XComGameState_Unit TargetUnitState;

	if(kTarget == none) {
		`RTLOG("RTC_UTV: kTarget == none, returning false.");
		return false;
	}

	TargetUnitState = XComGameState_Unit(kTarget);
	if(TargetUnitState == none) {
		`RTLOG("What the fuck is going on here? (RTC_UnfurlTheVeil)", true, false);
		return false;
	}

	if(kSource != none) {
		// CallMeetsConditionWithSource
		if(kSource.ObjectID != kTarget.ObjectID) {
			`RTLOG("RTC_UTV is not self targeted?", true, false);
			return false;
		}
	}

	History = `XCOMHISTORY;
	// only available if all activated enemies are affected by OTS
	foreach History.IterateByClassType(class'XComGameState_Unit', IteratorState) {
		if(!IteratorState.IsEnemyUnit(TargetUnitState)) {
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