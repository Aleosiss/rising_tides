//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_PrecisionShotDamage.uc
//  AUTHOR:  Aleosiss
//  DATE:    3 March 2016
//  PURPOSE: Gives Precision Shot its damage boost
//  NOTES: Credit to steam user guby for GetToHitModifiers function         
//---------------------------------------------------------------------------------------
//	Precision Shot damage effect
//---------------------------------------------------------------------------------------
class RTEffect_VPTargeting extends X2Effect_Persistent;

var int BonusDamage;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage)
{
	//Check for disabling shot
	if (AbilityState.GetMyTemplateName() == 'DisablingShot')
	{
		return 0;
	}
	return BonusDamage;
}																			  