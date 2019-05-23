//---------------------------------------------------------------------------------------
//  FILE:    RTAbility_GhostAbilitySet.uc
//  AUTHOR:  Aleosiss
//  DATE:    8 February 2016
//  PURPOSE: Defines abilities used by all Rising Tides classes.
//
//---------------------------------------------------------------------------------------
//	General Perks
//---------------------------------------------------------------------------------------

class RTAbility_GhostAbilitySet extends RTAbility
	config(RisingTides);

	var localized string FEEDBACK_TITLE;
	var localized string FEEDBACK_DESC;
	var localized string STEALTH_TITLE;
	var localized string STEALTH_DESC;
	var localized string MELD_TITLE;
	var localized string MELD_DESC;
	var localized string FADE_COOLDOWN_TITLE;
	var localized string FADE_COOLDOWN_DESC;

	var config int BASE_REFLECTION_CHANCE;
	var config int BASE_DEFENSE_INCREASE;
	var config int TEEK_REFLECTION_INCREASE;
	var config int TEEK_DEFENSE_INCREASE;
	var config int TEEK_DODGE_INCREASE;
	var config int OVERLOAD_CHARGES;
	var config int OVERLOAD_BASE_COOLDOWN;
	var config int OVERLOAD_PANIC_CHECK;
	var config float OVERLOAD_MAX_RANGE;
	var config int FADE_DURATION;
	var config int FADE_COOLDOWN;
	var config int MIND_CONTROL_AI_TURNS_DURATION;
	var config int MIND_CONTROL_COOLDOWN;
	var config int GHOST_CHARGES;

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
	Templates.AddItem(RTProgramEvacuation());
	Templates.AddItem(RTProgramEvacuationPartOne());
	Templates.AddItem(RTProgramEvacuationPartTwo());

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
	local X2Effect_Persistent					Effect;
	local X2Effect_AdditionalAnimSets 			AnimSetEffect;
	local X2Effect_StayConcealed				PhantomEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GhostPsiSuite');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_program_shield";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Effect = new class 'X2Effect_Persistent';
	Effect.BuildPersistentEffect(1, true, true, true);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(Effect);

	PhantomEffect = new class'X2Effect_StayConcealed';
	PhantomEffect.BuildPersistentEffect(1, true, false);
	Template.AddTargetEffect(PhantomEffect);

	AnimSetEffect = new class'X2Effect_AdditionalAnimSets';
	//AnimSetEffect.AddAnimSetWithPath("RisingTidesContentPackage.Anims.AS_Psi_X2");
	AnimSetEffect.AddAnimSetWithPath("RisingTidesContentPackage.Anims.AS_Psi_WOTC");
	Template.AddTargetEffect(AnimSetEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!

	Template.bCrossClassEligible = false;

	return Template;
}
//---------------------------------------------------------------------------------------
//---StandardGhostShot-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate StandardGhostShot()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local array<name>                       SkipExclusions;
	local X2Effect_Knockback				KnockbackEffect;
	local X2Condition_Visibility            VisibilityCondition;
	local RTEffect_Siphon					SiphonEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'StandardGhostShot');

	Template.bDontDisplayInAbilitySummary = true;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_standard";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.DisplayTargetHitChance = true;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
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
	SiphonEffect = class'RTEffectBuilder'.static.RTCreateSiphonEffect(class'RTAbility_BerserkerAbilitySet'.default.SIPHON_AMOUNT_MULTIPLIER, class'RTAbility_BerserkerAbilitySet'.default.SIPHON_MIN_VAL, class'RTAbility_BerserkerAbilitySet'.default.SIPHON_MAX_VAL);
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
	Template.AddTargetEffect(KnockbackEffect);

	Template.PostActivationEvents.AddItem('StandardGhostShotActivated');
	Template.PostActivationEvents.AddItem('StandardShotActivated');
	class'X2StrategyElement_XpackDarkEvents'.static.AddStilettoRoundsEffect(Template);

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	Template.bFrameEvenWhenUnitIsHidden = true;

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
	local X2AbilityCooldown									Cooldown;
	local X2Effect_KillUnit									KillUnitEffect;
	local X2AbilityCost_ActionPoints						ActionPointCost;
	local X2Condition_UnitProperty							TargetUnitPropertyCondition;

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

	TargetUnitPropertyCondition = new class'X2Condition_UnitProperty';
	TargetUnitPropertyCondition.RequireWithinRange = true;
	TargetUnitPropertyCondition.WithinRange = default.OVERLOAD_MAX_RANGE;

	Template.AbilityTargetConditions.AddItem(TargetUnitPropertyCondition);
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
	//local X2AbilityCost_ActionPoints		ActionPointCost;


	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTFeedback');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_hunter";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Neutral;

	Template.ConcealmentRule = eConceal_Always;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'RTFeedback';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	// Build the effect
	PanicEffect = class'RTEffectBuilder'.static.RTCreateFeedbackEffect(default.FEEDBACK_DURATION, default.RTFeedbackEffectName, default.FEEDBACK_TITLE, default.FEEDBACK_DESC, Template.IconImage);
	Template.AddTargetEffect(PanicEffect);

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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_fade";

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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_teek";

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
	local X2Effect_Knockback				KnockbackEffect;

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
	
	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddTargetEffect(KnockbackEffect);

	class'X2StrategyElement_XpackDarkEvents'.static.AddStilettoRoundsEffect(Template);

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	Template.bFrameEvenWhenUnitIsHidden = true;

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

