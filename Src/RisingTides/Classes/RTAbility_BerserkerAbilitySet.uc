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

//---------------------------------------------------------------------------------------
//---CreateTemplates---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(BumpInTheNight());
	Templates.AddItem(BumpInTheNightListener());
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
	Template.AddTargetEffect(BumpEffect);

	Template.AdditionalAbilities.AddItem('GhostPsiSuite');
	Template.AdditionalAbilities.AddItem('JoinMeld');
	Template.AdditionalAbilities.AddItem('LeaveMeld');
	Template.AdditionalAbilities.AddItem('PsiOverload');
	Template.AdditionalAbilities.AddItem('PsiOverloadPanic');
	Template.AdditionalAbilities.AddItem('LIOverwatchShot');
	Template.AdditionalAbilities.AddItem('BumpInTheNightListener');
	Template.AdditionalAbilities.AddItem('StandardGhostShot');

	// Probably required 
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;

}
//---------------------------------------------------------------------------------------
//---BumpInTheNightListener--------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate BumpInTheNightListener()
{
	local X2AbilityTemplate                 Template;
	local RTEffect_Bloodlust				BloodlustEffect;
	local RTEffect_Stealth					StealthEffect;
	local X2AbilityTrigger_EventListener	Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BumpInTheNightListener');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash"; // TODO: Change this
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;

	BloodlustEffect = new class'RTEffect_Bloodlust';
	BloodlustEffect.BuildPersistentEffect(2, false, false, false, eGameRule_PlayerTurnEnd);
	BloodlustEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(BloodlustEffect);

	StealthEffect = new class'RTEffect_Stealth';
	StealthEffect.fStealthModifier = 1;
	StealthEffect.BuildPersistentEffect(2, false, false, false, eGameRule_PlayerTurnEnd);
	Template.AddTargetEffect(StealthEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());
	

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'RTBloodlust_Proc';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.bShowActivation = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
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
	//local RTEffect_Acid						AcidEffect;
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

	//// Acid Effect
	//AcidEffect = new class'RTEffect_Acid';
	//AcidEffect.BuildPersistentEffect(default.Acid_DURATION, true, false, false, eGameRule_PlayerTurnEnd);
	//AcidEffect.SetDisplayInfo(ePerkBuff_Penalty, default.AcidFriendlyName, default.AcidFriendlyDesc, Template.IconImage, true);
	//AcidEffect.DuplicateResponse = eDupe_Refresh;	 
	//AcidEffect.bStackOnRefresh = true;
	//AcidEffect.SetAcidDamage(default.ACID_BLADE_DOT_DAMAGE, default.ACID_BLADE_DOT_SHRED);
//
	//AcidCondition = new class'X2Condition_AbilityProperty';
	//AcidCondition.OwnerHasSoldierAbilities.AddItem('RTAcidicBlade');
	//AcidEffect.TargetConditions.AddItem(AcidCondition);
	//Template.AddTargetEffect(AcidEffect);

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
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_ShowIfAvailable;
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
	StealthEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true);
	StealthEffect.bRemoveWhenTargetConcealmentBroken = true;
	Template.AddTargetEffect(StealthEffect);

	PurgeEffect = new class'RTEffect_RemoveStacks';;
	PurgeEffect.EffectNameToPurge = class'RTEffect_Bloodlust'.default.EffectName;
	PurgeEffect.iStacksToRemove = default.PURGE_STACK_REQUIREMENT;
	Template.AddTargetEffect(PurgeEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());
	
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// TODO: Visualization

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
        local X2AbilityToHitCalc_StandardMelee                  StandardMelee;
        local RTEffect_BerserkerMeleeDamage                     WeaponDamageEffect;
        // local RTEffect_Acid                                     AcidEffect;
        // local X2Condition_AbilityProperty                       AcidCondition;
        local RTEffect_Siphon                                   SiphonEffect;
        local X2Condition_AbilityProperty                       SiphonCondition;
        local X2Condition_UnitProperty                          TargetUnitPropertyCondition;
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

	//// Acid Effect
	//AcidEffect = new class'RTEffect_Acid';
	//AcidEffect.BuildPersistentEffect(default.Acid_DURATION, true, false, false, eGameRule_PlayerTurnEnd);
	//AcidEffect.SetDisplayInfo(ePerkBuff_Penalty, default.AcidFriendlyName, default.AcidFriendlyDesc, Template.IconImage, true);
	//AcidEffect.DuplicateResponse = eDupe_Refresh;	 
	//AcidEffect.bStackOnRefresh = true;
	//AcidEffect.SetAcidDamage(default.ACID_BLADE_DOT_DAMAGE, default.ACID_BLADE_DOT_SHRED);
//
	//AcidCondition = new class'X2Condition_AbilityProperty';
	//AcidCondition.OwnerHasSoldierAbilities.AddItem('RTAcidicBlade');
	//AcidEffect.TargetConditions.AddItem(AcidCondition);
	//Template.AddTargetEffect(AcidEffect);

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
	Trigger.ListenerData.EventID = 'BerserkerKnifeAttack';
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
