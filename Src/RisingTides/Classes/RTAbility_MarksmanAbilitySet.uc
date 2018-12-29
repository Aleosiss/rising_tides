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
	var config int KNOCKTHEMDOWN_DAMAGE_INCREMENT;
	var config float SIXOCLOCK_WILL_BONUS;
	var config float SIXOCLOCK_PSI_BONUS;
	var config float SIXOCLOCK_DEFENSE_BONUS;
	var config int TIMESTANDSSTILL_COOLDOWN;
	var config int BARRIER_STRENGTH, BARRIER_COOLDOWN;
	var config int VITAL_POINT_TARGETING_DAMAGE;
	var config int SURGE_COOLDOWN;
	var config int HEATCHANNEL_COOLDOWN;
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
	var config int SIS_CONCEALMENT_TURNS;
	var config int REPOSITIONING_TILES_MOVED_REQUIREMENT;
	var config int REPOSITIONING_MAX_POSITIONS_SAVED;
	var config int AGGRESSION_CRIT_PER_UNIT;
	var config int AGGRESSION_UNITS_FOR_MAX_BONUS;

	var config int HARBINGER_SHIELD_AMOUNT, HARBINGER_COOLDOWN, HARBINGER_DAMAGE_BONUS, HARBINGER_WILL_BONUS, HARBINGER_AIM_BONUS, HARBINGER_ARMOR_BONUS;
	var config WeaponDamageValue HARBINGER_DMG;

	var localized string TimeStopEffectTitle;
	var localized string TimeStopEffectDescription;

	var config int KUBIKURI_COOLDOWN;
	var config int KUBIKURI_AMMO_COST;
	var config int KUBIKURI_MIN_ACTION_REQ;
	var config int KUBIKURI_MAX_HP_PCT;

	var name KillZoneReserveType;
	var name TimeStopEffectName;

	var config array<name> AbilityPerksToLoad;

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
	Templates.AddItem(RTAggression());
	Templates.AddItem(KnockThemDown());
	Templates.AddItem(RTDisablingShot());
	Templates.AddItem(RTDisablingShotDamage());
	Templates.AddItem(RTSnapshot());
	Templates.AddItem(SixOClock());									// icon
	Templates.AddItem(SixOClockEffect());
	//Templates.AddItem(VitalPointTargeting());
	Templates.AddItem(RTDamnGoodGround());
	Templates.AddItem(SlowIsSmooth());
	Templates.AddItem(SlowIsSmoothEffect());
	Templates.AddItem(Sovereign());
	Templates.AddItem(SovereignEffect());
	Templates.AddItem(DaybreakFlame());										// animation
	Templates.AddItem(DaybreakFlameIcon());
	Templates.AddItem(YourHandsMyEyes());
	Templates.AddItem(TimeStandsStill());									// animation
	Templates.AddItem(TimeStandsStillInterruptListener());
	Templates.AddItem(TimeStandsStillEndListener());
	Templates.AddItem(TwitchReaction());
	Templates.AddItem(TwitchReactionShot());
	Templates.AddItem(LinkedIntelligence());
	Templates.AddItem(PsionicSurge());								   	// animation
	Templates.AddItem(EyeInTheSky());
	Templates.AddItem(HeatChannel());										// animation
	Templates.AddItem(HeatChannelIcon());
	Templates.AddItem(HeatChannelCooldown());
	Templates.AddItem(Harbinger());
	Templates.AddItem(RTHarbingerPsionicLance());
	Templates.AddItem(HarbingerCleanseListener());
	Templates.AddItem(ShockAndAwe());
	Templates.AddItem(ShockAndAweListener());
	Templates.AddItem(RTKillzone());								// icon
	Templates.AddItem(RTEveryMomentMatters());
	Templates.AddItem(RTOverflowBarrier());
	Templates.AddItem(RTOverflowBarrierEvent());
	Templates.AddItem(RTKubikuri());
	Templates.AddItem(RTKubikuriDamage());
	Templates.AddItem(RTRepositioning());

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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_stealth_crit2_snd";
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
	Template.AdditionalAbilities.AddItem('RTFeedback');
	Template.AdditionalAbilities.AddItem('RTMindControl');
	Template.AdditionalAbilities.AddItem('RTEnterStealth');

	// unique abilities for Scoped and Dropped
	Template.AdditionalAbilities.AddItem('RTStandardSniperShot');
	Template.AdditionalAbilities.AddItem('RTOverwatch');
	Template.AdditionalAbilities.AddItem('RTOverwatchShot');

	// special meld abilities
	Template.AdditionalAbilities.AddItem('LIOverwatchShot');
	Template.AdditionalAbilities.AddItem('RTUnstableConduitBurst');
	Template.AdditionalAbilities.AddItem('PsionicActivate');
	Template.AdditionalAbilities.AddItem('RTHarbingerPsionicLance');

	// Probably required
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

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
	//local X2Condition_Visibility            TargetVisibilityCondition;
	local RTCondition_VisibleToPlayer	VisibleToPlayerCondition;
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
	// can only shoot visible enemies, LOS required
	VisibleToPlayerCondition = new class'RTCondition_VisibleToPlayer';
	VisibleToPlayerCondition.bRequireLOS = true;
	Template.AbilityTargetConditions.AddItem(VisibleToPlayerCondition);

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

	class'X2StrategyElement_XpackDarkEvents'.static.AddStilettoRoundsEffect(Template);

	KnockbackEffect = new class'X2Effect_Knockback';
	Template.AddTargetEffect(KnockbackEffect);

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	Template.bFrameEvenWhenUnitIsHidden = true;


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
	CoveringFireCondition.OwnerHasSoldierAbilities.AddItem('EyeInTheSky');
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
	local X2AbilityTrigger_Event	      Trigger;
	local array<name>                       SkipExclusions;
	local X2Condition_Visibility            TargetVisibilityCondition;
	local RTCondition_VisibleToPlayer VisibleToPlayerCondition;

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
	TargetVisibilityCondition.bRequireLOS = true;
	TargetVisibilityCondition.bDisablePeeksOnMovement = true;
	TargetVisibilityCondition.bAllowSquadsight = true;

	VisibleToPlayerCondition = new class'RTCondition_VisibleToPlayer';
	VisibleToPlayerCondition.bRequireLOS = true;
	Template.AbilityTargetConditions.AddItem(VisibleToPlayerCondition);

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
	Template.AbilitySourceName = 'eAbilitySource_Standard';
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
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_aggression";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	//Apply perk at the start of the mission.
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	AgroEffect = new class'RTEffect_Aggression';
	AgroEffect.iCritBonusPerUnit = default.AGGRESSION_CRIT_PER_UNIT;
	AgroEffect.iUnitsForMaxBonus = default.AGGRESSION_UNITS_FOR_MAX_BONUS;
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

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	//Apply perk at the start of the mission.
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	KnockEffect = new class'RTEffect_KnockThemDown';
	KnockEffect.DAMAGE_INCREMENT = default.KNOCKTHEMDOWN_DAMAGE_INCREMENT;
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
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

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
	local RTEffect_Snapshot						SnapshotEffect;

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

	SnapshotEffect = new class'RTEffect_Snapshot';
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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_sixoclock";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
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

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_stealth_cycle_sis";

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
	SISEffect.CONCEALMENT_DELAY_TURNS = default.SIS_CONCEALMENT_TURNS;
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
	local X2Condition_UnitProperty				MultiUnitPropertyCondition;
	local X2Effect_Panicked				      PanicEffect;
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
	local RTAbilityMultiTarget_TargetedLine		LineMultiTarget;
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
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
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

	// can only shoot visible (to the player) enemies, LOS NOT required
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
	Template.AbilityToHitCalc = ToHitCalc;

	//Template.bOverrideAim = true;
	Template.bUseSourceLocationZToAim = true;

	// Damage/Burning Effect
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.EffectDamageValue.Pierce = 9999;
	WeaponDamageEffect.EffectDamageValue.Shred = 4;
	WeaponDamageEffect.EffectDamageValue.Crit = 4;
	WeaponDamageEffect.bApplyWorldEffectsForEachTargetLocation = true;
	WeaponDamageEffect.EnvironmentalDamageAmount = 250;
	Template.AddTargetEffect(WeaponDamageEffect);
	Template.AddMultiTargetEffect(WeaponDamageEffect);

	BurningEffect = class'X2StatusEffects'.static.CreateBurningStatusEffect(3, 2);	//Adds Burning Effect for 3 damage, 2 spread
	BurningEffect.ApplyChance = 100;												//Should be a 100% chance to actually apply burning
	Template.AddTargetEffect(BurningEffect);
	Template.AddMultiTargetEffect(BurningEffect);									//Adds the burning effect to the targeted area

	WorldDamage = new class'X2Effect_ApplyDirectionalWorldDamage';	//creates the framework to apply damage to the world
	WorldDamage.bUseWeaponDamageType = False;						//overrides the normal weapon damage type
	WorldDamage.bUseWeaponEnvironmentalDamage = false;				//replaces the weapon's environmental damage with the abilities
	WorldDamage.EnvironmentalDamageAmount = 250;					//determines the amount of enviornmental damage the ability applies
	WorldDamage.bApplyOnHit = true;									//obv
	WorldDamage.bApplyOnMiss = true;								//obv
	WorldDamage.bApplyToWorldOnHit = true;							//obv
	WorldDamage.bApplyToWorldOnMiss = true;							//obv
	WorldDamage.bHitAdjacentDestructibles = false;					//applies environmental damage to things adjacent to the Line
	WorldDamage.PlusNumZTiles = 1;									//determines how 'high' the world damage is applied
	WorldDamage.bHitTargetTile = true;								//Makes sure that everthing that is targetted is hit
	WorldDamage.bHitSourceTile = false;
	WorldDamage.ApplyChance = 100;
	Template.AddMultiTargetEffect(WorldDamage);		//May be redundant

	FireToWorldEffect = new class'X2Effect_ApplyFireToWorld';	//This took a while to find
	FireToWorldEffect.bUseFireChanceLevel = true;
	FireToWorldEffect.bDamageFragileOnly = false;
	FireToWorldEffect.bCheckForLOSFromTargetLocation = false;
	FireToWorldEffect.FireChance_Level1 = 0.95f;				//%chance of fire to catch
	FireToWorldEffect.FireChance_Level2 = 0.95f;
	FireToWorldEffect.FireChance_Level3 = 0.95f;
	Template.AddTargetEffect(FireToWorldEffect);
	Template.AddMultiTargetEffect(FireToWorldEffect);			//this is required to add the fire effect

	Template.OverrideAbilities.AddItem('SniperStandardFire');
	Template.OverrideAbilities.AddItem('RTStandardSniperShot');

	// MAKE IT LIVE!
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	// TODO: VISUALIZATION
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	class'X2StrategyElement_XpackDarkEvents'.static.AddStilettoRoundsEffect(Template);
	// add it to multitargets as well
	Template.AddMultiTargetEffect(Template.AbilityTargetEffects[Template.AbilityTargetEffects.Length - 1]);

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddTargetEffect(KnockbackEffect);
	Template.AddMultiTargetEffect(KnockbackEffect);

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	Template.bFrameEvenWhenUnitIsHidden = true;

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

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_psi_box_yhme";

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

	Template.AddShooterEffectExclusions();

	SetUnitValueEffect = new class'X2Effect_SetUnitValue';
	SetUnitValueEffect.UnitName = 'TimeStopCounter';
	SetUnitValueEffect.NewValueToSet = 3;
	SetUnitValueEffect.CleanupType = eCleanup_BeginTactical;
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

	// should nab everyone
	MultiTarget = new class'X2AbilityMultiTarget_Radius';
	MultiTarget.fTargetRadius = 500 * class'XComWorldData'.const.WORLD_StepSize * class'XComWorldData'.const.WORLD_UNITS_TO_METERS_MULTIPLIER;
	MultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	MultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTarget;

	// no one can escape
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.FailOnNonUnits = true;
	UnitPropertyCondition.ExcludeInStasis = false;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeDead = false;
	UnitPropertyCondition.ExcludeCosmetic = false;
	Template.AbilityMultiTargetConditions.Additem(UnitPropertyCondition);

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
	TimeStopEffect.SetDisplayInfo(ePerkBuff_Penalty, default.TimeStopEffectTitle, default.TimeStopEffectDescription, Template.IconImage);
	TimeStopEffect.bRemoveWhenTargetDies = true;
	TimeStopEffect.bRemoveWhenSourceDies = true;
	TimeStopEffect.bCanTickEveryAction = true;
	TimeStopEffect.EffectName = default.TimeStopEffectName;

	//TimeStopEffect.TargetConditions.AddItem(UnitPropertyCondition);

	Template.AddMultiTargetEffect(TimeStopEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.PostActivationEvents.AddItem(default.UnitUsedPsionicAbilityEvent);


	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CustomFireAnim = 'HL_Psi_SelfCast';
	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Template.AdditionalAbilities.AddItem('TimeStandsStillEndListener');
	Template.AdditionalAbilities.AddItem('TimeStandsStillInterruptListener');


	Template.bCrossClassEligible = false;
	return Template;
}

