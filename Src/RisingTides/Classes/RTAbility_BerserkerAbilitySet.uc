//---------------------------------------------------------------------------------------
//  FILE:    RTAbility_BerserkerAbilitySet.uc
//  AUTHOR:  Aleosiss
//  DATE:    8 August 2016
//  PURPOSE: Defines abilities used by Queen.
//           
//---------------------------------------------------------------------------------------
//	Queen's perks.
//---------------------------------------------------------------------------------------

class RTAbility_BerserkerAbilitySet extends RTAbility_GhostAbilitySet config(RisingTides);

	var config int BITN_TILEDISTANCE;
	var config int ACID_BLADE_DOT_DAMAGE;
	var config int ACID_BLADE_DOT_SHRED;
	var config WeaponDamageValue BURST_DMG;
	var config int BURST_COOLDOWN;
	var config float BURST_RADIUS_METERS;
	var config float SIPHON_AMOUNT_MULTIPLIER;
	var config int SIPHON_MIN_VAL;
	var config int SIPHON_MAX_VAL;
	var config int SIPHON_RANGE;
	var config int BLUR_DEFENSE_BONUS;
	var config int BLUR_DODGE_BONUS;
	var config int BLUR_MOBILITY_BONUS;	 
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
	var config int BITN_DEFENSE_BONUS;

