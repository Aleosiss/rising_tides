//---------------------------------------------------------------------------------------
//  FILE:    RTAbility_GhostAbilitySet.uc
//  AUTHOR:  Aleosiss
//  DATE:    8 February 2016
//  PURPOSE: Defines abilities used by all Rising Tides classes.
//
//---------------------------------------------------------------------------------------
//	General Perks
//---------------------------------------------------------------------------------------

class RTAbility_GhostAbilitySet extends X2Ability
	config(RisingTides);

	var protected X2Condition_UnitProperty						LivingFriendlyUnitOnlyProperty;
	var protected X2Condition_UnitEffectsWithAbilitySource		OverTheShoulderProperty;
	var protected X2Condition_UnitProperty						LivingHostileUnitOnlyNonRoboticProperty;
	var protected RTCondition_PsionicTarget						PsionicTargetingProperty;
	var protected RTCondition_UnitSize							StandardSizeProperty;
	var protected EffectReason									TagReason;

	var localized string FEEDBACK_TITLE;
	var localized string FEEDBACK_DESC;
	var localized string OTS_TITLE;
	var localized string OTS_DESC_SELF;
	var localized string OTS_DESC_ALLY;
	var localized string OTS_DESC_ENEMY;
	var localized string BLOODLUST_TITLE;
	var localized string BLOODLUST_DESC;
	var localized string STEALTH_TITLE;
	var localized string STEALTH_DESC;
	var localized string MELD_TITLE;
	var localized string MELD_DESC;
	var localized string FADE_COOLDOWN_TITLE;
	var localized string FADE_COOLDOWN_DESC;
	var localized string UV_TITLE;
	var localized string UV_DESC;
	var localized string SOC_TITLE;
	var localized string SOC_DESC;
	var localized string GREYSCALED_TITLE;
	var localized string GREYSCALED_DESC;
	var localized string HARBINGER_BROKEN_ALERT;
	var localized string OVERFLOW_READOUT;

	var config int BASE_REFLECTION_CHANCE;
	var config int BASE_DEFENSE_INCREASE;
	var config int TEEK_REFLECTION_INCREASE;
	var config int TEEK_DEFENSE_INCREASE;
	var config int TEEK_DODGE_INCREASE;
	var config int OVERLOAD_CHARGES;
	var config int OVERLOAD_BASE_COOLDOWN;
	var config int OVERLOAD_PANIC_CHECK;
	var config int FADE_DURATION;
	var config int FADE_COOLDOWN;
	var config int MAX_BLOODLUST_MELDJOIN;
	var config int FEEDBACK_DURATION;
	var config int MIND_CONTROL_AI_TURNS_DURATION;
	var config int MIND_CONTROL_COOLDOWN;
	var config int GHOST_CHARGES;

	var name RTFeedbackEffectName;
	var name RTFeedbackWillDebuffName;
	var name RTMindControlEffectName;
	var name RTGhostTagEffectName;

	var name RTMindControlTemplateName;
	var name RTTechnopathyTemplateName;

	var name UnitUsedPsionicAbilityEvent;
	var name ForcePsionicAbilityEvent;

	var config string BurstParticleString;
	var config name BurstSocketName;
	var config name BurstArrayName;
	var config name BurstAnimName;

	var float DefaultPsionicAnimDelay;