//---------------------------------------------------------------------------------------
//---Time Stands Still Interrupt Listener------------------------------------------------
//---------------------------------------------------------------------------------------
 static function X2AbilityTemplate TimeStandsStillInterruptListener()
{
	local X2AbilityTemplate						Template;
	local RTEffect_TimeStop						TimeStopEffect;
	local X2Condition_UnitProperty				UnitPropertyCondition;
	local X2AbilityTrigger_Placeholder			Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'TimeStandsStillInterruptListener');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_horoarma";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.FailOnNonUnits = true;
	UnitPropertyCondition.ExcludeInStasis = false;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeDead = false;
	UnitPropertyCondition.ExcludeCosmetic = false;
	Template.AbilityMultiTargetConditions.Additem(UnitPropertyCondition);

	Template.ConcealmentRule = eConceal_Always;

	// OnUnitBeginPlay
	Trigger = new class'X2AbilityTrigger_Placeholder';
	Template.AbilityTriggers.AddItem(Trigger);

	// this effect should always apply (even if it is forced to miss) and lasts until Whisper ends it himself
	TimeStopEffect = new class'RTEffect_TimeStop';
	TimeStopEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	TimeStopEffect.ApplyChance = 100;
	TimeStopEffect.bIsImpairing = true;
	TimeStopEffect.bTickWhenApplied = false;
	TimeStopEffect.bCanBeRedirected = false;
	TimeStopEffect.bApplyOnMiss = true;
	TimeStopEffect.EffectTickedVisualizationFn = class'RTEffect_TimeStop'.static.TimeStopVisualizationTicked;
	TimeStopEffect.SetDisplayInfo(ePerkBuff_Penalty, default.TimeStopEffectTitle, default.TimeStopEffectDescription, Template.IconImage);
	TimeStopEffect.bRemoveWhenTargetDies = true;
	TimeStopEffect.bCanTickEveryAction = true;
	TimeStopEffect.EffectName = default.TimeStopEffectName;
	TimeStopEffect.bRemoveWhenSourceDies = true;

	Template.AddTargetEffect(TimeStopEffect);

	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bCrossClassEligible = false;
	return Template;
}
//---------------------------------------------------------------------------------------
//---Time Stands Still End Listener------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate TimeStandsStillEndListener()
{
	local X2AbilityTemplate						Template;
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
	MultiTarget.fTargetRadius = 500 * class'XComWorldData'.const.WORLD_StepSize * class'XComWorldData'.const.WORLD_UNITS_TO_METERS_MULTIPLIER;
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
	RemoveMultiEffect.EffectNamesToRemove.AddItem(default.TimeStopEffectName);
	RemoveMultiEffect.bCheckSource = false;
	RemoveMultiEffect.bApplyOnMiss = true;

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddMultiTargetEffect(KnockbackEffect);

	Template.AddShooterEffect(RemoveSelfEffect);
	Template.AddMultiTargetEffect(RemoveMultiEFfect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.CinescriptCameraType = "Psionic_FireAtUnit";

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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_mind_psi_chevron_x3_networkedoi";

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
	Template.AddTargetEffect(KnockbackEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

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
	local X2Effect_Persistent				Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'PsionicSurge');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_psi_shot_2_psisurge";

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

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Effect = new class'X2Effect_Persistent';
	Effect.BuildPersistentEffect(0, false);
	Effect.VFXTemplateName = class'RTEffectBuilder'.default.SurgeStartupParticleString;
	Template.AddShooterEffect(Effect);

	SurgeEffect = new class 'RTEffect_PsionicSurge';
	SurgeEffect.BuildPersistentEffect(1, false, true, false,  eGameRule_PlayerTurnEnd);
	SurgeEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	SurgeEffect.VFXTemplateName = class'RTEffectBuilder'.default.SurgePersistentParticleString;
	SurgeEffect.VFXSocket = class'RTEffectBuilder'.default.SurgeSocketName;
	SurgeEffect.VFXSocketsArrayName = class'RTEffectBuilder'.default.SurgeArrayName;
	Template.AddTargetEffect(SurgeEffect);

	ActionPointEffect = new class'X2Effect_GrantActionPoints';
	ActionPointEffect.NumActionPoints = 1;
	ActionPointEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	Template.AddTargetEffect(ActionPointEffect);

	Template.PostActivationEvents.AddItem(default.UnitUsedPsionicAbilityEvent);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	//TODO: VISUALIZATION
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_reload_psi_heatchannel";

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
	local X2AbilityTemplate Template;

	Template = CreateRTCooldownCleanse('HeatChannelIcon', 'HeatChannelCooldownTrackerEffect', 'HeatChannelCooldownComplete');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_reload_psi_heatchannel";

	return Template;
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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_reload_psi_heatchannel";

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
	AgroEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_eyeinthesky";

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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_assumingdirectcontrol";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.ConcealmentRule = eConceal_Always;

	ShieldedEffect = new class'X2Effect_EnergyShield';
	ShieldedEffect.BuildPersistentEffect(1, true, true, , eGameRule_PlayerTurnEnd);
	ShieldedEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,true,,Template.AbilitySourceName);
	ShieldedEffect.AddPersistentStatChange(eStat_ShieldHP, default.HARBINGER_SHIELD_AMOUNT);
	ShieldedEffect.EffectRemovedVisualizationFn = OnHarbingerShieldRemoved_BuildVisualization;
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
	TargetCondition.ExcludeHostileToSource = false;
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
	HarbingerEffect.EffectName = 'HarbingerPossessionEffect';
	Template.AddTargetEffect(HarbingerEffect);

	TagEffect = new class'X2Effect_Persistent';
	TagEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	TagEffect.EffectName = 'HarbingerTagEffect';
	Template.AddShooterEffect(TagEffect);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.PostActivationEvents.AddItem(default.UnitUsedPsionicAbilityEvent);

	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	//TODO: VISUALIZATION
	Template.CustomFireAnim = 'HL_Psi_MindControl';
	Template.AdditionalAbilities.AddItem('HarbingerCleanseListener');

	Template.bCrossClassEligible = false;

	return Template;
}