//---------------------------------------------------------------------------------------
//---CreateTemplates---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(BumpInTheNight());																							  // icon	// animation
	Templates.AddItem(BumpInTheNightBloodlustListener());																			  
	Templates.AddItem(BumpInTheNightStealthListener());																				  
	Templates.AddItem(RTBerserkerKnifeAttack());																					  // icon
	Templates.AddItem(PurePassive('RTAcidicBlade', "img:///RisingTidesContentPackage.PerkIcons.UIPerk_stim_knife", true));
	Templates.AddItem(PurePassive('RTPsionicBlade', "img:///RisingTidesContentPackage.PerkIcons.UIPerk_psi_knife", true));
	Templates.AddItem(PurePassive('RTHiddenBlade', "img:///RisingTidesContentPackage.PerkIcons.UIPerk_stealth_knife", true));
	Templates.AddItem(PurePassive('RTSiphon', "img:///UILibrary_PerkIcons.UIPerk_salvo", true));									  // icon
	Templates.AddItem(RTBurst());																									  // icon	// animation
	Templates.AddItem(RTBlur());																									  // icon
	Templates.AddItem(RTPurge());																									  // icon	// animation
	Templates.AddItem(RTMentor());																									  // icon	// animation
	Templates.AddItem(RTReprobateWaltz());																							  
	Templates.AddItem(RTReprobateWaltzIcon());																						  // icon
	Templates.AddItem(RTPyroclasticFlow());																							  // icon
	Templates.AddItem(RTCreateFireTrailAbility());																					  
	Templates.AddItem(RTPyroclasticSlash());																						  // icon
	Templates.AddItem(RTContainedFuryMeldJoin());
	Templates.AddItem(RTContainedFury());																							  // icon
	Templates.AddItem(RTUnstableConduit());																							  			// animation
	Templates.AddItem(RTUnstableConduitIcon());																						  // icon
	Templates.AddItem(RTUnstableConduitBurst());																					  // icon
	Templates.AddItem(RTPersistingImages());
	Templates.AddItem(RTPersistingImagesIcon());																					  // icon
	Templates.AddItem(RTGhostInTheShell());																							  
	Templates.AddItem(RTGhostInTheShellEffect());
	Templates.AddItem(RTQueenOfBlades());																							  // icon	
	Templates.AddItem(RTShadowStrike());																							  // icon
	Templates.AddItem(RTDashingStrike());
	

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
	BumpEffect.DEFENSE_BONUS = default.BITN_DEFENSE_BONUS;
	Template.AddTargetEffect(BumpEffect);

	// standard ghost abilities
	Template.AdditionalAbilities.AddItem('GhostPsiSuite');
	Template.AdditionalAbilities.AddItem('JoinMeld');
	Template.AdditionalAbilities.AddItem('LeaveMeld');
	Template.AdditionalAbilities.AddItem('PsiOverload');
	Template.AdditionalAbilities.AddItem('RTFeedback');
	
	// unique abilities for Bump In The Night
	Template.AdditionalAbilities.AddItem('BumpInTheNightBloodlustListener');
	Template.AdditionalAbilities.AddItem('BumpInTheNightStealthListener');
	Template.AdditionalAbilities.AddItem('StandardGhostShot');

	// special meld abilities
	Template.AdditionalAbilities.AddItem('LIOverwatchShot');
	Template.AdditionalAbilities.AddItem('RTUnstableConduitBurst');
	Template.AdditionalAbilities.AddItem('PsionicActivate');
	Template.AdditionalAbilities.AddItem('RTHarbingerBonusDamage');

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

	BloodlustEffect = new class'RTEffect_Bloodlust';
	BloodlustEffect.iMobilityMod = 1;
	BloodlustEffect.iMeleeHitChanceMod = 5;
	BloodlustEffect.fCritDamageMod = 0.1f;
	BloodlustEffect.BuildPersistentEffect(2, false, true, false, eGameRule_PlayerTurnEnd);
	BloodlustEffect.SetDisplayInfo(ePerkBuff_Bonus, "Bloodlust", "Gain bonus melee crit chance and crit damage, but lose movement speed.", Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(BloodlustEffect);

	StealthEffect = class'RTEffectBuilder'.static.RTCreateStealthEffect(1, false, 1.0f, eGameRule_PlayerTurnBegin, Template.AbilitySourceName); 
	Template.AddTargetEffect(StealthEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_Immediate;
	Trigger.ListenerData.EventID = 'RTBumpInTheNight_BloodlustProc';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.bShowPostActivation = true;
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
	local RTEffect_Stealth					StealthEffect;
	local X2AbilityTrigger_EventListener	Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BumpInTheNightStealthListener');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash"; // TODO: Change this
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;

	StealthEffect = class'RTEffectBuilder'.static.RTCreateStealthEffect(1, false, 1.0f, eGameRule_PlayerTurnBegin, Template.AbilitySourceName); 
	Template.AddTargetEffect(StealthEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_Immediate;
	Trigger.ListenerData.EventID = 'RTBumpInTheNight_StealthProc';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.bShowPostActivation = true;
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
	local RTCondition_VisibleToPlayer		PlayerVisibilityCondition;

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
	//Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	PlayerVisibilityCondition = new class'RTCondition_VisibleToPlayer';
	Template.AbilityTargetConditions.AddItem(PlayerVisibilityCondition); 

	// Shooter Conditions
	//
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	//SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions();

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
	TargetUnitPropertyCondition.ExcludeDead = false;
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
    local X2AbilityTemplate							Template;
    local X2AbilityMultiTarget_Radius				MultiTarget;
    local X2Effect_ApplyDirectionalWorldDamage		WorldDamage;
    local X2Effect_ApplyWeaponDamage				WeaponDamageEffect;
    local X2AbilityCooldown							Cooldown;
    local X2AbilityCost_ActionPoints				ActionPointCost;
    local X2Effect_Knockback						KnockbackEffect;
	local X2Effect_Persistent						Effect;

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
	MultiTarget.fTargetRadius = default.BURST_RADIUS_METERS * class'XComWorldData'.const.WORLD_StepSize * class'XComWorldData'.const.WORLD_UNITS_TO_METERS_MULTIPLIER;
	MultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	MultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTarget;

	Effect = new class'X2Effect_Persistent';
	Effect.BuildPersistentEffect(0, false);
	Effect.VFXTemplateName = default.BurstParticleString;
	Template.AddShooterEffect(Effect);

    WorldDamage = new class'X2Effect_ApplyDirectionalWorldDamage';  //creates the framework to apply damage to the world
	WorldDamage.bUseWeaponDamageType = False;                       //overrides the normal weapon damage type
	WorldDamage.bUseWeaponEnvironmentalDamage = false;              //replaces the weapon's environmental damage with the abilities
	WorldDamage.EnvironmentalDamageAmount = 2500;                   //determines the amount of enviornmental damage the ability applies
	WorldDamage.bApplyOnHit = true;                                 //obv
	WorldDamage.bApplyOnMiss = true;                                //obv
	WorldDamage.bApplyToWorldOnHit = true;                          //obv
	WorldDamage.bApplyToWorldOnMiss = true;                         //obv
	WorldDamage.bHitAdjacentDestructibles = true;                   
	WorldDamage.PlusNumZTiles = 2;                                 //determines how 'high' the world damage is applied
	WorldDamage.bHitTargetTile = true;                              
	WorldDamage.ApplyChance = 100;
	WorldDamage.bAllowDestructionOfDamageCauseCover = true;
	Template.AddMultiTargetEffect(WorldDamage);                    

	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';   
	WeaponDamageEffect.bIgnoreBaseDamage = true;	
	WeaponDamageEffect.EffectDamageValue = default.BURST_DMG;			 
	WeaponDamageEffect.bApplyWorldEffectsForEachTargetLocation = true;
	WeaponDamageEffect.EnvironmentalDamageAmount = 250;        
	Template.AddMultiTargetEffect(WeaponDamageEffect);              

	Template.PostActivationEvents.AddItem(default.UnitUsedPsionicAbilityEvent);

	Template.bShowActivation = true;
	Template.bSkipFireAction = true;

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
	BlurEffect.AddPersistentStatChange(eStat_Mobility, default.BLUR_MOBILITY_BONUS);
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
	local X2Effect_RemoveEffects			RemoveEffect;
	
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

	RemoveEffect = new class'X2Effect_RemoveEffects';   
	RemoveEffect.EffectNamesToRemove.AddItem(default.RTFeedbackEffectName);
	RemoveEffect.EffectNamesToRemove.AddItem(default.RTFeedbackWillDebuffName);
	Template.AddTargetEffect(RemoveEffect);

    MentorEffect = new class'X2Effect_PersistentStatChange';
    MentorEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
    MentorEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true, , Template.AbilitySourceName);
    MentorEffect.AddPersistentStatChange(eStat_Will, default.MENTOR_BONUS);
    MentorEffect.AddPersistentStatChange(eStat_PsiOffense, default.MENTOR_BONUS);
    Template.AddTargetEffect(MentorEffect);     
	
	// melded  
    MeldCondition = new class'X2Condition_UnitEffects';
	MeldCondition.AddRequireEffect('RTEffect_Meld', 'AA_UnitNotMelded');
	Template.AbilityShooterConditions.AddItem(MeldCondition);

	// You probably can't be a good mentor if you're filled with bloodlust
    BloodlustCondition = new class'RTCondition_EffectStackCount';
	BloodlustCondition.iMaximumStacks = default.MENTOR_STACK_MAXIMUM;
	BloodlustCondition.StackingEffect = class'RTEffect_Bloodlust'.default.EffectName;
	BloodlustCondition.bRequireEffect = false;
    Template.AbilityShooterConditions.AddItem(BloodlustCondition);
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

    Template.PostActivationEvents.AddItem(default.UnitUsedPsionicAbilityEvent);

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
	TargetUnitPropertyCondition.ExcludeRobotic = false;
	TargetUnitPropertyCondition.ExcludeFriendlyToSource = false;
	TargetUnitPropertyCondition.ExcludeHostileToSource = false;
	TargetUnitPropertyCondition.FailOnNonUnits = true;
	Template.AbilityTargetConditions.AddItem(TargetUnitPropertyCondition);

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

	// ability will be activated by an event listener
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

	Template.bShowActivation = true;

	Template.AdditionalAbilities.AddItem('RTReprobateWaltzIcon');


	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_reaper";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	

	return Template;
}

//---------------------------------------------------------------------------------------
//---Reprobate Waltz Icon----------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTReprobateWaltzIcon()
{
	local X2AbilityTemplate		Template;
	local RTEffect_ReprobateWaltz	Effect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTReprobateWaltzIcon');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aim";	   // TODO: THIS
    Template.AbilitySourceName = 'eAbilitySource_Psionic';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
	
	// Apply perk at the start of the mission. 
    Template.AbilityToHitCalc = default.DeadEye; 
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

    // Effect to apply
    Effect = new class'RTEffect_ReprobateWaltz';
    Effect.BuildPersistentEffect(1, true, true, true);
	Effect.EffectName = 'RTReprobateWaltz';
    Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
    Template.AddTargetEffect(Effect);
	
    // Probably required 
    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    //  NOTE: No visualization on purpose!


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
	Template.AdditionalAbilities.AddItem('RTCreateFireTrailAbility');
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!
	
	Template.bCrossClassEligible = false;

	return Template;
}

// copied from X2Ability_AndromedonRobot.uc
static function X2AbilityTemplate RTCreateFireTrailAbility()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTCreateFireTrailAbility');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_andromedon_poisoncloud"; // TODO: This needs to be changed

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	//This ability fires as part of game states where the Andromedon robot moves
	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitMoveFinished';
	EventListener.ListenerData.Filter = eFilter_Unit;
	EventListener.ListenerData.EventFn = BuildFireTrail_Self;
	Template.AbilityTriggers.AddItem(EventListener);

	// Targets the Andromedon unit so it can be replaced by the andromedon robot;
	Template.AbilityTargetStyle = default.SelfTarget;

	//NOTE: This ability does not require a build game state or visualization function because this is handled
	//      by the event listener and associated functionality when creating world tile effects
	Template.BuildNewGameStateFn = Empty_BuildGameState;

	return Template;
}
function XComGameState Empty_BuildGameState( XComGameStateContext Context )
{
	return none;
}
static function EventListenerReturn BuildFireTrail_Self(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameStateContext_Ability MoveContext;
	local int TileIndex;	
	local XComGameState NewGameState;
	local float AbilityRadius;
	local XComWorldData WorldData;
	local vector TargetLocation;
	local array<TilePosPair> OutTiles;
	local TTile MovementTile;
	local XComGameState_Unit UnitStateObject;
	local XComGameStateHistory History;
	local X2Effect_ApplyFireToWorld FireEffect;

	local XComGameState_Unit SourceUnit;


	MoveContext = XComGameStateContext_Ability(GameState.GetContext());

	History = `XCOMHISTORY;
	WorldData = `XWORLD;

	SourceUnit = XComGameState_Unit(EventSource);
	if(SourceUnit.AffectedByEffectNames.Find(class'X2StatusEffects'.default.BurningName) == INDEX_NONE) {
		return ELR_NoInterrupt;
	}

	//Define how wide the Acid will spread
	AbilityRadius = class'XComWorldData'.const.WORLD_StepSize * 0.5f;

	//These branches define different situations for which we should generate tile effects. Our first step is to 
	//see what tiles we will be affecting
	if( MoveContext.InputContext.MovementPaths[0].MovementTiles.Length > 0 )
	{		
		//If this move was uninterrupted, or we do not have a resume
		if( MoveContext.InterruptionStatus == eInterruptionStatus_None || MoveContext.ResumeHistoryIndex < 0 )
		{
			//Build the list of tiles that will be affected by the Acid and set it into our tile update game state object			
			for(TileIndex = 0; TileIndex < MoveContext.InputContext.MovementPaths[0].MovementTiles.Length; ++TileIndex)
			{
				MovementTile = MoveContext.InputContext.MovementPaths[0].MovementTiles[TileIndex];
				TargetLocation = WorldData.GetPositionFromTileCoordinates(MovementTile);				
				WorldData.CollectTilesInSphere( OutTiles, TargetLocation, AbilityRadius );
			}
		}
	}
	else
	{
		//This may occur during teleports, spawning, or other instaneous modes of travel
		UnitStateObject = XComGameState_Unit(History.GetGameStateForObjectID(MoveContext.InputContext.SourceObject.ObjectID));
		
		UnitStateObject.GetKeystoneVisibilityLocation(MovementTile);
		TargetLocation = WorldData.GetPositionFromTileCoordinates(MovementTile);		
		
		WorldData.CollectTilesInSphere( OutTiles, TargetLocation, AbilityRadius );
	}
		
	//If we will be adding Acid to any tiles, do the rest of the set up
	if( OutTiles.Length > 0 )
	{
		//Build the game state for the Acid trail update
		NewGameState = History.CreateNewGameState(true, class'XComGameStateContext_AreaDamage'.static.CreateXComGameStateContext());

		if( UnitStateObject == none )
		{
			//This may occur during teleports, spawning, or other instaneous modes of travel
			UnitStateObject = XComGameState_Unit(History.GetGameStateForObjectID(MoveContext.InputContext.SourceObject.ObjectID));
		}
		FireEffect = X2Effect_ApplyFireToWorld(class'Engine'.static.FindClassDefaultObject("X2Effect_ApplyFireToWorld"));
		class'X2Effect_ApplyFireToWorld'.static.SharedApplyFireToTiles('X2Effect_ApplyFireToWorld', FireEffect, NewGameState, OutTiles, UnitStateObject, 1);
	
		//Submit the new game state to the rules engine
		`GAMERULES.SubmitGameState(NewGameState);
	}

	return ELR_NoInterrupt;
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

	local RTCondition_VisibleToPlayer			PlayerVisibilityCondition;

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


	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

	// Target Conditions
	//
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	// can only target visible (to the player) enemies
	PlayerVisibilityCondition = new class'RTCondition_VisibleToPlayer';
	Template.AbilityTargetConditions.AddItem(PlayerVisibilityCondition); 

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
	TargetUnitPropertyCondition.ExcludeDead = false;
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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_psi_circle";
	
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

	MeldEffect = class'RTEffectBuilder'.static.RTCreateMeldEffect(1, true) ;
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
	local X2Effect_ImmediateMultiTargetAbilityActivation MultiActivateAbilityEffect;
	local X2Effect_ImmediateAbilityActivation ActivateAbilityEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTUnstableConduit');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_mindcontrol";
	
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Offensive;

	Template.ConcealmentRule = eConceal_Miss;		// unsure


	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	
	Condition = new class'X2Condition_UnitEffects';
	Condition.AddRequireEffect('RTEffect_Meld', 'AA_UnitNotMelded');
	Template.AbilityShooterConditions.AddItem(Condition);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = default.UnitUsedPsionicAbilityEvent;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	// Add dead eye to guarantee
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	// MultiTarget = new class'X2AbilityMultiTarget_AllAllies';
	// MultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	// Template.AbilityMultiTargetStyle = MultiTarget;

	// ActivateAbilityEffect = new class'X2Effect_ImmediateAbilityActivation';
	// ActivateAbilityEffect.AbilityName = 'RTUnstableConduitBurst';	
	// Template.AddTargetEffect(ActivateAbilityEffect);

	// MultiActivateAbilityEffect = new class'X2Effect_ImmediateMultiTargetAbilityActivation';
	// MultiActivateAbilityEffect.AbilityName = 'RTUnstableConduitBurst';
	//Template.AddMultiTargetEffect(MultiActivateAbilityEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!

	Template.AdditionalAbilities.AddItem('RTUnstableConduitIcon');
	Template.PostActivationEvents.AddItem('RTUnstableConduitActivation');
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
	local X2Condition_UnitEffects			Condition;
    local X2Effect_Knockback  KnockbackEffect;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Effect_Persistent				Effect;



    `CREATE_X2ABILITY_TEMPLATE(Template, 'RTUnstableConduitBurst');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snipershot"; //TODO: Change this
    Template.AbilitySourceName = 'eAbilitySource_Psionic';  
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Neutral;

	// Template.AbilityCosts.AddItem(default.FreeActionCost);
	Template.ConcealmentRule = eConceal_Always;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	// Template.AddShooterEffectExclusions();

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'RTUnstableConduitActivation';
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Condition = new class'X2Condition_UnitEffects';
	Condition.AddRequireEffect(class'RTEffectBuilder'.default.MeldEffectName, 'AA_UnitNotMelded');
	Template.AbilityShooterConditions.AddItem(Condition);

	MultiTarget = new class'X2AbilityMultiTarget_Radius';
	MultiTarget.fTargetRadius = default.BURST_RADIUS_METERS * class'XComWorldData'.const.WORLD_StepSize * class'XComWorldData'.const.WORLD_UNITS_TO_METERS_MULTIPLIER;
	MultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	MultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTarget;

	Effect = new class'X2Effect_Persistent';
	Effect.BuildPersistentEffect(0, false);
	Effect.VFXTemplateName = default.BurstParticleString;
	Template.AddShooterEffect(Effect);

    WorldDamage = new class'X2Effect_ApplyDirectionalWorldDamage';  //creates the framework to apply damage to the world
	WorldDamage.bUseWeaponDamageType = False;                       //overrides the normal weapon damage type
	WorldDamage.bUseWeaponEnvironmentalDamage = false;              //replaces the weapon's environmental damage with the abilities
	WorldDamage.EnvironmentalDamageAmount = 2500;                   //determines the amount of enviornmental damage the ability applies
	WorldDamage.bApplyOnHit = true;                                 //obv
	WorldDamage.bApplyOnMiss = true;                                //obv
	WorldDamage.bApplyToWorldOnHit = true;                          //obv
	WorldDamage.bApplyToWorldOnMiss = true;                         //obv
	WorldDamage.bHitAdjacentDestructibles = true;                   
	WorldDamage.PlusNumZTiles = 2;                                 //determines how 'high' the world damage is applied
	WorldDamage.bHitTargetTile = true;                              
	WorldDamage.ApplyChance = 100;
	WorldDamage.bAllowDestructionOfDamageCauseCover = true;
	Template.AddMultiTargetEffect(WorldDamage);                    

	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';   
	WeaponDamageEffect.bIgnoreBaseDamage = true;	
	WeaponDamageEffect.EffectDamageValue = default.BURST_DMG;			 
	WeaponDamageEffect.bApplyWorldEffectsForEachTargetLocation = true;
	WeaponDamageEffect.EnvironmentalDamageAmount = 250;        
	Template.AddMultiTargetEffect(WeaponDamageEffect);          

	Template.bSkipFireAction = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Psionic_FireAtUnit";

	Template.bShowActivation = true;

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
	local RTEffect_GhostInTheShell	Effect;
	local X2Effect_StayConcealed PhantomEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTGhostInTheShell');
    Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_ghostintheshell";	   // TODO: THIS
    Template.AbilitySourceName = 'eAbilitySource_Psionic';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
	
	// Apply perk at the start of the mission. 
    Template.AbilityToHitCalc = default.DeadEye; 
    Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

    // Effect to apply
    Effect = new class'RTEffect_GhostInTheShell';
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

	Template.AdditionalAbilities.AddItem('RTGhostInTheShellEffect');

	return Template;
}

//---------------------------------------------------------------------------------------
//---Ghost In The Shell Listener---------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTGhostInTheShellEffect()
{
	local X2AbilityTemplate		Template;
	local X2Effect_Persistent	Effect;
	local RTEffect_Stealth StealthEffect;
	local X2Effect_RangerStealth ConcealEffect;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTGhostInTheShellEffect');
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aim";	   // TODO: THIS
    Template.AbilitySourceName = 'eAbilitySource_Psionic';
    Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
    Template.Hostility = eHostility_Neutral;
	
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;

	ConcealEffect = new class'X2Effect_RangerStealth';
	ConcealEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	ConcealEffect.bRemoveWhenTargetConcealmentBroken = true;
	Template.AddTargetEffect(ConcealEffect);
	
	StealthEffect = class'RTEffectBuilder'.static.RTCreateStealthEffect(default.GITS_STEALTH_DURATION, false, 1.0f, eGameRule_PlayerTurnBegin, Template.AbilitySourceName);
	Template.AddTargetEffect(StealthEffect);
	
	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	// ability will be triggered through a custom event listener
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

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

//---------------------------------------------------------------------------------------
//---Shadow Strike-----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2DataTemplate RTShadowStrike()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown Cooldown;
	local X2AbilityTarget_Cursor CursorTarget;
	local X2AbilityMultiTarget_Radius RadiusMultiTarget;
	local X2AbilityTrigger_PlayerInput InputTrigger;
	local X2AbilityToHitCalc_StandardMelee StandardMelee;
	local RTEffect_BerserkerMeleeDamage     WeaponDamageEffect;
	local RTEffect_Acid						AcidEffect;
	local array<name>                       SkipExclusions;
	local X2Condition_AbilityProperty  		AcidCondition, SiphonCondition;
	local X2Condition_UnitProperty			TargetUnitPropertyCondition;
	local RTEffect_Siphon					SiphonEffect;
	local X2AbilityTarget_MovingMelee TargetStyle;
	local X2Condition_Visibility TargetVisibilityCondition;
	local X2Effect_AdditionalAnimSets AnimSets;
	local RTCondition_VisibleToPlayer PlayerVisibilityCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTShadowStrike');

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_codex_teleport";

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 5;
	Template.AbilityCooldown = Cooldown;

	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);

	StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
	Template.AbilityToHitCalc = StandardMelee;

	TargetStyle = new class'X2AbilityTarget_MovingMelee';
	TargetStyle.MovementRangeAdjustment = -9999;
	Template.AbilityTargetStyle = TargetStyle;
	Template.TargetingMethod =  class'RTTargetingMethod_TargetedMeleeTeleport';

	AnimSets = new class'X2Effect_AdditionalAnimSets';
	AnimSets.AddAnimSetWithPath("Advent_ANIM.Anims.AS_Advent");
	AnimSets.BuildPersistentEffect(1, false, false, false);
	AnimSets.EffectName = 'RTAdventAnimSet';
	Template.AddShooterEffect(AnimSets);
	
	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bAllowSquadsight = true;
	TargetVisibilityCondition.bVisibleToAnyAlly = true;
	//Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

	PlayerVisibilityCondition = new class'RTCondition_VisibleToPlayer';
	Template.AbilityTargetConditions.AddItem(PlayerVisibilityCondition); 

	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	// Shooter Conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

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
	TargetUnitPropertyCondition.ExcludeDead = false;
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
	//// Damage Effect
	Template.AbilityMultiTargetConditions.AddItem(default.LivingTargetUnitOnlyProperty);
	Template.PostActivationEvents.AddItem('RTRemoveAnimSets');
	Template.AdditionalAbilities.AddItem('RTRemoveAdditionalAnimSets');
	Template.PostActivationEvents.AddItem('RTBerserkerKnifeAttack');

	Template.ModifyNewContextFn = Teleport_ModifyActivatedAbilityContext;
	Template.BuildNewGameStateFn = Teleport_BuildGameState;
	Template.BuildVisualizationFn = Teleport_BuildVisualization;

	return Template;
}

