class RTEffect_KnowledgeIsPower extends X2Effect_Persistent;

var int StackCap;
var float CritChancePerStack;


// Every turn this effect is sustained on a target, you gain increased damage and critical chance against it.


function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers) {
	local ShotModifierInfo ModInfo;

	if(Target.AffectedByEffectNames.Find(class'RTAbility_GathererAbilitySet'.default.OverTheShoulderEffectName) == INDEX_NONE) {
		return;
	}

	ModInfo.ModType = eHit_Crit;
	ModInfo.Reason = FriendlyName;
	ModInfo.Value = (EffectState.iStacks + 1) * CritChancePerStack;
	ShotModifiers.AddItem(ModInfo);
}


function int GetDefendingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect) {
	local int BonusDamage;
	local bool ShouldApply;

	if(XComGameState_Unit(TargetDamageable).AffectedByEffectNames.Find(class'RTAbility_GathererAbilitySet'.default.OverTheShoulderEffectName) == INDEX_NONE) {
		return 0;
	}

	bShouldApply = false;
	if(class'RTHelpers'.CheckAbilityActivated(AbilityState.GetMyTemplateName(), eCheckList_SniperShots))
		bShouldApply = true;
	if(class'RTHelpers'.CheckAbilityActivated(AbilityState.GetMyTemplateName(), eCheckList_StandardShots))
		bShouldApply = true;
	if(class'RTHelpers'.CheckAbilityActivated(AbilityState.GetMyTemplateName(), eCheckList_MeleeAttacks))
		bShouldApply = true;

	if(!bShouldApply) {
		return 0;
	}

	BonusDamage = EffectState.iStacks + 1;
	if(BonusDamage > DamageCap) {
		BonusDamage = DamageCap;
	}

	return BonusDamage;
}

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication) {

	kNewEffectState.iStacks++;

    return super.OnEffectTicked(ApplyEffectParameters, kNewEffectState, NewGameState, FirstApplication);
}

defaultproperties
{
	StackCap = 4
	CritChancePerStack = 5.0f
}