simulated function OnHarbingerShieldRemoved_BuildVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;

	if (XGUnit(ActionMetadata.VisualizeActor).IsAlive())
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, class'RTAbility_GathererAbilitySet'.default.HarbingerShieldLostStr, '', eColor_Bad, , 0.75, true);
	}
}

//---------------------------------------------------------------------------------------
//---Harbinger Bonus Damage--------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTHarbingerPsionicLance() {
	local X2AbilityTemplate					Template;
	local X2AbilityTarget_Cursor			CursorTarget;
	local X2AbilityMultiTarget_Line         LineMultiTarget;
	local X2Condition_UnitProperty          TargetCondition;
	local X2Condition_UnitEffects			EffectCondition;
	local X2Effect_ApplyWeaponDamage        DamageEffect;
	local X2AbilityCooldown_PerPlayerType	Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTHarbingerPsionicLance');

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.Hostility = eHostility_Offensive;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_nulllance";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.OVERWATCH_PRIORITY + 5;

	Template.CustomFireAnim = 'HL_Psi_ProjectileHigh';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.AbilityCosts.AddItem(default.FreeActionCost);

	Cooldown = new class'X2AbilityCooldown_PerPlayerType';
	Cooldown.iNumTurns = 1;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityToHitCalc = default.DeadEye;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = 18;
	Template.AbilityTargetStyle = CursorTarget;

	LineMultiTarget = new class'X2AbilityMultiTarget_Line';
	Template.AbilityMultiTargetStyle = LineMultiTarget;

	EffectCondition = new class'X2Condition_UnitEffects';
	EffectCondition.AddRequireEffect('HarbingerPossessionEffect', 'AA_UnitIsSupressed');
	Template.AbilityShooterConditions.AddItem(EffectCondition);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeFriendlyToSource = false;
	TargetCondition.ExcludeDead = true;
	Template.AbilityMultiTargetConditions.AddItem(TargetCondition);

	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	DamageEffect.bIgnoreBaseDamage = true;
	DamageEffect.DamageTag = 'PsionicLance';
	DamageEffect.bIgnoreArmor = false;
	DamageEffect.EffectDamageValue = class'RTAbility_BerserkerAbilitySet'.default.PSILANCE_DMG;
	Template.AddMultiTargetEffect(DamageEffect);

	Template.TargetingMethod = class'X2TargetingMethod_Line';
	Template.CinescriptCameraType = "Psionic_FireAtLocation";

	Template.ActivationSpeech = 'NullLance';

	Template.bOverrideAim = true;
	Template.bUseSourceLocationZToAim = true;

	Template.PostActivationEvents.AddItem(default.UnitUsedPsionicAbilityEvent);

	return Template;
}


