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

	var config int SLOWISSMOOTH_AIM_BONUS, SLOWISSMOOTH_CRIT_BONUS;
	var config int HEADSHOT_CRIT_BONUS, HEADSHOT_COOLDOWN;
	var config int HEADSHOT_AIM_MULTIPLIER;
	var config int SNAPSHOT_AIM_BONUS;
	var config int DISABLESHOT_AIM_BONUS, DISABLESHOT_COOLDOWN;
	var config float KNOCKTHEMDOWN_CRITDMG_MULTIPLIER;
	var config float SIXOCLOCK_WILL_BONUS;
	var config float SIXOCLOCK_PSI_BONUS;
	var config float SIXOCLOCK_DEFENSE_BONUS;
	var config int TIMESTANDSSTILL_COOLDOWN;
	var config int BARRIER_STRENGTH, BARRIER_COOLDOWN;
	var config int OVERRIDE_COOLDOWN;
	var config int VITAL_POINT_TARGETING_DAMAGE;
	var config int SURGE_COOLDOWN;
	var config int HEAT_CHANNEL_COOLDOWN;
	var config int HARBINGER_SHIELD_AMOUNT, HARBINGER_COOLDOWN, HARBINGER_DAMAGE_BONUS, HARBINGER_WILL_BONUS, HARBINGER_AIM_BONUS, HARBINGER_ARMOR_BONUS;
	var config int SHOCKANDAWE_DAMAGE_TO_ACTIVATE;

//---------------------------------------------------------------------------------------
//---CreateTemplates---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(ScopedAndDropped());
	Templates.AddItem(RTStandardSniperShot());
	Templates.AddItem(RTOverwatch());
	Templates.AddItem(RTOverwatchShot());
	Templates.AddItem(RTPrecisionShot());
	Templates.AddItem(RTPrecisionShotDamage());
	Templates.AddItem(Aggression());
	Templates.AddItem(KnockThemDown());
	Templates.AddItem(DisablingShot());
	Templates.AddItem(DisablingShotDamage());
	Templates.AddItem(Snapshot());
	Templates.AddItem(SixOClock());
	Templates.AddItem(SixOClockEffect());
	Templates.AddItem(VitalPointTargeting());
	Templates.AddItem(DamnGoodGround());
	Templates.AddItem(SlowIsSmooth());
	Templates.AddItem(SlowIsSmoothEffect());
	Templates.AddItem(Sovereign());
	Templates.AddItem(SovereignEffect());
	Templates.AddItem(DaybreakFlame());
	Templates.AddItem(DaybreakFlameIcon());
	Templates.AddItem(YourHandsMyEyes());
	Templates.AddItem(TimeStandsStill());
	Templates.AddItem(TimeStandsStillCleanseListener());
	Templates.AddItem(TwitchReaction());
	Templates.AddItem(TwitchReactionShot());
	Templates.AddItem(LinkedIntelligence());
	Templates.AddItem(PsionicSurge());
	Templates.AddItem(HeatChannel());
	Templates.AddItem(HeatChannelIcon());
	//Templates.AddItem(SIShot());
	//Templates.AddItem(TimeStandsStill());
	//Templates.AddItem(Override());
	//Templates.AddItem(Barrier());

	return Templates;
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
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aim";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	// Apply perk at the start of the mission. 
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	// Effect to apply
	ScopedEffect = new class'RTEffect_ScopedAndDropped';
	ScopedEffect.BuildPersistentEffect(1, true, true, true);
	ScopedEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(ScopedEffect);

	Template.AdditionalAbilities.AddItem('RTStandardSniperShot');
	Template.AdditionalAbilities.AddItem('RTOverwatch');
	Template.AdditionalAbilities.AddItem('GhostPsiSuite');
	Template.AdditionalAbilities.AddItem('JoinMeld');
	Template.AdditionalAbilities.AddItem('LeaveMeld');
	Template.AdditionalAbilities.AddItem('PsiOverload');
	Template.AdditionalAbilities.AddItem('PsiOverloadPanic');

	// Probably required 
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}
//---------------------------------------------------------------------------------------
//---RT Standard Shot--------------------------------------------------------------------
//---------------------------------------------------------------------------------------
 static function X2AbilityTemplate RTStandardSniperShot()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityCost_Ammo				AmmoCost;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
	local X2Condition_Visibility            TargetVisibilityCondition;
	local array<name>                       SkipExclusions;
	local X2Effect_Knockback				KnockbackEffect;

	//Macro to do localisation and stuffs
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTStandardSniperShot');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snipershot";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY;
	Template.DisplayTargetHitChance = true;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailableOrNoTargets;
	// color of the icon
	Template.AbilitySourceName = 'eAbilitySource_Standard';                                      
	// Activated by a button press; additionally, tells the AI this is an activatable
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	
	// *** VALIDITY CHECKS *** //
	// Status condtions that do *not* prohibit this action.
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// *** TARGETING PARAMETERS *** //
	// Can only shoot visible enemies
	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	// Can't target dead; Can't target friendlies
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	// Only at single targets that are in range.
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// Action Point
	ActionPointCost = new class'RTAbilityCost_SnapshotActionPoints';
	ActionPointCost.iNumPoints = 2;
	// Consume all points
	ActionPointCost.bConsumeAllPoints = true;                                               
	Template.AbilityCosts.AddItem(ActionPointCost);

	// Ammo
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	Template.bAllowAmmoEffects = true;

	// Weapon Upgrade Compatibility
	// Flag that permits action to become 'free action' via 'Hair Trigger' or similar upgrade / effects
	Template.bAllowFreeFireWeaponUpgrade = true;                                           

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	//  Various Soldier ability specific effects - effects check for the ability before applying	
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	// Damage Effect
	Template.AddTargetEffect(default.WeaponUpgradeMissDamage);

	// Hit Calculation (Different weapons now have different calculations for range)
	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.SQUADSIGHT_DISTANCE_MOD = 0;
	Template.AbilityToHitCalc = ToHitCalc;

	// Targeting Method
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	Template.OverrideAbilities.AddItem('SniperStandardFire');

	// MAKE IT LIVE!
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	KnockbackEffect.bUseTargetLocation = true;
	Template.AddTargetEffect(KnockbackEffect);

	return Template;
}
//---------------------------------------------------------------------------------------
//---RT Overwatch------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTOverwatch()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_ReserveActionPoints      ReserveActionPointsEffect;
	local array<name>                       SkipExclusions;
	local X2Effect_CoveringFire             CoveringFireEffect;
	local X2Condition_AbilityProperty       CoveringFireCondition;
	local X2Condition_UnitProperty          ConcealedCondition;
	local X2Effect_SetUnitValue             UnitValueEffect;
	local X2Condition_UnitEffects           SuppressedCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTOverwatch');
	
	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 1;
	AmmoCost.bFreeCost = true;                  //  ammo is consumed by the shot, not by this, but this should verify ammo is available
	Template.AbilityCosts.AddItem(AmmoCost);
	
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 2;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.bFreeCost = true;           //  ReserveActionPoints effect will take all action points away
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	SuppressedCondition = new class'X2Condition_UnitEffects';
	SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(SuppressedCondition);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);
	
	ReserveActionPointsEffect = new class'X2Effect_ReserveOverwatchPoints';
	Template.AddTargetEffect(ReserveActionPointsEffect);

	CoveringFireEffect = new class'X2Effect_CoveringFire';
	CoveringFireEffect.AbilityToActivate = 'RTOverwatchShot';
	CoveringFireEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	CoveringFireCondition = new class'X2Condition_AbilityProperty';
	CoveringFireCondition.OwnerHasSoldierAbilities.AddItem('CoveringFire');
	CoveringFireEffect.TargetConditions.AddItem(CoveringFireCondition);
	Template.AddTargetEffect(CoveringFireEffect);

	ConcealedCondition = new class'X2Condition_UnitProperty';
	ConcealedCondition.ExcludeFriendlyToSource = false;
	ConcealedCondition.IsConcealed = true;
	UnitValueEffect = new class'X2Effect_SetUnitValue';
	UnitValueEffect.UnitName = class'X2Ability_DefaultAbilitySet'.default.ConcealedOverwatchTurn;
	UnitValueEffect.CleanupType = eCleanup_BeginTurn;
	UnitValueEffect.NewValueToSet = 1;
	UnitValueEffect.TargetConditions.AddItem(ConcealedCondition);
	Template.AddTargetEffect(UnitValueEffect);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.HideErrors.AddItem('AA_CannotAfford_ActionPoints');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_long_watch";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.OVERWATCH_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.AbilityConfirmSound = "Unreal2DSounds_OverWatch";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_DefaultAbilitySet'.static.OverwatchAbility_BuildVisualization;
	Template.CinescriptCameraType = "Overwatch";

	Template.Hostility = eHostility_Defensive;

	Template.PostActivationEvents.AddItem('RTOverwatch');
	Template.OverrideAbilities.AddItem('SniperRifleOverwatch');
	Template.AdditionalAbilities.AddItem('RTOverwatchShot');

	Template.DefaultKeyBinding = class'UIUtilities_Input'.const.FXS_KEY_Y;
	Template.bNoConfirmationWithHotKey = true;

	return Template;	
}