static simulated function Teleport_ModifyActivatedAbilityContext(XComGameStateContext Context)
{
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameStateHistory History;
	local PathPoint NextPoint, EmptyPoint;
	local PathingInputData InputData;
	local XComWorldData World;
	local vector NewLocation;
	local TTile NewTileLocation;
	local array<TTile> PathTiles;

	History = `XCOMHISTORY;
	World = `XWORLD;
	
	AbilityContext = XComGameStateContext_Ability(Context);
	`assert(AbilityContext.InputContext.TargetLocations.Length > 0);
	
	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
	
	// Build the MovementData for the path
	// First posiiton is the current location
	InputData.MovementTiles.AddItem(UnitState.TileLocation);
	
	NextPoint.Position = World.GetPositionFromTileCoordinates(UnitState.TileLocation);
	NextPoint.Traversal = eTraversal_Teleport;
	//NextPoint.Traversal = eTraversal_Phasing;
	
	NextPoint.PathTileIndex = 0;
	InputData.MovementData.AddItem(NextPoint);
	
	// Second posiiton is the cursor position
	`assert(AbilityContext.InputContext.TargetLocations.Length == 1);
  	`PRES.GetTacticalHUD().GetTargetingMethod().GetPreAbilityPath(PathTiles);
	NewTileLocation = PathTiles[PathTiles.Length - 1];
	
	NewLocation = World.FindClosestValidLocation(World.GetPositionFromTileCoordinates(NewTileLocation), false, true, false);


	NextPoint = EmptyPoint;
	NextPoint.Position = NewLocation;
	NextPoint.Traversal = eTraversal_Landing;
	NextPoint.PathTileIndex = 1;
	InputData.MovementData.AddItem(NextPoint);
	InputData.MovementTiles.AddItem(NewTileLocation);
	
    //Now add the path to the input context
	InputData.MovingUnitRef = UnitState.GetReference();
	AbilityContext.InputContext.MovementPaths.Length = 0;
	AbilityContext.InputContext.MovementPaths[0] = InputData;
}

static simulated function XComGameState Teleport_BuildGameState(XComGameStateContext Context)
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability AbilityContext;
	local vector NewLocation;
	local TTile NewTileLocation;
	local XComWorldData World;
	local X2EventManager EventManager;
	local int LastElementIndex;

	World = `XWORLD;
	EventManager = `XEVENTMGR;

	//Build the new game state frame
	NewGameState = TypicalAbility_BuildGameState(Context);

	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());	
	UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', AbilityContext.InputContext.SourceObject.ObjectID));

	LastElementIndex = AbilityContext.InputContext.MovementPaths[0].MovementData.Length - 1;

	// Set the unit's new location
	// The last position in MovementData will be the end location
	`assert(LastElementIndex > 0);
	NewLocation = AbilityContext.InputContext.MovementPaths[0].MovementData[LastElementIndex].Position;
	NewTileLocation = World.GetTileCoordinatesFromPosition(NewLocation);
	UnitState.SetVisibilityLocation(NewTileLocation);

	NewGameState.AddStateObject(UnitState);

	AbilityContext.ResultContext.bPathCausesDestruction = false;//MoveAbility_StepCausesDestruction(UnitState, AbilityContext.InputContext, 0, AbilityContext.InputContext.MovementPaths[0].MovementTiles.Length - 1);
	MoveAbility_AddTileStateObjects(NewGameState, UnitState, AbilityContext.InputContext, 0, AbilityContext.InputContext.MovementPaths[0].MovementTiles.Length - 1);

	EventManager.TriggerEvent('ObjectMoved', UnitState, UnitState, NewGameState);
	EventManager.TriggerEvent('UnitMoveFinished', UnitState, UnitState, NewGameState);

	//Return the game state we have created
	return NewGameState;
}

