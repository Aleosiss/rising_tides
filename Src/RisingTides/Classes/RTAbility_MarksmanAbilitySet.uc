//---------------------------------------------------------------------------------------
//  FILE:    RTAbility_MarksmanAbilitySet.uc
//  AUTHOR:  Aleosiss
//  DATE:    8 February 2016
//  PURPOSE: Defines abilities used by Whisper.
//           
//---------------------------------------------------------------------------------------
//	Whisper's perks.
//---------------------------------------------------------------------------------------

class RTAbility_MarksmanAbilitySet extends RTAbility_GhostAbilitySet
	config(RisingTides);

	var config int SLOWISSMOOTH_AIM_BONUS, SLOWISSMOOTH_CRIT_BONUS;
	var config float HEADSHOT_CRITDMG_BONUS;
	var config int HEADSHOT_CRIT_BONUS, HEADSHOT_COOLDOWN;
	var config int HEADSHOT_AIM_MULTIPLIER;
	var config int SQUADSIGHT_CRIT_CHANCE;
	var config int SNAPSHOT_AIM_BONUS;
	var config int DISABLESHOT_AIM_BONUS, DISABLESHOT_COOLDOWN;
	var config float KNOCKTHEMDOWN_CRITDMG_MULTIPLIER;
	var config float SIXOCLOCK_WILL_BONUS;
	var config float SIXOCLOCK_PSI_BONUS;
	var config float SIXOCLOCK_DEFENSE_BONUS;
	var config int TIMESTANDSSTILL_COOLDOWN;
	var config int BARRIER_STRENGTH, BARRIER_COOLDOWN;
	var config int VITAL_POINT_TARGETING_DAMAGE;
	var config int SURGE_COOLDOWN;
	var config int HEATCHANNEL_COOLDOWN;
	var config int HARBINGER_SHIELD_AMOUNT, HARBINGER_COOLDOWN, HARBINGER_DAMAGE_BONUS, HARBINGER_WILL_BONUS, HARBINGER_AIM_BONUS, HARBINGER_ARMOR_BONUS;
	var config int SHOCKANDAWE_DAMAGE_TO_ACTIVATE;
	var config int SOVEREIGN_PANIC_CHANCE;
	var config int PSIONICKILLZONE_COOLDOWN;
	var config float DISABLING_SHOT_REDUCTION;
	var config int SNAPSHOT_AIM_PENALTY;
	var config int SOC_DEFENSE_BONUS;
	var config int SOC_PSI_BONUS; 
	var config int SOC_WILL_BONUS;
	var config int DGG_DEFENSE_BONUS; 
	var config int DGG_AIM_BONUS;
	var config int SND_DEFENSE_BONUS;
	var config float EMM_DAMAGE_PERCENT;

	var Name KillZoneReserveType;

//---------------------------------------------------------------------------------------
//---CreateTemplates---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(ScopedAndDropped());							// icon
	Templates.AddItem(RTStandardSniperShot());
	Templates.AddItem(RTOverwatch());
	Templates.AddItem(RTOverwatchShot());
	Templates.AddItem(RTPrecisionShot());
	Templates.AddItem(RTPrecisionShotDamage());
	Templates.AddItem(RTAggression());
	Templates.AddItem(KnockThemDown());
	Templates.AddItem(RTDisablingShot());
	Templates.AddItem(RTDisablingShotDamage());
	Templates.AddItem(RTSnapshot());
	Templates.AddItem(SixOClock());									// icon
	Templates.AddItem(SixOClockEffect());
	Templates.AddItem(VitalPointTargeting());
	Templates.AddItem(RTDamnGoodGround());
	Templates.AddItem(SlowIsSmooth());								// icon
	Templates.AddItem(SlowIsSmoothEffect());
	Templates.AddItem(Sovereign());									// icon
	Templates.AddItem(SovereignEffect());
	Templates.AddItem(DaybreakFlame());										// animation
	Templates.AddItem(DaybreakFlameIcon());							// icon
	Templates.AddItem(YourHandsMyEyes());							// icon
	Templates.AddItem(TimeStandsStill());									// animation
	Templates.AddItem(TimeStandsStillEndListener());
	Templates.AddItem(TwitchReaction());
	Templates.AddItem(TwitchReactionShot());
	Templates.AddItem(LinkedIntelligence());						// icon
	Templates.AddItem(PsionicSurge());								// icon
	Templates.AddItem(EyeInTheSky());								// icon
	Templates.AddItem(HeatChannel());										// animation
	Templates.AddItem(HeatChannelIcon());							// icon
	Templates.AddItem(HeatChannelCooldown());								
	Templates.AddItem(Harbinger());									// icon	// animation
	Templates.AddItem(HarbingerCleanseListener());
	Templates.AddItem(ShockAndAwe());								// icon
	Templates.AddItem(ShockAndAweListener());
	Templates.AddItem(RTKillzone());								// icon
	Templates.AddItem(RTEveryMomentMatters());						// icon

	return Templates;
}

