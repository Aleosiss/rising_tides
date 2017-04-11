//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_Acid.uc
//  AUTHOR:  Aleosiss  --  9/29/2016
//  PURPOSE: Queen's acidic blades have unique rules when compared to burning:
//           Stacking duration and damage on re-apply, and shredding armor on tick.
//
//---------------------------------------------------------------------------------------

class RTEffect_Acid extends X2Effect_Persistent;

// var int iStackCount;


// trying out a new method of increasing damage per stack
function bool IsThisEffectBetterThanExistingEffect(const out XComGameState_Effect ExistingEffect)
{
	local RTEffect_Acid ExistingAcidEffectTemplate;

	ExistingAcidEffectTemplate = RTEffect_Acid(ExistingEffect.GetX2Effect());
	`assert( ExistingAcidEffectTemplate != None );

		// increase the damage of the effect
		GetAcidDamage().EffectDamageValue.Damage += ExistingAcidEffectTemplate.GetAcidDamage().EffectDamageValue.Damage;
		GetAcidDamage().EffectDamageValue.Shred += ExistingAcidEffectTemplate.GetAcidDamage().EffectDamageValue.Shred;
		// iStackCount = ExistingAcidEffectTemplate.iStackCount + 1;


	return true; // the effect is always better
}

simulated function SetAcidDamage(int Damage, int Spread, int Shred, name DamageType)
{
	local X2Effect_ApplyWeaponDamage AcidDamage;

	AcidDamage= GetAcidDamage();
	AcidDamage.EffectDamageValue.Damage = Damage;
	AcidDamage.EffectDamageValue.Spread = Spread;
	AcidDamage.EffectDamageValue.Shred = Shred;
	AcidDamage.EffectDamageValue.DamageType = DamageType;
	AcidDamage.bIgnoreBaseDamage = true;
}



simulated function X2Effect_ApplyWeaponDamage GetAcidDamage()
{
	return X2Effect_ApplyWeaponDamage(ApplyOnTick[0]);
}

// helper method copied from X2StatusEffects.uc
static function RTEffect_Acid CreateAcidBurningStatusEffect(name AcidName, int Duration)
{
	local RTEffect_Acid BurningEffect;
	local X2Condition_UnitProperty UnitPropCondition;

	BurningEffect = new class'RTEffect_Acid';
	BurningEffect.EffectName = AcidName;
	BurningEffect.BuildPersistentEffect(Duration, , , , eGameRule_PlayerTurnBegin);
	BurningEffect.SetDisplayInfo(ePerkBuff_Penalty, class'X2StatusEffects'.default.AcidBurningFriendlyName, class'X2StatusEffects'.default.AcidBurningFriendlyDesc, "img:///UILibrary_PerkIcons.UIPerk_burn");
	BurningEffect.VisualizationFn = class'X2StatusEffects'.static.AcidBurningVisualization;
	BurningEffect.EffectTickedVisualizationFn = class'X2StatusEffects'.static.AcidBurningVisualizationTicked;
	BurningEffect.EffectRemovedVisualizationFn = class'X2StatusEffects'.static.AcidBurningVisualizationRemoved;
	BurningEffect.bRemoveWhenTargetDies = true;
	BurningEffect.DuplicateResponse = eDupe_Refresh;
	BurningEffect.bCanTickEveryAction = false; // this would probably be really broken if enabled @aleosiss

	if (class'X2StatusEffects'.default.AcidEnteredParticle_Name != "")
	{
		BurningEffect.VFXTemplateName = class'X2StatusEffects'.default.AcidEnteredParticle_Name;
		BurningEffect.VFXSocket = class'X2StatusEffects'.default.AcidEnteredSocket_Name;
		BurningEffect.VFXSocketsArrayName = class'X2StatusEffects'.default.AcidEnteredSocketsArray_Name;
	}

	UnitPropCondition = new class'X2Condition_UnitProperty';
	UnitPropCondition.ExcludeFriendlyToSource = false;
	BurningEffect.TargetConditions.AddItem(UnitPropCondition);

	return BurningEffect;
}

DefaultProperties
{
	DamageTypes(0)="Acid"
	DuplicateResponse=eDupe_Refresh
	bCanTickEveryAction= false // would probably be op
	iStackCount = 1

	Begin Object Class=X2Effect_ApplyWeaponDamage Name=AcidDamage
	End Object

	ApplyOnTick.Add(AcidDamage)
}
