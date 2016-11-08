//---------------------------------------------------------------------------------------
//  FILE:    RTAbility_BerserkerAbilitySet.uc
//  AUTHOR:  Aleosiss
//  DATE:    8 August 2016
//  PURPOSE: Defines abilities used by the GHOST Berserker class.
//           
//---------------------------------------------------------------------------------------
//	Queen's perks.
//---------------------------------------------------------------------------------------

class RTAbility_BerserkerAbilitySet extends RTAbility_GhostAbilitySet config(RisingTides);

	var config int BITN_TILEDISTANCE;
	var config int ACID_BLADE_DOT_DAMAGE;
	var config int ACID_BLADE_DOT_SHRED;
	var config int BURST_DAMAGE;
	var config int BURST_COOLDOWN;
	var config float SIPHON_AMOUNT_MULTIPLIER;
	var config int SIPHON_MIN_VAL;
	var config int SIPHON_MAX_VAL;
	var config int SIPHON_RANGE;
	var config int BLUR_DEFENSE_BONUS;
	var config int BLUR_DODGE_BONUS;
	var config int BLUR_MOBILITIY_BONUS;	 
	var config int BLADE_DAMAGE;
	var config int BLADE_CRIT_DAMAGE;
	var config int BLADE_DAMAGE_SPREAD;
	var config int ACID_BLADE_SHRED;
	var config float HIDDEN_BLADE_CRIT_MODIFIER;
	var config int PURGE_STACK_REQUIREMENT;
	var config int MENTOR_COOLDOWN;
	var config int MENTOR_BONUS;
	var config int MENTOR_STACK_MAXIMUM;
	var config float REPROBATE_WALTZ_BLOODLUST_STACK_CHANCE;
	var config float REPROBATE_WALTZ_BASE_CHANCE;
	var config int PYROCLASTICFLOW_MOBILITY_BONUS;
	var config bool PYROCLASTICFLOW_SHOULDUSECURRENTDAMAGETICK;
	var config int PYROCLASTICFLOW_DAMAGE;

//---------------------------------------------------------------------------------------
//---CreateTemplates---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(BumpInTheNight());
	Templates.AddItem(BumpInTheNightBloodlustListener());
	Templates.AddItem(BumpInTheNightStealthListener());
	Templates.AddItem(RTBerserkerKnifeAttack());
	// TODO: Icons
	Templates.AddItem(PurePassive('RTAcidicBlade', "img:///UILibrary_PerkIcons.UIPerk_salvo", true));
	Templates.AddItem(PurePassive('RTPsionicBlade', "img:///UILibrary_PerkIcons.UIPerk_salvo", true));
	Templates.AddItem(PurePassive('RTHiddenBlade', "img:///UILibrary_PerkIcons.UIPerk_salvo", true));
	Templates.AddItem(PurePassive('RTSiphon', "img:///UILibrary_PerkIcons.UIPerk_salvo", true));

	Templates.AddItem(RTBurst());
	Templates.AddItem(RTBlur());
	Templates.AddItem(RTPurge());
	Templates.AddItem(RTMentor());
	Templates.AddItem(RTReprobateWaltz());
	Templates.AddItem(RTPyroclasticFlow());
	Templates.AddItem(RTPyroclasticSlash());
	Templates.AddItem(RTContainedFuryMeldJoin());
	Templates.AddItem(RTContainedFury());
	Templates.AddItem(RTUnstableConduit());
	Templates.AddItem(RTUnstableConduitIcon());
	Templates.AddItem(RTUnstableConduitBurst());
	Templates.AddItem(RTPersistingImages());
	Templates.AddItem(RTPersistingImagesIcon());
	Templates.AddItem(RTGhostInTheShell());
	Templates.AddItem(RTQueenOfBlades());

	return Templates;
}