//---------------------------------------------------------------------------------------
//---RT Overwatch Shot-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTOverwatchShot()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ReserveActionPoints ReserveActionPointCost;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2Condition_UnitProperty          ShooterCondition;
	local X2AbilityTarget_Single            SingleTarget;
	local X2AbilityTrigger_Event	        Trigger;
	local array<name>                       SkipExclusions;
	local X2Condition_Visibility            TargetVisibilityCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTOverwatchShot');
	
	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 1;	
	Template.AbilityCosts.AddItem(AmmoCost);
	
	ReserveActionPointCost = new class'X2AbilityCost_ReserveActionPoints';
	ReserveActionPointCost.iNumPoints = 1;
	ReserveActionPointCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint);
	Template.AbilityCosts.AddItem(ReserveActionPointCost);
	
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bReactionFire = true;
	Template.AbilityToHitCalc = StandardAim;
	Template.AbilityToHitOwnerOnMissCalc = StandardAim;

	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bDisablePeeksOnMovement = true;
	TargetVisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(new class'X2Condition_EverVigilant');
	Template.AbilityTargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);	
	ShooterCondition = new class'X2Condition_UnitProperty';
	ShooterCondition.ExcludeConcealed = true;
	Template.AbilityShooterConditions.AddItem(ShooterCondition);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);
	Template.bAllowAmmoEffects = true;
	
	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.OnlyIncludeTargetsInsideWeaponRange = false;
	Template.AbilityTargetStyle = SingleTarget;

	//Trigger on movement - interrupt the move
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_MovementObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);
	
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overwatch";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.OVERWATCH_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.DisplayTargetHitChance = false;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bAllowFreeFireWeaponUpgrade = false;	

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
	// Damage Effect
	//
	Template.AddTargetEffect(default.WeaponUpgradeMissDamage);

	Template.PostActivationEvents.AddItem('RTOverwatchShot');

	Template.OverrideAbilities.AddItem('OverwatchShot');
	
	return Template;	
}
//---------------------------------------------------------------------------------------
//---Precision Shot----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTPrecisionShot()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCooldown                 Cooldown;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
	local X2Condition_Visibility            TargetVisibilityCondition;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTPrecisionShot');

	Template.AdditionalAbilities.AddItem('RTPrecisionShotDamage');

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
	Cooldown.iNumTurns = default.HEADSHOT_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.BuiltInHitMod = -(default.HEADSHOT_AIM_MULTIPLIER);
	Template.AbilityToHitCalc = ToHitCalc;

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	ActionPointCost = new class'RTAbilityCost_SnapshotActionPoints';
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

	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Precision Shot Damage Effect--------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTPrecisionShotDamage()
{
	local X2AbilityTemplate						Template;
	local RTEffect_PrecisionShotDamage          DamageEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTPrecisionShotDamage');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_momentum";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	DamageEffect = new class'RTEffect_PrecisionShotDamage';
	DamageEffect.BuildPersistentEffect(1, true, true, true);
	DamageEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false,,Template.AbilitySourceName);
	Template.AddTargetEffect(DamageEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}
