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

// credits to /u/robojumper

//This function is native for performance reasons, the script code below describes its function
// NO LONGER AM I SHACKLED BY NATIVE CODE
simulated function name GatherAbilityTargets(out array<AvailableTarget> Targets, optional XComGameState_Unit OverrideOwnerState)
{
	local int i, j;
	local XComGameState_Unit kOwner;
	local name AvailableCode;
	local XComGameStateHistory History;

	GetMyTemplate();
	History = `XCOMHISTORY;
	kOwner = XComGameState_Unit(History.GetGameStateForObjectID(OwnerStateObject.ObjectID));
	if (OverrideOwnerState != none)
		kOwner = OverrideOwnerState;

	if (m_Template != None)
	{
		AvailableCode = m_Template.AbilityTargetStyle.GetPrimaryTargetOptions(self, Targets);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;
	
		for (i = Targets.Length - 1; i >= 0; --i)
		{
			AvailableCode = m_Template.CheckTargetConditions(self, kOwner, History.GetGameStateForObjectID(Targets[i].PrimaryTarget.ObjectID));
			if (AvailableCode != 'AA_Success')
			{
				Targets.Remove(i, 1);
			}
		}

		if (m_Template.AbilityMultiTargetStyle != none)
		{
			m_Template.AbilityMultiTargetStyle.GetMultiTargetOptions(self, Targets);

			for (i = Targets.Length - 1; i >= 0; --i)
			{
				for (j = Targets[i].AdditionalTargets.Length - 1; j >= 0; --j)
				{
					AvailableCode = m_Template.CheckMultiTargetConditions(self, kOwner, History.GetGameStateForObjectID(Targets[i].AdditionalTargets[j].ObjectID));
					if (AvailableCode != 'AA_Success' || (Targets[i].AdditionalTargets[j].ObjectID == Targets[i].PrimaryTarget.ObjectID) && !m_Template.AbilityMultiTargetStyle.bAllowSameTarget)
					{
						Targets[i].AdditionalTargets.Remove(j, 1);
					}
				}

				AvailableCode = m_Template.AbilityMultiTargetStyle.CheckFilteredMultiTargets(self, Targets[i]);
				if (AvailableCode != 'AA_Success')
					Targets.Remove(i, 1);
			}
		}

		//The Multi-target style may have deemed some primary targets invalid in calls to CheckFilteredMultiTargets - so CheckFilteredPrimaryTargets must come afterwards.
		AvailableCode = m_Template.AbilityTargetStyle.CheckFilteredPrimaryTargets(self, Targets);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;

		Targets.Sort(SortAvailableTargets);
	}
	return 'AA_Success';
}

simulated function int SortAvailableTargets(AvailableTarget TargetA, AvailableTarget TargetB)
{
	local XComGameStateHistory History;
	local XComGameState_Destructible DestructibleA, DestructibleB;
	local int HitChanceA, HitChanceB;
	local ShotBreakdown BreakdownA, BreakdownB;

	if (TargetA.PrimaryTarget.ObjectID != 0 && TargetB.PrimaryTarget.ObjectID == 0)
	{
		return -1;
	}
	if (TargetB.PrimaryTarget.ObjectID != 0 && TargetA.PrimaryTarget.ObjectID == 0)
	{
		return 1;
	}
	if (TargetA.PrimaryTarget.ObjectID == 0 && TargetB.PrimaryTarget.ObjectID == 0)
	{
		return 1;
	}
	History = `XCOMHISTORY;
	DestructibleA = XComGameState_Destructible(History.GetGameStateForObjectID(TargetA.PrimaryTarget.ObjectID));
	DestructibleB = XComGameState_Destructible(History.GetGameStateForObjectID(TargetB.PrimaryTarget.ObjectID));
	if (DestructibleA != none && DestructibleB == none)
	{
		return -1;
	}
	if (DestructibleB != none && DestructibleA == none)
	{
		return 1;
	}

	HitChanceA = GetShotBreakdown(TargetA, BreakdownA);
	HitChanceB = GetShotBreakdown(TargetB, BreakdownB);
	if (HitChanceA < HitChanceB)
	{
		return -1;
	}

	return 1;
}




defaultproperties
{
}
