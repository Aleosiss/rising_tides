// This is an Unreal Script

class RTEffect_UnsettlingVoices extends X2Effect_PersistentStatChange;

var int UV_AIM_PENALTY, UV_DEFENSE_PENALTY, UV_WILL_PENALTY;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	m_aStatChanges.Length = 0;
	AddPersistentStatChange(eStat_Will, -(UV_WILL_PENALTY));
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfoAim;

	ModInfoAim.ModType = eHit_Success;
	ModInfoAim.Reason = FriendlyName;
	ModInfoAim.Value = -(UV_AIM_PENALTY);
	ShotModifiers.AddItem(ModInfoAim);
}

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfoAim;

	ModInfoAim.ModType = eHit_Success;
	ModInfoAim.Reason = FriendlyName;
	ModInfoAim.Value = UV_DEFENSE_PENALTY;
	ShotModifiers.AddItem(ModInfoAim);
}
