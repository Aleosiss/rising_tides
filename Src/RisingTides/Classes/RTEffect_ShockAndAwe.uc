// This is an Unreal Script			 

class RTEffect_ShockAndAwe extends X2Effect_Persistent;

var int iDamageRequiredToActivate;
/*
function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit Attacker, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Unit			EffectTargetUnit, PanicTargetUnit;
	local X2EventManager					EventMgr;
	local XComGameState_Ability				AbilityState;
	local UnitValue							DamageDealt, ShockCounter;
	local int								iTotalDamageDealt;
	local bool								bIsStandardFire, bIsMindWrack, bDealtDamage;

	`LOG("Shock N' Awe called!");
	bIsStandardFire = false;
	bIsMindWrack = false;
	
	if(kAbility.GetMyTemplateName() == 'RTStandardSniperShot' || kAbility.GetMyTemplateName() == 'DaybreakFlame' || kAbility.GetMyTemplateName() == 'RTPrecisionShot' || kAbility.GetMyTemplateName() == 'RTDisablingShot' || kAbility.GetMyTemplateName() == 'RTOverwatchShot')
		bIsStandardFire = true;
	if(AbilityContext.ResultContext.HitResult == eHit_Crit || AbilityContext.ResultContext.HitResult == eHit_Graze || AbilityContext.ResultContext.HitResult == eHit_Success)
		bDealtDamage = true;
		
	//  make sure we're dealing damage
	if (bIsStandardFire)
	{  
		EffectTargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
		if (EffectTargetUnit != none && bDealtDamage)
		{
			// math
			EffectTargetUnit.GetUnitValue('LastEffectDamage', DamageDealt);
			Attacker.GetUnitValue('ShockAndAweCounter', ShockCounter);

			iTotalDamageDealt = int(DamageDealt.fValue) + int(ShockCounter.fValue);
			if(iTotalDamageDealt < iDamageRequiredToActivate) {
				Attacker.SetUnitFloatValue('ShockAndAweCounter', iTotalDamageDealt, eCleanup_BeginTurn);
			} else {
				// t-t-t-t-triggered
				`XEVENTMGR.TriggerEvent('ShockAndAweTrigger', EffectTargetUnit, Attacker, NewGameState);	
				while(iTotalDamageDealt > iDamageRequiredToActivate) {
					iTotalDamageDealt -= iDamageRequiredToActivate;
				}
				Attacker.SetUnitFloatValue('ShockAndAweCounter', iTotalDamageDealt, eCleanup_BeginTurn);
			}												 
		}
	} 																		
	return false;
} */