//---------------------------------------------------------------------------------------
//---Aggression--------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate Aggression()
{
	local X2AbilityTemplate						Template;
	local RTEffect_Aggression					AgroEffect;

	//Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'Aggression');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aggression";
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	//Apply perk at the start of the mission. 
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	AgroEffect = new class'RTEffect_Aggression';
	AgroEffect.BuildPersistentEffect(1, true, true, true);
	AgroEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(AgroEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

//---------------------------------------------------------------------------------------
//---Knock Them Down---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate KnockThemDown()
{
	local X2AbilityTemplate					Template;
	local RTEffect_KnockThemDown			KnockEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'KnockThemDown');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_ammo_fletchette";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	//Apply perk at the start of the mission. 
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	KnockEffect = new class'RTEffect_KnockThemDown';
	KnockEffect.BuildPersistentEffect(1, true, true, true);
	KnockEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(KnockEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

//---------------------------------------------------------------------------------------
//---Disabling Shot----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate DisablingShot()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCooldown                 Cooldown;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
	local X2Condition_Visibility            TargetVisibilityCondition;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_DisableWeapon			DisableWeapon;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DisablingShot');

	Template.AdditionalAbilities.AddItem('DisablingShotDamage');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_disablingshot";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Offensive;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.DISABLESHOT_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.BuiltInHitMod = -(default.DISABLESHOT_AIM_BONUS);
	Template.AbilityToHitCalc = ToHitCalc;

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	ActionPointCost = new class'RTAbilityCost_SnapshotActionPoints';
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

	DisableWeapon = new class'X2Effect_DisableWeapon';
	DisableWeapon.TargetConditions.AddItem(default.LivingTargetUnitOnlyProperty);
	Template.AddTargetEffect(DisableWeapon);

	Template.bAllowAmmoEffects = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Disabling Shot Damage Effect--------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate DisablingShotDamage()
{
	local X2AbilityTemplate						Template;
	local RTEffect_DisablingShotDamage          DamageEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'DisablingShotDamage');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_momentum";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	DamageEffect = new class'RTEffect_DisablingShotDamage';
	DamageEffect.BuildPersistentEffect(1, true, true, true);
	DamageEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false,,Template.AbilitySourceName);
	Template.AddTargetEffect(DamageEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

//---------------------------------------------------------------------------------------
//---Snapshot----------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate Snapshot()
{
	local X2AbilityTemplate						Template;
	local RTEffect_SnapshotEffect		  SnapshotEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'Snapshot');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snapshot";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	//Apply perk at the start of the mission. 
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	SnapshotEffect = new class'RTEffect_SnapshotEffect';
	SnapshotEffect.BuildPersistentEffect(1, true, true, true);
	SnapshotEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(SnapshotEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

//---------------------------------------------------------------------------------------
//---SixOClock---------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate SixOClock()
{
    local X2AbilityTemplate                     Template;
	local RTEffect_SixOClock            PersistentEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'SixOClock');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_tacticalsense";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	//  This is a dummy effect so that an icon shows up in the UI.
	PersistentEffect = new class'RTEffect_SixOClock';
	PersistentEffect.BuildPersistentEffect(1, true, false);
	PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(PersistentEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!

	Template.bCrossClassEligible = false;
	Template.AdditionalAbilities.AddItem('SixOClockEffect');

	return Template;

}

//---------------------------------------------------------------------------------------
//---SixOClockEffect---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate SixOClockEffect()
{
	local X2AbilityTemplate						Template;
	local RTEffect_SixOClockEffect				ClockEffect;
	local X2AbilityTrigger_EventListener		Trigger;
	local X2Condition_UnitProperty				UnitPropertyCondition;
	local X2AbilityMultiTarget_Radius			MultiTarget;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'SixOClockEffect');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_tacticalsense";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;


	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	// Apply perk when we go on overwatch. 	
	//Trigger = new class 'X2AbilityTrigger_OnAbilityActivated';
	//Trigger.SetListenerData('RTOverwatch');
	//Template.AbilityTriggers.AddItem(Trigger);
	
	// Apply perk when we go on overwatch (ATTEMPT 2)
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'RTOverwatch';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	// Copied Straight from Shieldbearer ability
	// Multi target
	MultiTarget = new class'X2AbilityMultiTarget_Radius';
	MultiTarget.fTargetRadius = 200;

	// This should really be false, because it makes no sense that 
	// Whisper can somehow see units behind cover, but it murders FPS
	// whenever it recalculates, so true for now
	MultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTarget;

	// Copied Straight from Shieldbearer ability
	// The Targets must be within the AOE and friendly
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;												  
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeHostileToSource = true;
	UnitPropertyCondition.ExcludeCivilian = true;
	UnitPropertyCondition.FailOnNonUnits = true;
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

	// Build the effect
	ClockEffect = new class'RTEffect_SixOClockEffect';
	// One turn duration
	ClockEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	ClockEffect.AddPersistentStatChange(eStat_Defense, default.SIXOCLOCK_DEFENSE_BONUS);
	ClockEffect.AddPersistentStatChange(eStat_PsiOffense, default.SIXOCLOCK_PSI_BONUS);
	ClockEffect.AddPersistentStatChange(eStat_Will, default.SIXOCLOCK_WILL_BONUS);
	ClockEffect.SetDisplayInfo(ePerkBuff_Bonus, "I've got your six.", 
		"Whisper has this unit's six. Gain +" @ 10 @ " bonus to defense, psi, and will.", Template.IconImage);
	

	// Add it
	Template.AddMultiTargetEffect(ClockEffect);
	//Template.bShowActivation = true;
	//Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	//  NOTE: No visualization on purpose!

	return Template;
}

//---------------------------------------------------------------------------------------
//---Vital Point Targeting---------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate VitalPointTargeting()
{
    local X2AbilityTemplate                     Template;
	local RTEffect_VPTargeting					VPEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'VitalPointTargeting');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_groundzero";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	//  This is a dummy effect so that an icon shows up in the UI.
	VPEffect = new class'RTEffect_VPTargeting';
	VPEffect.BonusDamage = default.VITAL_POINT_TARGETING_DAMAGE;
	VPEffect.BuildPersistentEffect(1, true, false, false);
	VPEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(VPEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!

	Template.bCrossClassEligible = false;

	return Template;

}
//---------------------------------------------------------------------------------------
//---Damn Good Ground--------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate DamnGoodGround()
{
	local X2AbilityTemplate						Template;
	local RTEffect_DamnGoodGround				DGGEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DamnGoodGround');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_damngoodground";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	DGGEffect = new class 'RTEffect_DamnGoodGround';
	DGGEffect.BuildPersistentEffect(1, true, false, false);
	DGGEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(DGGEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!
	
	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Slow is Smooth----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate SlowIsSmooth()
{
	local X2AbilityTemplate						Template;
	local X2Effect_Persistent					Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SlowIsSmooth');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_deadeye";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Effect = new class'X2Effect_Persistent';
	Effect.EffectName = 'SlowIsSmooth';
	Effect.DuplicateResponse = eDupe_Ignore;
	Effect.BuildPersistentEffect(1, true, false);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	
	Template.AdditionalAbilities.AddItem('SlowIsSmoothEffect');
	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Slow is Smooth Secondary Effect-----------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate SlowIsSmoothEffect()
{
	local X2AbilityTemplate						Template;
	local RTEffect_SlowIsSmooth					SISEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SlowIsSmoothEffect');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overwatch";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	SISEffect = new class 'RTEffect_SlowIsSmooth';
	SISEffect.BuildPersistentEffect(1, true, false, false,  eGameRule_PlayerTurnEnd);
	//Temporary Icon to confirm effect is on target					 
	Template.AddTargetEffect(SISEffect);
	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Sovereign---------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate Sovereign()
{
	local X2AbilityTemplate						Template;
	local RTEffect_Sovereign					SOVEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Sovereign');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_voidadept";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	SOVEffect = new class 'RTEffect_Sovereign';
	SOVEffect.BuildPersistentEffect(1, true, true, true);
	SOVEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(SOVEffect);

	Template.AdditionalAbilities.AddItem('SovereignEffect');
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!
	
	Template.bCrossClassEligible = false;

	return Template;
}
//---------------------------------------------------------------------------------------
//---Sovereign Effect--------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate SovereignEffect()
{
	local X2AbilityTemplate						Template;
	local X2Condition_UnitProperty				UnitPropertyCondition;
	local X2Effect_Panicked				        PanicEffect;
 	local X2AbilityTrigger_EventListener		EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SovereignEffect');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_voidadept";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = true;
	UnitPropertyCondition.ExcludeRobotic = true;
	UnitPropertyCondition.FailOnNonUnits = true;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.EventID = 'SovereignTrigger';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.Filter = eFilter_Unit;
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.VoidRiftInsanityListener;
	Template.AbilityTriggers.AddItem(EventListener);

	//  Panic effect for 1+ unblocked psi hits
	PanicEffect = class'X2StatusEffects'.static.CreatePanickedStatusEffect();
	PanicEffect.MinStatContestResult = 1;
	PanicEffect.MaxStatContestResult = 0;
	PanicEffect.DamageTypes.AddItem('Mental');
	Template.AddTargetEffect(PanicEffect);

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityToHitCalc = new class'X2AbilityToHitCalc_StatCheck_UnitVsUnit';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!


	return Template;
}

//---------------------------------------------------------------------------------------
//---Daybreak Flame----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
 static function X2AbilityTemplate DaybreakFlame()
{
	local X2AbilityTemplate						Template;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2AbilityCost_Ammo					AmmoCost;
	local X2AbilityToHitCalc_StandardAim		ToHitCalc;
	local X2Condition_Visibility				TargetVisibilityCondition;
	local array<name>							SkipExclusions;
	local X2Effect_Knockback					KnockbackEffect;
	local X2Effect_ApplyWeaponDamage			WeaponDamageEffect; //invokes the ability to add weapon damage
	local X2Effect_ApplyFireToWorld				FireToWorldEffect;  //allows ability to set shit on fire
	local X2Effect_ApplyDirectionalWorldDamage  WorldDamage;  //allows destruction of environment
	local X2Effect_Burning						BurningEffect;      //Allows Burning 
	local RTAbilityMultiTarget_TargetedLine		LineMultiTarget;
	local X2AbilityTarget_Cursor				CursorTarget;
	local X2AbilityTarget_Single				SingleTarget;
	//Macro to do localisation and stuffs
	`CREATE_X2ABILITY_TEMPLATE(Template, 'DaybreakFlame');

	// Icon Properties
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snipershot";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY;
	Template.DisplayTargetHitChance = true;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailableOrNoTargets;
	// color of the icon
	Template.AbilitySourceName = 'eAbilitySource_Standard';                                      
	// Activated by a button press; additionally, tells the AI this is an activatable
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	
	// *** VALIDITY CHECKS *** //
	// Status condtions that do *not* prohibit this action.
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// *** TARGETING PARAMETERS *** //
	// Can only shoot visible enemies
	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bAllowSquadsight = true;
	TargetVisibilityCondition.bVisibleToAnyAlly = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	// Can't target dead; Can't target friendlies
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	
	// Single targets that are in range. (This doesn't work)
	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.bAllowDestructibleObjects = true;
	SingleTarget.bShowAOE = true;
	Template.AbilityTargetStyle = SingleTarget;

	// Targeting Method
	Template.TargetingMethod = class'RTTargetingMethod_AimedLineSkillshot';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	//// Cursor target	 (This 'works')
	//CursorTarget = new class'X2AbilityTarget_Cursor';
	//CursorTarget.FixedAbilityRange = 200;
	//Template.AbilityTargetStyle = CursorTarget;
//
	// Line skillshot
	LineMultiTarget = new class'RTAbilityMultiTarget_TargetedLine';
	LineMultiTarget.bSightRangeLimited = false;
	Template.AbilityMultiTargetStyle = LineMultiTarget;

	// Action Point
	ActionPointCost = new class'RTAbilityCost_SnapshotActionPoints';
	ActionPointCost.iNumPoints = 2;
	// Consume all points
	ActionPointCost.bConsumeAllPoints = true;                                               
	Template.AbilityCosts.AddItem(ActionPointCost);

	// Ammo
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	Template.bAllowAmmoEffects = true;

	// Weapon Upgrade Compatibility
	// Flag that permits action to become 'free action' via 'Hair Trigger' or similar upgrade / effects
	Template.bAllowFreeFireWeaponUpgrade = true;                                           

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	//  Various Soldier ability specific effects - effects check for the ability before applying	
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	// Damage Effect
	//Template.AddTargetEffect(default.WeaponUpgradeMissDamage);

	// Hit Calculation (Different weapons now have different calculations for range)
	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.SQUADSIGHT_DISTANCE_MOD = 0;
	Template.AbilityToHitCalc = ToHitCalc;

	//Template.bOverrideAim = true;  
	Template.bUseSourceLocationZToAim = true;

	// Damage/Burning Effect
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';   //creates the framework to apply weapon damage to the ability
	WeaponDamageEffect.bExplosiveDamage = true;					  //forces the ability to use the explosive damage type
	WeaponDamageEffect.bApplyWorldEffectsForEachTargetLocation = true;          
	Template.AddMultiTargetEffect(WeaponDamageEffect);           //Adds weapon damage to multiple targets
	BurningEffect = class'X2StatusEffects'.static.CreateBurningStatusEffect(3, 0);   //Adds Burning Effect for 3 damage, 0 spread
	BurningEffect.ApplyChance = 100;                                         //Should be a 50% chance to actually apply burning 
	Template.AddTargetEffect(BurningEffect);
	Template.AddMultiTargetEffect(BurningEffect);                                    //Adds the burning effect to the targeted area

	WorldDamage = new class'X2Effect_ApplyDirectionalWorldDamage';  //creates the framework to apply damage to the world
	WorldDamage.bUseWeaponDamageType = False;                       //overrides the normal weapon damage type
	WorldDamage.bUseWeaponEnvironmentalDamage = false;              //replaces the weapon's environmental damage with the abilities
	WorldDamage.EnvironmentalDamageAmount = 3000;                   //determines the amount of enviornmental damage the ability applies
	WorldDamage.bApplyOnHit = true;                                 //obv
	WorldDamage.bApplyOnMiss = true;                                //obv
	WorldDamage.bApplyToWorldOnHit = true;                          //obv
	WorldDamage.bApplyToWorldOnMiss = true;                         //obv
	WorldDamage.bHitAdjacentDestructibles = false;                   //applies environmental damage to things adjacent to the Line
	WorldDamage.PlusNumZTiles = 1;                                 //determines how 'high' the world damage is applied
	WorldDamage.bHitTargetTile = true;                              //Makes sure that everthing that is targetted is hit
	WorldDamage.ApplyChance = 100;
	Template.AddMultiTargetEffect(WorldDamage);                     //May be redundant

	FireToWorldEffect = new class'X2Effect_ApplyFireToWorld';                //This took a while to find
	FireToWorldEffect.bUseFireChanceLevel = true;                           
	FireToWorldEffect.bDamageFragileOnly = false;
	FireToWorldEffect.bCheckForLOSFromTargetLocation = false;
	FireToWorldEffect.FireChance_Level1 = 0.95f;                             //%chance of fire to catch
	FireToWorldEffect.FireChance_Level2 = 0.95f;
	FireToWorldEffect.FireChance_Level3 = 0.95f;
	Template.AddMultiTargetEffect(FireToWorldEffect);                        //this is required to add the fire effect

	Template.OverrideAbilities.AddItem('SniperStandardFire');
	Template.OverrideAbilities.AddItem('RTStandardSniperShot');
	
	// MAKE IT LIVE!
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;


	// TODO: VISUALIZATION
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	KnockbackEffect.bUseTargetLocation = true;
	Template.AddTargetEffect(KnockbackEffect);
	Template.AddMultiTargetEffect(KnockbackEffect);

	return Template;
}

//---------------------------------------------------------------------------------------
//---Daybreak Flame Icon-----------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate DaybreakFlameIcon()
{
	local X2AbilityTemplate						Template;
	local X2Effect_Persistent					SOVEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DaybreakFlameIcon');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snipershot";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	SOVEffect = new class 'X2Effect_Persistent';
	SOVEffect.BuildPersistentEffect(1, true, true, true);
	SOVEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(SOVEffect);

	Template.AdditionalAbilities.AddItem('DaybreakFlame');
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!
	
	Template.bCrossClassEligible = false;

	return Template;
}
//---------------------------------------------------------------------------------------
//---Inevitibility-----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate Inevitibility()
{
	local X2AbilityTemplate						Template;
	local RTEffect_Inevitibility				RTEffect;

	 `CREATE_X2ABILITY_TEMPLATE(Template, 'Inevitibility');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snipershot";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	RTEffect = new class 'RTEffect_Inevitibility';
	RTEffect.BuildPersistentEffect(1, true, false, false,  eGameRule_PlayerTurnEnd);
	RTEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(RTEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!
	
	Template.bCrossClassEligible = false;

	return Template;
}
//---------------------------------------------------------------------------------------
//---Your Hands, My Eyes-----------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate YourHandsMyEyes()
{
	local X2AbilityTemplate						Template;
	local RTEffect_YourHandsMyEyes				RTEffect;

	 `CREATE_X2ABILITY_TEMPLATE(Template, 'YourHandsMyEyes');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_insanity";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	RTEffect = new class 'RTEffect_YourHandsMyEyes';
	RTEffect.BuildPersistentEffect(1, true, false, false,  eGameRule_PlayerTurnEnd);
	RTEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(RTEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!
	
	Template.bCrossClassEligible = false;
	return Template;
}

//---------------------------------------------------------------------------------------
//---Time Stands Still-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate TimeStandsStill()
{
	local X2AbilityTemplate						Template;
	local RTEffect_TimeStop						TimeStopEffect;
	local RTEffect_TimeStopMaster					TimeMasterEffect;
	local X2Effect_SetUnitValue					SetUnitValueEffect;
	local RTEffect_Counter						CounterEffect;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2AbilityCooldown						Cooldown;
	local X2AbilityMultiTarget_Radius			MultiTarget;
	local X2Condition_UnitProperty				UnitPropertyCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'TimeStandsStill');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_insanity";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Offensive;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	SetUnitValueEffect = new class'X2Effect_SetUnitValue';
	SetUnitValueEffect.UnitName = 'TimeStopCounter';
	SetUnitValueEffect.NewValueToSet = 3;
	SetUnitValueEffect.CleanupType = eCleanup_Never;
	Template.AddShooterEffect(SetUnitValueEffect);
	
	TimeMasterEffect = new class'RTEffect_TimeStopMaster';
	TimeMasterEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	TimeMasterEffect.EffectName = 'TimeStopMasterEffect';
	Template.AddShooterEffect(TimeMasterEffect);

	CounterEffect = new class'RTEffect_Counter';
	CounterEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	CounterEffect.CounterUnitValName = 'TimeStopCounter';
	CounterEffect.WatchRule = eGameRule_PlayerTurnEnd;
	CounterEFfect.TriggerEventName = 'TimeStopEnded';
	CounterEffect.bShouldTriggerEvent = true;
	CounterEffect.EffectName = 'TimeStandsStillCounterEffect';
	Template.AddShooterEffect(CounterEffect);

	MultiTarget = new class'X2AbilityMultiTarget_Radius';
	MultiTarget.fTargetRadius = 500;
	MultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	MultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTarget;

	Template.ConcealmentRule = eConceal_Always;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;												  
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	UnitPropertyCondition.ExcludeCivilian = false;
	UnitPropertyCondition.FailOnNonUnits = true;
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 2;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = TIMESTANDSSTILL_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	TimeStopEffect = new class'RTEffect_TimeStop';
	TimeStopEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	TimeStopEffect.ApplyChance = 100;
	TimeStopEffect.EffectTickedVisualizationFn = class'RTEffect_TimeStop'.static.TimeStopVisualizationTicked;
	TimeStopEffect.SetDisplayInfo(ePerkBuff_Penalty, "Greyscaled", 
		"This unit has been frozen in time. It cannot take actions and is much easier to hit.", Template.IconImage);
	TimeStopEffect.bRemoveWhenTargetDies = true;
	TimeStopEffect.bCanTickEveryAction = true;
	Template.AddMultiTargetEffect(TimeStopEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	// TODO: VISUALIZATION
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	Template.AdditionalAbilities.AddItem('TimeStandsStillCleanseListener');


	Template.bCrossClassEligible = false;
	return Template;
}

//---------------------------------------------------------------------------------------
//---Time Stands Still Cleanse Listener--------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate TimeStandsStillCleanseListener()
{
	local X2AbilityTemplate						Template;
	local X2Condition_UnitProperty				UnitPropertyCondition;
	local X2Effect_RemoveEffects				RemoveSelfEffect; 
	local X2Effect_RemoveEffects				RemoveMultiEffect;
	local X2AbilityMultiTarget_Radius			MultiTarget;
 	local X2AbilityTrigger_EventListener		EventListener;
	local X2Effect_Knockback					KnockbackEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'TimeStandsStillCleanseListener');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_voidadept";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	MultiTarget = new class'X2AbilityMultiTarget_Radius';
	MultiTarget.fTargetRadius = 500;
	MultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	MultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTarget;

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.EventID = 'TimeStopEnded';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.Filter = eFilter_Unit;
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.AbilityTargetStyle = default.SelfTarget;

	RemoveSelfEffect = new class'X2Effect_RemoveEffects';
	RemoveSelfEffect.EffectNamesToRemove.AddItem('TimeStandsStillCounterEffect');
	RemoveSelfEffect.EffectNamesToRemove.AddItem('TimeStopMasterEffect');
	RemoveSelfEffect.bCheckSource = false;

	RemoveMultiEffect = new class'X2Effect_RemoveEffects';
	RemoveMultiEffect.EffectNamesToRemove.AddItem('Freeze');
	RemoveMultiEffect.bCheckSource = false;

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	KnockbackEffect.bUseTargetLocation = true;
	Template.AddMultiTargetEffect(KnockbackEffect);
	
	Template.AddShooterEffect(RemoveSelfEffect);
	Template.AddMultiTargetEffect(RemoveMultiEFfect);
	
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;


	Template.bCrossClassEligible = false;
	return Template;
}
//---------------------------------------------------------------------------------------
//---Linked Intelligence-----------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate LinkedIntelligence()
{
	local X2AbilityTemplate						Template;
	local X2AbilityMultiTarget_Radius			MultiTarget;
	local RTEffect_LinkedIntelligence			LinkedEffect, ChainEffect;
	local X2Condition_UnitEffectsWithAbilityTarget	UnitCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'LinkedIntelligence');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_insanity";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	UnitCondition = new class'X2Condition_UnitEffectsWithAbilityTarget';
	UnitCondition.AddRequireEffect('GhostPsiSuite', 'AA_UnitMustBeGhost');
	//Template.AbilityTargetConditions.AddItem(UnitCondition);
	Template.AbilityMultiTargetConditions.AddItem(UnitCondition);

	MultiTarget = new class'X2AbilityMultiTarget_AllAllies';
	Template.AbilityMultiTargetStyle = MultiTarget;
	
	// seperate self/allied effects to differentiate buff categories
	LinkedEffect = new class 'RTEffect_LinkedIntelligence';
	LinkedEffect.BuildPersistentEffect(1, true, false, false,  eGameRule_PlayerTurnEnd);
	LinkedEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddShooterEffect(LinkedEffect);

	ChainEffect = new class 'RTEffect_LinkedIntelligence';
	ChainEffect.BuildPersistentEffect(1, true, false, false,  eGameRule_PlayerTurnEnd);
	//ChainEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddMultiTargetEffect(ChainEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!
	
	Template.bCrossClassEligible = false;
	return Template;
	
}

//---------------------------------------------------------------------------------------
//---Twitch Reaction---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate TwitchReaction()
{
	local X2AbilityTemplate                 Template;
	local RTEffect_TwitchReaction			TwitchEffect;


	`CREATE_X2ABILITY_TEMPLATE(Template, 'TwitchReaction');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aim";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	// Apply perk at the start of the mission. 
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	// Effect to apply
	TwitchEffect = new class'RTEffect_TwitchReaction';
	TwitchEffect.BuildPersistentEffect(1, true, true, true);
	TwitchEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(TwitchEffect);

	//Template.AdditionalAbilities.AddItem('TwitchReactionShot');

	// Probably required 
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

//---------------------------------------------------------------------------------------
//---Twitch Reaction Shot----------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate TwitchReactionShot()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_Ammo				AmmoCost;
	local X2AbilityCost_ReserveActionPoints ReserveActionPointCost;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2AbilityTarget_Single            SingleTarget;
	local X2Effect_Persistent               TwitchReactionEffectTarget;
	local X2Condition_UnitEffectsWithAbilitySource  TwitchReactionCondition;
	local X2Condition_Visibility            TargetVisibilityCondition;
	local X2Condition_UnitProperty          ShooterCondition;
	local X2Effect_Knockback				KnockbackEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'TwitchReactionShot');
	Template.bHideOnClassUnlock = true;
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	ReserveActionPointCost = new class'X2AbilityCost_ReserveActionPoints';
	ReserveActionPointCost.iNumPoints = 1;
	ReserveActionPointCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint);
	Template.AbilityCosts.AddItem(ReserveActionPointCost);

	// considering the penalty on reaction shots, -40 might be too harsh, -30 for now
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bReactionFire = true;
	StandardAim.BuiltInHitMod = -30;
	Template.AbilityToHitCalc = StandardAim;

	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bDisablePeeksOnMovement = true;
	TargetVisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());

	//  Do not shoot targets that were already hit by this unit this turn with this ability
	TwitchReactionCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	TwitchReactionCondition.AddExcludeEffect('TwitchReactionTarget', 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(TwitchReactionCondition);
	//  Mark the target as shot by this unit so it cannot be shot again this turn
	TwitchReactionEffectTarget = new class'X2Effect_Persistent';
	TwitchReactionEffectTarget.EffectName = 'TwitchReactionTarget';
	TwitchReactionEffectTarget.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);
	TwitchReactionEffectTarget.SetupEffectOnShotContextResult(true, true);      //  mark them regardless of whether the shot hit or missed
	Template.AddTargetEffect(TwitchReactionEffectTarget);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	ShooterCondition = new class'X2Condition_UnitProperty';
	ShooterCondition.ExcludeConcealed = true;
	// meld condition on the shooter goes here? but how do I check that the target is shooting a melded unit?
	//MeldCondition = new class'RTCondition_MeldProperty';
	//Template.AbilityShooterConditions.AddItem(MeldCondition);
	
	Template.AbilityShooterConditions.AddItem(ShooterCondition);
	Template.AddShooterEffectExclusions();

	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.OnlyIncludeTargetsInsideWeaponRange = true;
	Template.AbilityTargetStyle = SingleTarget;

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	Template.AddTargetEffect(default.WeaponUpgradeMissDamage);

	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overwatch";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;	 

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	KnockbackEffect.bUseTargetLocation = true;
	Template.AddTargetEffect(KnockbackEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Psionic Surge-----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate PsionicSurge()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCooldown                 Cooldown;
	local X2AbilityCost_ActionPoints		ActionPoint;
	local RTEffect_PsionicSurge				SurgeEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'PsionicSurge');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_mindcontrol";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.ConcealmentRule = eConceal_Always;

	ActionPoint = new class'X2AbilityCost_ActionPoints';
	ActionPoint.iNumPoints = 1;
	ActionPoint.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPoint);
	
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.SURGE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	SurgeEffect = new class 'RTEffect_PsionicSurge';
	SurgeEffect.BuildPersistentEffect(1, true, true, false,  eGameRule_PlayerTurnEnd);
	SurgeEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(SurgeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	//TODO: VISUALIZATION
	Template.bSkipFireAction = true;

	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Heat Channel------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate HeatChannel()
{
	local X2AbilityTemplate					Template;
	local X2AbilityTrigger_EventListener	Trigger;
	local X2AbilityCooldown                 Cooldown;	
	local X2Condition_UnitProperty			ShooterPropertyCondition;
	local X2Condition_AbilitySourceWeapon	WeaponCondition;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'HeatChannel');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_phantom";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Neutral;

	Template.ConcealmentRule = eConceal_Always;

	ShooterPropertyCondition = new class'X2Condition_UnitProperty';	
	ShooterPropertyCondition.ExcludeDead = true;                    //Can't reload while dead
	Template.AbilityShooterConditions.AddItem(ShooterPropertyCondition);
	WeaponCondition = new class'X2Condition_AbilitySourceWeapon';
	WeaponCondition.WantsReload = true;
	Template.AbilityShooterConditions.AddItem(WeaponCondition);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.HEAT_CHANNEL_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'UnitUsedPsionicAbility';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'RTGameState_Ability'.static.HeatChannelCheck;
	Template.AbilityTriggers.AddItem(Trigger);
	
	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.bSkipFireAction = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;

	Template.AdditionalAbilities.AddItem('HeatChannelIcon');


	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	//TODO: VISUALIZATION
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bCrossClassEligible = false;				

	return Template;
}

//---------------------------------------------------------------------------------------
//---Heat Channel Icon-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate HeatChannelIcon()
{
	local X2AbilityTemplate					Template;
	local X2Effect_Persistent				AgroEffect;

	//Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'HeatChannelIcon');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aggression";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	//Apply perk at the start of the mission. 
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	AgroEffect = new class'X2Effect_Persistent';
	AgroEffect.BuildPersistentEffect(1, true, true, true);
	AgroEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(AgroEffect);



	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

//---------------------------------------------------------------------------------------
//---Eye in the Sky----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate EyeInTheSky()
{
	local X2AbilityTemplate					Template;
	local X2Effect_ModifyReactionFire		ReactionFire;

	//Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'EyeInTheSky');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overwatch";
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	//Apply perk at the start of the mission. 
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	ReactionFire = new class'X2Effect_ModifyReactionFire';
	ReactionFire.bAllowCrit = true;
	ReactionFire.ReactionModifier = 30;
	ReactionFire.BuildPersistentEffect(1, true, true, true);
	ReactionFire.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(ReactionFire);

	Template.AdditionalAbilities.AddItem('CoveringFire');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

//---------------------------------------------------------------------------------------
//---Shock And Awe----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate ShockAndAwe()
{
	local X2AbilityTemplate					Template;
	local RTEffect_ShockAndAwe				ShockEffect;

	//Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShockAndAwe');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overwatch";
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	//Apply perk at the start of the mission. 
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	ShockEffect = new class'RTEffect_ShockAndAwe';
	ShockEffect.BuildPersistentEffect(1, true, true, false);
	ShockEffect.iDamageRequiredToActivate = SHOCKANDAWE_DAMAGE_TO_ACTIVATE;
	ShockEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(ShockEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

//---------------------------------------------------------------------------------------
//---Shock And Awe Listener--------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate ShockAndAweListener()
{
	local X2AbilityTemplate					Template;
	local X2AbilityTrigger_EventListener	EventListener;
	local X2AbilityMultiTarget_Radius		MultiTarget;
	local X2Condition_UnitProperty			UnitPropertyCondition;

	//Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShockAndAweListener');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overwatch";
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Offensive;

	//Apply perk at the start of the mission. 
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;

	// Copied Straight from Shieldbearer ability
	// The Targets must be within the AOE and hostile
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;												  
	UnitPropertyCondition.ExcludeFriendlyToSource = true;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	UnitPropertyCondition.ExcludeCivilian = true;
	UnitPropertyCondition.FailOnNonUnits = true;
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

	MultiTarget = new class'X2AbilityMultiTarget_Radius';
	MultiTarget.fTargetRadius = 17;
	MultiTarget.bIgnoreBlockingCover = false;
	Template.AbilityMultiTargetStyle = MultiTarget;

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.EventID = 'ShockAndAweTrigger';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.Filter = eFilter_Unit;
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.VoidRiftInsanityListener;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.AddMultiTargetEffect(class'X2StatusEffects'.static.CreateDisorientedStatusEffect(, , false));


	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.bSkipFireAction = true;
	//  TODO: VISUALIZATION

	return Template;
}
//---------------------------------------------------------------------------------------
//---Harbinger-----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate Harbinger()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCooldown                 Cooldown;
	local X2AbilityCost_ActionPoints		ActionPoint;
	local RTEffect_Harbinger				HarbingerEffect;
	local X2Condition_UnitEffectsWithAbilitySource	MeldCondition;
	local X2Effect_EnergyShield ShieldedEffect;


	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'Harbinger');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_mindcontrol";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.ConcealmentRule = eConceal_Always;

	ShieldedEffect = new class'X2Effect_EnergyShield';
	ShieldedEffect.BuildPersistentEffect(1, true, true, , eGameRule_PlayerTurnEnd);
	ShieldedEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,true,,Template.AbilitySourceName);
	ShieldedEffect.AddPersistentStatChange(eStat_ShieldHP, HARBINGER_SHIELD_AMOUNT);
	ShieldedEffect.EffectRemovedVisualizationFn = class'X2Ability_AdventShieldBearer'.OnShieldRemoved_BuildVisualization;
	Template.AddTargetEffect(ShieldedEffect);

	ActionPoint = new class'X2AbilityCost_ActionPoints';
	ActionPoint.iNumPoints = 1;
	ActionPoint.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPoint);

	MeldCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	MeldCondition.AddRequireEffect('RTEffect_Meld', 'Unit must be melded!');
	Template.AbilityShooterConditions.AddItem(MeldCondition);
	Template.AbilityTargetConditions.AddItem(MeldCondition);
	
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.HARBINGER_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	HarbingerEffect = new class 'RTEffect_Harbinger';
	HarbingerEffect.BuildPersistentEffect(1, true, true, false,  eGameRule_PlayerTurnEnd);
	HarbingerEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	HarbingerEffect.BONUS_PSI_DAMAGE = default.HARBINGER_DAMAGE_BONUS;
	HarbingerEffect.BONUS_AIM = default.HARBINGER_AIM_BONUS;
	HarbingerEffect.BONUS_WILL = default.HARBINGER_WILL_BONUS;
	HarbingerEffect.BONUS_ARMOR = default.HARBINGER_ARMOR_BONUS;
	Template.AddTargetEffect(HarbingerEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	//TODO: VISUALIZATION
	Template.bSkipFireAction = true;

	Template.bCrossClassEligible = false;

	return Template;
}





