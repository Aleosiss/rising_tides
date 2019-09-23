//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_Aggression.uc
//  AUTHOR:  Aleosiss
//  DATE:    10 March 2016
//  PURPOSE: DGG Defense/Aim calculation
//---------------------------------------------------------------------------------------
//	Damn Good Ground
//---------------------------------------------------------------------------------------

class RTEffect_DamnGoodGround extends X2Effect_Persistent config (RisingTides);

var localized string RTFriendlyName;
var int DGG_DEFENSE_BONUS, DGG_AIM_BONUS;


function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfoAim;

	if(Attacker.HasHeightAdvantageOver(Target, true))
	{
		ModInfoAim.ModType = eHit_Success;
		ModInfoAim.Reason = RTFriendlyName;
		ModInfoAim.Value = DGG_AIM_BONUS;
		ShotModifiers.AddItem(ModInfoAim);
	}
}

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfoAim;

	if(Target.HasHeightAdvantageOver(Attacker, false))
	{
		ModInfoAim.ModType = eHit_Success;
		ModInfoAim.Reason = RTFriendlyName;
		ModInfoAim.Value = -(DGG_DEFENSE_BONUS);
		ShotModifiers.AddItem(ModInfoAim);
	}
}
