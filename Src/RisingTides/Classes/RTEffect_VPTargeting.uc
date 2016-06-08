//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_VPTargeting.uc
//  AUTHOR:  Aleosiss
//  DATE:    3 March 2016
//  PURPOSE: general damage effect
//---------------------------------------------------------------------------------------
//	Vital Point Targeting
//---------------------------------------------------------------------------------------
class RTEffect_VPTargeting extends X2Effect_Persistent;

var int BonusDamage;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	//Check for disabling shot
	if (AbilityState.GetMyTemplateName() == 'DisablingShot')
	{
		return 0;
	}
	if(AppliedData.AbilityResultContext.HitResult == eHit_Crit || AppliedData.AbilityResultContext.HitResult == eHit_Success)
		return BonusDamage;
}																			  