//---------------------------------------------------------------------------------------
//---Harbinger Cleanse Listener----------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate HarbingerCleanseListener()
{
	local X2AbilityTemplate						Template;
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
	local X2AbilityTemplate						Template;
	local X2AbilityCooldown						Cooldown;
	// local X2AbilityCost_Ammo					AmmoCost; don't want this for the case where Heat Channel is up and you want to use it to reload and killzone at the same time
	local RTAbilityCost_SnapshotActionPoints    ActionPointCost;
	local X2AbilityTarget_Cursor				CursorTarget;
	local X2AbilityMultiTarget_Cone				ConeMultiTarget;
	local X2Effect_ReserveActionPoints			ReservePointsEffect;
	local X2Effect_MarkValidActivationTiles		MarkTilesEffect;
	local X2Condition_UnitEffects				SuppressedCondition;
	local X2Effect_Persistent					Effect, Effect2;


	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTKillZone');

	ActionPointCost = new class'RTAbilityCost_SnapshotActionPoints';
	ActionPointCost.bIgnore = true;
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

	Effect = new class'X2Effect_Persistent';
	Effect.BuildPersistentEffect(0, false);
	Effect.VFXTemplateName = class'RTEffectBuilder'.default.KillzoneStartupParticleString;
	Template.AddShooterEffect(Effect);

	Effect2 = new class'X2Effect_Persistent';
	Effect2.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	Effect2.VFXTemplateName = class'RTEffectBuilder'.default.KillzoneStartupParticleString;
	Effect2.VFXSocket = class'RTEffectBuilder'.default.KillzoneSocketName;
	Effect2.VFXSocketsArrayName = class'RTEffectBuilder'.default.KillzoneArrayName;
	Template.AddShooterEffect(Effect2);

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
	Template.PostActivationEvents.AddItem(default.UnitUsedPsionicAbilityEvent);

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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_shot_bullet_everymomentmatters";

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

//---------------------------------------------------------------------------------------
//---Overflow Barrier----------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTOverflowBarrier()
{
	local X2AbilityTemplate Template;
	local RTEffect_OverflowBarrier RTEffect;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Condition_UnitEffects		MeldCondition;
	local X2AbilityMultiTarget_Radius	MultiTarget;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTOverflowBarrier');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_shield_psi_overflowbarrier";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	MeldCondition = new class'X2Condition_UnitEffects';
	MeldCondition.AddRequireEffect(class'RTEffect_Meld'.default.EffectName, 'AA_UnitNotMelded');

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(MeldCondition);

	MultiTarget = new class'X2AbilityMultiTarget_Radius';
	MultiTarget.fTargetRadius = 500;
	MultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	MultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTarget;
	Template.AbilityMultiTargetConditions.Additem(default.LivingTargetUnitOnlyProperty);
	Template.AbilityMultiTargetConditions.AddItem(MeldCondition);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'KillMail';
	Trigger.ListenerData.Priority = 40;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	// Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	RTEffect = new class 'RTEffect_OverflowBarrier';
	RTEffect.BuildPersistentEffect(1, false, true, false,  eGameRule_PlayerTurnBegin);
	RTEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	RTEffect.EffectRemovedVisualizationFn = OnShieldRemoved_BuildVisualization;
	RTEffect.EffectName = 'OverflowBarrierShield';
	Template.AddTargetEffect(RTEffect);
	Template.AddMultiTargetEffect(RTEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//Template.BuildVisualizationFn = Shielded_BuildVisualization;
	Template.bSkipFireAction = true;
	 Template.bShowActivation = true;

	Template.BuildVisualizationFn = OverflowShielded_BuildVisualization;
	Template.CinescriptCameraType = "AdvShieldBearer_EnergyShieldArmor";

	Template.AdditionalAbilities.AddItem('RTOverflowBarrierEvent');

	Template.bCrossClassEligible = false;
	return Template;

}

static function X2AbilityTemplate RTOverflowBarrierEvent() {
	local X2AbilityTemplate Template;
	local RTEffect_OverflowEvent EventEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTOverflowBarrierEvent');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_insanity";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	EventEffect = new class'RTEffect_OverflowEvent';
	EventEffect.BuildPersistentEffect(1, true, false, false);
	EventEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(EventEffect);

	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	return Template;
}

simulated function OnShieldRemoved_BuildVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;

	if (XGUnit(ActionMetadata.VisualizeActor).IsAlive())
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, class'XLocalizedData'.default.ShieldRemovedMsg, '', eColor_Bad, , , true);
	}
}