//---------------------------------------------------------------------------------------
//---CreateTemplates---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(GhostPsiSuite());
	Templates.AddItem(StandardGhostShot());

	Templates.AddItem(LeaveMeld());
	Templates.AddItem(JoinMeld());

	//Templates.AddItem(Reflection());
	Templates.AddItem(PsiOverload());
	Templates.AddItem(RTFeedback());

	Templates.AddItem(Teek());
	Templates.AddItem(Fade());
	Templates.AddItem(RTMindControl());
	Templates.AddItem(RTEnterStealth());


	Templates.AddItem(LIOverwatchShot());
	Templates.AddItem(PsionicActivate());
	Templates.AddItem(RTRemoveAdditionalAnimSets());

	Templates.AddItem(TestAbility());



	return Templates;
}
//---------------------------------------------------------------------------------------
//---Ghost Psi Suite---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate GhostPsiSuite()
{
	local X2AbilityTemplate						Template;
	local X2Effect_Persistent		Effect;
	local X2Effect_AdditionalAnimSets AnimSetEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GhostPsiSuite');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_mindcontrol";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Effect = new class 'X2Effect_Persistent';
	Effect.BuildPersistentEffect(1, true, true, true);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(Effect);

	AnimSetEffect = new class'X2Effect_AdditionalAnimSets';
	AnimSetEffect.AddAnimSetWithPath("RisingTidesContentPackage.Anims.AS_Psi");
	Template.AddTargetEffect(AnimSetEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!

	Template.bCrossClassEligible = false;

	return Template;
}
//---------------------------------------------------------------------------------------
//---StandardGhostShot--------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate StandardGhostShot()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local array<name>                       SkipExclusions;
	local X2Effect_Knockback				KnockbackEffect;
	local X2Condition_Visibility            VisibilityCondition;
	local X2Condition_AbilityProperty		SiphonCondition;
	local X2Condition_UnitProperty			TargetUnitPropertyCondition;
	local RTEffect_Siphon					SiphonEffect;

	// Macro to do localisation and stuffs
	`CREATE_X2ABILITY_TEMPLATE(Template, 'StandardGhostShot');

	// Icon Properties
	Template.bDontDisplayInAbilitySummary = true;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_standard";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.DisplayTargetHitChance = true;
	Template.AbilitySourceName = 'eAbilitySource_Standard';                                       // color of the icon
	// Activated by a button press; additionally, tells the AI this is an activatable
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);


	// Targeting Details
	// Can only shoot visible enemies
	VisibilityCondition = new class'X2Condition_Visibility';
	VisibilityCondition.bRequireGameplayVisible = true;
	VisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(VisibilityCondition);
	// Can't target dead; Can't target friendlies
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	// Only at single targets that are in range.
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// Action Point
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	// Ammo
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	Template.bAllowAmmoEffects = true; //
	Template.bAllowBonusWeaponEffects = true;

	// Weapon Upgrade Compatibility
	Template.bAllowFreeFireWeaponUpgrade = true;                        // Flag that permits action to become 'free action' via 'Hair Trigger' or similar upgrade / effects

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	//  Various Soldier ability specific effects - effects check for the ability before applying
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	// Damage Effect
	Template.AddTargetEffect(default.WeaponUpgradeMissDamage);

	// Siphon Effect
	SiphonEffect = new class'RTEffect_Siphon';
	SiphonEffect.SiphonAmountMultiplier = class'RTAbility_BerserkerAbilitySet'.default.SIPHON_AMOUNT_MULTIPLIER;
	SiphonEffect.SiphonMinVal = class'RTAbility_BerserkerAbilitySet'.default.SIPHON_MIN_VAL;
	SiphonEffect.SiphonMaxVal = class'RTAbility_BerserkerAbilitySet'.default.SIPHON_MAX_VAL;
	SiphonEffect.DamageTypes.AddItem('Psi');

	TargetUnitPropertyCondition = new class'X2Condition_UnitProperty';
	TargetUnitPropertyCondition.ExcludeDead = false;
	TargetUnitPropertyCondition.ExcludeRobotic = true;
	TargetUnitPropertyCondition.ExcludeFriendlyToSource = false;
	TargetUnitPropertyCondition.ExcludeHostileToSource = false;
	TargetUnitPropertyCondition.FailOnNonUnits = true;
	TargetUnitPropertyCondition.RequireWithinRange = true;
	TargetUnitPropertyCondition.WithinRange = class'RTAbility_BerserkerAbilitySet'.default.SIPHON_RANGE;

	SiphonCondition = new class'X2Condition_AbilityProperty';
	SiphonCondition.OwnerHasSoldierAbilities.AddItem('RTSiphon');

	SiphonEffect.TargetConditions.AddItem(SiphonCondition);
	SiphonEffect.TargetConditions.AddItem(TargetUnitPropertyCondition);
	Template.AddTargetEffect(SiphonEffect);
	Template.AssociatedPassives.AddItem('RTSiphon');

	// Hit Calculation (Different weapons now have different calculations for range)
	Template.AbilityToHitCalc = default.SimpleStandardAim;
	Template.AbilityToHitOwnerOnMissCalc = default.SimpleStandardAim;

	// Targeting Method
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	Template.AssociatedPassives.AddItem('HoloTargeting');

	// MAKE IT LIVE!
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.OverrideAbilities.AddItem('StandardShot');

	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	KnockbackEffect.bUseTargetLocation = true;
	Template.AddTargetEffect(KnockbackEffect);

	Template.PostActivationEvents.AddItem('StandardGhostShotActivated');

	return Template;
}
//---------------------------------------------------------------------------------------
//---Reflection--------------------------------------------------------------------------
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//---Meld--------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//---JoinMeld----------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate JoinMeld()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCooldown                 Cooldown;
	local X2Condition_UnitEffects			Condition;
	local RTCondition_EffectStackCount		StackCondition;
	local RTEffect_Meld						MeldEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'JoinMeld');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_psi_x2_meld";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.Hostility = eHostility_Neutral;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;
	Template.HideErrors.AddItem('AA_AbilityUnavailable');
	Template.HideErrors.AddItem('AA_MeldEffect_Active');
	Template.HideErrors.AddItem('AA_NoTargets');

	Template.ConcealmentRule = eConceal_Always;

	Template.AbilityCosts.AddItem(default.FreeActionCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 1;
	Template.AbilityCooldown = Cooldown;

	Condition = new class'X2Condition_UnitEffects';
	Condition.AddExcludeEffect('RTEffect_Meld', 'MeldEffect_Active');
	Template.AbilityShooterConditions.AddItem(Condition);

	StackCondition = new class'RTCondition_EffectStackCount';
	StackCondition.StackingEffect = class'RTEffect_Bloodlust'.default.EffectName;
	StackCondition.iMaximumStacks = default.MAX_BLOODLUST_MELDJOIN;
	StackCondition.bRequireEffect = false;
	Template.AbilityShooterConditions.AddItem(StackCondition);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	MeldEffect = class'RTEffectBuilder'.static.RTCreateMeldEffect(1, true);
	Template.AddTargetEffect(MeldEffect);


	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---LeaveMeld---------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate LeaveMeld()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCooldown                 Cooldown;
	local X2Effect_RemoveEffects			MeldRemovedEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'LeaveMeld');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_psi_move";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideIfOtherAvailable;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;
	Template.HideIfAvailable.AddItem('JoinMeld');
	Template.HideIfAvailable.AddItem('RTContainedFuryMeldJoin');
	Template.Hostility = eHostility_Neutral;

	Template.AbilityCosts.AddItem(default.FreeActionCost);
	Template.ConcealmentRule = eConceal_Always;

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 1;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	MeldRemovedEffect = new class 'X2Effect_RemoveEffects';
	MeldRemovedEffect.EffectNamesToRemove.AddItem('RTEffect_Meld');
	Template.AddTargetEffect(MeldRemovedEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;


	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---PsiOverload-------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate PsiOverload()
{
	local X2AbilityTemplate									Template;
	local X2AbilityCooldown                 Cooldown;
	local X2Effect_KillUnit									KillUnitEffect;
	local X2AbilityCost_ActionPoints        ActionPointCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'PsiOverload');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_hunter";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Offensive;

	Template.AbilityCosts.AddItem(default.FreeActionCost);
	Template.ConcealmentRule = eConceal_Always;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityTargetConditions.AddItem(default.PsionicTargetingProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.OVERLOAD_BASE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	KillUnitEffect = new class 'X2Effect_KillUnit';
	Template.AddTargetEffect(KillUnitEffect);

	Template.PostActivationEvents.AddItem('RTFeedback');
	Template.PostActivationEvents.AddItem(default.UnitUsedPsionicAbilityEvent);

	Template.CustomFireAnim = 'HL_Psi_MindControl';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Psionic_FireAtUnit";

	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---PsiOverloadPanic--------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTFeedback()
{
	local X2AbilityTemplate					Template;
	local X2AbilityTrigger_EventListener	Trigger;
	local RTEffect_Panicked					PanicEffect;
	local X2Condition_UnitProperty			Condition;
	local X2Effect_PanickedWill				PanickedWillEffect;
	local X2AbilityCost_ActionPoints		ActionPointCost;


	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTFeedback');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_hunter";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Neutral;

	Template.ConcealmentRule = eConceal_Always;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.bFreeCost = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'RTFeedback';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	// Build the effect
	PanicEffect = new class'RTEffect_Panicked';
	PanicEffect.DuplicateResponse = eDupe_Ignore;
	PanicEffect.AddPersistentStatChange(eStat_Offense, -10);
	PanicEffect.EffectHierarchyValue = 550;
	PanicEffect.VisualizationFn = class'X2StatusEffects'.static.PanickedVisualization;
	PanicEffect.EffectTickedVisualizationFn = class'X2StatusEffects'.static.PanickedVisualizationTicked;
	PanicEffect.EffectRemovedVisualizationFn = class'X2StatusEffects'.static.PanickedVisualizationRemoved;
	PanicEffect.bRemoveWhenTargetDies = true;
	PanicEffect.DelayVisualizationSec = 0.0f;
	PanicEffect.EffectName = default.RTFeedbackEffectName;
	// One turn duration
	PanicEffect.BuildPersistentEffect(default.FEEDBACK_DURATION, false, true, false, eGameRule_PlayerTurnBegin);
	PanicEffect.SetDisplayInfo(ePerkBuff_Penalty, default.FEEDBACK_TITLE,
		default.FEEDBACK_DESC, Template.IconImage);
	Template.AddTargetEffect(PanicEffect);

	PanickedWillEffect = new class'X2Effect_PanickedWill';
	PanickedWillEffect.BuildPersistentEffect(default.FEEDBACK_DURATION, false, true, false, eGameRule_PlayerTurnBegin);
	PanickedWillEffect.EffectName = default.RTFeedbackWillDebuffName;
	Template.AddTargetEffect(PanickedWillEffect);

	Condition = new class'X2Condition_UnitProperty';
	Condition.ExcludeRobotic = true;
	Condition.ExcludePanicked = true;
	//Template.AbilityTargetConditions.AddItem(Condition);

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.PostActivationEvents.AddItem('UnitPanicked');
	Template.PostActivationEvents.AddItem('RTUnitFeedbacked');

	Template.bSkipFireAction = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Fade--------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate Fade()
{
	local X2AbilityTemplate					Template;
	local X2AbilityTrigger_EventListener	Trigger;
	local RTEffect_Stealth					StealthEffect;
	local X2AbilityCooldown                 Cooldown;
	local X2Effect_Persistent		CooldownTrackerEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Fade');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_phantom";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Defensive;

	Template.ConcealmentRule = eConceal_Always;

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.FADE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'UnitTakeEffectDamage';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	StealthEffect = class'RTEffectBuilder'.static.RTCreateStealthEffect(default.FADE_DURATION, , , eGameRule_PlayerTurnBegin, Template.AbilitySourceName);
	Template.AddTargetEffect(StealthEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	CooldownTrackerEffect = new class'X2Effect_Persistent';
	CooldownTrackerEffect.BuildPersistentEffect(default.FADE_COOLDOWN, false, true, false, eGameRule_PlayerTurnEnd);
	CooldownTrackerEffect.SetDisplayInfo(ePerkBuff_Penalty, default.FADE_COOLDOWN_TITLE, default.FADE_COOLDOWN_DESC, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(CooldownTrackerEffect);

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.bSkipFireAction = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;


	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Teek--------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate Teek() {
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange BlurEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Teek');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_voidrift";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	// Apply perk at start of the mission.
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	BlurEffect = new class'X2Effect_PersistentStatChange';
	BlurEffect.BuildPersistentEffect(1, true, true, true);
	BlurEffect.AddPersistentStatChange(eStat_Defense, default.TEEK_DEFENSE_INCREASE);
	BlurEffect.AddPersistentStatChange(eStat_Dodge, default.TEEK_DODGE_INCREASE);
	BlurEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(BlurEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// NOTE: No visualization on purpose!

	return Template;
}

//---------------------------------------------------------------------------------------
//---FadeIcon--------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate FadeIcon()
{
	local X2AbilityTemplate					Template;
	local X2Effect_Persistent			 	TeekEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'FadeIcon');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_voidrift";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Neutral;

	Template.ConcealmentRule = eConceal_Always;

	TeekEffect = new class'X2Effect_Persistent';
	TeekEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	TeekEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	TeekEffect.DuplicateResponse = eDupe_Ignore;
	TeekEffect.EffectName = 'FadeIcon';
	Template.AddTargetEffect(TeekEffect);

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Template.AdditionalAbilities.AddItem('Fade');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---LI Overwatch Shot-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate LIOverwatchShot()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ReserveActionPoints ReserveActionPointCost;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2Condition_UnitProperty          ShooterCondition;
	local X2AbilityTarget_Single            SingleTarget;
	local array<name>                       SkipExclusions;
	local X2Condition_Visibility            TargetVisibilityCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'LIOverwatchShot');

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

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
	TargetVisibilityCondition.bDisablePeeksOnMovement = true;
	TargetVisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	ShooterCondition = new class'X2Condition_UnitProperty';
	ShooterCondition.ExcludeConcealed = true;
	Template.AbilityShooterConditions.AddItem(ShooterCondition);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);
	Template.bAllowAmmoEffects = true;

	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.OnlyIncludeTargetsInsideWeaponRange = true;
	Template.AbilityTargetStyle = SingleTarget;

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overwatch";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.OVERWATCH_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.DisplayTargetHitChance = false;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.bAllowFreeFireWeaponUpgrade = false;

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
	// Damage Effect
	//
	Template.AddTargetEffect(default.WeaponUpgradeMissDamage);

	return Template;
}

//---------------------------------------------------------------------------------------
//---Psionic Activation------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate PsionicActivate()
{
	local X2AbilityTemplate	Template;
	local X2AbilityTrigger_EventListener Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'PsionicActivate');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_voidrift";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Neutral;

	Template.ConcealmentRule = eConceal_Always;

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = default.ForcePsionicAbilityEvent;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	//  NOTE: No visualization on purpose!
	Template.PostActivationEvents.AddItem(default.UnitUsedPsionicAbilityEvent);

	Template.bCrossClassEligible = false;

	return Template;
}

static function X2AbilityTemplate RTRemoveAdditionalAnimSets()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Effect_RemoveEffects RemoveEffectsEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTRemoveAdditionalAnimSets');
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Neutral;

	Template.ConcealmentRule = eConceal_Always;

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	RemoveEffectsEffect	= new class'X2Effect_RemoveEffects';
	RemoveEffectsEffect.EffectNamesToRemove.AddItem('RTAdventAnimSet');
	Template.AddTargetEffect(RemoveEffectsEffect);


	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'RTRemoveAnimSets';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = false;

	return Template;
}





// helpers

static function X2Condition_UnitValue CreateOverTheShoulderProperty() {
	local X2Condition_UnitValue Condition;

	Condition = new class'X2Condition_UnitValue';
	Condition.AddCheckValue(class'RTAbility_GathererAbilitySet'.default.OverTheShoulderTagName, 1, eCheck_LessThan);

	return Condition;

}

// cooldown cleanser

static function X2AbilityTemplate CreateRTCooldownCleanse (name TemplateName, name EffectNameToRemove, name EventIDToListenFor) {
	local X2AbilityTemplate Template;
	local X2Effect_RemoveEffects RemoveEffectEffect;
	local X2AbilityTrigger_EventListener Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.ConcealmentRule = eConceal_Always;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = EventIDToListenFor;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	RemoveEffectEffect = new class'X2Effect_RemoveEffects';
	RemoveEffectEffect.EffectNamesToRemove.AddItem(EffectNameToRemove);

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AddTargetEffect(RemoveEffectEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	Template.bCrossClassEligible = false;
	return Template;
}

static function X2AbilityTemplate CreateRTPassiveAbilityCooldown(name TemplateName, name CooldownTrackerEffectName, optional bool bTriggerCooldownViaEvent = false, optional name EventIDToListenFor) {
        local X2AbilityTemplate Template;
        local X2Effect_Persistent Effect;
        local X2AbilityTrigger_EventListener Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.ConcealmentRule = eConceal_Always;

    Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = EventIDToListenFor;
	Trigger.ListenerData.Filter = eFilter_Unit;
    Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
    if(bTriggerCooldownViaEvent) {
		Template.AbilityTriggers.AddItem(Trigger);
    } else {
		Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');
    }

    // Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Effect = new class'X2Effect_Persistent';
	Effect.BuildPersistentEffect(1, true, true, true, eGameRule_PlayerTurnEnd);
	Effect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Effect.EffectName = CooldownTrackerEffectName;
	Template.AddTargetEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	//TODO: VISUALIZATION

	Template.bSkipFireAction = true;

	Template.bCrossClassEligible = false;

        return Template;
}

static function X2AbilityTemplate TestAbility() {
	local X2AbilityTemplate Template;
	local X2Effect_Persistent Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'TestAbility');
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;
	Template.ConcealmentRule = eConceal_Always;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_solace";

	Template.AbilityCosts.AddItem(default.FreeActionCost);
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	Effect = new class'X2Effect_Persistent';
	Effect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);
	Effect.SetDisplayInfo(ePerkBuff_Penalty, "DEBUG", "DEBUG TEST EFFECT", Template.IconImage, true,,Template.AbilitySourceName);
	Effect.DuplicateResponse = eDupe_Allow;
	//Effect.EffectName = "TestEffect";
	//Effect.TargetConditions.AddItem(class'X2Condition_OrderCheck'.static.CreateOrderCheck('EffectTargetCondition'));
	Template.AddTargetEffect(Effect);

	//Template.AbilityTargetConditions.AddItem(class'X2Condition_OrderCheck'.static.CreateOrderCheck('AbilityTargetCondition'));
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	//TODO: VISUALIZATION
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.bSkipFireAction = true;
	Template.bCrossClassEligible = false;

	return Template;

}

static function X2DataTemplate RTMindControl()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown Cooldown;
	local X2Condition_UnitEffects EffectCondition;
	local X2Effect_MindControl MindControlEffect;
	local X2Effect_RemoveEffects MindControlRemoveEffects;
	local X2AbilityTarget_Single SingleTarget;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.RTMindControlTemplateName);

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_mindcontrol";
	Template.Hostility = eHostility_Offensive;
	Template.bShowActivation = true;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.MIND_CONTROL_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = new class'RTAbilityToHitCalc_StatCheck_UnitVsUnit';

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetConditions.AddItem(default.PsionicTargetingProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	EffectCondition = new class'X2Condition_UnitEffects';
	EffectCondition.AddExcludeEffect(class'X2Effect_MindControl'.default.EffectName, 'AA_UnitIsMindControlled');
	EffectCondition.AddExcludeEffect(default.RTMindControlEffectName, 'AA_UnitIsMindControlled');
	Template.AbilityTargetConditions.AddItem(EffectCondition);

	// MindControl effect for 1 or more unblocked psi hit
	MindControlEffect = class'X2StatusEffects'.static.CreateMindControlStatusEffect(default.MIND_CONTROL_AI_TURNS_DURATION, false, false, -1.5f);
	MindControlEffect.MinStatContestResult = 1;
	MindControlEffect.iNumTurnsForAI = default.MIND_CONTROL_AI_TURNS_DURATION;
	MindControlEffect.EffectName = default.RTMindControlEffectName;
	Template.AddTargetEffect(MindControlEffect);

	MindControlRemoveEffects = class'X2StatusEffects'.static.CreateMindControlRemoveEffects();
	MindControlRemoveEffects.MinStatContestResult = 1;
	Template.AddTargetEffect(MindControlRemoveEffects);
	// MindControl effect for 1 or more unblocked psi hit

	SingleTarget = new class'X2AbilityTarget_Single';
	Template.AbilityTargetStyle = SingleTarget;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Unlike in other cases, in TypicalAbility_BuildVisualization, the MissSpeech is used on the Target!
	Template.TargetMissSpeech = 'SoldierResistsMindControl';

	Template.CustomFireAnim = 'HL_Psi_MindControl';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Psionic_FireAtUnit";

	Template.PostActivationEvents.AddItem(default.UnitUsedPsionicAbilityEvent);

	return Template;
}

static function X2AbilityTemplate RTEnterStealth() {
	local X2AbilityTemplate Template;
	local RTEffect_Stealth StealthEffect;
	local X2AbilityCharges Charges;
	local X2Condition_UnitEffects	EffectCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTEnterStealth');

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = class'RTEffectBuilder'.default.StealthIconPath;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityCosts.AddItem(new class'X2AbilityCost_Charges');
	Template.AbilityCosts.AddItem(default.FreeActionCost);

	Charges = new class'X2AbilityCharges';
	Charges.InitialCharges = default.GHOST_CHARGES;
	Template.AbilityCharges = Charges;

	EffectCondition = new class'X2Condition_UnitEffects';
	EffectCondition.AddExcludeEffect(class'RTEffectBuilder'.default.StealthEffectName, 'AA_UnitIsConcealed');
	Template.AbilityShooterConditions.AddItem(EffectCondition);
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	StealthEffect = class'RTEffectBuilder'.static.RTCreateStealthEffect(2, false);
	Template.AddTargetEffect(StealthEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Template.ActivationSpeech = 'ActivateConcealment';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;


	return Template;

}




defaultproperties
{
	Begin Object Class=X2Condition_UnitProperty Name=DefaultLivingFriendlyUnitOnlyProperty
		ExcludeAlive=false
		ExcludeDead=true
		ExcludeFriendlyToSource=false
		ExcludeHostileToSource=true
		TreatMindControlledSquadmateAsHostile=false
		FailOnNonUnits=true
		ExcludeCivilian=true
	End Object
	LivingFriendlyUnitOnlyProperty = DefaultLivingFriendlyUnitOnlyProperty

	Begin Object Class=X2Condition_UnitProperty Name=DefaultLivingHostileUnitOnlyNonRoboticProperty
		ExcludeAlive=false
		ExcludeDead=true
		ExcludeFriendlyToSource=true
		ExcludeHostileToSource=false
		TreatMindControlledSquadmateAsHostile=true
		ExcludeRobotic=true
		FailOnNonUnits=true
	End Object
	LivingHostileUnitOnlyNonRoboticProperty = DefaultLivingHostileUnitOnlyNonRoboticProperty

	Begin Object Class=RTCondition_PsionicTarget Name=DefaultPsionicTargetingProperty
		bIgnoreRobotic=false
		bIgnorePsionic=false
		bIgnoreGHOSTs=false
		bIgnoreDead=true
		bIgnoreEnemies=false
		bTargetAllies=false
		bTargetCivilians=false
	End Object
	PsionicTargetingProperty = DefaultPsionicTargetingProperty

	Begin Object Class=RTCondition_UnitSize Name=DefaultStandardSizeProperty
	End Object
	StandardSizeProperty = DefaultStandardSizeProperty




	RTFeedbackEffectName = "RTFeedback"
	RTFeedbackWillDebuffName = "RTFeedbackWillDebuff"
	UnitUsedPsionicAbilityEvent = "UnitUsedPsionicAbility"
	ForcePsionicAbilityEvent = "ForcePsionicAbilityEvent"


	RTMindControlEffectName = "RTMindControlEffect"
	RTGhostTagEffectName = "RTGhostOperative"

	RTMindControlTemplateName = "RTMindControl"
	RTTechnopathyTemplateName = "RTTechnopathy"
	DefaultPsionicAnimDelay = 4.0


}
