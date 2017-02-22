// This is an Unreal Script

class RTCondition_Conditional extends X2Condition;

var bool bConjunction;					// if this is true, all conditions are required to pass  
var array<X2Condition> Conditionals;	// the conditions to check on the first pass
var array<X2Condition> PassConditions;	// return the output of these conditions if we passed the first check
var array<X2Condition> FailConditions;	// return the output of these conditions if we failed the first check

// oh no 
var private XComGameState_Ability			CachedAbilityState;
var private XComGameState_BaseObject		CachedTargetUnitState;
var private XComGameSTate_BaseObject		CachedSourceUnitState;


event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget) {
	local name RetCode; 
	local X2Condition Condition;

	CacheConditionInputs(kAbility, kTarget);

	`LOG(" ");
	`LOG("Rising Tides: Checking AbilityConditionalCondition");
	`LOG("Target = " @ kTarget.GetMyTemplateName());
	`LOG("Ability = " @ kAbility.GetMyTemplateName());

	RetCode = 'AA_Success';

	// check the conditionals
	`LOG("Rising Tides: Checking the ability conditionals...");
	foreach Conditionals(Condition) {
		`LOG("Checking " @ Condition);
		RetCode = Condition.AbilityMeetsCondition(kAbility, kTarget);
		`LOG(RetCode);
		if(RetCode != 'AA_Success' && bConjunction) {
			break;
		}

		if(RetCode == 'AA_Success' && !bConjunction) {
			break;
		}

	}
	// check the pass conditions 
	`LOG("Check RetCode was " @ RetCode);
	if(RetCode == 'AA_Success') {
	`LOG("Rising Tides: Checking the pass ability conditions...");
		foreach PassConditions(Condition) {
			`LOG("Checking " @ Condition);
			RetCode = MeetsAllConditions(Condition, kAbility, kTarget, CachedSourceUnitState);
			`LOG(RetCode);
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
	`LOG("Rising Tides: Checking the fail ability conditions...");
		foreach FailConditions(Condition) {
			`LOG("Checking " @ Condition);
			RetCode = MeetsAllConditions(Condition, kAbility, kTarget, CachedSourceUnitState);
			`LOG(RetCode);
			if(RetCode != 'AA_Success' && bConjunction) {
				break;
			}

			if(RetCode == 'AA_Success' && !bConjunction) {
				break;
			}
		}
	}

	`LOG("Final RetCode was " @ RetCode);

	// need to clear the cache if we're not going to hit the last call
	if(RetCode != 'AA_Success')
		ClearConditionCache();

	return RetCode; 
}


event name CallMeetsCondition(XComGameState_BaseObject kTarget) {
	local name RetCode; 
	local X2Condition Condition;

	`LOG(" ");
	`LOG("Rising Tides: Checking ConditionalCondition");
	`LOG("Target = " @ kTarget.GetMyTemplateName());

	RetCode = 'AA_Success';

	// check the conditionals
	`LOG("Rising Tides: Checking the conditionals...");
	foreach Conditionals(Condition) {
		`LOG("Checking " @ Condition);
		RetCode = Condition.MeetsCondition(kTarget);
		`LOG(RetCode);
		if(RetCode != 'AA_Success' && bConjunction) {
			break;
		}

		if(RetCode == 'AA_Success' && !bConjunction) {
			break;
		}

	}
	// check the pass conditions 
	`LOG("Check RetCode was " @ RetCode);
	if(RetCode == 'AA_Success') {
	`LOG("Rising Tides: Checking the pass conditions...");
		foreach PassConditions(Condition) {
			`LOG("Checking " @ Condition);
			RetCode = MeetsAllConditions(Condition, CachedAbilityState, kTarget, CachedSourceUnitState);
			`LOG(RetCode);
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
	`LOG("Rising Tides: Checking the fail conditions...");
		foreach FailConditions(Condition) {
			`LOG("Checking " @ Condition);
			RetCode = MeetsAllConditions(Condition, CachedAbilityState, kTarget, CachedSourceUnitState);
			`LOG(RetCode);
			if(RetCode != 'AA_Success' && bConjunction) {
				break;
			}

			if(RetCode == 'AA_Success' && !bConjunction) {
				break;
			}
		}
	}

	`LOG("Final RetCode was " @ RetCode);

	// need to clear the cache if we're not going to hit the last call
	if(RetCode != 'AA_Success')
		ClearConditionCache();

	return RetCode; 
}

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource) { 
	local name RetCode;
	local X2Condition Condition;						

	RetCode = 'AA_Success';
   	`LOG(" ");
	`LOG("Rising Tides: Checking ConditionalConditionWithSource");	
	`LOG("Target = " @ kTarget.GetMyTemplateName());
	`LOG("Source = " @ kSource.GetMyTemplateName());

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
	`LOG("Check Source RetCode was " @ RetCode);
	// check the pass conditions 
	if(RetCode == 'AA_Success') {
		`LOG("Rising Tides: Checking the pass conditions with source...");
		foreach PassConditions(Condition) {
			`LOG("Checking " @ Condition);
			RetCode = MeetsAllConditions(Condition, CachedAbilityState, kTarget, kSource);
			`LOG(RetCode);
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
		`LOG("Rising Tides: Checking the fail conditions with source...");
		foreach FailConditions(Condition) {
			`LOG("Checking " @ Condition);
			RetCode = MeetsAllConditions(Condition, CachedAbilityState, kTarget, kSource);
			`LOG(RetCode);
			if(RetCode != 'AA_Success' && bConjunction) {
				break;
			}

			if(RetCode == 'AA_Success' && !bConjunction) {
				break;
			}
		}
	}

	`LOG("Final Source RetCode was " @ RetCode);
	// always clear here
	ClearConditionCache();

	return RetCode; 
}

protected function CacheConditionInputs(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget) {
	CachedAbilityState = kAbility;
	CachedTargetUnitState = kTarget;
	CachedSourceUnitState = XComGameState_BaseObject(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
}

protected function ClearConditionCache() {
	CachedAbilityState = none;
	CachedTargetUnitState = none;
	CachedSourceUnitState = none;
}

// this function replicates the same logic found in X2Effect
protected static function name MeetsAllConditions(X2Condition Condition, XComGameState_Ability kAbility, XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource) {
	local name RetCode;

	RetCode = 'AA_Success';

	RetCode = Condition.AbilityMeetsCondition(kAbility, kTarget);
	if(RetCode != 'AA_Success') {
		return RetCode;
	}

	RetCode = Condition.MeetsCondition(kTarget);
	if(RetCode != 'AA_Success') {
		return RetCode;
	}

	RetCode = Condition.MeetsConditionWithSource(kTarget, kSource);
	if(RetCode != 'AA_Success') {
		return RetCode;
	}

	return RetCode;
}