simulated function Teleport_BuildVisualization(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{
	local X2AbilityTemplate						AbilityTemplate;
	local XComGameStateContext_Ability			Context;
	local AbilityInputContext					AbilityContext;
	local StateObjectReference					ShootingUnitRef;	
	local X2Action								AddedAction;
	local XComGameState_BaseObject				TargetStateObject;//Container for state objects within VisualizeGameState	
	local XComGameState_Item					SourceWeapon;
	local X2GrenadeTemplate						GrenadeTemplate;
	local X2AmmoTemplate						AmmoTemplate;
	local X2WeaponTemplate						WeaponTemplate;
	local array<X2Effect>						MultiTargetEffects;
	local bool									bSourceIsAlsoTarget;
	local Actor									TargetVisualizer, ShooterVisualizer;
	local X2VisualizerInterface					TargetVisualizerInterface, ShooterVisualizerInterface;
	local int									EffectIndex;
	local XComGameState_EnvironmentDamage		EnvironmentDamageEvent;
	local XComGameState_WorldEffectTileData		WorldDataUpdate;
	local VisualizationTrack					EmptyTrack;
	local VisualizationTrack					BuildTrack;
	local VisualizationTrack					SourceTrack, InterruptTrack;
	local int									TrackIndex;
	local XComGameStateHistory					History;
	local X2Action_MoveTurn						MoveTurnAction;
	local XComGameStateContext_Ability			CounterAttackContext;
	local X2AbilityTemplate						CounterattackTemplate;
	local array<VisualizationTrack>				OutCounterattackVisualizationTracks;
	local int									ActionIndex;
	local X2Action_PlaySoundAndFlyOver			SoundAndFlyover;
	local name									ApplyResult;
	local XComGameState_InteractiveObject		InteractiveObject;
	local XComGameState_Ability					AbilityState;
	local bool									bInterruptPath;
	local X2Action_ExitCover					ExitCoverAction;
	local XComGameState_Unit					SourceUnitState;
	local UnitValue								SilentMelee;
			
	History = `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityContext = Context.InputContext;
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.AbilityRef.ObjectID));
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.AbilityTemplateName);
	ShootingUnitRef = Context.InputContext.SourceObject;
	SourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ShootingUnitRef.ObjectID));
	bInterruptPath = false;

	//Configure the visualization track for the shooter, part I. We split this into two parts since
	//in some situations the shooter can also be a target
	//****************************************************************************************
	ShooterVisualizer = History.GetVisualizer(ShootingUnitRef.ObjectID);
	ShooterVisualizerInterface = X2VisualizerInterface(ShooterVisualizer);

	SourceTrack = EmptyTrack;
	SourceTrack.StateObject_OldState = History.GetGameStateForObjectID(ShootingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	SourceTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(ShootingUnitRef.ObjectID);
	if (SourceTrack.StateObject_NewState == none)
		SourceTrack.StateObject_NewState = SourceTrack.StateObject_OldState;
	SourceTrack.TrackActor = ShooterVisualizer;

	SourceTrack.AbilityName = AbilityTemplate.DataName;

	SourceWeapon = XComGameState_Item(History.GetGameStateForObjectID(AbilityContext.ItemObject.ObjectID));
	if (SourceWeapon != None)
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		AmmoTemplate = X2AmmoTemplate(SourceWeapon.GetLoadedAmmoTemplate(AbilityState));
	}
	if(AbilityTemplate.bShowPostActivation)
	{
		//Show the text flyover at the end of the visualization after the camera pans back
		Context.PostBuildVisualizationFn.AddItem(ActivationFlyOver_PostBuildVisualization);
	}
	if (AbilityTemplate.bShowActivation || AbilityTemplate.ActivationSpeech != '')
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTrack(SourceTrack, Context));

		if (SourceWeapon != None)
		{
			GrenadeTemplate = X2GrenadeTemplate(SourceWeapon.GetMyTemplate());
		}

		if (GrenadeTemplate != none)
		{
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", GrenadeTemplate.OnThrowBarkSoundCue, eColor_Good);
		}
		else
		{
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.bShowActivation ? AbilityTemplate.LocFriendlyName : "", AbilityTemplate.ActivationSpeech, eColor_Good, AbilityTemplate.bShowActivation ? AbilityTemplate.IconImage : "");
		}
	}

	if( Context.IsResultContextMiss() && AbilityTemplate.SourceMissSpeech != '' )
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTrack(BuildTrack, Context));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", AbilityTemplate.SourceMissSpeech, eColor_Bad);
	}
	else if( Context.IsResultContextHit() && AbilityTemplate.SourceHitSpeech != '' )
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTrack(BuildTrack, Context));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", AbilityTemplate.SourceHitSpeech, eColor_Good);
	}

	if( !AbilityTemplate.bSkipFireAction || Context.InputContext.MovementPaths.Length > 0 )
	{

		ExitCoverAction = X2Action_ExitCover(class'X2Action_ExitCover'.static.AddToVisualizationTrack(SourceTrack, Context));
		ExitCoverAction.bSkipExitCoverVisualization = AbilityTemplate.bSkipExitCoverWhenFiring;

		// move action
		class'X2VisualizerHelpers'.static.ParsePath(Context, SourceTrack, OutVisualizationTracks, AbilityTemplate.bSkipMoveStop);
		
		// if this ability has a built in move, do it right before we do the fire action
		if(Context.InputContext.MovementPaths.Length > 0)
		{

			if( !AbilityTemplate.bSkipFireAction )
			{
				// add our fire action
				AddedAction = AbilityTemplate.ActionFireClass.static.AddToVisualizationTrack(SourceTrack, Context);
			}
			
			if (!bInterruptPath)
			{
				// swap the fire action for the end move action, so that we trigger it just before the end. This sequences any moving fire action
				// correctly so that it blends nicely before the move end.
				for (TrackIndex = 0; TrackIndex < SourceTrack.TrackActions.Length; ++TrackIndex)
				{
					if (X2Action_MoveEnd(SourceTrack.TrackActions[TrackIndex]) != none)
					{
						break;
					}
				}
				if(TrackIndex >= SourceTrack.TrackActions.Length)
				{
					`Redscreen("X2Action_MoveEnd not found when building Typical Ability path. @gameplay @dburchanowski @jbouscher");
				}
				else
				{
					SourceTrack.TrackActions[TrackIndex + 1] = SourceTrack.TrackActions[TrackIndex];
					SourceTrack.TrackActions[TrackIndex] = AddedAction;
				}
			}
			//else
			//{
			//	//  prompt the target to play their hit reacts after the attack
			//	InterruptMsg = X2Action_SendInterTrackMessage(class'X2Action_SendInterTrackMessage'.static.AddToVisualizationTrack(SourceTrack, Context));
			//	InterruptMsg.SendTrackMessageToRef = InterruptContext.InputContext.SourceObject;
			//}
		}
		else if( !AbilityTemplate.bSkipFireAction )
		{
			// no move, just add the fire action
			AddedAction = AbilityTemplate.ActionFireClass.static.AddToVisualizationTrack(SourceTrack, Context);
		}

		if( !AbilityTemplate.bSkipFireAction )
		{
			if( AbilityTemplate.AbilityToHitCalc != None )
			{
				X2Action_Fire(AddedAction).SetFireParameters(Context.IsResultContextHit());
			}

			//Process a potential counter attack from the target here
			if( Context.ResultContext.HitResult == eHit_CounterAttack )
			{
				CounterAttackContext = class'X2Ability'.static.FindCounterAttackGameState(Context, XComGameState_Unit(SourceTrack.StateObject_OldState));
				if( CounterAttackContext != none )
				{
					//Entering this code block means that we were the target of a counter attack to our original attack. Here, we look forward in the history
					//and append the necessary visualization tracks so that the counter attack can happen visually as part of our original attack.

					//Get the ability template for the counter attack against us
					CounterattackTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(CounterAttackContext.InputContext.AbilityTemplateName);
					CounterattackTemplate.BuildVisualizationFn(CounterAttackContext.AssociatedState, OutCounterattackVisualizationTracks);

					//Take the visualization actions from the counter attack game state ( where we are the target )
					for( TrackIndex = 0; TrackIndex < OutCounterattackVisualizationTracks.Length; ++TrackIndex )
					{
						if( OutCounterattackVisualizationTracks[TrackIndex].StateObject_OldState.ObjectID == SourceTrack.StateObject_OldState.ObjectID )
						{
							for( ActionIndex = 0; ActionIndex < OutCounterattackVisualizationTracks[TrackIndex].TrackActions.Length; ++ActionIndex )
							{
								//Don't include waits
								if( !OutCounterattackVisualizationTracks[TrackIndex].TrackActions[ActionIndex].IsA('X2Action_WaitForAbilityEffect') )
								{
									SourceTrack.TrackActions.AddItem(OutCounterattackVisualizationTracks[TrackIndex].TrackActions[ActionIndex]);
								}
							}
							break;
						}
					}

					//Notify the visualization mgr that the counter attack visualization is taken care of, so it can be skipped
					`XCOMVISUALIZATIONMGR.SkipVisualization(CounterAttackContext.AssociatedState.HistoryIndex);
				}
			}
		}
	}

	//If there are effects added to the shooter, add the visualizer actions for them
	for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
	{
		AbilityTemplate.AbilityShooterEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, SourceTrack, Context.FindShooterEffectApplyResult(AbilityTemplate.AbilityShooterEffects[EffectIndex]));		
	}
	//****************************************************************************************

	//Configure the visualization track for the target(s). This functionality uses the context primarily
	//since the game state may not include state objects for misses.
	//****************************************************************************************	
	bSourceIsAlsoTarget = AbilityContext.PrimaryTarget.ObjectID == AbilityContext.SourceObject.ObjectID; //The shooter is the primary target
	if (AbilityTemplate.AbilityTargetEffects.Length > 0 &&			//There are effects to apply
		AbilityContext.PrimaryTarget.ObjectID > 0)				//There is a primary target
	{
		TargetVisualizer = History.GetVisualizer(AbilityContext.PrimaryTarget.ObjectID);
		TargetVisualizerInterface = X2VisualizerInterface(TargetVisualizer);

		if( bSourceIsAlsoTarget )
		{
			BuildTrack = SourceTrack;
		}
		else
		{
			BuildTrack = InterruptTrack;        //  interrupt track will either be empty or filled out correctly
		}

		BuildTrack.TrackActor = TargetVisualizer;

		TargetStateObject = VisualizeGameState.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
		if( TargetStateObject != none )
		{
			History.GetCurrentAndPreviousGameStatesForObjectID(AbilityContext.PrimaryTarget.ObjectID, 
															   BuildTrack.StateObject_OldState, BuildTrack.StateObject_NewState,
															   eReturnType_Reference,
															   VisualizeGameState.HistoryIndex);
			`assert(BuildTrack.StateObject_NewState == TargetStateObject);
		}
		else
		{
			//If TargetStateObject is none, it means that the visualize game state does not contain an entry for the primary target. Use the history version
			//and show no change.
			BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
			BuildTrack.StateObject_NewState = BuildTrack.StateObject_OldState;
		}

		// if this is a melee attack, make sure the target is facing the location he will be melee'd from
		if(!AbilityTemplate.bSkipFireAction 
			&& !bSourceIsAlsoTarget 
			&& AbilityContext.MovementPaths.Length > 0
			&& AbilityContext.MovementPaths[0].MovementData.Length > 0
			&& XGUnit(TargetVisualizer) != none)
		{
			MoveTurnAction = X2Action_MoveTurn(class'X2Action_MoveTurn'.static.AddToVisualizationTrack(BuildTrack, Context));
			MoveTurnAction.m_vFacePoint = AbilityContext.MovementPaths[0].MovementData[AbilityContext.MovementPaths[0].MovementData.Length - 1].Position;
			MoveTurnAction.m_vFacePoint.Z = TargetVisualizerInterface.GetTargetingFocusLocation().Z;
			MoveTurnAction.UpdateAimTarget = true;
		}

		//Make the target wait until signaled by the shooter that the projectiles are hitting
		if (!AbilityTemplate.bSkipFireAction && !bSourceIsAlsoTarget)
		{
			class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTrack(BuildTrack, Context);
		}
		
		//Add any X2Actions that are specific to this effect being applied. These actions would typically be instantaneous, showing UI world messages
		//playing any effect specific audio, starting effect specific effects, etc. However, they can also potentially perform animations on the 
		//track actor, so the design of effect actions must consider how they will look/play in sequence with other effects.
		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
		{
			ApplyResult = Context.FindTargetEffectApplyResult(AbilityTemplate.AbilityTargetEffects[EffectIndex]);

			// Target effect visualization
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, ApplyResult);

			// Source effect visualization
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceTrack, ApplyResult);
		}

		//the following is used to handle Rupture flyover text
		if (XComGameState_Unit(BuildTrack.StateObject_OldState).GetRupturedValue() == 0 &&
			XComGameState_Unit(BuildTrack.StateObject_NewState).GetRupturedValue() > 0)
		{
			//this is the frame that we realized we've been ruptured!
			class 'X2StatusEffects'.static.RuptureVisualization(VisualizeGameState, BuildTrack);
		}

		if (AbilityTemplate.bAllowAmmoEffects && AmmoTemplate != None)
		{
			for (EffectIndex = 0; EffectIndex < AmmoTemplate.TargetEffects.Length; ++EffectIndex)
			{
				ApplyResult = Context.FindTargetEffectApplyResult(AmmoTemplate.TargetEffects[EffectIndex]);
				AmmoTemplate.TargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, ApplyResult);
				AmmoTemplate.TargetEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceTrack, ApplyResult);
			}
		}
		if (AbilityTemplate.bAllowBonusWeaponEffects && WeaponTemplate != none)
		{
			for (EffectIndex = 0; EffectIndex < WeaponTemplate.BonusWeaponEffects.Length; ++EffectIndex)
			{
				ApplyResult = Context.FindTargetEffectApplyResult(WeaponTemplate.BonusWeaponEffects[EffectIndex]);
				WeaponTemplate.BonusWeaponEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, ApplyResult);
				WeaponTemplate.BonusWeaponEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceTrack, ApplyResult);
			}
		}

		if (Context.IsResultContextMiss() && (AbilityTemplate.LocMissMessage != "" || AbilityTemplate.TargetMissSpeech != ''))
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTrack(BuildTrack, Context));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocMissMessage, AbilityTemplate.TargetMissSpeech, eColor_Bad);
		}
		else if( Context.IsResultContextHit() && (AbilityTemplate.LocHitMessage != "" || AbilityTemplate.TargetHitSpeech != '') )
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTrack(BuildTrack, Context));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocHitMessage, AbilityTemplate.TargetHitSpeech, eColor_Good);
		}

		if( TargetVisualizerInterface != none )
		{
			//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
			TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, BuildTrack);
		}

		if (!bSourceIsAlsoTarget && BuildTrack.TrackActions.Length > 0)
		{
			OutVisualizationTracks.AddItem(BuildTrack);
		}

		if( bSourceIsAlsoTarget )
		{
			SourceTrack = BuildTrack;
		}
	}

	//Finish adding the shooter's track
	//****************************************************************************************
	if( !bSourceIsAlsoTarget && ShooterVisualizerInterface != none)
	{
		ShooterVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, SourceTrack);				
	}	

	if (!AbilityTemplate.bSkipFireAction)
	{
		if (!AbilityTemplate.bSkipExitCoverWhenFiring)
		{
			class'X2Action_EnterCover'.static.AddToVisualizationTrack(SourceTrack, Context);
		}
		
		
	}	

	OutVisualizationTracks.AddItem(SourceTrack);

	//  Handle redirect visualization
	TypicalAbility_AddEffectRedirects(VisualizeGameState, OutVisualizationTracks, SourceTrack);

	//****************************************************************************************

	//Configure the visualization tracks for the environment
	//****************************************************************************************
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_EnvironmentDamage', EnvironmentDamageEvent)
	{
		BuildTrack = EmptyTrack;
		BuildTrack.TrackActor = none;
		BuildTrack.StateObject_NewState = EnvironmentDamageEvent;
		BuildTrack.StateObject_OldState = EnvironmentDamageEvent;

		//Wait until signaled by the shooter that the projectiles are hitting
		if (!AbilityTemplate.bSkipFireAction)
			class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTrack(BuildTrack, Context);

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityShooterEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, 'AA_Success');		
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, 'AA_Success');
		}

		for (EffectIndex = 0; EffectIndex < MultiTargetEffects.Length; ++EffectIndex)
		{
			MultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, 'AA_Success');	
		}

		OutVisualizationTracks.AddItem(BuildTrack);
	}

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_WorldEffectTileData', WorldDataUpdate)
	{
		BuildTrack = EmptyTrack;
		BuildTrack.TrackActor = none;
		BuildTrack.StateObject_NewState = WorldDataUpdate;
		BuildTrack.StateObject_OldState = WorldDataUpdate;

		//Wait until signaled by the shooter that the projectiles are hitting
		if (!AbilityTemplate.bSkipFireAction)
			class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTrack(BuildTrack, Context);

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityShooterEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, 'AA_Success');		
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, 'AA_Success');
		}

		for (EffectIndex = 0; EffectIndex < MultiTargetEffects.Length; ++EffectIndex)
		{
			MultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, 'AA_Success');	
		}

		OutVisualizationTracks.AddItem(BuildTrack);
	}
	//****************************************************************************************

	//Process any interactions with interactive objects
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_InteractiveObject', InteractiveObject)
	{
		// Add any doors that need to listen for notification
		if (InteractiveObject.IsDoor() && InteractiveObject.HasDestroyAnim()) //Is this a closed door?
		{
			BuildTrack = EmptyTrack;
			//Don't necessarily have a previous state, so just use the one we know about
			BuildTrack.StateObject_OldState = InteractiveObject;
			BuildTrack.StateObject_NewState = InteractiveObject;
			BuildTrack.TrackActor = History.GetVisualizer(InteractiveObject.ObjectID);

			if (!AbilityTemplate.bSkipFireAction)
				class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTrack(BuildTrack, Context);

			class'X2Action_BreakInteractActor'.static.AddToVisualizationTrack(BuildTrack, Context);

			OutVisualizationTracks.AddItem(BuildTrack);
		}
	}
}