//---------------------------------------------------------------------------------------
//---Bump in the Night-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate BumpInTheNight()
{
	local X2AbilityTemplate                 Template;
	local RTEffect_BumpInTheNight			BumpEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'BumpInTheNight');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	// Apply perk at the start of the mission. 
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	// Effect to apply
	BumpEffect = new class'RTEffect_BumpInTheNight';
	BumpEffect.BuildPersistentEffect(1, true, true, true);
	BumpEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	BumpEffect.iTileDistanceToActivate = default.BITN_TILEDISTANCE;
	Template.AddTargetEffect(BumpEffect);

	Template.AdditionalAbilities.AddItem('GhostPsiSuite');
	Template.AdditionalAbilities.AddItem('JoinMeld');
	Template.AdditionalAbilities.AddItem('LeaveMeld');
	Template.AdditionalAbilities.AddItem('PsiOverload');
	Template.AdditionalAbilities.AddItem('PsiOverloadPanic');
	Template.AdditionalAbilities.AddItem('LIOverwatchShot');
	Template.AdditionalAbilities.AddItem('BumpInTheNightBloodlustListener');
	Template.AdditionalAbilities.AddItem('BumpInTheNightStealthListener');
	Template.AdditionalAbilities.AddItem('StandardGhostShot');
	Template.AdditionalAbilities.AddItem('RTUnstableConduitBurst');

	// Probably required 
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;

}
//---------------------------------------------------------------------------------------
//---BumpInTheNightBloodlustListener-----------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate BumpInTheNightBloodlustListener()
{
	local X2AbilityTemplate                 Template;
	local RTEffect_Bloodlust				BloodlustEffect;
	local RTEffect_Stealth					StealthEffect;
	local X2AbilityTrigger_EventListener	Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BumpInTheNightBloodlustListener');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash"; // TODO: Change this
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityCosts.AddItem(default.FreeActionCost);

	BloodlustEffect = new class'RTEffect_Bloodlust';
	BloodlustEffect.iMobilityMod = 1;
	BloodlustEffect.iMeleeHitChanceMod = 5;
	BloodlustEffect.fCritDamageMod = 0.1f;
	BloodlustEffect.BuildPersistentEffect(2, false, true, false, eGameRule_PlayerTurnEnd);
	BloodlustEffect.SetDisplayInfo(ePerkBuff_Bonus, "Bloodlust", "Gain bonus melee crit chance and crit damage, but lose movement speed.", Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(BloodlustEffect);

	StealthEffect = new class'RTEffect_Stealth';
	StealthEffect.fStealthModifier = 1;
	StealthEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	StealthEffect.SetDisplayInfo(ePerkBuff_Bonus, "Stealth", "Become invisible, and extremely difficult to detect.", Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(StealthEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'RTBumpInTheNight_BloodlustProc';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	//Template.bShowActivation = true;
	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	// TODO: Visualization!

	return Template;
}

//---------------------------------------------------------------------------------------
//---BumpInTheNightStealthListener-----------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate BumpInTheNightStealthListener()
{
	local X2AbilityTemplate                 Template;
	local RTEffect_Bloodlust				BloodlustEffect;
	local RTEffect_Stealth					StealthEffect;
	local X2AbilityTrigger_EventListener	Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BumpInTheNightStealthListener');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash"; // TODO: Change this
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityCosts.AddItem(default.FreeActionCost);

	StealthEffect = new class'RTEffect_Stealth';
	StealthEffect.fStealthModifier = 1;
	StealthEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	StealthEffect.SetDisplayInfo(ePerkBuff_Bonus, "Stealth", "Become invisible, and extremely difficult to detect.", Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(StealthEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'RTBumpInTheNight_StealthProc';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	//Template.bShowActivation = true;
	Template.bSkipFireAction = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	// TODO: Visualization!

	return Template;
}

//---------------------------------------------------------------------------------------
//---RTBerserker Knife Attack------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTBerserkerKnifeAttack()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityToHitCalc_StandardMelee  StandardMelee;
	local RTEffect_BerserkerMeleeDamage     WeaponDamageEffect;
	local RTEffect_Acid						AcidEffect;
	local array<name>                       SkipExclusions;
	local X2Condition_AbilityProperty  		AcidCondition, SiphonCondition;
	local X2Condition_UnitProperty			TargetUnitPropertyCondition;
	local RTEffect_Siphon					SiphonEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTBerserkerKnifeAttack');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Ranger_Reaper";
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash";
	Template.bHideOnClassUnlock = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
	Template.AbilityToHitCalc = StandardMelee;
	Template.ConcealmentRule = eConceal_Always;

	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

	// Target Conditions
	//
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	// Shooter Conditions
	//
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// Damage Effect
	//		var int iBaseBladeDamage, iBaseBladeCritDamage, iBaseBladeDamageSpread, iAcidicBladeShred;var float fHiddenBladeCritModifier;
	WeaponDamageEffect = new class'RTEffect_BerserkerMeleeDamage';	 
	WeaponDamageEffect.iBaseBladeDamage = default.BLADE_DAMAGE;
	WeaponDamageEffect.iBaseBladeCritDamage = default.BLADE_CRIT_DAMAGE;
	WeaponDamageEffect.iBaseBladeDamageSpread = default.BLADE_DAMAGE_SPREAD;
	WeaponDamageEffect.iAcidicBladeShred = default.ACID_BLADE_SHRED;
	WeaponDamageEffect.fHiddenBladeCritModifier = default.HIDDEN_BLADE_CRIT_MODIFIER;
	WeaponDamageEffect.bIgnoreBaseDamage = true;
	Template.AddTargetEffect(WeaponDamageEffect);

	// Acid Effect
	AcidEffect = class'RTEffect_Acid'.static.CreateAcidBurningStatusEffect('RTAcid', 4);
	AcidEffect.SetAcidDamage(default.ACID_BLADE_DOT_DAMAGE, 0, default.ACID_BLADE_DOT_SHRED, 'RTAcid');

	AcidCondition = new class'X2Condition_AbilityProperty';
	AcidCondition.OwnerHasSoldierAbilities.AddItem('RTAcidicBlade');
	AcidEffect.TargetConditions.AddItem(AcidCondition);
	Template.AddTargetEffect(AcidEffect);

	// Siphon Effect
	SiphonEffect = new class'RTEffect_Siphon';
	SiphonEffect.SiphonAmountMultiplier = default.SIPHON_AMOUNT_MULTIPLIER;
	SiphonEffect.SiphonMinVal = default.SIPHON_MIN_VAL;
	SiphonEffect.SiphonMaxVal = default.SIPHON_MAX_VAL;
	SiphonEffect.DamageTypes.AddItem('Psi');

	TargetUnitPropertyCondition = new class'X2Condition_UnitProperty';
	TargetUnitPropertyCondition.ExcludeDead = true;
	TargetUnitPropertyCondition.ExcludeRobotic = true;
	TargetUnitPropertyCondition.ExcludeFriendlyToSource = false;
	TargetUnitPropertyCondition.ExcludeHostileToSource = false;
	TargetUnitPropertyCondition.FailOnNonUnits = true;

	SiphonCondition = new class'X2Condition_AbilityProperty';
	SiphonCondition.OwnerHasSoldierAbilities.AddItem('RTSiphon');

	SiphonEffect.TargetConditions.AddItem(SiphonCondition);
	SiphonEffect.TargetConditions.AddItem(TargetUnitPropertyCondition);
	Template.AddTargetEffect(SiphonEffect);

	Template.bAllowBonusWeaponEffects = true;
	Template.bSkipMoveStop = true;
	
	Template.AssociatedPassives.AddItem('RTAcidicBlade');
	Template.AssociatedPassives.AddItem('RTPsionicBlade');
	Template.AssociatedPassives.AddItem('RTHiddenBlade');
	Template.AssociatedPassives.AddItem('RTSiphon');
	
	Template.PostActivationEvents.AddItem('RTBerserkerKnifeAttack');


	// Voice events
	//
	Template.SourceMissSpeech = 'SwordMiss';

	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Burst-------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTBurst() {
    local X2AbilityTemplate Template;
    local X2AbilityMultiTarget_Radius MultiTarget;
    local X2Effect_ApplyDirectionalWorldDamage WorldDamage;
    local X2Effect_ApplyWeaponDamage WeaponDamageEffect;
    local X2AbilityCooldown Cooldown;
    local X2AbilityCost_ActionPoints  ActionPointCost;
    local X2Effect_Knockback  KnockbackEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'RTBurst');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snipershot"; //TODO: Change this
    Template.AbilitySourceName = 'eAbilitySource_Psionic';  
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Offensive;

        
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

   	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.BURST_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	MultiTarget = new class'X2AbilityMultiTarget_Radius';
	MultiTarget.fTargetRadius = 2.5;
	MultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	MultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTarget;

    WorldDamage = new class'X2Effect_ApplyDirectionalWorldDamage';  //creates the framework to apply damage to the world
	WorldDamage.bUseWeaponDamageType = False;                       //overrides the normal weapon damage type
	WorldDamage.bUseWeaponEnvironmentalDamage = false;              //replaces the weapon's environmental damage with the abilities
	WorldDamage.EnvironmentalDamageAmount = 3000;                   //determines the amount of enviornmental damage the ability applies
	WorldDamage.bApplyOnHit = true;                                 //obv
	WorldDamage.bApplyOnMiss = true;                                //obv
	WorldDamage.bApplyToWorldOnHit = true;                          //obv
	WorldDamage.bApplyToWorldOnMiss = true;                         //obv
	WorldDamage.bHitAdjacentDestructibles = true;                   
	WorldDamage.PlusNumZTiles = 2;                                 //determines how 'high' the world damage is applied
	WorldDamage.bHitTargetTile = false;                              
	WorldDamage.ApplyChance = 100;
	Template.AddMultiTargetEffect(WorldDamage);                    

	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';   
	WeaponDamageEffect.bIgnoreBaseDamage = true;	
	WeaponDamageEffect.EffectDamageValue.Damage = default.BURST_DAMAGE;			 
	WeaponDamageEffect.bApplyWorldEffectsForEachTargetLocation = true;          
	Template.AddMultiTargetEffect(WeaponDamageEffect);          

	Template.PostActivationEvents.AddItem('UnitUsedPsionicAbility');

	Template.CustomFireAnim = 'HL_Psi_MindControl';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Psionic_FireAtUnit";

	Template.bCrossClassEligible = false;

    return Template;
}

//---------------------------------------------------------------------------------------
//---Blur--------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTBlur() {
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange BlurEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTBlur');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snapshot";
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	
	// Apply perk at start of the mission.
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	BlurEffect = new class'X2Effect_PersistentStatChange';
	BlurEffect.BuildPersistentEffect(1, true, true, true);
	BlurEffect.AddPersistentStatChange(eStat_Mobility, default.BLUR_MOBILITIY_BONUS);
	BlurEffect.AddPersistentStatChange(eStat_Defense, default.BLUR_DEFENSE_BONUS);
	BlurEffect.AddPersistentStatChange(eStat_Dodge, default.BLUR_DODGE_BONUS);
	BlurEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(BlurEffect);
	
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// NOTE: No visualization on purpose!

	return Template;
}

//---------------------------------------------------------------------------------------
//---Purge-------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTPurge() {
	local X2AbilityTemplate Template;
	local X2Effect_RangerStealth StealthEffect;
	local RTEffect_RemoveStacks	PurgeEffect;
	local RTCondition_EffectStackCount	BloodlustCondition;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTPurge');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snapshot";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;
	
	// Deadeye to ensure
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	BloodlustCondition = new class'RTCondition_EffectStackCount';
	BloodlustCondition.iMinimumStacks = default.PURGE_STACK_REQUIREMENT;
	BloodlustCondition.StackingEffect = class'RTEffect_Bloodlust'.default.EffectName;
	Template.AbilityShooterConditions.AddItem(BloodlustCondition);
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	StealthEffect = new class'X2Effect_RangerStealth';
	StealthEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	StealthEffect.bRemoveWhenTargetConcealmentBroken = true;
	Template.AddTargetEffect(StealthEffect);

	PurgeEffect = new class'RTEffect_RemoveStacks';;
	PurgeEffect.EffectNameToPurge = class'RTEffect_Bloodlust'.default.EffectName;
	PurgeEffect.iStacksToRemove = default.PURGE_STACK_REQUIREMENT;
	Template.AddTargetEffect(PurgeEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());
	
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}
//---------------------------------------------------------------------------------------
//---Mentor------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTMentor() {
	local X2AbilityTemplate 				Template;
	local X2Condition_UnitEffects			MeldCondition;
    local X2Condition_UnitProperty          TargetUnitPropertyCondition;
	local X2Effect_PersistentStatChange		MentorEffect;
	local X2AbilityCost_ActionPoints		ActionPointCost;
    local RTCondition_EffectStackCount      BloodlustCondition;
	local X2AbilityCooldown					Cooldown;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTMentor');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snipershot"; //TODO: Change this
    Template.AbilitySourceName = 'eAbilitySource_Psionic';  
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Offensive;
        
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

   	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.MENTOR_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	TargetUnitPropertyCondition = new class'X2Condition_UnitProperty';
	TargetUnitPropertyCondition.ExcludeDead = true;
	TargetUnitPropertyCondition.ExcludeRobotic = true;
	TargetUnitPropertyCondition.ExcludeFriendlyToSource = false;
	TargetUnitPropertyCondition.ExcludeHostileToSource = true;
	TargetUnitPropertyCondition.FailOnNonUnits = true;
	Template.AbilityTargetConditions.AddItem(TargetUnitPropertyCondition);

    MentorEffect = new class'X2Effect_PersistentStatChange';
    MentorEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
    MentorEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true, , Template.AbilitySourceName);
    MentorEffect.AddPersistentStatChange(eStat_Will, default.MENTOR_BONUS);
    MentorEffect.AddPersistentStatChange(eStat_PsiOffense, default.MENTOR_BONUS);
    Template.AddTargetEffect(MentorEffect);        
    
	// melded  
    MeldCondition = new class'X2Condition_UnitEffects';
    MeldCondition = new class'X2Condition_UnitEffects';
	MeldCondition.AddRequireEffect('RTEffect_Meld', 'AA_UnitNotMelded');
	Template.AbilityShooterConditions.AddItem(MeldCondition);
	Template.AbilityTargetConditions.AddItem(MeldCondition);

	// You probably can't be a good mentor if you're filled with bloodlust
    BloodlustCondition = new class'RTCondition_EffectStackCount';
	BloodlustCondition.iMaximumStacks = default.MENTOR_STACK_MAXIMUM;
	BloodlustCondition.StackingEffect = class'RTEffect_Bloodlust'.default.EffectName;
    Template.AbilityShooterConditions.AddItem(BloodlustCondition);

    Template.PostActivationEvents.AddItem('UnitUsedPsionicAbility');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
        
	
	return Template;
}