//---------------------------------------------------------------------------------------
//---Scoped and Dropped------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate ScopedAndDropped()
{
	local X2AbilityTemplate						Template;
	local RTEffect_ScopedAndDropped				ScopedEffect;
	local RTEffect_Squadsight					SSEffect;

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
	ScopedEffect.iPanicChance = default.SOVEREIGN_PANIC_CHANCE;
	ScopedEffect.iDamageRequiredToActivate = default.SHOCKANDAWE_DAMAGE_TO_ACTIVATE;
	ScopedEffect.DEFENSE_BONUS = default.SND_DEFENSE_BONUS;
	Template.AddTargetEffect(ScopedEffect);
	
	SSEffect = new class'RTEffect_Squadsight';
	SSEffect.BuildPersistentEffect(1, true, true, true);
	Template.AddTargetEffect(SSEffect);

	// standard ghost abilities
	Template.AdditionalAbilities.AddItem('GhostPsiSuite');
	Template.AdditionalAbilities.AddItem('JoinMeld');
	Template.AdditionalAbilities.AddItem('LeaveMeld');
	Template.AdditionalAbilities.AddItem('PsiOverload');
	Template.AdditionalAbilities.AddItem('PsiOverloadPanic');

	// unique abilities for Scoped and Dropped
	Template.AdditionalAbilities.AddItem('RTStandardSniperShot');
	Template.AdditionalAbilities.AddItem('RTOverwatch');
	Template.AdditionalAbilities.AddItem('RTOverwatchShot');

	// special meld abilities
	Template.AdditionalAbilities.AddItem('LIOverwatchShot');
	Template.AdditionalAbilities.AddItem('RTUnstableConduitBurst');
	Template.AdditionalAbilities.AddItem('PsionicActivate');

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
	
	ActionPointCost = new class'RTAbilityCost_SnapshotActionPoints';
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
	StandardAim.SQUADSIGHT_DISTANCE_MOD = 0;
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
	local RTAbilityCooldown                 Cooldown;
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

	Cooldown = new class'RTAbilityCooldown';
	Cooldown.iNumTurns = default.HEADSHOT_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.SQUADSIGHT_DISTANCE_MOD = 0;
	ToHitCalc.BuiltInHitMod = -(default.HEADSHOT_AIM_MULTIPLIER);
	Template.AbilityToHitCalc = ToHitCalc;

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	ActionPointCost = new class'RTAbilityCost_SnapshotActionPoints';																																				   
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.iNumPoints = 2;
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
	DamageEffect.HEADSHOT_CRITDMG_BONUS = default.HEADSHOT_CRITDMG_BONUS;
	DamageEffect.HEADSHOT_CRIT_BONUS = default.HEADSHOT_CRIT_BONUS;
	DamageEffect.SQUADSIGHT_CRIT_CHANCE = default.SQUADSIGHT_CRIT_CHANCE;
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
static function X2AbilityTemplate RTAggression()
{
	local X2AbilityTemplate						Template;
	local RTEffect_Aggression					AgroEffect;

	//Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTAggression');
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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_sniper_bullet_x3";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	//Apply perk at the start of the mission. 
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	KnockEffect = new class'RTEffect_KnockThemDown';
	KnockEffect.CRIT_DAMAGE_MODIFIER = default.KNOCKTHEMDOWN_CRITDMG_MULTIPLIER;
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
static function X2AbilityTemplate RTDisablingShot()
{
	local X2AbilityTemplate                 Template;
	local RTAbilityCooldown                 Cooldown;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
	local X2Condition_Visibility            TargetVisibilityCondition;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_DisableWeapon			DisableWeapon;
	local X2Effect_Stunned			StunEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTDisablingShot');

	Template.AdditionalAbilities.AddItem('RTDisablingShotDamage');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_disablingshot";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Offensive;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	Cooldown = new class'RTAbilityCooldown';
	Cooldown.iNumTurns = default.DISABLESHOT_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.SQUADSIGHT_DISTANCE_MOD = 0;
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
	
	StunEffect = new class'X2Effect_Stunned';
	StunEffect.StunLevel = 1;
	StunEffect.TargetConditions.AddItem(default.LivingTargetUnitOnlyProperty);
	Template.AddTargetEffect(StunEffect);

	Template.bAllowAmmoEffects = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Disabling Shot Damage Effect--------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTDisablingShotDamage()
{
	local X2AbilityTemplate						Template;
	local RTEffect_DisablingShotDamage          DamageEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTDisablingShotDamage');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_momentum";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	DamageEffect = new class'RTEffect_DisablingShotDamage';
	DamageEffect.DISABLING_SHOT_REDUCTION = default.DISABLING_SHOT_REDUCTION;
	DamageEffect.BuildPersistentEffect(1, true, true, true);
	DamageEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false,,Template.AbilitySourceName);
	Template.AddTargetEffect(DamageEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

//---------------------------------------------------------------------------------------
//---RTSnapshot----------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTSnapshot()
{
	local X2AbilityTemplate						Template;
	local RTEffect_SnapshotEffect		  SnapshotEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTSnapshot');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snapshot";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	//Apply perk at the start of the mission. 
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	SnapshotEffect = new class'RTEffect_SnapshotEffect';
	SnapshotEffect.SNAPSHOT_AIM_PENALTY = default.SNAPSHOT_AIM_PENALTY;
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
	local X2Effect_PersistentStatChange			ClockEffect;
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
	MultiTarget.fTargetRadius = 500;

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
	ClockEffect = new class'X2Effect_PersistentStatChange';
	// One turn duration
	ClockEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	ClockEffect.AddPersistentStatChange(eStat_Defense, default.SOC_DEFENSE_BONUS);
	ClockEffect.AddPersistentStatChange(eStat_PsiOffense, default.SOC_PSI_BONUS);
	ClockEffect.AddPersistentStatChange(eStat_Will, default.SOC_WILL_BONUS);
	ClockEffect.SetDisplayInfo(ePerkBuff_Bonus, "I've got your six.", 
		"Whisper has this unit's six. Gain +" @ 10 @ " bonus to defense, psi, and will.", Template.IconImage);
	

	// Add it
	Template.AddMultiTargetEffect(ClockEffect);
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
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
static function X2AbilityTemplate RTDamnGoodGround()
{
	local X2AbilityTemplate						Template;
	local RTEffect_DamnGoodGround				DGGEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTDamnGoodGround');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_damngoodground";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	DGGEffect = new class 'RTEffect_DamnGoodGround';
	DGGEffect.DGG_DEFENSE_BONUS = default.DGG_DEFENSE_BONUS;
	DGGEffect.DGG_AIM_BONUS = default.DGG_AIM_BONUS;
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
	Effect.EffectName = 'RTEffect_SlowIsSmooth';
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
	SISEffect.AIM_BONUS = default.SLOWISSMOOTH_AIM_BONUS;
	SISEffect.CRIT_BONUS = default.SLOWISSMOOTH_CRIT_BONUS;
	SISEffect.BuildPersistentEffect(1, true, false, false,  eGameRule_PlayerTurnEnd);
	//Temporary Icon to confirm effect is on target					 
	Template.AddTargetEffect(SISEffect);

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
	local X2Condition_UnitProperty				MultiUnitPropertyCondition, UnitPropertyCondition;
	local X2Effect_Panicked				        PanicEffect;
	local X2AbilityCooldown						Cooldown;
 	local X2AbilityTrigger_EventListener		EventListener;
	local X2AbilityMultiTarget_Radius			MultiTarget;
	local X2Effect_Persistent					CooldownEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SovereignEffect');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_voidadept";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	//UnitPropertyCondition = new class'X2Condition_UnitProperty';
	//UnitPropertyCondition.ExcludeAlive = true;
	//Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	MultiUnitPropertyCondition = new class'X2Condition_UnitProperty';
	MultiUnitPropertyCondition.ExcludeFriendlyToSource = true;
	MultiUnitPropertyCondition.ExcludeRobotic = true;
	MultiUnitPropertyCondition.FailOnNonUnits = true;
	Template.AbilityMultiTargetConditions.AddItem(MultiUnitPropertyCondition);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 5;
	Template.AbilityCooldown = Cooldown;

	CooldownEffect = new class'X2Effect_Persistent';
	CooldownEffect.BuildPersistentEffect(5, false, true, false, eGameRule_PlayerTurnEnd);
	CooldownEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, "Sovereign is on cooldown!", Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddShooterEffect(CooldownEffect);

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.EventID = 'SovereignTrigger';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.Filter = eFilter_Unit;
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.VoidRiftInsanityListener;
	Template.AbilityTriggers.AddItem(EventListener);

	PanicEffect = class'X2StatusEffects'.static.CreatePanickedStatusEffect();
	Template.AddMultiTargetEffect(PanicEffect);

	MultiTarget = new class'X2AbilityMultiTarget_Radius';
	MultiTarget.bIgnoreBlockingCover = true;
	MultiTarget.fTargetRadius = 10;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityMultiTargetStyle = MultiTarget;
	Template.AddShooterEffectExclusions();

	Template.AbilityToHitCalc = default.DeadEye;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	
	Template.bCrossClassEligible = false;


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
	local RTAbilityMultiTarget_TargetedLine		LineMultiTarget, LineSingleTarget;
	local X2AbilityTarget_Cursor				CursorTarget;
	local X2AbilityTarget_Single				SingleTarget;

	local RTCondition_VisibleToPlayer			PlayerVisibilityCondition;

	
	//Macro to do localisation and stuffs
	`CREATE_X2TEMPLATE(class'RTAbilityTemplate', Template, 'DaybreakFlame');
	//`CREATE_X2ABILITY_TEMPLATE(Template, 'DaybreakFlame');
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
	TargetVisibilityCondition.bAllowSquadsight = true;
	TargetVisibilityCondition.bVisibleToAnyAlly = true;
	//TargetVisibilityCondition.RequireGameplayVisibleTags.AddItem('OverTheShoulder');
	//Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

	// can only shoot visible (to the player) enemies
	PlayerVisibilityCondition = new class'RTCondition_VisibleToPlayer';
	Template.AbilityTargetConditions.AddItem(PlayerVisibilityCondition); 

	// Can't target dead; Can't target friendlies
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	
	// Single targets that are in range. 
	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.bAllowDestructibleObjects = true;
	SingleTarget.bShowAOE = true;
	Template.AbilityTargetStyle = SingleTarget;

	// Targeting Method
	Template.TargetingMethod = class'RTTargetingMethod_AimedLineSkillshot';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	// Line skillshot
	LineMultiTarget = new class'RTAbilityMultiTarget_TargetedLine';
	LineMultiTarget.bSightRangeLimited = false;
	Template.AbilityMultiTargetStyle = LineMultiTarget;
	Template.bRecordValidTiles = true;

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
	//Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	// Damage Effect
	Template.AddTargetEffect(default.WeaponUpgradeMissDamage);

	// Hit Calculation (Different weapons now have different calculations for range)
	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.SQUADSIGHT_DISTANCE_MOD = 0;
	Template.AbilityToHitCalc = ToHitCalc;

	//Template.bOverrideAim = true;  
	Template.bUseSourceLocationZToAim = true;

	// Damage/Burning Effect
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.EffectDamageValue.Pierce = 9999;
	WeaponDamageEffect.EffectDamageValue.Shred = 4;			 
	WeaponDamageEffect.bApplyWorldEffectsForEachTargetLocation = true;     
	Template.AddTargetEffect(WeaponDamageEffect);     
	Template.AddMultiTargetEffect(WeaponDamageEffect);   
	
	BurningEffect = class'X2StatusEffects'.static.CreateBurningStatusEffect(3, 0);   //Adds Burning Effect for 3 damage, 0 spread
	BurningEffect.ApplyChance = 100;                                         //Should be a 100% chance to actually apply burning 
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
	WorldDamage.bHitSourceTile = false;
	WorldDamage.ApplyChance = 100;
	Template.AddMultiTargetEffect(WorldDamage);                     //May be redundant

	FireToWorldEffect = new class'X2Effect_ApplyFireToWorld';                //This took a while to find
	FireToWorldEffect.bUseFireChanceLevel = true;                           
	FireToWorldEffect.bDamageFragileOnly = false;
	FireToWorldEffect.bCheckForLOSFromTargetLocation = false;
	FireToWorldEffect.FireChance_Level1 = 0.95f;                             //%chance of fire to catch
	FireToWorldEffect.FireChance_Level2 = 0.95f;
	FireToWorldEffect.FireChance_Level3 = 0.95f;
	Template.AddTargetEffect(FireToWorldEffect);
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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_daybreaker";

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
	local RTEffect_TimeStopMaster				TimeMasterEffect;
	local X2Effect_SetUnitValue					SetUnitValueEffect;
	local RTEffect_Counter						CounterEffect;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2AbilityCooldown						Cooldown;
	local X2AbilityMultiTarget_Radius			MultiTarget;
	local X2Condition_UnitProperty				UnitPropertyCondition;
	local RTEffect_TimeStopTag					TagEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'TimeStandsStill');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_horoarma";

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

	TagEffect = new class'RTEffect_TimeStopTag';
	TagEffect.BuildPersistentEffect(1, true, true, true);
	TagEffect.EffectName = 'TimeStopTagEffect';
	Template.AddShooterEffect(TagEffect);

	CounterEffect = new class'RTEffect_Counter';
	CounterEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	CounterEffect.CounterUnitValName = 'TimeStopCounter';
	CounterEFfect.TriggerEventName = 'TimeStopEnded';
	CounterEffect.bShouldTriggerEvent = true;
	CounterEffect.EffectName = 'TimeStandsStillCounterEffect';
	Template.AddShooterEffect(CounterEffect);


	MultiTarget = new class'X2AbilityMultiTarget_Radius';
	MultiTarget.fTargetRadius = 500;
	MultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	MultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTarget;
	Template.AbilityMultiTargetConditions.Additem(default.LivingTargetUnitOnlyProperty);

	Template.ConcealmentRule = eConceal_Always;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 2;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.TIMESTANDSSTILL_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	// this effect should always apply (even if it is forced to miss) and lasts until Whisper ends it himself
	TimeStopEffect = new class'RTEffect_TimeStop';
	TimeStopEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	TimeStopEffect.ApplyChance = 100;
	TimeStopEffect.bIsImpairing = true;
	TimeStopEffect.bTickWhenApplied = false;
	TimeStopEffect.bCanBeRedirected = false;
	TimeStopEffect.bApplyOnMiss = true;
	TimeStopEffect.EffectTickedVisualizationFn = class'RTEffect_TimeStop'.static.TimeStopVisualizationTicked;
	TimeStopEffect.SetDisplayInfo(ePerkBuff_Penalty, "Greyscaled", 
		"This unit has been frozen in time. It cannot take actions and is much easier to hit.", Template.IconImage);
	TimeStopEffect.bRemoveWhenTargetDies = true;
	TimeStopEffect.bCanTickEveryAction = true;

	//UnitPropertyCondition = new class'X2Condition_UnitProperty';
	//UnitPropertyCondition.FailOnNonUnits = true;
	//TimeStopEffect.TargetConditions.AddItem(UnitPropertyCondition);

	Template.AddMultiTargetEffect(TimeStopEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	Template.PostActivationEvents.AddItem('UnitUsedPsionicAbility');

	// TODO: VISUALIZATION
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	Template.AdditionalAbilities.AddItem('TimeStandsStillEndListener');


	Template.bCrossClassEligible = false;
	return Template;
}

//---------------------------------------------------------------------------------------
//---Time Stands Still End Listener------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate TimeStandsStillEndListener()
{
	local X2AbilityTemplate						Template;
	local X2Condition_UnitProperty				UnitPropertyCondition;
	local X2Effect_RemoveEffects				RemoveSelfEffect; 
	local X2Effect_RemoveEffects				RemoveMultiEffect;
	local X2AbilityMultiTarget_Radius			MultiTarget;
 	local X2AbilityTrigger_EventListener		EventListener;
	local X2Effect_Knockback					KnockbackEffect;
	local RTEffect_TimeStopDamage				TimeStopDamageEffect;									

	`CREATE_X2ABILITY_TEMPLATE(Template, 'TimeStandsStillEndListener');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_voidadept";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.ConcealmentRule = eConceal_Always;

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

	TimeStopDamageEffect = new class'RTEffect_TimeStopDamage';
	TimeStopDamageEffect.DamageTag = 'TimeStopDamageEffect';
	TimeStopDamageEffect.bIgnoreBaseDamage = true;
	Template.AddMultiTargetEffect(TimeStopDamageEffect);

	RemoveSelfEffect = new class'X2Effect_RemoveEffects';
	RemoveSelfEffect.EffectNamesToRemove.AddItem('TimeStandsStillCounterEffect');
	RemoveSelfEffect.EffectNamesToRemove.AddItem('TimeStopMasterEffect');
	RemoveSelfEffect.EffectNamesToRemove.AddItem('TimeStopTagEffect');
	RemoveSelfEffect.bCheckSource = false;

	RemoveMultiEffect = new class'X2Effect_RemoveEffects';
	RemoveMultiEffect.EffectNamesToRemove.AddItem('Freeze');
	RemoveMultiEffect.bCheckSource = false;

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	KnockbackEffect.bUseTargetLocation = true;
	Template.AddMultiTargetEffect(KnockbackEffect);
	Template.AbilityMultiTargetConditions.Additem(default.LivingTargetUnitOnlyProperty);
	
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
	LinkedEffect.AbilityToActivate = 'LIOverwatchShot';
	LinkedEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddShooterEffect(LinkedEffect);

	ChainEffect = new class 'RTEffect_LinkedIntelligence';
	ChainEffect.BuildPersistentEffect(1, true, false, false,  eGameRule_PlayerTurnEnd);
	ChainEffect.AbilityToActivate = 'LIOverwatchShot';
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

	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

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
	local X2Effect_GrantActionPoints		ActionPointEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'PsionicSurge');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_mindcontrol";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.ConcealmentRule = eConceal_Always;

	ActionPoint = new class'X2AbilityCost_ActionPoints';
	ActionPoint.iNumPoints = 1;
	ActionPoint.bFreeCost = true;
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
	SurgeEffect.BuildPersistentEffect(1, false, true, false,  eGameRule_PlayerTurnEnd);
	SurgeEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(SurgeEffect);

	ActionPointEffect = new class'X2Effect_GrantActionPoints';
	ActionPointEffect.NumActionPoints = 1;
	ActionPointEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	Template.AddTargetEffect(ActionPointEffect);

	Template.PostActivationEvents.AddItem('UnitUsedPsionicAbility');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	//TODO: VISUALIZATION
	Template.bShowActivation = true;
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
	local RTEffect_HeatChannel				HeatEffect;
	local RTEffect_Counter					CounterEffect;
	local X2Effect_SetUnitValue				UnitValEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'HeatChannel');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_phantom";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	UnitValEffect = new class'X2Effect_SetUnitValue';
	UnitValEffect.UnitName = 'RTEffect_HeatChannel_Cooldown';
	UnitValEffect.NewValueToSet = 0;
	UnitValEffect.CleanupType = eCleanup_BeginTactical;
	Template.AddShooterEffect(UnitValEffect);
	
	CounterEffect = new class'RTEffect_Counter';
	CounterEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	CounterEffect.CounterUnitValName = 'RTEffect_HeatChannel_Cooldown';
	CounterEffect.WatchRule = eGameRule_PlayerTurnEnd;
	CounterEffect.bShouldTriggerEvent = true;
	CounterEffect.TriggerEventName = 'HeatChannelCooldownComplete';
	CounterEffect.EffectName = 'HeatChannelCounterEffect';
	Template.AddShooterEffect(CounterEffect);
	
	HeatEffect = new class'RTEffect_HeatChannel';
	HeatEffect.BuildPersistentEffect(1, true, false, false, eGameRule_PlayerTurnEnd);
	HeatEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddShooterEffect(HeatEffect);
	
	Template.ConcealmentRule = eConceal_Always;

	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.bSkipFireAction = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;

	Template.AdditionalAbilities.AddItem('HeatChannelIcon');
	Template.AdditionalAbilities.AddItem('HeatChannelCooldown');


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
	return CreateRTCooldownCleanse('HeatChannelIcon', 'HeatChannelCooldownTrackerEffect', 'HeatChannelCooldownComplete');
}
	
//---------------------------------------------------------------------------------------
//---Heat Channel Cooldown---------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate HeatChannelCooldown()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCooldown                 Cooldown;
	local X2AbilityCost_ActionPoints		ActionPoint;
	local X2Effect_Persistent				AgroEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'HeatChannelCooldown');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_mindcontrol";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.ConcealmentRule = eConceal_Always;

	ActionPoint = new class'X2AbilityCost_ActionPoints';
	ActionPoint.iNumPoints = 0;
	ActionPoint.bFreeCost = true;
	ActionPoint.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPoint);
	
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 0;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	AgroEffect = new class'X2Effect_Persistent';
	AgroEffect.BuildPersistentEffect(1, true, true, true, eGameRule_PlayerTurnEnd);
	AgroEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, "Heat Channel is on cooldown!", Template.IconImage, true,,Template.AbilitySourceName);
	AgroEffect.EffectName = 'HeatChannelCooldownTrackerEffect';
	Template.AddTargetEffect(AgroEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	//TODO: VISUALIZATION
	Template.bSkipFireAction = true;

	Template.bCrossClassEligible = false;

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
	ShockEffect.iDamageRequiredToActivate = default.SHOCKANDAWE_DAMAGE_TO_ACTIVATE;
	ShockEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(ShockEffect);

	Template.AdditionalAbilities.AddItem('ShockAndAweListener');

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
	local X2AbilityCost_ActionPoints		ActionPoint;

	//Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShockAndAweListener');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overwatch";
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Offensive;

	// Deadeye to ensure
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	ActionPoint = new class'X2AbilityCost_ActionPoints';
	ActionPoint.bFreeCost = true;
	Template.AbilityCosts.AddItem(ActionPoint);

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
	MultiTarget.fTargetRadius = 10;
	MultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTarget;

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.EventID = 'ShockAndAweTrigger';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.Filter = eFilter_Unit;
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.VoidRiftInsanityListener;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.AddMultiTargetEffect(class'X2StatusEffects'.static.CreateDisorientedStatusEffect(, , false));


	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.bShowActivation = true;
	//  TODO: VISUALIZATION

	return Template;
}
//---------------------------------------------------------------------------------------
//---Harbinger---------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate Harbinger()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCooldown                 Cooldown;
	local X2AbilityCost_ActionPoints		ActionPoint;
	local RTEffect_Harbinger				HarbingerEffect;
	local X2Effect_Persistent				TagEffect;
	local X2Condition_UnitEffects	MeldCondition;
	local X2Condition_UnitEffects			TagCondition;
	local X2AbilityTarget_Single				SingleTarget;
	local X2Effect_EnergyShield ShieldedEffect;
	local X2Condition_UnitProperty	TargetCondition;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'Harbinger');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_mindcontrol";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.ConcealmentRule = eConceal_Always;

	ShieldedEffect = new class'X2Effect_EnergyShield';
	ShieldedEffect.BuildPersistentEffect(1, true, true, , eGameRule_PlayerTurnEnd);
	ShieldedEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,true,,Template.AbilitySourceName);
	ShieldedEffect.AddPersistentStatChange(eStat_ShieldHP, default.HARBINGER_SHIELD_AMOUNT);
	ShieldedEffect.EffectRemovedVisualizationFn = OnShieldRemoved_BuildVisualization;
	Template.AddTargetEffect(ShieldedEffect);

	ActionPoint = new class'X2AbilityCost_ActionPoints';
	ActionPoint.iNumPoints = 1;
	ActionPoint.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPoint);

	MeldCondition = new class'X2Condition_UnitEffects';
	MeldCondition.AddRequireEffect('RTEffect_Meld', 'AA_UnitNotMelded');
	Template.AbilityShooterConditions.AddItem(MeldCondition);
	Template.AbilityTargetConditions.AddItem(MeldCondition);

	TagCondition = new class'X2Condition_UnitEffects';
	TagCondition.AddExcludeEffect('HarbingerTagEffect', 'AA_UnitAlreadyUsedAbility');
	Template.AbilityShooterConditions.AddItem(TagCondition);
	
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.HARBINGER_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeHostileToSource = true;
	TargetCondition.ExcludeFriendlyToSource = false;
	TargetCondition.RequireSquadmates = true;
	TargetCondition.FailOnNonUnits = true;
	TargetCondition.ExcludeDead = true;
	TargetCondition.ExcludeRobotic = true;
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	SingleTarget = new class 'X2AbilityTarget_Single';
	SingleTarget.bIncludeSelf = false;
	SingleTarget.bAllowDestructibleObjects = false;
	Template.AbilityTargetStyle = SingleTarget;

	HarbingerEffect = new class 'RTEffect_Harbinger';
	HarbingerEffect.BuildPersistentEffect(1, true, true, false,  eGameRule_PlayerTurnEnd);
	HarbingerEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	HarbingerEffect.BONUS_PSI_DAMAGE = default.HARBINGER_DAMAGE_BONUS;
	HarbingerEffect.BONUS_AIM = default.HARBINGER_AIM_BONUS;
	HarbingerEffect.BONUS_WILL = default.HARBINGER_WILL_BONUS;
	HarbingerEffect.BONUS_ARMOR = default.HARBINGER_ARMOR_BONUS;
	Template.AddTargetEffect(HarbingerEffect);

	TagEffect = new class'X2Effect_Persistent';
	TagEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	TagEffect.EffectName = 'HarbingerTagEffect';
	Template.AddShooterEffect(TagEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	Template.PostActivationEvents.AddItem('UnitUsedPsionicAbility');
	
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	//TODO: VISUALIZATION
	Template.bSkipFireAction = true;

	Template.bCrossClassEligible = false;

	return Template;
}

simulated function OnShieldRemoved_BuildVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;

	if (XGUnit(BuildTrack.TrackActor).IsAlive())
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "Harbinger Shield Broken", '', eColor_Bad, , 0.75, true);
	}
}
//---------------------------------------------------------------------------------------
//---Harbinger Cleanse Listener----------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate HarbingerCleanseListener()
{
	local X2AbilityTemplate						Template;
	local X2Condition_UnitProperty				UnitPropertyCondition;
	local X2Effect_RemoveEffects				RemoveSelfEffect; 
	local X2Effect_RemoveEffects				RemoveMultiEffect;
	local X2AbilityMultiTarget_Radius			MultiTarget;
 	local X2AbilityTrigger_EventListener		EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'HarbingerCleanseListener');
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
	EventListener.ListenerData.EventID = 'RTRemoveUnitFromMeld';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.Filter = eFilter_Unit;
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.AbilityTargetStyle = default.SelfTarget;

	RemoveSelfEffect = new class'X2Effect_RemoveEffects';
	RemoveSelfEffect.EffectNamesToRemove.AddItem('HarbingerTagEffect');
	RemoveSelfEffect.bCheckSource = false;

	RemoveMultiEffect = new class'X2Effect_RemoveEffects';
	RemoveMultiEffect.EffectNamesToRemove.AddItem('Harbinger');
	RemoveMultiEffect.bCheckSource = false;

	Template.AddShooterEffect(RemoveSelfEffect);
	Template.AddMultiTargetEffect(RemoveMultiEFfect);
	
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;


	Template.bCrossClassEligible = false;
	return Template;
}

//---------------------------------------------------------------------------------------
//---Psionic Killzone--------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTKillZone()
{
	local X2AbilityTemplate             Template;
	local X2AbilityCooldown             Cooldown;
	local X2AbilityCost_Ammo            AmmoCost;
	local X2AbilityCost_ActionPoints    ActionPointCost;
	local X2AbilityTarget_Cursor        CursorTarget;
	local X2AbilityMultiTarget_Cone     ConeMultiTarget;
	local X2Effect_ReserveActionPoints  ReservePointsEffect;
	local X2Effect_MarkValidActivationTiles MarkTilesEffect;
	local X2Condition_UnitEffects           SuppressedCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTKillZone');

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 2;
	ActionPointCost.bConsumeAllPoints = true;   //  this will guarantee the unit has at least 1 action point
	ActionPointCost.bFreeCost = true;           //  ReserveActionPoints effect will take all action points away
	ActionPointCost.DoNotConsumeAllEffects.Length = 0;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.Length = 0;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();
	SuppressedCondition = new class'X2Condition_UnitEffects';
	SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(SuppressedCondition);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.PSIONICKILLZONE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bUseWeaponRadius = true;
	ConeMultiTarget.ConeEndDiameter = 32 * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.ConeLength = 60 * class'XComWorldData'.const.WORLD_StepSize;
	Template.AbilityMultiTargetStyle = ConeMultiTarget;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	ReservePointsEffect = new class'X2Effect_ReserveActionPoints';
	ReservePointsEffect.ReserveType = default.KillZoneReserveType;
	Template.AddShooterEffect(ReservePointsEffect);

	MarkTilesEffect = new class'X2Effect_MarkValidActivationTiles';
	MarkTilesEffect.AbilityToMark = 'KillZoneShot';
	Template.AddShooterEffect(MarkTilesEffect);

	Template.AdditionalAbilities.AddItem('KillZoneShot');
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.bShowActivation = true;

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_killzone";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.Hostility = eHostility_Defensive;
	Template.AbilityConfirmSound = "Unreal2DSounds_OverWatch";

	Template.ActivationSpeech = 'KillZone';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.TargetingMethod = class'X2TargetingMethod_Cone';

	Template.bCrossClassEligible = false;
	Template.PostActivationEvents.AddItem('UnitUsedPsionicAbility');

	return Template;
}

//---------------------------------------------------------------------------------------
//---Every Moment Matters----------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTEveryMomentMatters()
{
	local X2AbilityTemplate						Template;
	local RTEffect_EveryMomentMatters			RTEffect;

	 `CREATE_X2ABILITY_TEMPLATE(Template, 'RTEveryMomentMatters');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_insanity";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	RTEffect = new class 'RTEffect_EveryMomentMatters';
	RTEffect.BuildPersistentEffect(1, true, false, false,  eGameRule_PlayerTurnEnd);
	RTEffect.BONUS_DAMAGE_PERCENT = default.EMM_DAMAGE_PERCENT;
	RTEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(RTEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!
	
	Template.bCrossClassEligible = false;
	return Template;
}

defaultproperties
{
	KillZoneReserveType = "KillZone";
}