//---------------------------------------------------------------------------------------
//---Test Ability=-----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
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

//---------------------------------------------------------------------------------------
//---Mind Control------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
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

//---------------------------------------------------------------------------------------
//---Stealth-----------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
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

//---------------------------------------------------------------------------------------
//---ProgramEvacuation-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTProgramEvacuation() {
	local X2AbilityTemplate Template;
	local RTEffect_Sustain SustainEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTProgramEvacuation');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_sustain";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	SustainEffect = new class'RTEffect_Sustain';
	SustainEffect.BuildPersistentEffect(1, true, true);
	//SustainEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(SustainEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!

	//Template.AdditionalAbilities.AddItem('RTProgramEvacuationPartOne');
	//Template.AdditionalAbilities.AddItem('RTProgramEvacuationPartTwo');

	return Template;
}

static function X2AbilityTemplate RTProgramEvacuationPartOne() {
	local X2AbilityTemplate Template;
	local RTEffect_Stasis StasisEffect;
	local X2AbilityTrigger_EventListener EventTrigger;
	local X2Effect_ImmediateAbilityActivation ActivationEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTProgramEvacuationPartOne');

	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_sustain";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilitySourceName = 'eAbilitySource_Psionic';

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	//	check that the unit is still alive.
	//	it's possible that multiple event listeners responded to the same event, and some of those other listeners
	//	went ahead and killed the unit before we got to trigger sustain.
	//	it would look weird to do the sustain visualization and then have the unit die, so just don't trigger sustain.
	//	e.g. a unit with a homing mine on it that takes a kill shot wants to have the death stopped, but the
	//	homing mine explosion can trigger before the sustain trigger goes off, killing the unit before it would be sustained
	//	and making things look really weird. now the unit will just die without "sustaining" the corpse.
	//	-jbouscher
	
	// It's more important that we evac than any other consideration
	//Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	StasisEffect = new class'RTEffect_Stasis';
	StasisEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);
	StasisEffect.bUseSourcePlayerState = true;
	StasisEffect.bRemoveWhenTargetDies = true;          //  probably shouldn't be possible for them to die while in stasis, but just in case
	StasisEffect.StunStartAnim = 'HL_PsiSustainStart';
	StasisEffect.bSkipFlyover = true;
	Template.AddTargetEffect(StasisEffect);

	ActivationEffect = new class'X2Effect_ImmediateAbilityActivation';
	ActivationEffect.AbilityName = 'RTProgramEvacuationPartTwo';
	ActivationEffect.EffectName = 'RTProgramEvacuationPartTwoActivationEffect';
	Template.AddTargetEffect(ActivationEffect);

	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventID = class'RTEffect_Sustain'.default.SustainEvent;
	EventTrigger.ListenerData.Filter = eFilter_Unit;
	EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventTrigger.ListenerData.Priority = 20;	// Lower than Sustaining Sphere
	Template.AbilityTriggers.AddItem(EventTrigger);

	Template.bSkipFireAction = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate RTProgramEvacuationPartTwo()
{
	local X2AbilityTemplate Template;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTProgramEvacuationPartTwo');
	Template.bDontDisplayInAbilitySummary = true;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

	Template.bSkipFireAction = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;
	Template.BuildNewGameStateFn = ProgramOperativeDefeatedEscape_BuildGameState;
	Template.BuildVisualizationFn = ProgramOperativeDefeatedEscape_BuildVisualization;
	Template.AssociatedPlayTiming = SPT_AfterSequential;  // play after the chosen death that initiated this ability
//BEGIN AUTOGENERATED CODE: Template Overrides 'ChosenDefeatedEscape'
	Template.CinescriptCameraType = "Chosen_Escape";
//END AUTOGENERATED CODE: Template Overrides 'ChosenDefeatedEscape'

	return Template;
}