//---------------------------------------------------------------------------------------
//---Reprobate Waltz---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTReprobateWaltz()
{
	local X2AbilityTemplate					Template;
    local X2AbilityToHitCalc_StandardMelee  StandardMelee;
    local RTEffect_BerserkerMeleeDamage     WeaponDamageEffect;
    local RTEffect_Acid                     AcidEffect;
    local X2Condition_AbilityProperty       AcidCondition;
    local RTEffect_Siphon                   SiphonEffect;
    local X2Condition_AbilityProperty       SiphonCondition;
    local X2Condition_UnitProperty          TargetUnitPropertyCondition;
	local X2AbilityTrigger_EventListener    Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTReprobateWaltz');

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
	Template.AbilityToHitCalc = StandardMelee;

	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';
	Template.ConcealmentRule = eConceal_Always;


	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	// Damage Effect
	//		var int iBaseBladeDamage, iBaseBladeCritDamage, iBaseBladeDamageSpread, iAcidicBladeShred;var float fHiddenBladeCritModifier;
	WeaponDamageEffect = new class'RTEffect_BerserkerMeleeDamage';	 
	WeaponDamageEffect.iBaseBladeDamage = default.BLADE_DAMAGE;
	WeaponDamageEffect.iBaseBladeCritDamage = default.BLADE_CRIT_DAMAGE;
	WeaponDamageEffect.iBaseBladeDamageSpread = default.BLADE_DAMAGE_SPREAD;
	WeaponDamageEffect.iAcidicBladeShred = default.ACID_BLADE_SHRED;
	WeaponDamageEffect.fHiddenBladeCritModifier = default.HIDDEN_BLADE_CRIT_MODIFIER;
	WeaponDamageEffect.bIgnoreBaseDamage = true;
	Template.AddTargetEffect(WeaponDamageEffect);

	// Acid Effect
	AcidEffect = class'RTEffect_Acid'.static.CreateAcidBurningStatusEffect('RTAcid', 4);
	AcidEffect.SetAcidDamage(default.ACID_BLADE_DOT_DAMAGE, 0, default.ACID_BLADE_DOT_SHRED, 'RTAcid');

	AcidCondition = new class'X2Condition_AbilityProperty';
	AcidCondition.OwnerHasSoldierAbilities.AddItem('RTAcidicBlade');
	AcidEffect.TargetConditions.AddItem(AcidCondition);
	Template.AddTargetEffect(AcidEffect);

	// Siphon Effect
	SiphonEffect = new class'RTEffect_Siphon';
	SiphonEffect.SiphonAmountMultiplier = default.SIPHON_AMOUNT_MULTIPLIER;
	SiphonEffect.SiphonMinVal = default.SIPHON_MIN_VAL;
	SiphonEffect.SiphonMaxVal = default.SIPHON_MAX_VAL;
	SiphonEffect.DamageTypes.AddItem('Psi');

	TargetUnitPropertyCondition = new class'X2Condition_UnitProperty';
	TargetUnitPropertyCondition.ExcludeDead = true;
	TargetUnitPropertyCondition.ExcludeRobotic = true;
	TargetUnitPropertyCondition.ExcludeFriendlyToSource = false;
	TargetUnitPropertyCondition.ExcludeHostileToSource = false;
	TargetUnitPropertyCondition.FailOnNonUnits = true;

	SiphonCondition = new class'X2Condition_AbilityProperty';
	SiphonCondition.OwnerHasSoldierAbilities.AddItem('RTSiphon');

	SiphonEffect.TargetConditions.AddItem(SiphonCondition);
	SiphonEffect.TargetConditions.AddItem(TargetUnitPropertyCondition);
	Template.AddTargetEffect(SiphonEffect);

	Template.bAllowBonusWeaponEffects = true;
	Template.bSkipMoveStop = true;
	
	Template.AssociatedPassives.AddItem('RTAcidicBlade');
	Template.AssociatedPassives.AddItem('RTPsionicBlade');
	Template.AssociatedPassives.AddItem('RTHiddenBlade');
	Template.AssociatedPassives.AddItem('RTSiphon');

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'RTBerserkerKnifeAttack';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'RTGameState_Ability'.static.ReprobateWaltzListener;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_reaper";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	
	Template.bShowActivation = true;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Pyroclastic Flow--------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTPyroclasticFlow()
{
	local X2AbilityTemplate						Template;
	local X2Effect_Persistent					SOVEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTPyroclasticFlow');
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



	Template.AdditionalAbilities.AddItem('RTPyroclasticSlash');
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!
	
	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Pyroclastic Slash-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTPyroclasticSlash()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityToHitCalc_StandardMelee  StandardMelee;
	local RTEffect_BerserkerMeleeDamage     WeaponDamageEffect;
	local RTEffect_Acid						AcidEffect;
	local array<name>                       SkipExclusions;
	local X2Condition_AbilityProperty  		AcidCondition, SiphonCondition;
	local X2Condition_UnitProperty			TargetUnitPropertyCondition;
	local RTEffect_Siphon					SiphonEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTPyroclasticSlash');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Ranger_Reaper";
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash";
	Template.bHideOnClassUnlock = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
	Template.AbilityToHitCalc = StandardMelee;

	Template.ConcealmentRule = eConceal_Always;

	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

	// Target Conditions
	//
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	// Shooter Conditions
	//
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Damage Effect
	//		var int iBaseBladeDamage, iBaseBladeCritDamage, iBaseBladeDamageSpread, iAcidicBladeShred;var float fHiddenBladeCritModifier;
	WeaponDamageEffect = new class'RTEffect_BerserkerMeleeDamage';	 
	WeaponDamageEffect.iBaseBladeDamage = default.BLADE_DAMAGE;
	WeaponDamageEffect.iBaseBladeCritDamage = default.BLADE_CRIT_DAMAGE;
	WeaponDamageEffect.iBaseBladeDamageSpread = default.BLADE_DAMAGE_SPREAD;
	WeaponDamageEffect.iAcidicBladeShred = default.ACID_BLADE_SHRED;
	WeaponDamageEffect.fHiddenBladeCritModifier = default.HIDDEN_BLADE_CRIT_MODIFIER;
	WeaponDamageEffect.bIgnoreBaseDamage = true;
	Template.AddTargetEffect(WeaponDamageEffect);

	// Acid Effect
	AcidEffect = class'RTEffect_Acid'.static.CreateAcidBurningStatusEffect('RTAcid', 4);
	AcidEffect.SetAcidDamage(default.ACID_BLADE_DOT_DAMAGE, 0, default.ACID_BLADE_DOT_SHRED, 'RTAcid');

	AcidCondition = new class'X2Condition_AbilityProperty';
	AcidCondition.OwnerHasSoldierAbilities.AddItem('RTAcidicBlade');
	AcidEffect.TargetConditions.AddItem(AcidCondition);
	Template.AddTargetEffect(AcidEffect);

	// Siphon Effect
	SiphonEffect = new class'RTEffect_Siphon';
	SiphonEffect.SiphonAmountMultiplier = default.SIPHON_AMOUNT_MULTIPLIER;
	SiphonEffect.SiphonMinVal = default.SIPHON_MIN_VAL;
	SiphonEffect.SiphonMaxVal = default.SIPHON_MAX_VAL;
	SiphonEffect.DamageTypes.AddItem('Psi');

	TargetUnitPropertyCondition = new class'X2Condition_UnitProperty';
	TargetUnitPropertyCondition.ExcludeDead = true;
	TargetUnitPropertyCondition.ExcludeRobotic = true;
	TargetUnitPropertyCondition.ExcludeFriendlyToSource = false;
	TargetUnitPropertyCondition.ExcludeHostileToSource = false;
	TargetUnitPropertyCondition.FailOnNonUnits = true;

	SiphonCondition = new class'X2Condition_AbilityProperty';
	SiphonCondition.OwnerHasSoldierAbilities.AddItem('RTSiphon');

	SiphonEffect.TargetConditions.AddItem(SiphonCondition);
	SiphonEffect.TargetConditions.AddItem(TargetUnitPropertyCondition);
	Template.AddTargetEffect(SiphonEffect);

	Template.bAllowBonusWeaponEffects = true;
	Template.bSkipMoveStop = true;
	
	Template.AssociatedPassives.AddItem('RTAcidicBlade');
	Template.AssociatedPassives.AddItem('RTPsionicBlade');
	Template.AssociatedPassives.AddItem('RTHiddenBlade');
	Template.AssociatedPassives.AddItem('RTSiphon');
	
	Template.OverrideAbilities.AddItem('RTBerserkerKnifeAttack');
	Template.PostActivationEvents.AddItem('RTBerserkerKnifeAttack');


	// Voice events
	//
	Template.SourceMissSpeech = 'SwordMiss';

	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Contained Fury---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTContainedFury() {
	local X2AbilityTemplate 	Template;
    local X2Effect_Persistent	Effect;
    
    `CREATE_X2ABILITY_TEMPLATE(Template, 'RTContainedFury');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aim";
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
	
	// Apply perk at the start of the mission. 
    Template.AbilityToHitCalc = default.DeadEye; 
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

    // Effect to apply
    Effect = new class'X2Effect_Persistent';
    Effect.BuildPersistentEffect(1, true, true, true);
    Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
    Template.AddTargetEffect(Effect);
	
    // Probably required 
    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    //  NOTE: No visualization on purpose!
	
	Template.AdditionalAbilities.AddItem('RTContainedFuryMeldJoin');

    return Template;
}

//---------------------------------------------------------------------------------------
//---Contained Fury Meld Join------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTContainedFuryMeldJoin()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCooldown                 		Cooldown;
	local X2Condition_UnitEffects				Condition;
	local RTEffect_Meld					MeldEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTContainedFuryMeldJoin');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_mindcontrol";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;
	Template.HideErrors.AddItem('AA_AbilityUnavailable');
	Template.HideErrors.AddItem('AA_MeldEffect_Active');
	Template.HideErrors.AddItem('AA_NoTargets');
	Template.Hostility = eHostility_Neutral;
	Template.ConcealmentRule = eConceal_Always;

	Template.AbilityCosts.AddItem(default.FreeActionCost);
	
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 1;
	Template.AbilityCooldown = Cooldown;

	Condition = new class'X2Condition_UnitEffects';
	Condition.AddExcludeEffect('RTEffect_Meld', 'AA_MeldEffect_Active');
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
    Template.OverrideAbilities.AddItem('JoinMeld');

	return Template;
}

//---------------------------------------------------------------------------------------
//---Unstable Conduit--------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTUnstableConduit()
{
	local X2AbilityTemplate					Template;
	local X2Condition_UnitEffects			Condition;
	local X2AbilityMultiTarget_AllAllies	MultiTarget;
	local X2AbilityTrigger_EventListener	Trigger;
	local X2Effect_ImmediateAbilityActivation ActivateAbilityEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTUnstableConduit');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_mindcontrol";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Offensive;

	Template.ConcealmentRule = eConceal_Miss;		// unsure

	Template.AbilityCosts.AddItem(default.FreeActionCost);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();
	
	Condition = new class'X2Condition_UnitEffects';
	Condition.AddRequireEffect('RTEffect_Meld', 'AA_UnitNotMelded');
	Template.AbilityShooterConditions.AddItem(Condition);
	Template.AbilityMultiTargetConditions.AddItem(Condition);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'UnitUsedPsionicAbility';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	MultiTarget = new class'X2AbilityMultiTarget_AllAllies';
	Template.AbilityMultiTargetStyle = MultiTarget;

	ActivateAbilityEffect = new class'X2Effect_ImmediateAbilityActivation';
	ActivateAbilityEffect.AbilityName = 'UnstableConduitBurst';
	Template.AddTargetEffect(ActivateAbilityEffect);
	Template.AddMultiTargetEffect(ActivateAbilityEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	Template.AdditionalAbilities.AddItem('RTUnstableConduitIcon');

	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Unstable Conduit Icon---------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTUnstableConduitIcon() {
	local X2AbilityTemplate 	Template;
    local X2Effect_Persistent	Effect;
    
    `CREATE_X2ABILITY_TEMPLATE(Template, 'RTUnstableConduitIcon');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aim";
    Template.AbilitySourceName = 'eAbilitySource_Psionic';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
	
	// Apply perk at the start of the mission. 
    Template.AbilityToHitCalc = default.DeadEye; 
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);


    // Effect to apply
    Effect = new class'X2Effect_Persistent';
    Effect.BuildPersistentEffect(1, true, true, true);
    Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
    Template.AddTargetEffect(Effect);
	
    // Probably required 
    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    //  NOTE: No visualization on purpose!
	
    return Template;
}

//---------------------------------------------------------------------------------------
//---Unstable Conduit Burst--------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTUnstableConduitBurst() {
    local X2AbilityTemplate Template;
    local X2AbilityMultiTarget_Radius MultiTarget;
    local X2Effect_ApplyDirectionalWorldDamage WorldDamage;
    local X2Effect_ApplyWeaponDamage WeaponDamageEffect;
    local X2Effect_Knockback  KnockbackEffect;

    `CREATE_X2ABILITY_TEMPLATE(Template, 'RTUnstableConduitBurst');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snipershot"; //TODO: Change this
    Template.AbilitySourceName = 'eAbilitySource_Psionic';  
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Neutral;

	Template.AbilityCosts.AddItem(default.FreeActionCost);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	MultiTarget = new class'X2AbilityMultiTarget_Radius';
	MultiTarget.fTargetRadius = 2.5;
	MultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	MultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTarget;

    WorldDamage = new class'X2Effect_ApplyDirectionalWorldDamage';  //creates the framework to apply damage to the world
	WorldDamage.bUseWeaponDamageType = False;                       //overrides the normal weapon damage type
	WorldDamage.bUseWeaponEnvironmentalDamage = false;              //replaces the weapon's environmental damage with the abilities
	WorldDamage.EnvironmentalDamageAmount = 3000;                   //determines the amount of enviornmental damage the ability applies
	WorldDamage.bApplyOnHit = true;                                 //obv
	WorldDamage.bApplyOnMiss = true;                                //obv
	WorldDamage.bApplyToWorldOnHit = true;                          //obv
	WorldDamage.bApplyToWorldOnMiss = true;                         //obv
	WorldDamage.bHitAdjacentDestructibles = true;                   
	WorldDamage.PlusNumZTiles = 2;                                 //determines how 'high' the world damage is applied
	WorldDamage.bHitTargetTile = false;                              
	WorldDamage.ApplyChance = 100;
	Template.AddMultiTargetEffect(WorldDamage);                    

	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';   
	WeaponDamageEffect.bIgnoreBaseDamage = true;	
	WeaponDamageEffect.EffectDamageValue.Damage = default.BURST_DAMAGE;			 
	WeaponDamageEffect.bApplyWorldEffectsForEachTargetLocation = true;          
	Template.AddMultiTargetEffect(WeaponDamageEffect);          

	Template.CustomFireAnim = 'HL_Psi_MindControl';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Psionic_FireAtUnit";

	Template.bShowPostActivation = true;

	Template.bCrossClassEligible = false;

    return Template;
}

//---------------------------------------------------------------------------------------
//---Persisting Images-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTPersistingImages()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	local RTEffect_GenerateAfterimage AfterEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTPersistingImages');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aim";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityToHitCalc = default.DeadEye; 
    Template.AbilityTargetStyle = default.SelfTarget;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'UnitEnteredRTSTealth';
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self_VisualizeInGameState;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.TargetingMethod = class'X2TargetingMethod_MimicBeacon';
	Template.SkipRenderOfTargetingTemplate = true;

	AfterEffect = new class'RTEffect_GenerateAfterimage';
	AfterEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	Template.AddShooterEffect(AfterEffect);

	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = Afterimage_BuildVisualization;

	Template.AdditionalAbilities.AddItem('RTPersistingImagesIcon');

	return Template;

}

simulated function Afterimage_BuildVisualization(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;
	local VisualizationTrack EmptyTrack;
	local VisualizationTrack SourceTrack, MimicBeaconTrack;
	local XComGameState_Unit MimicSourceUnit, SpawnedUnit;
	local UnitValue SpawnedUnitValue;
	local X2Action_PlayAnimation AnimationAction;
	local RTEffect_GenerateAfterimage AfterEffect;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	SourceTrack = EmptyTrack;
	SourceTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	SourceTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	SourceTrack.TrackActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	class'X2Action_ExitCover'.static.AddToVisualizationTrack(SourceTrack, Context);
	class'X2Action_EnterCover'.static.AddToVisualizationTrack(SourceTrack, Context);

	// Configure the visualization track for the mimic beacon
	//******************************************************************************************
	MimicSourceUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID));
	`assert(MimicSourceUnit != none);
	MimicSourceUnit.GetUnitValue(class'X2Effect_SpawnUnit'.default.SpawnedUnitValueName, SpawnedUnitValue);

	MimicBeaconTrack = EmptyTrack;
	MimicBeaconTrack.StateObject_OldState = History.GetGameStateForObjectID(SpawnedUnitValue.fValue, eReturnType_Reference, VisualizeGameState.HistoryIndex);
	MimicBeaconTrack.StateObject_NewState = MimicBeaconTrack.StateObject_OldState;
	SpawnedUnit = XComGameState_Unit(MimicBeaconTrack.StateObject_NewState);
	`assert(SpawnedUnit != none);
	MimicBeaconTrack.TrackActor = History.GetVisualizer(SpawnedUnit.ObjectID);

	// Only one target effect and it is X2Effect_SpawnMimicBeacon
	AfterEffect = RTEffect_GenerateAfterimage(Context.ResultContext.ShooterEffectResults.Effects[0]);
	
	if( AfterEffect == none )
	{
		`RedScreenOnce("Afterimage_BuildVisualization: Missing RTEffect_GenerateAfterimage -bp1 @gameplay");
		return;
	}

	AfterEffect.AddSpawnVisualizationsToTracks(Context, SpawnedUnit, MimicBeaconTrack, MimicSourceUnit, SourceTrack);

	class'X2Action_SyncVisualizer'.static.AddToVisualizationTrack(MimicBeaconTrack, Context);

	AnimationAction = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTrack(MimicBeaconTrack, Context));
	AnimationAction.Params.AnimName = 'LL_MimicStart';
	AnimationAction.Params.BlendTime = 0.0f;

	OutVisualizationTracks.AddItem(SourceTrack);
	OutVisualizationTracks.AddItem(MimicBeaconTrack);
}

