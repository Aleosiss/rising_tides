//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_Acid.uc
//  AUTHOR:  Aleosiss  --  9/29/2016
//  PURPOSE: Queen's acidic blades have unique rules when compared to burning: 
//           Stacking duration and damage on re-apply, and shredding armor on tick.
//           
//---------------------------------------------------------------------------------------

class RTEffect_Acid extends X2Effect_Persistent;

var int iStackCount;

function bool IsThisEffectBetterThanExistingEffect(const out XComGameState_Effect ExistingEffect)
{
	local RTEffect_Acid ExistingAcidEffectTemplate;

	ExistingAcidEffectTemplate = RTEffect_Acid(ExistingEffect.GetX2Effect());
	`assert( ExistingAcidEffectTemplate != None );
        
        // increase the damage of the effect
        GetAcidDamage.EffectDamageValue.Damage += ExistingAcidEffectTemplate.GetAcidDamage().EffectDamageValue.Damage;
        GetAcidDamage.EffectDamageValue.Shred += ExistingAcidEffectTemplate.GetAcidDamage().EffectDamageValue.Shred;
        
	

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

// helper methods copied from X2StatusEffects.uc
static function X2Effect_Burning CreateAcidBurningStatusEffect(int DamagePerTick, int DamageSpreadPerTick)
{
	local RTEffect_Acid BurningEffect;
	local X2Condition_UnitProperty UnitPropCondition;

	BurningEffect = new class'RTEffect_Acid';
	BurningEffect.EffectName = default.AcidBurningName;
	BurningEffect.BuildPersistentEffect(default.ACID_BURNING_TURNS, , , , eGameRule_PlayerTurnBegin);
	BurningEffect.SetDisplayInfo(ePerkBuff_Penalty, default.AcidBurningFriendlyName, default.AcidBurningFriendlyDesc, "img:///UILibrary_PerkIcons.UIPerk_burn");
	BurningEffect.SetBurnDamage(DamagePerTick, DamageSpreadPerTick, 'RTAcid');
	BurningEffect.VisualizationFn = AcidBurningVisualization;
	BurningEffect.EffectTickedVisualizationFn = AcidBurningVisualizationTicked;
	BurningEffect.EffectRemovedVisualizationFn = AcidBurningVisualizationRemoved;
	BurningEffect.bRemoveWhenTargetDies = true;
	BurningEffect.DamageTypes.Length = 0;   // By default X2Effect_Burning has a damage type of fire, but acid is not fire
	BurningEffect.DamageTypes.InsertItem(0, 'RTAcid');
	BurningEffect.DuplicateResponse = eDupe_Refresh;
	BurningEffect.bCanTickEveryAction = false; // this would probably be really broken if enabled @aleosiss

	if (default.AcidEnteredParticle_Name != "")
	{
		BurningEffect.VFXTemplateName = default.AcidEnteredParticle_Name;
		BurningEffect.VFXSocket = default.AcidEnteredSocket_Name;
		BurningEffect.VFXSocketsArrayName = default.AcidEnteredSocketsArray_Name;
	}

	UnitPropCondition = new class'X2Condition_UnitProperty';
	UnitPropCondition.ExcludeFriendlyToSource = false;
	BurningEffect.TargetConditions.AddItem(UnitPropCondition);

	return BurningEffect;
}

static function AcidBurningVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	if (EffectApplyResult != 'AA_Success')
		return;
	if (!BuildTrack.StateObject_NewState.IsA('XComGameState_Unit'))
		return;

	class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(BuildTrack, VisualizeGameState.GetContext(), class'X2StatusEffects'.default.AcidBurningFriendlyName, 'Acid', eColor_Bad, class'UIUtilities_Image'.const.UnitStatus_Burning);
	class'X2StatusEffects'.static.AddEffectMessageToTrack(BuildTrack, class'X2StatusEffects'.default.AcidBurningEffectAcquiredString, VisualizeGameState.GetContext());
	class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}

static function AcidBurningVisualizationTicked(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(BuildTrack.StateObject_NewState);

	if (UnitState == None || UnitState.IsDead())
		return;

	AddEffectMessageToTrack(BuildTrack, default.AcidBurningEffectTickedString, VisualizeGameState.GetContext());
	UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}

static function AcidBurningVisualizationRemoved(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(BuildTrack.StateObject_NewState);

	if (UnitState == None || UnitState.IsDead())
		return;

	class'X2StatusEffects'.static.AddEffectMessageToTrack(BuildTrack, class'X2StatusEffects'.default.AcidBurningEffectLostString, VisualizeGameState.GetContext());
	class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}


DefaultProperties
{
	DamageTypes(0)="RTAcid"
	DuplicateResponse=eDupe_Refresh
	bCanTickEveryAction= false // would probably be op
        iStackCount = 1

	Begin Object Class=X2Effect_ApplyWeaponDamage Name=AcidDamage
	End Object

	ApplyOnTick.Add(AcidDamage)
}
