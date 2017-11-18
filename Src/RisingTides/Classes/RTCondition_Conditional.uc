// This is an Unreal Script

class RTCondition_Conditional extends X2Condition;

var bool bConjunction;					// if this is true, all conditions are required to pass
var array<X2Condition> Conditionals;	// the conditions to check on the first pass
var array<X2Condition> PassConditions;	// return the output of these conditions if we passed the first check
var array<X2Condition> FailConditions;	// return the output of these conditions if we failed the first check

// oh no
// Not sure of a better way around the problem of being able to call every Condition check from within every Condition check
var private XComGameState_Ability			CachedAbilityState;
var private XComGameState_BaseObject		CachedTargetUnitState;
var private XComGameState_Unit				CachedSourceUnitState;

var private bool bMeetsCondition;
var private bool bMeetsConditionWithSource;
var private bool bAbilityMeetsCondition;


event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget) {
	local name RetCode;
	local X2Condition Condition;

	// this is usually called  last; for AbilityShooterConditions, the source is the target
	CacheConditionInputs(kTarget, kAbility, );
	bAbilityMeetsCondition = true;
	RetCode = 'AA_Success';

	// check the conditionals
	foreach Conditionals(Condition) {
		RetCode = Condition.AbilityMeetsCondition(kAbility, kTarget);
		if(RetCode != 'AA_Success' && bConjunction) {
			break;
		}

		if(RetCode == 'AA_Success' && !bConjunction) {
			break;
		}

	}

	if(RetCode != 'AA_Success') {
			bAbilityMeetsCondition = false;
	}

	RetCode = CheckSubConditions();

	// need to clear the cache

	ClearConditionCache();

	return RetCode;
}


event name CallMeetsCondition(XComGameState_BaseObject kTarget) {
	local name RetCode;
	local X2Condition Condition;

	bMeetsCondition = true;
	RetCode = 'AA_Success';
	CacheConditionInputs(kTarget, , );

	// check the conditionals
	foreach Conditionals(Condition) {
		RetCode = Condition.MeetsCondition(kTarget);
		if(RetCode != 'AA_Success' && bConjunction) {
			break;
		}

		if(RetCode == 'AA_Success' && !bConjunction) {
			break;
		}

	}

	if(RetCode != 'AA_Success') {
		bMeetsCondition = false;
	}


	return 'AA_Success';
}

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource) {
	local name RetCode;
	local X2Condition Condition;

	bMeetsConditionWithSource = true;
	RetCode = 'AA_Success';
	CacheConditionInputs(kTarget, , XComGameState_Unit(kSource));
	// check the conditionals
	`LOG("Rising Tides: Checking the conditionals with source...");
	foreach Conditionals(Condition) {
		`LOG("Checking " @ Condition);
		RetCode = Condition.MeetsConditionWithSource(kTarget, kSource);
		`LOG(RetCode);
		if(RetCode != 'AA_Success' && bConjunction) {
			break;
		}

		if(RetCode == 'AA_Success' && !bConjunction) {
			break;
		}

	}

	if(RetCode != 'AA_Success') {
		bMeetsConditionWithSource = false;
	}


	//RetCode = CheckSubConditions();

	return 'AA_Success';
}

protected function CacheConditionInputs(XComGameState_BaseObject kTarget, optional XComGameState_Ability kAbility, optional XComGameState_Unit kSource) {
	if(kAbility != none)
		CachedAbilityState = kAbility;

	CachedTargetUnitState = kTarget;

	if(kSource == none) {
		if(CachedAbilityState == none)
			CachedSourceUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(CachedAbilityState.OwnerStateObject.ObjectID));
	} else
		CachedSourceUnitState = kSource;

}

protected function ClearConditionCache() {
	CachedAbilityState = none;
	CachedTargetUnitState = none;
	CachedSourceUnitState = none;

	bAbilityMeetsCondition = true;
	bMeetsCondition = true;
	bMeetsConditionWithSource = true;
}

// this function replicates the same logic found in CheckTargetConditions
protected static function name MeetsAllConditions(X2Condition Condition, XComGameState_Ability kAbility, XComGameState_BaseObject kTarget, XComGameState_Unit kSource) {
	local name RetCode;

	RetCode = 'AA_Success';

	RetCode = Condition.MeetsCondition(kTarget);
	if(RetCode != 'AA_Success') {
		return RetCode;
	}

	RetCode = Condition.MeetsConditionWithSource(kTarget, kSource);
	if(RetCode != 'AA_Success') {
		return RetCode;
	}

	RetCode = Condition.AbilityMeetsCondition(kAbility, kTarget);
	if(RetCode != 'AA_Success') {
		return RetCode;
	}

	return RetCode;
}

protected function name CheckSubConditions() {
	local X2Condition Condition;
	local name RetCode;

	RetCode = 'AA_Success';

	if(bAbilityMeetsCondition && bMeetsCondition && bMeetsConditionWithSource) {
			foreach PassConditions(Condition) {
					RetCode = MeetsAllConditions(Condition, CachedAbilityState, CachedTargetUnitState, CachedSourceUnitState);
					if(RetCode != 'AA_Success' && bConjunction) {
							break;
					}

					if(RetCode == 'AA_Success' && !bConjunction) {
							break;
					}
			}
	}
	// check the fail conditions
	else {
			foreach FailConditions(Condition) {
					RetCode = MeetsAllConditions(Condition, CachedAbilityState, CachedTargetUnitState, CachedSourceUnitState);
					if(RetCode != 'AA_Success' && bConjunction) {
							break;
					}

					if(RetCode == 'AA_Success' && !bConjunction) {
							break;
					}
			}
	}

	return RetCode;

}

defaultproperties {
	bAbilityMeetsCondition = true
	bMeetsCondition = true
	bMeetsConditionWithSource = true
}
