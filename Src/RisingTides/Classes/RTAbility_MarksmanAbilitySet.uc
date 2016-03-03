//---------------------------------------------------------------------------------------
//  FILE:    RTAbility_MarksmanAbilitySet.uc
//  AUTHOR:  Aleosiss
//  DATE:    8 February 2016
//  PURPOSE: Defines abilities used by the GHOST Marksman class.
//           
//---------------------------------------------------------------------------------------
//	Whisper's perks.
//---------------------------------------------------------------------------------------

class RTAbility_MarksmanAbilitySet extends RTAbility_GhostAbilitySet
	config(RTMarksman);

	var config int DAMNGOODGROUND_AIM_BONUS, DAMNGOODGROUND_DEF_BONUS;
	var config int SIXOCLOCK_DEF_BONUS;
	var config int SLOWISSMOOTH_AIM_BONUS, SLOWISSMOOTH_CRIT_BONUS;
	var config int HEADSHOT_AIM_BONUS, HEADSHOT_CRIT_BONUS, HEADSHOT_COOLDOWN;
	var config float HEADSHOT_CRITDMG_BONUS;
	var config int SNAPSHOT_AIM_BONUS;
	var config int DISABLESHOT_AIM_BONUS, DISABLESHOT_COOLDOWN;
	var config float KNOCKTHEMDOWN_CRITDMG_MULTIPLIER;
	var config int DISTORTION_STRENGTH;
	var config int HARBINGER_WILL_CHECK;
	var config int TIMESTANDSSTILL_COOLDOWN;
	var config int BARRIER_STRENGTH, BARRIER_COOLDOWN;
	var config int OVERRIDE_COOLDOWN;

	var bool MELDED;
	
	static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	//Templates.AddItem(AddSquadsightAbility());
	//Templates.AddItem(PurePassive('Quickdraw', "img:///UILibrary_PerkIcons.UIPerk_quickdraw"));
	//Templates.AddItem(PurePassive('Scoped_and_Dropped', "<insert image path here>");
	//Templates.AddItem(PurePassive('Teek', "<insert image path here>");
	//Templates.AddItem(PurePassive('Aggression', "<insert image path here>");
	//Templates.AddItem(PurePassive('Vital_Point_Targeting', "<insert image path here>");
	//Templates.AddItem(PurePassive('Damn_Good_Ground', "<insert image path here>");
	//Templates.AddItem(PurePassive('Slow_Is_Smooth', "<insert image path here>");
	//Templates.AddItem(PurePassive('Your_Hands, My Eyes', "<insert image path here>");
	//Templates.Additem(PurePassive('Covering_Fire', "<insert image path here>");
	//Templates.AddItem(PurePassive('Six_OClock', "<insert image path here>");
	//Templates.AddItem(PurePassive('Sovereign', "<insert image path here>");
	//Templates.AddItem(PurePassive('In_the_Zone', "<insert image path here>");
	//Templates.AddItem(PurePassive('Knock_Them_Down', "<insert image path here>");
	//Templates.AddItem(PurePassive('Ready_For_Anything', "<insert image path here>");
	//Templates.AddItem(PurePassive('Harbinger', "<insert image path here>");
	//Templates.AddItem(PurePassive('Daybreak_Flame', "<insert image path here>");
	//Templates.AddItem(PurePassive('Statistical_Inevitibility', "<insert image path here>");

	//Templates.AddItem(AddSquadSightAbility());
	Templates.AddItem(ScopedAndDropped());
	Templates.AddItem(PrecisionShot());
	//Templates.AddItem(StatisticalInevitibility());
	//Templates.AddItem(SIShot());
	//Templates.AddItem(TimeStandsStill());
	//Templates.AddItem(Override());
	//Templates.AddItem(Barrier());

	return Templates;
}

//---------------------------------------------------------------------------------------
//---Squadsight (Hard paste from X2Ability_SharpshooterAbilitySet.uc)--------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate AddSquadsightAbility()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local RTEffect_Squadsight                   RTSquadsight;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTSquadsight');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_squadsight";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	RTSquadsight = new class'RTEffect_Squadsight';
	RTSquadsight.BuildPersistentEffect(1, true, true, true);
	RTSquadsight.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(RTSquadsight);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}
//---------------------------------------------------------------------------------------
//---Scoped and Dropped------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate ScopedAndDropped()
{
	local X2AbilityTemplate						Template;
	local RTEffect_ScopedAndDropped				ScopedEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ScopedAndDropped');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_voidrift";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	//Apply perk at the start of the mission. 
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	ScopedEffect = new class'RTEffect_ScopedAndDropped';
	ScopedEffect.BuildPersistentEffect(1, true, true, true);
	ScopedEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(ScopedEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

//---------------------------------------------------------------------------------------
//---Barrier-----------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
/*
static function X2AbilityTemplate Barrier() 
{
	local X2AbilityTemplate						Template;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2AbilityCooldown						Cooldown;

	`CREATE_X2ABILITYTEMPLATE(Template, 'Barrier');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img://UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield";
	Template.bHideOnClassUnlock = false;
	Template.Hostility = eHostility_Defensive;

	ActionPointCost = new class 'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);


	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	// Multi target
	MultiTarget = new class'X2AbilityMultiTarget_Radius';
	MultiTarget.fTargetRadius = default.ENERGY_SHIELD_RANGE_METERS;
	MultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTarget;

	// The Targets must be within the AOE, LOS, and be a GHOST
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeHostileToSource = true;
	UnitPropertyCondition.ExcludeCivilian = true;
	UnitPropertyCondition.FailOnNonUnits = true;
	UnitPropertyCondition.RequireSoldierClass = 'RTGhost';
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

	// Friendlies in the radius receives a shield receives a shield
	ShieldedEffect = CreateShieldedEffect(Template.LocFriendlyName, Template.GetMyLongDescription(), default.ENERGY_SHIELD_Mk3_HP);

	Template.AddShooterEffect(ShieldedEffect);
	Template.AddMultiTargetEffect(ShieldedEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = Shielded_BuildVisualization;
	Template.CinescriptCameraType = "AdvShieldBearer_EnergyShieldArmor";
	
	return Template;
}*/

//---------------------------------------------------------------------------------------
//---Precision Shot----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate PrecisionShot()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCooldown                 Cooldown;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
	local X2Condition_Visibility            TargetVisibilityCondition;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'PrecisionShot');

	Template.AdditionalAbilities.AddItem('PrecisionShotBonus');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_deadeye";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Offensive;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.DEADEYE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.FinalMultiplier = default.DEADEYE_AIM_MULTIPLIER;
	Template.AbilityToHitCalc = ToHitCalc;

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 2;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	Template.bAllowAmmoEffects = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bCrossClassEligible = true;

	return Template;
}


}