simulated function OverflowShielded_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability  Context;
	local StateObjectReference InteractingUnitRef;
	//Tree metadata
	local VisualizationActionMetadata   InitData;
	local VisualizationActionMetadata   SourceData;
	local XComGameState_Unit	UnitState;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	SourceData = InitData;
	SourceData.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	SourceData.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	SourceData.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	UnitState = XComGameState_Unit(SourceData.StateObject_OldState);

	if(UnitState.AffectedByEffectNames.Find('OverflowBarrierShield') ==  INDEX_NONE) {
		TypicalAbility_BuildVisualization(VisualizeGameState);
	}
}


// Kubikiri
static function X2AbilityTemplate RTKubikuri()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityCooldown                 Cooldown;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
	local X2Condition_Visibility			VisibilityCondition;
	local X2Effect_Knockback				KnockbackEffect;
	local X2Condition_UnitStatCheck			TargetHPCondition;
	local X2Condition_UnitEffects			SuppressedCondition;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'RTKubikuri');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.LW_AbilityKubikuri";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.DisplayTargetHitChance = true;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.CinescriptCameraType = "StandardGunFiring";
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bCrossClassEligible = false;
	Template.bUsesFiringCamera = true;
	Template.bPreventsTargetTeleport = false;
	Template.Hostility = eHostility_Offensive;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AddShooterEffectExclusions();
	Template.ActivationSpeech = 'Reaper';

	VisibilityCondition = new class'X2Condition_Visibility';
	VisibilityCondition.bRequireGameplayVisible = true;
	VisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(VisibilityCondition);

	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AssociatedPassives.AddItem('HoloTargeting');
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
	Template.bAllowAmmoEffects = true;

	ActionPointCost = new class 'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.KUBIKURI_MIN_ACTION_REQ;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	TargetHPCondition = new class 'X2Condition_UnitStatCheck';
	TargetHPCondition.AddCheckStat(eStat_HP,default.KUBIKURI_MAX_HP_PCT,eCheck_LessThanOrEqual,,,true);
	Template.AbilityTargetConditions.AddItem(TargetHPCondition);

	SuppressedCondition = new class'X2Condition_UnitEffects';
	SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	SuppressedCondition.AddExcludeEffect('AreaSuppression', 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(SuppressedCondition);

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = ToHitCalc;

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.KUBIKURI_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = default.KUBIKURI_AMMO_COST;
	Template.AbilityCosts.AddItem(AmmoCost);

	Template.AdditionalAbilities.AddItem('RTKubikuriDamage');

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddTargetEffect(KnockbackEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	return Template;
}

static function X2AbilityTemplate RTKubikuriDamage()
{
	local X2Effect_Kubikuri					DamageEffect;
	local X2AbilityTemplate					Template;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'RTKubikuriDamage');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.LW_AbilityKubikuri";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = 2;
	Template.Hostility = 2;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	DamageEffect=new class'X2Effect_Kubikuri';
	DamageEffect.BuildPersistentEffect(1, true, false, false);
	DamageEffect.SetDisplayInfo(0, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false,, Template.AbilitySourceName);
	Template.AddTargetEffect(DamageEffect);
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	return Template;
}

