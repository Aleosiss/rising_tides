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
	config(RTGhost);

	var config int BASE_REFLECTION_CHANCE, BASE_DEFENSE_INCREASE;
	var config int TEEK_REFLECTION_INCREASE, TEEK_DEFENSE_INCREASE, TEEK_DODGE_INCREASE;
	var config int BURST_DAMAGE, BURST_COOLDOWN;
	var config int OVERLOAD_CHARGES, OVERLOAD_BASE_COOLDOWN;
	var config int OVERLOAD_PANIC_CHECK;
	var config int FADE_DURATION, FADE_COOLDOWN;

//---------------------------------------------------------------------------------------
//---CreateTemplates---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(GhostPsiSuite());
	//Templates.AddItem(Meld());
	Templates.AddItem(LeaveMeld());
	Templates.AddItem(JoinMeld());
	//Templates.AddItem(Reflection());
	Templates.AddItem(PsiOverload());
	Templates.AddItem(PsiOverloadPanic());
	Templates.AddItem(Teek());
	Templates.AddItem(Fade());
	Templates.AddItem(LIOverwatchShot());
	

	return Templates;
}
//---------------------------------------------------------------------------------------
//---Ghost Psi Suite---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate GhostPsiSuite()
{
	local X2AbilityTemplate						Template;
	local X2Effect_Persistent					Effect;

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

	Template.AdditionalAbilities.AddItem('JoinMeld');
	Template.AdditionalAbilities.AddItem('LeaveMeld');
	//Template.AdditionalAbilities.AddItem('Reflection');
	//Template.AdditionalAbilities.AddItem('PsiOverload');


	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!
	
	Template.bCrossClassEligible = false;

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
	local RTEffect_Meld						MeldEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'JoinMeld');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_mindcontrol";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;
	Template.HideErrors.AddItem('AA_AbilityUnavailable');
	Template.HideErrors.AddItem('MeldEffect_Active');
	Template.HideErrors.AddItem('AA_NoTargets');

	Template.ConcealmentRule = eConceal_Always;

	Template.AbilityCosts.AddItem(default.FreeActionCost);
	
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 1;
	Template.AbilityCooldown = Cooldown;

	Condition = new class'X2Condition_UnitEffects';
	Condition.AddExcludeEffect('RTMeld', 'MeldEffect_Active');
	Template.AbilityShooterConditions.AddItem(Condition);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	MeldEffect = new class 'RTEffect_Meld';
	MeldEffect.BuildPersistentEffect(1, true, true, false,  eGameRule_PlayerTurnEnd);
		MeldEffect.SetDisplayInfo(ePerkBuff_Bonus, "Mind Meld", 
		"This unit has joined the squad's mind meld, gaining and delivering psionic support.", Template.IconImage);
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
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_mindcontrol";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideIfOtherAvailable;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;
	Template.HideIfAvailable.AddItem('JoinMeld');

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
	local X2AbilityTemplate					Template;
	local X2AbilityCooldown                 Cooldown;
	local X2Effect_KillUnit					KillUnitEffect;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Condition_UnitProperty			UnitPropertyCondition;
	
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

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = true;
	UnitPropertyCondition.ExcludeRobotic = true;
	UnitPropertyCondition.FailOnNonUnits = true;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);	
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.OVERLOAD_BASE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	KillUnitEffect = new class 'X2Effect_KillUnit';
	KillUnitEffect.BuildPersistentEffect(1, false, false, false,  eGameRule_PlayerTurnBegin);
	Template.AddTargetEffect(KillUnitEffect);

	Template.PostActivationEvents.AddItem('RTPsiOverload');
	Template.PostActivationEvents.AddItem('UnitUsedPsionicAbility');
	//Template.AdditionalAbilities.AddItem('PsiOverloadPanic');

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
static function X2AbilityTemplate PsiOverloadPanic()
{
	local X2AbilityTemplate					Template;
	local X2AbilityTrigger_EventListener	Trigger;
	local RTEffect_Panicked					PanicEffect;
	local X2Condition_UnitProperty			Condition;
	local X2Effect_PanickedWill				PanickedWillEffect;
	local X2AbilityCost_ActionPoints		ActionPointCost;

	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'PsiOverloadPanic');
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
	Trigger.ListenerData.EventID = 'RTPsiOverload';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	// Build the effect
	PanicEffect = new class'RTEffect_Panicked';
	PanicEffect.EffectName = class'X2AbilityTemplateManager'.default.PanickedName;
	PanicEffect.DuplicateResponse = eDupe_Ignore;
	PanicEffect.AddPersistentStatChange(eStat_Offense, -10);
	PanicEffect.EffectHierarchyValue = 550;
	PanicEffect.VisualizationFn = class'X2StatusEffects'.static.PanickedVisualization;
	PanicEffect.EffectTickedVisualizationFn = class'X2StatusEffects'.static.PanickedVisualizationTicked;
	PanicEffect.EffectRemovedVisualizationFn = class'X2StatusEffects'.static.PanickedVisualizationRemoved;
	PanicEffect.bRemoveWhenTargetDies = true;
	PanicEffect.DelayVisualizationSec = 0.0f;
	// One turn duration
	PanicEffect.BuildPersistentEffect(4, false, true, false, eGameRule_PlayerTurnBegin);
	PanicEffect.SetDisplayInfo(ePerkBuff_Penalty, "AGugHGGHGH", 
		"This unit recently overloaded another unit's brain, and is suffering from psionic feedback. Protect them while they recover!", Template.IconImage);
	Template.AddTargetEffect(PanicEffect);

	PanickedWillEffect = new class'X2Effect_PanickedWill';
	PanickedWillEffect.BuildPersistentEffect(5, false, true, false);
	Template.AddTargetEffect(PanickedWillEffect);

	Condition = new class'X2Condition_UnitProperty';
	Condition.ExcludeRobotic = true;
	Condition.ExcludePanicked = true;
	//Template.AbilityTargetConditions.AddItem(Condition);

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.PostActivationEvents.AddItem('UnitPanicked');

	Template.bSkipFireAction = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;



	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
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

	StealthEffect = new class'RTEffect_Stealth';
	StealthEffect.BuildPersistentEffect(default.FADE_DURATION, false, true, false, eGameRule_PlayerTurnBegin);
	StealthEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(StealthEffect);
	
	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());
	
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
static function X2AbilityTemplate Teek()
{
	local X2AbilityTemplate					Template;
	local X2Effect_PersistentStatChange 	TeekEffect;
	local X2AbilityCooldown                 Cooldown;	
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'Teek');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_voidrift";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Neutral;

	Template.ConcealmentRule = eConceal_Always;

	TeekEffect = new class'X2Effect_PersistentStatChange';
	TeekEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	TeekEffect.AddPersistentStatChange(eStat_Dodge, default.TEEK_DODGE_INCREASE);
	TeekEffect.AddPersistentStatChange(eStat_Defense, default.TEEK_DEFENSE_INCREASE);
	TeekEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	TeekEffect.DuplicateResponse = eDupe_Ignore;
	TeekEffect.EffectName = 'Teek';
	Template.AddTargetEffect(TeekEffect);
	
	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);


	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = false;				

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
	local X2AbilityTrigger_Event	        Trigger;
	local array<name>                       SkipExclusions;
	local X2Condition_Visibility            TargetVisibilityCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'LIOverwatchShot');
	
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
	Template.bAllowFreeFireWeaponUpgrade = false;	

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
	// Damage Effect
	//
	Template.AddTargetEffect(default.WeaponUpgradeMissDamage);
	
	return Template;
}