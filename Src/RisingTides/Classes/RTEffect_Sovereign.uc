//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_Sovereign.uc
//  AUTHOR:  Aleosiss
//  DATE:    11 March 2016
//  PURPOSE: Tick panic on crit kills      
//---------------------------------------------------------------------------------------
//	Tick Panic
//---------------------------------------------------------------------------------------
class RTEffect_Sovereign extends X2Effect_Persistent;

var int SOVEREIGN_PANIC_CHANCE;

/*
function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit Attacker, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Unit				EffectTargetUnit, PanicTargetUnit;
	local X2EventManager					EventMgr;
	local XComGameState_Ability				AbilityState;
	local GameRulesCache_VisibilityInfo		VisInfo;
	local UnitValue							NumTimes;
	local array<StateObjectReference>		VisibleUnits;
	local int								Index, RandRoll;
	local bool								bIsStandardFire, bIsMindWrack, bIsCriticalHit, bTesting;

	bIsStandardFire = false;
	bIsMindWrack = false;
	bIsCriticalHit = false;

	bTesting = true;
	`LOG("Sovereign called!");

	if(kAbility.GetMyTemplateName() == 'RTStandardSniperShot' || kAbility.GetMyTemplateName() == 'DaybreakFlame' || kAbility.GetMyTemplateName() == 'PrecisionShot' || kAbility.GetMyTemplateName() == 'DisablingShot')
		bIsStandardFire = true;
	if(kAbility.GetMyTemplateName() == 'PsiOverload')
		bIsMindWrack = true;
	if(EffectState.ApplyEffectParameters.AbilityResultContext.HitResult == eHit_Crit)
		bIsCriticalHit = true;
		
	//  make sure we're getting a crit with a gun or using mind wrack
	if (bIsStandardFire && bIsCriticalHit || bIsMindWrack)
	{
		// if the target is dead
		EffectTargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
		if (EffectTargetUnit != none && EffectTargetUnit.IsDead())
		{
			// Sovereign check
			if(Attacker.HasSoldierAbility('Sovereign'))
			{
				// Rewrite this filth, one AOE panic attack, not an individual panic attack against every unit in an AOE
				// Panic
				RandRoll = `SYNC_RAND(100);
				if(RandRoll < SOVEREIGN_PANIC_CHANCE || bTesting)
				{
					// T-T-Triggered
					EventMgr = `XEVENTMGR;
					EventMgr.TriggerEvent('SovereignTrigger', PanicTargetUnit, Attacker, NewGameState);
				}
			}
		}
	}
			//return true;
		
																							
	return false;
}
*/

DefaultProperties
{
	EffectName="RTEffect_Sovereign"
	SOVEREIGN_PANIC_CHANCE=20
}
