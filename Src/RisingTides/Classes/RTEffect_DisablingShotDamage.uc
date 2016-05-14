//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_DisablingShotDamage.uc
//  AUTHOR:  Aleosiss
//  DATE:    4 March 2016
//  PURPOSE: Gives Disabling Shot its damage reduction      
//---------------------------------------------------------------------------------------
//	Disabling Shot damage effect
//---------------------------------------------------------------------------------------
class RTEffect_DisablingShotDamage extends X2Effect_Persistent config(RTMarksman);

var config float DISABLING_SHOT_REDUCTION;

//Add damage reduction for disabling shot
function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local float ExtraDamage;
	//Check for hit
	if (AppliedData.AbilityResultContext.HitResult == eHit_Success)
	{
		//Check for disabling shot
		if (AbilityState.GetMyTemplateName() == 'DisablingShot')
		{
			ExtraDamage = CurrentDamage * DISABLING_SHOT_REDUCTION;
			ExtraDamage = (ExtraDamage * -1);
		}
	}
	return int(ExtraDamage);
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
}