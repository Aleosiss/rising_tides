class RTEffect_KnowledgeIsPower extends X2Effect_Persistent;

var int StackCap;
var float CritChancePerStack;


// Every turn this effect is sustained on a target, you gain increased damage and critical strike chance against it.

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers) {
	local ShotModifierInfo ModInfo;
	local float CritChance;

	if(Target.AffectedByEffectNames.Find(class'RTAbility_GathererAbilitySet'.default.OverTheShoulderEffectName) == INDEX_NONE) {
		return;
	}

	if(EffectState.iStacks > StackCap) {
		CritChance = (StackCap) * CritChancePerStack;
	} else {
		CritChance = (EffectState.iStacks) * CritChancePerStack;
	}

	ModInfo.ModType = eHit_Crit;
	ModInfo.Reason = FriendlyName;
	ModInfo.Value = CritChance;
	ShotModifiers.AddItem(ModInfo);
}


function int GetDefendingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, 
							const out EffectAppliedData AppliedData, const int CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect, optional XComGameState NewGameState) {
	local int BonusDamage;
	local int DamageCap;
	local bool bShouldApply;

	if(XComGameState_Unit(TargetDamageable).AffectedByEffectNames.Find(class'RTAbility_GathererAbilitySet'.default.OverTheShoulderEffectName) == INDEX_NONE) {
		return 0;
	}

	bShouldApply = false;
	if(class'RTHelpers'.static.CheckAbilityActivated(AbilityState.GetMyTemplateName(), eCheckList_SniperShots))
		bShouldApply = true;
	if(class'RTHelpers'.static.CheckAbilityActivated(AbilityState.GetMyTemplateName(), eCheckList_StandardShots))
		bShouldApply = true;
	if(class'RTHelpers'.static.CheckAbilityActivated(AbilityState.GetMyTemplateName(), eCheckList_MeleeAbilities))
		bShouldApply = true;

	if(!bShouldApply) {
		return 0;
	}

	DamageCap = StackCap;
	BonusDamage = EffectState.iStacks;

	if(BonusDamage > DamageCap) {
		BonusDamage = DamageCap;
	}

	return BonusDamage;
}

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication, XComGameState_Player PlayerState) {
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if(UnitState.AffectedByEffectNames.Find(class'RTAbility_GathererAbilitySet'.default.OverTheShoulderEffectName) == INDEX_NONE) {
		kNewEffectState.iStacks = 0;
	}


	kNewEffectState.iStacks++;

    return super.OnEffectTicked(ApplyEffectParameters, kNewEffectState, NewGameState, FirstApplication, PlayerState);
}

defaultproperties
{
	StackCap = 4
	CritChancePerStack = 5.0f
}
