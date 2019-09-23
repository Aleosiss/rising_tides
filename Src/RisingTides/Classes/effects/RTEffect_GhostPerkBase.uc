// This class grants specific boons to all of my special classes	

class RTEffect_GhostPerkBase extends X2Effect_Persistent;

var int DEFENSE_BONUS;
var localized string GhostPerkBaseName;

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfoAim;

	if(!bIndirectFire) { // how the fuck are you dodging a grenade, bruh
		ModInfoAim.ModType = eHit_Success;
		ModInfoAim.Reason = default.GhostPerkBaseName;
		ModInfoAim.Value = -(DEFENSE_BONUS);
		ShotModifiers.AddItem(ModInfoAim);
	}
	
}