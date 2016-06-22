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

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit Attacker, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Unit				EffectTargetUnit, PanicTargetUnit;
	local X2EventManager					EventMgr;
	local XComGameState_Ability				AbilityState;
	local GameRulesCache_VisibilityInfo		VisInfo;
	local UnitValue							NumTimes;
	local array<StateObjectReference>		VisibleUnits;
	local int								Index, RandRoll;
	local bool								bIsStandardFire;

	bIsStandardFire = false;
	if(kAbility.GetMyTemplateName() == 'RTStandardSniperShot' || kAbility.GetMyTemplateName() == 'DaybreakFlame' || kAbility.GetMyTemplateName() == 'PrecisionShot' || kAbility.GetMyTemplateName() == 'DisablingShot')
		bIsStandardFire = true;
	//  make sure we're shooting a gun
	if (bIsStandardFire)
	{
		// if the target is dead 
		EffectTargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
		if (EffectTargetUnit != none && EffectTargetUnit.IsDead())
		{
			// Sovereign check
					if(Attacker.HasSoldierAbility('Sovereign'))
					{
						// Getting all visible units to the dead target
						class'RTTacticalVisibilityHelpers'.static.GetAllVisibleAlliesForUnit(EffectTargetUnit.ObjectID, VisibleUnits/*, -1, false*/);
						for(Index = 0; Index < VisibleUnits.Length; Index++)
						{
							// Units within 4 tiles of the source that aren't psionic or robotic or the source
							PanicTargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(VisibleUnits[Index].ObjectID));
							if(EffectTargetUnit.TileDistanceBetween(PanicTargetUnit) < 4) 
							{
								if(!PanicTargetUnit.IsRobotic() && !PanicTargetUnit.IsPsionic())
								{
									// 20% chance
									RandRoll = `SYNC_RAND(100);
									`COMBATLOG("Sovereign rolled " @ RandRoll @ "; Target is 19!");
									if(RandRoll < SOVEREIGN_PANIC_CHANCE)
									{
										// T-T-Triggered
										EventMgr = `XEVENTMGR;
										EventMgr.TriggerEvent('SovereignTrigger', PanicTargetUnit, Attacker, NewGameState);
									}
								}
							}
						}
					}
			//return true;
		}
	}																						
	return false;
}

DefaultProperties
{
	EffectName="RTEffect_Sovereign"
	SOVEREIGN_PANIC_CHANCE=20
}
