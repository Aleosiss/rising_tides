// This is an Unreal Script

class RTCondition_Conditional extends X2Condition;

var bool bCheckSource;
var bool bConjunction;					// if this is true, all conditions are required to pass  
var array<X2Condition> Conditionals;	// the conditions to check on the first pass
var array<X2Condition> PassConditions;	// return the output of these conditions if we passed the first check
var array<X2Condition> FailConditions;	// return the output of these conditions if we failed the first check


event name CallMeetsCondition(XComGameState_BaseObject kTarget) {
	local name RetCode; 
	local X2Condition Condition;

	// check the conditionals
	foreach Conditionals(Condition) {
		RetCode = Condition.CallMeetsCondition(kTarget);
		if(RetCode != 'AA_Success' && bConjunction) {
			break;
		}

		if(RetCode == 'AA_Success' && !bConjunction) {
			break;
		}

	}
	// check the pass conditions 
	if(RetCode != 'AA_Success') {
		foreach PassConditions(Condition) {
			RetCode = Condition.CallMeetsCondition(kTarget);
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
			RetCode = Condition.CallMeetsCondition(kTarget);
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




event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource) { 
	local name RetCode;
	local X2Condition Conditional;

	// check the conditionals
	foreach Conditionals(Condition) {
		RetCode = Condition.CallMeetsConditionWithSource(kTarget, kSource);
		if(RetCode != 'AA_Success' && bConjunction) {
			break;
		}

		if(RetCode == 'AA_Success' && !bConjunction) {
			break;
		}

	}
	// check the pass conditions 
	if(RetCode != 'AA_Success') {
		foreach PassConditions(Condition) {
			RetCode = Condition.CallMeetsConditionWithSource(kTarget, kSource);
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
			RetCode = Condition.CallMeetsConditionWithSource(kTarget, kSource);
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