static function X2AbilityTemplate RTPersistingImagesIcon() {
	local X2AbilityTemplate 	Template;
    local X2Effect_Persistent	Effect;
    
    `CREATE_X2ABILITY_TEMPLATE(Template, 'RTPersistingImagesIcon');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aim";	   // TODO: THIS
    Template.AbilitySourceName = 'eAbilitySource_Psionic';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
	
	// Apply perk at the start of the mission. 
    Template.AbilityToHitCalc = default.DeadEye; 
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

    // Effect to apply
    Effect = new class'X2Effect_Persistent';
    Effect.BuildPersistentEffect(1, true, true, true);
    Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
    Template.AddTargetEffect(Effect);
	
    // Probably required 
    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    //  NOTE: No visualization on purpose!
	
    return Template;
}

//---------------------------------------------------------------------------------------
//---Ghost In The Shell------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTGhostInTheShell()
{
	local X2AbilityTemplate		Template;
	local X2Effect_Persistent	Effect;
	local X2Effect_StayConcealed PhantomEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTGhostInTheShell');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aim";	   // TODO: THIS
    Template.AbilitySourceName = 'eAbilitySource_Psionic';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
	
	// Apply perk at the start of the mission. 
    Template.AbilityToHitCalc = default.DeadEye; 
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

    // Effect to apply
    Effect = new class'X2Effect_Persistent';
    Effect.BuildPersistentEffect(1, true, true, true);
	Effect.EffectName = 'RTGhostInTheShell';
    Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
    Template.AddTargetEffect(Effect);

	PhantomEffect = new class'X2Effect_StayConcealed';
	PhantomEffect.BuildPersistentEffect(1, true, false);
	Template.AddTargetEffect(PhantomEffect);
	
    // Probably required 
    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    //  NOTE: No visualization on purpose!

	return Template;
}

//---------------------------------------------------------------------------------------
//---Queen of Blades---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTQueenOfBlades()
{
	local X2AbilityTemplate		Template;
	local X2Effect_Persistent	Effect;
	local X2Effect_StayConcealed PhantomEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTQueenOfBlades');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aim";	   // TODO: THIS
    Template.AbilitySourceName = 'eAbilitySource_Psionic';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
	
	// Apply perk at the start of the mission. 
    Template.AbilityToHitCalc = default.DeadEye; 
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

    // Effect to apply
    Effect = new class'X2Effect_Persistent';
    Effect.BuildPersistentEffect(1, true, true, true);
	Effect.EffectName = 'RTQueenOfBlades';
    Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
    Template.AddTargetEffect(Effect);
	
    // Probably required 
    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    //  NOTE: No visualization on purpose!

	return Template;
}
