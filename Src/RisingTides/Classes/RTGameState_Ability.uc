// This is an Unreal Script

class RTGameState_Ability extends XComGameState_Ability;

// Get Bloodlust Stack Count  
public static function int getBloodlustStackCount(XComGameState_Unit WaltzUnit) {
   local int iStackCount;
   local StateObjectReference IteratorObjRef;
   local RTGameState_BloodlustEffect BloodlustEffectState;

   if (WaltzUnit != none) {
		// get our stacking effect
		foreach WaltzUnit.AffectedByEffects(IteratorObjRef) {
			BloodlustEffectState = RTGameState_BloodlustEffect(`XCOMHISTORY.GetGameStateForObjectID(IteratorObjRef.ObjectID));
			if(BloodlustEffectState != none) {
				break;
			}
		}
		if(BloodlustEffectState != none) {
			iStackCount = BloodlustEffectState.iStacks;
		} else {
			iStackCount = 0;
		}
	} else  {
		`LOG("Rising Tides: No SourceUnit found for getBloodlustStackCount!");
	}
	return iStackCount;
}

// Reprobate Waltz	
function EventListenerReturn ReprobateWaltzListener( Object EventData, Object EventSource, XComGameState GameState, Name EventID) {
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit WaltzUnit;
	local int iStackCount;
	local float fStackModifier, fFinalPercentChance;

	`LOG("Attempting a Reprobate Waltz");
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	WaltzUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));

	if(AbilityContext != none) {
		iStackCount = getBloodlustStackCount(WaltzUnit);
		fFinalPercentChance = 100 -  ( class'RTAbility_BerserkerAbilitySet'.default.REPROBATE_WALTZ_BASE_CHANCE + ( class'RTAbility_BerserkerAbilitySet'.default.REPROBATE_WALTZ_BLOODLUST_STACK_CHANCE * iStackCount ));
		
		if(`SYNC_RAND(100) <= int(fFinalPercentChance)) {
			AbilityTriggerAgainstSingleTarget(AbilityContext.InputContext.PrimaryTarget, false);
		}	
	}	
	return ELR_NoInterrupt;
}
