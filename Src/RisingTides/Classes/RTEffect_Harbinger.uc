//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_Harbinger.uc
//  AUTHOR:  Aleosiss
//  DATE:    18 July 2016   
//---------------------------------------------------------------------------------------
//	Tick Panic
//---------------------------------------------------------------------------------------

class RTEffect_Harbinger extends X2Effect_Persistent;

var int BONUS_PSI_DAMAGE, BONUS_AIM, BONUS_WILL, BONUS_ARMOR, BONUS_SHIELD;
var localized string RTFriendlyName;


simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{

}

function ModifyTurnStartActionPoints(XComGameState_Unit UnitState, out array<name> ActionPoints, XComGameState_Effect EffectState) {

}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers) {
	local ShotModifierInfo ModInfoAim;
	
	ModInfoAim.ModType = eHit_Success;
	ModInfoAim.Reason = RTFriendlyName;
	ModInfoAim.Value = BONUS_AIM;
	ShotModifiers.AddItem(ModInfoAim);
}