//---------------------------------------------------------------------------------------
//---Dashing Strike----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2DataTemplate RTDashingStrike()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown Cooldown;

	local X2AbilityTarget_Cursor CursorTarget;
	local X2AbilityMultiTarget_Cone ConeMultiTarget;
	local X2AbilityTrigger_PlayerInput InputTrigger;


	local X2AbilityToHitCalc_StandardMelee StandardMelee;
	local RTEffect_BerserkerMeleeDamage     WeaponDamageEffect;
	local RTEffect_Acid						AcidEffect;
	local array<name>                       SkipExclusions;
	local X2Condition_AbilityProperty  		AcidCondition, SiphonCondition;
	local X2Condition_UnitProperty			TargetUnitPropertyCondition;
	local RTEffect_Siphon					SiphonEffect;

	local X2Condition_Visibility TargetVisibilityCondition;
	local X2Effect_AdditionalAnimSets AnimSets;

	`CREATE_X2TEMPLATE(class'RTAbilityTemplate', Template, 'RTDashingStrike');
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_codex_teleport";

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 0;
	Template.AbilityCooldown = Cooldown;

	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);

	StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
	Template.AbilityToHitCalc = StandardMelee;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = 5 * class'XComWorldData'.const.WORLD_StepSize;
	Template.AbilityTargetStyle = CursorTarget;

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.ConeEndDiameter = 1 * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.ConeLength = 5 * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.bUseWeaponRangeForLength = false;
	ConeMultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	ConeMultiTarget.fTargetRadius = 99;
	Template.AbilityMultiTargetStyle = ConeMultiTarget;

	Template.TargetingMethod = class'RTTargetingMethod_Cone';
	// Template.bUseSourceLocationZToAim = true;

	AnimSets = new class'X2Effect_AdditionalAnimSets';
	AnimSets.AddAnimSetWithPath("Advent_ANIM.Anims.AS_Advent");	   // temp
	AnimSets.BuildPersistentEffect(1, false, false, false);
	AnimSets.EffectName = 'RTAdventAnimSet';
	// Template.AddShooterEffect(AnimSets);

	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	// Shooter Conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	// Damage Effect
	//		var int iBaseBladeDamage, iBaseBladeCritDamage, iBaseBladeDamageSpread, iAcidicBladeShred;var float fHiddenBladeCritModifier;
	WeaponDamageEffect = new class'RTEffect_BerserkerMeleeDamage';	 
	WeaponDamageEffect.iBaseBladeDamage = default.BLADE_DAMAGE;
	WeaponDamageEffect.iBaseBladeCritDamage = default.BLADE_CRIT_DAMAGE;
	WeaponDamageEffect.iBaseBladeDamageSpread = default.BLADE_DAMAGE_SPREAD;
	WeaponDamageEffect.iAcidicBladeShred = default.ACID_BLADE_SHRED;
	WeaponDamageEffect.fHiddenBladeCritModifier = default.HIDDEN_BLADE_CRIT_MODIFIER;
	WeaponDamageEffect.bIgnoreBaseDamage = true;
	Template.AddMultiTargetEffect(WeaponDamageEffect);

	// Acid Effect
	AcidEffect = class'RTEffect_Acid'.static.CreateAcidBurningStatusEffect('RTAcid', 4);
	AcidEffect.SetAcidDamage(default.ACID_BLADE_DOT_DAMAGE, 0, default.ACID_BLADE_DOT_SHRED, 'RTAcid');

	AcidCondition = new class'X2Condition_AbilityProperty';
	AcidCondition.OwnerHasSoldierAbilities.AddItem('RTAcidicBlade');
	AcidEffect.TargetConditions.AddItem(AcidCondition);
	Template.AddMultiTargetEffect(AcidEffect);

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
	Template.AddMultiTargetEffect(SiphonEffect);

	Template.bAllowBonusWeaponEffects = true;
	//// Damage Effect
	Template.AbilityMultiTargetConditions.AddItem(default.LivingTargetUnitOnlyProperty);

	Template.ModifyNewContextFn = Teleport_ModifyActivatedAbilityContext;
	Template.BuildNewGameStateFn = Teleport_BuildGameState;
	//Template.BuildVisualizationFn = Teleport_BuildVisualization;

	//Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
			  
	return Template;
}