static function XComGameState ProgramOperativeDefeatedEscape_BuildGameState(XComGameStateContext Context)
{
	local XComGameState NewGameState;
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local X2EventManager EventManager;

	EventManager = `XEVENTMGR;
	History = `XCOMHISTORY;

	NewGameState = History.CreateNewGameState(true, Context);

	TypicalAbility_FillOutGameState(NewGameState);

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(XComGameStateContext_Ability(Context).InputContext.SourceObject.ObjectID));

	EventManager.TriggerEvent('UnitRemovedFromPlay', UnitState, UnitState, NewGameState);

	return NewGameState;
}

simulated function ProgramOperativeDefeatedEscape_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local VisualizationActionMetadata EmptyTrack;
	local VisualizationActionMetadata ActionMetadata;
	local XComGameState_Ability Ability;
	local X2AbilityTemplate AbilityTemplate;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyover;
	local X2Action_PlayAnimation PlayAnimation;
	local XGUnit Unit;
	local XComUnitPawn UnitPawn;
	local X2Action_PlayEffect EffectAction;
	local X2Action_Delay DelayAction;
	local X2Action_CameraLookAt LookAtAction;
	local int i, j;
	local StateObjectReference InteractingUnitRef;
	
	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());

	//Configure the visualization track for the shooter
	//****************************************************************************************
	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(Context.InputContext.SourceObject.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(Context.InputContext.SourceObject.ObjectID);
	ActionMetadata.VisualizeActor = History.GetVisualizer(Context.InputContext.SourceObject.ObjectID);

	Ability = XComGameState_Ability(History.GetGameStateForObjectID(Context.InputContext.AbilityRef.ObjectID));
	AbilityTemplate = Ability.GetMyTemplate();

	LookAtAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	LookAtAction.UseTether = false;
	LookAtAction.LookAtObject = ActionMetadata.StateObject_NewState;
	LookAtAction.LookAtDuration = 10.0;
	LookAtAction.CameraTag = 'ChosenDefeatedEscape';

	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', eColor_Good);
	
	if( ActionMetadata.VisualizeActor != None )
	{
		Unit = XGUnit(ActionMetadata.VisualizeActor);
		if( Unit != None )
		{
			UnitPawn = Unit.GetPawn();
			if( UnitPawn != None )
			{
				PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
				PlayAnimation.Params.AnimName = Ability.GetFireAnimationName(UnitPawn, false, false, vector(UnitPawn.Rotation), vector(UnitPawn.Rotation), true, 0);
			}
		}
	}

	EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(ActionMetadata, Context, false, PlayAnimation));
	EffectAction.EffectName = "FX_Chosen_Teleport.P_Chosen_Teleport_Out_w_Sound";
	EffectAction.EffectLocation = ActionMetadata.VisualizeActor.Location;
	EffectAction.bWaitForCompletion = false;

	DelayAction = X2Action_Delay(class'X2Action_Delay'.static.AddToVisualizationTree(ActionMetadata, Context, false, PlayAnimation));
	DelayAction.Duration = 0.25;

	class'X2Action_RemoveUnit'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, DelayAction);

	LookAtAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, Context, false, EffectAction));
	LookAtAction.bRemoveTaggedCamera = true;
	LookAtAction.CameraTag = 'ChosenDefeatedEscape';
	//****************************************************************************************

	// Multitargets
	for( i = 0; i < Context.InputContext.MultiTargets.Length; ++i )
	{
		InteractingUnitRef = Context.InputContext.MultiTargets[i];
		ActionMetadata = EmptyTrack;
		ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
		ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
		ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);
		ActionMetadata.LastActionAdded = EffectAction;

		for( j = 0; j < Context.ResultContext.MultiTargetEffectResults[i].Effects.Length; ++j )
		{
			Context.ResultContext.MultiTargetEffectResults[i].Effects[j].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, Context.ResultContext.MultiTargetEffectResults[i].ApplyResults[j]);
		}
	}
}

static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
//	local name Tag;

//	Tag = name(InString);

	return false;
}