//---------------------------------------------------------------------------------------
//---Repositioning-----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTRepositioning() {
	local X2AbilityTemplate Template;
	local RTEffect_Repositioning RTEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTRepositioning');

	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_repositioning";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bCrossClassEligible = false;

	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	RTEffect = new class 'RTEffect_Repositioning';
	RTEffect.BuildPersistentEffect(1, true, false, false, eGameRule_PlayerTurnEnd);
	RTEffect.TilesMovedRequired = default.REPOSITIONING_TILES_MOVED_REQUIREMENT;
	RTEffect.MaxPositionsSaved = default.REPOSITIONING_MAX_POSITIONS_SAVED;
	RTEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(RTEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

defaultproperties
{
	KillZoneReserveType = "KillZone"
	TimeStopEffectName = "TimeStopEffect"
}

static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	local name Tag;

	Tag = name(InString);

	switch(Tag)
	{
	case 'RTREPOSITIONING_MAX_POSITIONS_SAVED':
		OutString = string(default.REPOSITIONING_MAX_POSITIONS_SAVED);
		return true;
	case 'RTREPOSITIONING_TILE_DISTANCE':
		OutString = string(default.REPOSITIONING_TILES_MOVED_REQUIREMENT);
		return true;
	case 'RTPRECISION_SHOT_CRIT_CHANCE':
		OutString = string(default.HEADSHOT_CRIT_BONUS);
		return true;
	case 'RTPRECISION_SHOT_CRIT_DAMAGE':
		OutString = string(default.HEADSHOT_CRITDMG_BONUS);
		return true;
	case 'RTPRECISION_SHOT_AIM_PENALITY':
		OutString = string(default.HEADSHOT_AIM_MULTIPLIER);
		return true;
	case 'AGGRESSION_CRIT_PER_UNIT':
		OutString = string(default.AGGRESSION_CRIT_PER_UNIT);
		return true;
	case 'AGGRESSION_MAX_CRIT':
		OutString = string(default.AGGRESSION_UNITS_FOR_MAX_BONUS * default.AGGRESSION_CRIT_PER_UNIT);
		return true;
	}

	return false;
}