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
	var config WeaponDamageValue PSILANCE_DMG;
	var config int PSIONIC_LANCE_COOLDOWN;
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
	var config int GITS_STEALTH_DURATION;
	var config int CCS_AMMO_PER_SHOT;
	var config int SHADOWSTRIKE_COOLDOWN;
	var config string PurgeParticleString;

	var config array<name> AbilityPerksToLoad;

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
	Templates.AddItem(PurePassive('RTAcidicBlade', "img:///RisingTidesContentPackage.PerkIcons.UIPerk_stim_knife", false, 'eAbilitySource_Perk'));
	Templates.AddItem(PurePassive('RTPsionicBlade', "img:///RisingTidesContentPackage.PerkIcons.UIPerk_psi_knife", false, 'eAbilitySource_Psionic'));
	Templates.AddItem(PurePassive('RTHiddenBlade', "img:///RisingTidesContentPackage.PerkIcons.UIPerk_stealth_knife", false, 'eAbilitySource_Perk'));
	Templates.AddItem(PurePassive('RTSiphon', "img:///RisingTidesContentPackage.PerkIcons.UIPerk_medkit_knife_siphon", false, 'eAbilitySource_Psionic'));			  // icon
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
	Templates.AddItem(RTPsionicLance());
	Templates.AddItem(RTCloseCombatSpecialist());
	Templates.AddItem(RTCloseCombatSpecialistAttack()); 


	return Templates;
}

//---------------------------------------------------------------------------------------
//---Bump in the Night-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate BumpInTheNight()
{
	local X2AbilityTemplate                 Template;
	local RTEffect_BumpInTheNight			BumpEffect;
	local X2Effect_AdditionalAnimSets		AnimSets;
	local RTEffect_LoadPerks				LoadPerks;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'BumpInTheNight');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_knife_blossom_bitn";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
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

	AnimSets = new class'X2Effect_AdditionalAnimSets';
	AnimSets.AddAnimSetWithPath("RisingTidesContentPackage.Anims.AS_Queen");
	AnimSets.BuildPersistentEffect(1, true, false, false);
	AnimSets.EffectName = 'RTQueenAnimSet';
	Template.AddShooterEffect(AnimSets);

	LoadPerks = new class'RTEffect_LoadPerks';
	LoadPerks.AbilitiesToLoad = default.AbilityPerksToLoad;
	Template.AddShooterEffect(LoadPerks);

	// standard ghost abilities
	Template.AdditionalAbilities.AddItem('GhostPsiSuite');
	Template.AdditionalAbilities.AddItem('JoinMeld');
	Template.AdditionalAbilities.AddItem('LeaveMeld');
	Template.AdditionalAbilities.AddItem('PsiOverload');
	Template.AdditionalAbilities.AddItem('RTFeedback');
	Template.AdditionalAbilities.AddItem('RTMindControl');
	Template.AdditionalAbilities.AddItem('RTEnterStealth');

	// unique abilities for Bump In The Night
	Template.AdditionalAbilities.AddItem('BumpInTheNightBloodlustListener');
	Template.AdditionalAbilities.AddItem('BumpInTheNightStealthListener');
	Template.AdditionalAbilities.AddItem('StandardGhostShot');

	// special meld abilities
	Template.AdditionalAbilities.AddItem('LIOverwatchShot');
	Template.AdditionalAbilities.AddItem('RTUnstableConduitBurst');
	Template.AdditionalAbilities.AddItem('PsionicActivate');
	Template.AdditionalAbilities.AddItem('RTHarbingerPsionicLance');

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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_knife_adrenaline_bloodlust"; // TODO: Change this
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
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

	Template.PostActivationEvents.AddItem('RTBumpInTheNightStatCheck');

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
	//local array<name>                       SkipExclusions;
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
	// local X2Effect_Knockback						KnockbackEffect;
	// local X2Effect_Persistent						Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTBurst');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash"; //TODO: Change this
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
	WorldDamage.bHitTargetTile = false;
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

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.CustomFireAnim = 'HL_Psi_SelfCast';
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = Burst_BuildVisualization;
	Template.CinescriptCameraType = "Psionic_FireAtUnit";

	Template.bCrossClassEligible = false;

	return Template;
}


simulated function Burst_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;
	local X2VisualizerInterface Visualizer;
	local VisualizationActionMetadata ActionMetadata, EnvActionMetadata, EmptyActionMetadata, BuildData, InitData, EmptyTrack;
	//local X2Action_PlayEffect EffectAction;
	//local X2Action_StartStopSound SoundAction;
	local XComGameState_Unit AvatarUnit;
	//local XComWorldData World;
	//local vector TargetLocation;
	//local TTile TargetTile;
	local X2Action_TimedWait WaitAction;
	//local X2Action_PlaySoundAndFlyOver SoundCueAction;
	local int i, j, EffectIndex;
	local X2VisualizerInterface TargetVisualizerInterface;
	local XComGameState_EnvironmentDamage EnvironmentDamageEvent;
	local XComGameState_WorldEffectTileData WorldDataUpdate;
	local XComGameState_InteractiveObject  InteractiveObject;
	local X2AbilityTemplate AbilityTemplate;
	local AbilityInputContext AbilityContext;
	local array<X2Effect>               MultiTargetEffects;
	local X2Action_PlayEffect EffectAction;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityContext = Context.InputContext;

	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.AbilityTemplateName);
	MultiTargetEffects = AbilityTemplate.AbilityMultiTargetEffects;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	InteractingUnitRef = Context.InputContext.SourceObject;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);
	
	AvatarUnit = XComGameState_Unit(ActionMetadata.StateObject_NewState);

	if( AvatarUnit != none )
	{
		

		if (Context.InterruptionStatus != eInterruptionStatus_None)
		{
			//Insert markers for the subsequent interrupt to insert into
			class'X2Action'.static.AddInterruptMarkerPair(ActionMetadata, Context, WaitAction);
		}

		class'X2Action_Fire_OpenUnfinishedAnim'.static.AddToVisualizationTree(ActionMetadata, Context);

		// Wait to time the start of the warning FX
		WaitAction = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(ActionMetadata, Context));
		WaitAction.DelayTimeSec = 4;

		EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(ActionMetadata, Context));
		EffectAction.EffectName = default.BurstParticleString;
		EffectAction.EffectLocation = `XWORLD.GetPositionFromTileCoordinates(AvatarUnit.TileLocation);

		// Play Target audio
		//SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTrack(AvatarBuildTrack, Context));
		//SoundAction.Sound = new class'SoundCue';
		//SoundAction.Sound.AkEventOverride = AkEvent'SoundX2AvatarFX.Avatar_Ability_Dimensional_Rift_Target_Activate';
		//SoundAction.iAssociatedGameStateObjectId = AvatarUnit.ObjectID;
		//SoundAction.bStartPersistentSound = false;
		//SoundAction.bIsPositional = true;
		//SoundAction.vWorldPosition = World.GetPositionFromTileCoordinates(AvatarUnit.TileLocation);

		class'X2Action_Fire_CloseUnfinishedAnim'.static.AddToVisualizationTree(ActionMetadata, Context);

		Visualizer = X2VisualizerInterface(ActionMetadata.VisualizeActor);
		if( Visualizer != none )
		{
			Visualizer.BuildAbilityEffectsVisualization(VisualizeGameState, ActionMetadata);
		}

	}
	//****************************************************************************************

	//****************************************************************************************
	//Configure the visualization track for the targets
	//****************************************************************************************
	for (i = 0; i < Context.InputContext.MultiTargets.Length; ++i)
	{
		InteractingUnitRef = Context.InputContext.MultiTargets[i];

		if( InteractingUnitRef == AvatarUnit.GetReference() )
		{
			
		}
		else
		{
			ActionMetadata = EmptyTrack;
			ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
			ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
			ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);
		}

		for( j = 0; j < Context.ResultContext.MultiTargetEffectResults[i].Effects.Length; ++j )
		{
			Context.ResultContext.MultiTargetEffectResults[i].Effects[j].AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, Context.ResultContext.MultiTargetEffectResults[i].ApplyResults[j]);
		}

		TargetVisualizerInterface = X2VisualizerInterface(ActionMetadata.VisualizeActor);
		if( TargetVisualizerInterface != none )
		{
			//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
			TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, ActionMetadata);
		}
	}

	TypicalAbility_AddEffectRedirects(VisualizeGameState, ActionMetadata);

		//****************************************************************************************

	//Configure the visualization tracks for the environment
	//****************************************************************************************
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_EnvironmentDamage', EnvironmentDamageEvent)
	{
		EnvActionMetadata = EmptyActionMetadata;
		EnvActionMetadata.VisualizeActor = none;
		EnvActionMetadata.StateObject_NewState = EnvironmentDamageEvent;
		EnvActionMetadata.StateObject_OldState = EnvironmentDamageEvent;

		//Wait until signaled by the shooter that the projectiles are hitting
		if (!AbilityTemplate.bSkipFireAction) {
			WaitAction = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(EnvActionMetadata, VisualizeGameState.GetContext(), false, EnvActionMetadata.LastActionAdded));
			WaitAction.DelayTimeSec = 4;
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityShooterEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, EnvActionMetadata, 'AA_Success');		
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, EnvActionMetadata, 'AA_Success');
		}

		for (EffectIndex = 0; EffectIndex < MultiTargetEffects.Length; ++EffectIndex)
		{
			MultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, EnvActionMetadata, 'AA_Success');	
		}
	}

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_WorldEffectTileData', WorldDataUpdate)
	{
		EnvActionMetadata = EmptyActionMetadata;
		EnvActionMetadata.VisualizeActor = none;
		EnvActionMetadata.StateObject_NewState = WorldDataUpdate;
		EnvActionMetadata.StateObject_OldState = WorldDataUpdate;

		//Wait until signaled by the shooter that the projectiles are hitting
		if (!AbilityTemplate.bSkipFireAction) {
			WaitAction = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(EnvActionMetadata, VisualizeGameState.GetContext(), false, EnvActionMetadata.LastActionAdded));
			WaitAction.DelayTimeSec = 4;
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityShooterEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, EnvActionMetadata, 'AA_Success');		
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, EnvActionMetadata, 'AA_Success');
		}

		for (EffectIndex = 0; EffectIndex < MultiTargetEffects.Length; ++EffectIndex)
		{
			MultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, EnvActionMetadata, 'AA_Success');	
		}
	}
	//****************************************************************************************

	//Process any interactions with interactive objects
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_InteractiveObject', InteractiveObject)
	{
		// Add any doors that need to listen for notification. 
		// Move logic is taken from MoveAbility_BuildVisualization, which only has special case handling for AI patrol movement ( which wouldn't happen here )
		if ( Context.InputContext.MovementPaths.Length > 0 || (InteractiveObject.IsDoor() && InteractiveObject.HasDestroyAnim()) ) //Is this a closed door?
		{
			BuildData = InitData;
			//Don't necessarily have a previous state, so just use the one we know about
			BuildData.StateObject_OldState = InteractiveObject;
			BuildData.StateObject_NewState = InteractiveObject;
			BuildData.VisualizeActor = History.GetVisualizer(InteractiveObject.ObjectID);

			class'X2Action_BreakInteractActor'.static.AddToVisualizationTree(BuildData, Context);
		}
	}


}

//---------------------------------------------------------------------------------------
//---Blur--------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTBlur() {
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange BlurEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTBlur');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_snapshot";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
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
	local X2AbilityTemplate									Template;
	local X2Effect_RangerStealth							StealthEffect;
	local RTEffect_RemoveStacks								PurgeEffect;
	local RTCondition_EffectStackCount						BloodlustCondition;
	local X2Effect_Persistent 								VFXEffect;

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

	VFXEffect = new class'X2Effect_Persistent';
	VFXEffect.VFXTemplateName = default.PurgeParticleString;
	VFXEffect.BuildPersistentEffect(0, false);
	//Template.AddTargetEffect(VFXEffect);

	Template.CustomFireAnim = 'HL_Psi_SelfCast';

	PurgeEffect = new class'RTEffect_RemoveStacks';;
	PurgeEffect.EffectNameToPurge = class'RTEffect_Bloodlust'.default.EffectName;
	PurgeEffect.iStacksToRemove = default.PURGE_STACK_REQUIREMENT;
	Template.AddTargetEffect(PurgeEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Template.PostActivationEvents.AddItem('RTBumpInTheNightStatCheck');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

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
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash"; //TODO: Change this
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
	Template.CustomFireAnim = 'HL_Psi_ProjectileMedium';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

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
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_reaper";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

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
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_reaper";	   // TODO: THIS
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
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash";

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

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
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
static function EventListenerReturn BuildFireTrail_Self(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
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
		Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash";
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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_psi_x2_meld";

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
	local X2AbilityTrigger_EventListener	Trigger;

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
		Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash";
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
	local X2AbilityTemplate								Template;
	local X2AbilityMultiTarget_Radius					MultiTarget;
	local X2Effect_ApplyDirectionalWorldDamage			WorldDamage;
	local X2Effect_ApplyWeaponDamage					WeaponDamageEffect;
	local X2Condition_UnitEffects						Condition;
	local X2AbilityTrigger_EventListener				Trigger;
	local X2Effect_Persistent							Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTUnstableConduitBurst');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash"; //TODO: Change this
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Neutral;

	// Template.AbilityCosts.AddItem(default.FreeActionCost);
	Template.ConcealmentRule = eConceal_Always;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

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
	WorldDamage.bHitAdjacentDestructibles = false;
	WorldDamage.PlusNumZTiles = 2;                                 //determines how 'high' the world damage is applied
	WorldDamage.bHitTargetTile = true;
	WorldDamage.ApplyChance = 100;
	WorldDamage.bAllowDestructionOfDamageCauseCover = true;
	Template.AddMultiTargetEffect(WorldDamage);

	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.bIgnoreBaseDamage = true;
	WeaponDamageEffect.EffectDamageValue = default.BURST_DMG;
	WeaponDamageEffect.bApplyWorldEffectsForEachTargetLocation = true;
	WeaponDamageEffect.EnvironmentalDamageAmount = 2500;
	Template.AddMultiTargetEffect(WeaponDamageEffect);

	Template.bSkipFireAction = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
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
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_stealth_circle_pi";
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

simulated function Afterimage_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;
	local VisualizationActionMetadata BuildData, MimicData, InitData;
	local XComGameState_Unit MimicSourceUnit, SpawnedUnit;
	local UnitValue SpawnedUnitValue;
	local X2Action_PlayAnimation AnimationAction;
	local RTEffect_GenerateAfterimage AfterEffect;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	BuildData = InitData;
	BuildData.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	BuildData.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	BuildData.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	class'X2Action_ExitCover'.static.AddToVisualizationTree(BuildData, Context, false, BuildData.LastActionAdded);
	class'X2Action_EnterCover'.static.AddToVisualizationTree(BuildData, Context, false, BuildData.LastActionAdded);

	// Configure the visualization track for the mimic beacon
	//******************************************************************************************
	MimicSourceUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID));
	`assert(MimicSourceUnit != none);
	MimicSourceUnit.GetUnitValue(class'X2Effect_SpawnUnit'.default.SpawnedUnitValueName, SpawnedUnitValue);

	MimicData = InitData;
	MimicData.StateObject_OldState = History.GetGameStateForObjectID(SpawnedUnitValue.fValue, eReturnType_Reference, VisualizeGameState.HistoryIndex);
	MimicData.StateObject_NewState = MimicData.StateObject_OldState;
	SpawnedUnit = XComGameState_Unit(MimicData.StateObject_NewState);
	`assert(SpawnedUnit != none);
	MimicData.VisualizeActor = History.GetVisualizer(SpawnedUnit.ObjectID);

	// Only one target effect and it is X2Effect_SpawnMimicBeacon
	AfterEffect = RTEffect_GenerateAfterimage(Context.ResultContext.ShooterEffectResults.Effects[0]);

	if( AfterEffect == none )
	{
		`RedScreenOnce("Afterimage_BuildVisualization: Missing RTEffect_GenerateAfterimage -bp1 @gameplay");
		return;
	}

	AfterEffect.AddSpawnVisualizationsToTracks(Context, SpawnedUnit, MimicData, MimicSourceUnit, BuildData);

	class'X2Action_SyncVisualizer'.static.AddToVisualizationTree(MimicData, Context, false, MimicData.LastActionAdded);

	AnimationAction = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(MimicData, Context, false, MimicData.LastActionAdded));
	AnimationAction.Params.AnimName = 'LL_MimicStart';
	AnimationAction.Params.BlendTime = 0.0f;
}

static function X2AbilityTemplate RTPersistingImagesIcon() {
	local X2AbilityTemplate 	Template;
	local X2Effect_Persistent	Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTPersistingImagesIcon');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_stealth_circle_pi";
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
	local RTEffect_Stealth StealthEffect;
	local X2Effect_RangerStealth ConcealEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTGhostInTheShellEffect');
		Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash";	   // TODO: THIS
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

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTQueenOfBlades');
		Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash";	   // TODO: THIS
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
	local X2AbilityTrigger_PlayerInput InputTrigger;
	local X2AbilityToHitCalc_StandardMelee StandardMelee;
	local RTEffect_BerserkerMeleeDamage     WeaponDamageEffect;
	local RTEffect_Acid						AcidEffect;
	// local array<name>                       SkipExclusions;
	local X2Condition_AbilityProperty  		AcidCondition, SiphonCondition;
	local X2Condition_UnitProperty			TargetUnitPropertyCondition;
	local RTEffect_Siphon					SiphonEffect;
	local X2AbilityTarget_MovingMelee TargetStyle;
	local RTCondition_VisibleToPlayer PlayerVisibilityCondition;

	`CREATE_X2TEMPLATE(class'RTAbilityTemplate', Template, 'RTShadowStrike');

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_codex_teleport";

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.SHADOWSTRIKE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);

	StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
	Template.AbilityToHitCalc = StandardMelee;

	TargetStyle = new class'RTAbilityTarget_TeleportMelee';
	Template.AbilityTargetStyle = TargetStyle;
	Template.TargetingMethod =  class'RTTargetingMethod_TargetedMeleeTeleport';

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
	Template.PostActivationEvents.AddItem('RTBerserkerKnifeAttack');

	Template.ModifyNewContextFn = Teleport_ModifyActivatedAbilityContext;
	Template.BuildNewGameStateFn = Teleport_BuildGameState;
	Template.BuildVisualizationFn = Teleport_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;

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

simulated function Teleport_BuildVisualization(XComGameState VisualizeGameState)
{
	//general
	local XComGameStateHistory	History;
	local XComGameStateVisualizationMgr VisualizationMgr;

	//visualizers
	local Actor	TargetVisualizer, ShooterVisualizer;

	//actions
	local X2Action							AddedAction;
	local X2Action							FireAction;
	local X2Action_MoveTurn					MoveTurnAction;
	local X2Action_PlaySoundAndFlyOver		SoundAndFlyover;
	local X2Action_ExitCover				ExitCoverAction;
	local X2Action_MoveTeleport				TeleportMoveAction;
	local X2Action_Delay					MoveDelay;
	local X2Action_MoveEnd					MoveEnd;
	local X2Action_MarkerNamed				JoinActions;
	local array<X2Action>					LeafNodes;
	local X2Action_WaitForAnotherAction		WaitForFireAction;

	//state objects
	local XComGameState_Ability				AbilityState;
	local XComGameState_EnvironmentDamage	EnvironmentDamageEvent;
	local XComGameState_WorldEffectTileData WorldDataUpdate;
	local XComGameState_InteractiveObject	InteractiveObject;
	local XComGameState_BaseObject			TargetStateObject;
	local XComGameState_Item				SourceWeapon;
	local StateObjectReference				ShootingUnitRef;

	//interfaces
	local X2VisualizerInterface			TargetVisualizerInterface, ShooterVisualizerInterface;

	//contexts
	local XComGameStateContext_Ability	Context;
	local AbilityInputContext			AbilityContext;

	//templates
	local X2AbilityTemplate	AbilityTemplate;
	local X2AmmoTemplate	AmmoTemplate;
	local X2WeaponTemplate	WeaponTemplate;
	local array<X2Effect>	MultiTargetEffects;

	//Tree metadata
	local VisualizationActionMetadata   InitData;
	local VisualizationActionMetadata   BuildData;
	local VisualizationActionMetadata   SourceData, InterruptTrack;

	local XComGameState_Unit TargetUnitState;	
	local name         ApplyResult;

	//indices
	local int	EffectIndex, TargetIndex;
	local int	TrackIndex;
	local int	WindowBreakTouchIndex;

	//flags
	local bool	bSourceIsAlsoTarget;
	local bool	bMultiSourceIsAlsoTarget;
	local bool  bPlayedAttackResultNarrative;
			
	// good/bad determination
	local bool bGoodAbility;

	History = `XCOMHISTORY;
	VisualizationMgr = `XCOMVISUALIZATIONMGR;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityContext = Context.InputContext;
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.AbilityRef.ObjectID));
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.AbilityTemplateName);
	ShootingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter, part I. We split this into two parts since
	//in some situations the shooter can also be a target
	//****************************************************************************************
	ShooterVisualizer = History.GetVisualizer(ShootingUnitRef.ObjectID);
	ShooterVisualizerInterface = X2VisualizerInterface(ShooterVisualizer);

	SourceData = InitData;
	SourceData.StateObject_OldState = History.GetGameStateForObjectID(ShootingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	SourceData.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(ShootingUnitRef.ObjectID);
	if (SourceData.StateObject_NewState == none)
		SourceData.StateObject_NewState = SourceData.StateObject_OldState;
	SourceData.VisualizeActor = ShooterVisualizer;	

	SourceWeapon = XComGameState_Item(History.GetGameStateForObjectID(AbilityContext.ItemObject.ObjectID));
	if (SourceWeapon != None)
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		AmmoTemplate = X2AmmoTemplate(SourceWeapon.GetLoadedAmmoTemplate(AbilityState));
	}

	bGoodAbility = XComGameState_Unit(SourceData.StateObject_NewState).IsFriendlyToLocalPlayer();

	if( Context.IsResultContextMiss() && AbilityTemplate.SourceMissSpeech != '' )
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(BuildData, Context));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", AbilityTemplate.SourceMissSpeech, bGoodAbility ? eColor_Bad : eColor_Good);
	}
	else if( Context.IsResultContextHit() && AbilityTemplate.SourceHitSpeech != '' )
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(BuildData, Context));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", AbilityTemplate.SourceHitSpeech, bGoodAbility ? eColor_Good : eColor_Bad);
	}

	if( !AbilityTemplate.bSkipFireAction || Context.InputContext.MovementPaths.Length > 0 )
	{
		ExitCoverAction = X2Action_ExitCover(class'X2Action_ExitCover'.static.AddToVisualizationTree(SourceData, Context));
		ExitCoverAction.bSkipExitCoverVisualization = AbilityTemplate.bSkipExitCoverWhenFiring;

		// if this ability has a built in move, do it right before we do the fire action
		if(Context.InputContext.MovementPaths.Length > 0)
		{			
			// note that we skip the stop animation since we'll be doing our own stop with the end of move attack
			class'X2VisualizerHelpers'.static.ParsePath(Context, SourceData, AbilityTemplate.bSkipMoveStop);

			//  add paths for other units moving with us (e.g. gremlins moving with a move+attack ability)
			if (Context.InputContext.MovementPaths.Length > 1)
			{
				for (TrackIndex = 1; TrackIndex < Context.InputContext.MovementPaths.Length; ++TrackIndex)
				{
					BuildData = InitData;
					BuildData.StateObject_OldState = History.GetGameStateForObjectID(Context.InputContext.MovementPaths[TrackIndex].MovingUnitRef.ObjectID);
					BuildData.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(Context.InputContext.MovementPaths[TrackIndex].MovingUnitRef.ObjectID);
					MoveDelay = X2Action_Delay(class'X2Action_Delay'.static.AddToVisualizationTree(BuildData, Context));
					MoveDelay.Duration = class'X2Ability_DefaultAbilitySet'.default.TypicalMoveDelay;
					class'X2VisualizerHelpers'.static.ParsePath(Context, BuildData, AbilityTemplate.bSkipMoveStop);	
				}
			}

			if( !AbilityTemplate.bSkipFireAction )
			{
				MoveEnd = X2Action_MoveEnd(VisualizationMgr.GetNodeOfType(VisualizationMgr.BuildVisTree, class'X2Action_MoveEnd', SourceData.VisualizeActor));				

				if (MoveEnd != none)
				{
					// add the fire action as a child of the node immediately prior to the move end
					AddedAction = AbilityTemplate.ActionFireClass.static.AddToVisualizationTree(SourceData, Context, false, none, MoveEnd.ParentActions);

					// reconnect the move end action as a child of the fire action, as a special end of move animation will be performed for this move + attack ability
					VisualizationMgr.DisconnectAction(MoveEnd);
					VisualizationMgr.ConnectAction(MoveEnd, VisualizationMgr.BuildVisTree, false, AddedAction);
				}
				else
				{
					//See if this is a teleport. If so, don't perform exit cover visuals
					TeleportMoveAction = X2Action_MoveTeleport(VisualizationMgr.GetNodeOfType(VisualizationMgr.BuildVisTree, class'X2Action_MoveTeleport', SourceData.VisualizeActor));
					if (TeleportMoveAction != none)
					{
						//Skip the FOW Reveal ( at the start of the path ). Let the fire take care of it ( end of the path )
						ExitCoverAction.bSkipFOWReveal = true;
					}

					AddedAction = AbilityTemplate.ActionFireClass.static.AddToVisualizationTree(SourceData, Context, false, SourceData.LastActionAdded);
				}
			}
		}
		else
		{
			//If we were interrupted, insert a marker node for the interrupting visualization code to use. In the move path version above, it is expected for interrupts to be 
			//done during the move.
			if (Context.InterruptionStatus != eInterruptionStatus_None)
			{
				//Insert markers for the subsequent interrupt to insert into
				class'X2Action'.static.AddInterruptMarkerPair(SourceData, Context, ExitCoverAction);
			}

			if (!AbilityTemplate.bSkipFireAction)
			{
				// no move, just add the fire action. Parent is exit cover action if we have one
				AddedAction = AbilityTemplate.ActionFireClass.static.AddToVisualizationTree(SourceData, Context, false, SourceData.LastActionAdded);
			}			
		}

		if( !AbilityTemplate.bSkipFireAction )
		{
			FireAction = AddedAction;

			class'XComGameState_NarrativeManager'.static.BuildVisualizationForDynamicNarrative(VisualizeGameState, false, 'AttackBegin', FireAction.ParentActions[0]);

			if( AbilityTemplate.AbilityToHitCalc != None )
			{
				X2Action_Fire(AddedAction).SetFireParameters(Context.IsResultContextHit());
			}
		}
	}

	//If there are effects added to the shooter, add the visualizer actions for them
	for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
	{
		AbilityTemplate.AbilityShooterEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, SourceData, Context.FindShooterEffectApplyResult(AbilityTemplate.AbilityShooterEffects[EffectIndex]));		
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
			BuildData = SourceData;
		}
		else
		{
			BuildData = InterruptTrack;        //  interrupt track will either be empty or filled out correctly
		}

		BuildData.VisualizeActor = TargetVisualizer;

		TargetStateObject = VisualizeGameState.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
		if( TargetStateObject != none )
		{
			History.GetCurrentAndPreviousGameStatesForObjectID(AbilityContext.PrimaryTarget.ObjectID, 
															   BuildData.StateObject_OldState, BuildData.StateObject_NewState,
															   eReturnType_Reference,
															   VisualizeGameState.HistoryIndex);
			`assert(BuildData.StateObject_NewState == TargetStateObject);
		}
		else
		{
			//If TargetStateObject is none, it means that the visualize game state does not contain an entry for the primary target. Use the history version
			//and show no change.
			BuildData.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
			BuildData.StateObject_NewState = BuildData.StateObject_OldState;
		}

		// if this is a melee attack, make sure the target is facing the location he will be melee'd from
		if(!AbilityTemplate.bSkipFireAction 
			&& !bSourceIsAlsoTarget 
			&& AbilityContext.MovementPaths.Length > 0
			&& AbilityContext.MovementPaths[0].MovementData.Length > 0
			&& XGUnit(TargetVisualizer) != none)
		{
			MoveTurnAction = X2Action_MoveTurn(class'X2Action_MoveTurn'.static.AddToVisualizationTree(BuildData, Context, false, ExitCoverAction));
			MoveTurnAction.m_vFacePoint = AbilityContext.MovementPaths[0].MovementData[AbilityContext.MovementPaths[0].MovementData.Length - 1].Position;
			MoveTurnAction.m_vFacePoint.Z = TargetVisualizerInterface.GetTargetingFocusLocation().Z;
			MoveTurnAction.UpdateAimTarget = true;

			// Jwats: Add a wait for ability effect so the idle state machine doesn't process!
			WaitForFireAction = X2Action_WaitForAnotherAction(class'X2Action_WaitForAnotherAction'.static.AddToVisualizationTree(BuildData, Context, false, MoveTurnAction));
			WaitForFireAction.ActionToWaitFor = FireAction;
		}

		//Pass in AddedAction (Fire Action) as the LastActionAdded if we have one. Important! As this is automatically used as the parent in the effect application sub functions below.
		if (AddedAction != none && AddedAction.IsA('X2Action_Fire'))
		{
			BuildData.LastActionAdded = AddedAction;
		}
		
		//Add any X2Actions that are specific to this effect being applied. These actions would typically be instantaneous, showing UI world messages
		//playing any effect specific audio, starting effect specific effects, etc. However, they can also potentially perform animations on the 
		//track actor, so the design of effect actions must consider how they will look/play in sequence with other effects.
		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
		{
			ApplyResult = Context.FindTargetEffectApplyResult(AbilityTemplate.AbilityTargetEffects[EffectIndex]);

			// Target effect visualization
			if( !Context.bSkipAdditionalVisualizationSteps )
			{
				AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, ApplyResult);
			}

			// Source effect visualization
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceData, ApplyResult);
		}

		//the following is used to handle Rupture flyover text
		TargetUnitState = XComGameState_Unit(BuildData.StateObject_OldState);
		if (TargetUnitState != none &&
			XComGameState_Unit(BuildData.StateObject_OldState).GetRupturedValue() == 0 &&
			XComGameState_Unit(BuildData.StateObject_NewState).GetRupturedValue() > 0)
		{
			//this is the frame that we realized we've been ruptured!
			class 'X2StatusEffects'.static.RuptureVisualization(VisualizeGameState, BuildData);
		}

		if (AbilityTemplate.bAllowAmmoEffects && AmmoTemplate != None)
		{
			for (EffectIndex = 0; EffectIndex < AmmoTemplate.TargetEffects.Length; ++EffectIndex)
			{
				ApplyResult = Context.FindTargetEffectApplyResult(AmmoTemplate.TargetEffects[EffectIndex]);
				AmmoTemplate.TargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, ApplyResult);
				AmmoTemplate.TargetEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceData, ApplyResult);
			}
		}
		if (AbilityTemplate.bAllowBonusWeaponEffects && WeaponTemplate != none)
		{
			for (EffectIndex = 0; EffectIndex < WeaponTemplate.BonusWeaponEffects.Length; ++EffectIndex)
			{
				ApplyResult = Context.FindTargetEffectApplyResult(WeaponTemplate.BonusWeaponEffects[EffectIndex]);
				WeaponTemplate.BonusWeaponEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, ApplyResult);
				WeaponTemplate.BonusWeaponEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceData, ApplyResult);
			}
		}

		if (Context.IsResultContextMiss() && (AbilityTemplate.LocMissMessage != "" || AbilityTemplate.TargetMissSpeech != ''))
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(BuildData, Context, false, BuildData.LastActionAdded));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocMissMessage, AbilityTemplate.TargetMissSpeech, bGoodAbility ? eColor_Bad : eColor_Good);
		}
		else if( Context.IsResultContextHit() && (AbilityTemplate.LocHitMessage != "" || AbilityTemplate.TargetHitSpeech != '') )
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(BuildData, Context, false, BuildData.LastActionAdded));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocHitMessage, AbilityTemplate.TargetHitSpeech, bGoodAbility ? eColor_Good : eColor_Bad);
		}

		if (!bPlayedAttackResultNarrative)
		{
			class'XComGameState_NarrativeManager'.static.BuildVisualizationForDynamicNarrative(VisualizeGameState, false, 'AttackResult');
			bPlayedAttackResultNarrative = true;
		}

		if( TargetVisualizerInterface != none )
		{
			//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
			TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, BuildData);
		}

		if( bSourceIsAlsoTarget )
		{
			SourceData = BuildData;
		}
	}

	if (AbilityTemplate.bUseLaunchedGrenadeEffects)
	{
		MultiTargetEffects = X2GrenadeTemplate(SourceWeapon.GetLoadedAmmoTemplate(AbilityState)).LaunchedGrenadeEffects;
	}
	else if (AbilityTemplate.bUseThrownGrenadeEffects)
	{
		MultiTargetEffects = X2GrenadeTemplate(SourceWeapon.GetMyTemplate()).ThrownGrenadeEffects;
	}
	else
	{
		MultiTargetEffects = AbilityTemplate.AbilityMultiTargetEffects;
	}

	//  Apply effects to multi targets - don't show multi effects for burst fire as we just want the first time to visualize
	if( MultiTargetEffects.Length > 0 && AbilityContext.MultiTargets.Length > 0 && X2AbilityMultiTarget_BurstFire(AbilityTemplate.AbilityMultiTargetStyle) == none)
	{
		for( TargetIndex = 0; TargetIndex < AbilityContext.MultiTargets.Length; ++TargetIndex )
		{	
			bMultiSourceIsAlsoTarget = false;
			if( AbilityContext.MultiTargets[TargetIndex].ObjectID == AbilityContext.SourceObject.ObjectID )
			{
				bMultiSourceIsAlsoTarget = true;
				bSourceIsAlsoTarget = bMultiSourceIsAlsoTarget;				
			}

			TargetVisualizer = History.GetVisualizer(AbilityContext.MultiTargets[TargetIndex].ObjectID);
			TargetVisualizerInterface = X2VisualizerInterface(TargetVisualizer);

			if( bMultiSourceIsAlsoTarget )
			{
				BuildData = SourceData;
			}
			else
			{
				BuildData = InitData;
			}
			BuildData.VisualizeActor = TargetVisualizer;

			// if the ability involved a fire action and we don't have already have a potential parent,
			// all the target visualizations should probably be parented to the fire action and not rely on the auto placement.
			if( (BuildData.LastActionAdded == none) && (FireAction != none) )
				BuildData.LastActionAdded = FireAction;

			TargetStateObject = VisualizeGameState.GetGameStateForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID);
			if( TargetStateObject != none )
			{
				History.GetCurrentAndPreviousGameStatesForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID, 
																	BuildData.StateObject_OldState, BuildData.StateObject_NewState,
																	eReturnType_Reference,
																	VisualizeGameState.HistoryIndex);
				`assert(BuildData.StateObject_NewState == TargetStateObject);
			}			
			else
			{
				//If TargetStateObject is none, it means that the visualize game state does not contain an entry for the primary target. Use the history version
				//and show no change.
				BuildData.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID);
				BuildData.StateObject_NewState = BuildData.StateObject_OldState;
			}
		
			//Add any X2Actions that are specific to this effect being applied. These actions would typically be instantaneous, showing UI world messages
			//playing any effect specific audio, starting effect specific effects, etc. However, they can also potentially perform animations on the 
			//track actor, so the design of effect actions must consider how they will look/play in sequence with other effects.
			for (EffectIndex = 0; EffectIndex < MultiTargetEffects.Length; ++EffectIndex)
			{
				ApplyResult = Context.FindMultiTargetEffectApplyResult(MultiTargetEffects[EffectIndex], TargetIndex);

				// Target effect visualization
				MultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, ApplyResult);

				// Source effect visualization
				MultiTargetEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceData, ApplyResult);
			}			

			//the following is used to handle Rupture flyover text
			TargetUnitState = XComGameState_Unit(BuildData.StateObject_OldState);
			if (TargetUnitState != none && 
				XComGameState_Unit(BuildData.StateObject_OldState).GetRupturedValue() == 0 &&
				XComGameState_Unit(BuildData.StateObject_NewState).GetRupturedValue() > 0)
			{
				//this is the frame that we realized we've been ruptured!
				class 'X2StatusEffects'.static.RuptureVisualization(VisualizeGameState, BuildData);
			}
			
			if (!bPlayedAttackResultNarrative)
			{
				class'XComGameState_NarrativeManager'.static.BuildVisualizationForDynamicNarrative(VisualizeGameState, false, 'AttackResult');
				bPlayedAttackResultNarrative = true;
			}

			if( TargetVisualizerInterface != none )
			{
				//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
				TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, BuildData);
			}

			if( bMultiSourceIsAlsoTarget )
			{
				SourceData = BuildData;
			}			
		}
	}
	//****************************************************************************************

	//Finish adding the shooter's track
	//****************************************************************************************
	if( !bSourceIsAlsoTarget && ShooterVisualizerInterface != none)
	{
		ShooterVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, SourceData);				
	}	

	//  Handle redirect visualization
	TypicalAbility_AddEffectRedirects(VisualizeGameState, SourceData);

	//****************************************************************************************

	//Configure the visualization tracks for the environment
	//****************************************************************************************

	if (ExitCoverAction != none)
	{
		ExitCoverAction.ShouldBreakWindowBeforeFiring( Context, WindowBreakTouchIndex );
	}

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_EnvironmentDamage', EnvironmentDamageEvent)
	{
		BuildData = InitData;
		BuildData.VisualizeActor = none;
		BuildData.StateObject_NewState = EnvironmentDamageEvent;
		BuildData.StateObject_OldState = EnvironmentDamageEvent;

		// if this is the damage associated with the exit cover action, we need to force the parenting within the tree
		// otherwise LastActionAdded with be 'none' and actions will auto-parent.
		if ((ExitCoverAction != none) && (WindowBreakTouchIndex > -1))
		{
			if (EnvironmentDamageEvent.HitLocation == AbilityContext.ProjectileEvents[WindowBreakTouchIndex].HitLocation)
			{
				BuildData.LastActionAdded = ExitCoverAction;
			}
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityShooterEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');		
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');
		}

		for (EffectIndex = 0; EffectIndex < MultiTargetEffects.Length; ++EffectIndex)
		{
			MultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');	
		}
	}

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_WorldEffectTileData', WorldDataUpdate)
	{
		BuildData = InitData;
		BuildData.VisualizeActor = none;
		BuildData.StateObject_NewState = WorldDataUpdate;
		BuildData.StateObject_OldState = WorldDataUpdate;

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityShooterEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');		
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');
		}

		for (EffectIndex = 0; EffectIndex < MultiTargetEffects.Length; ++EffectIndex)
		{
			MultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');	
		}
	}
	//****************************************************************************************

	//Process any interactions with interactive objects
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_InteractiveObject', InteractiveObject)
	{
		// Add any doors that need to listen for notification. 
		// Move logic is taken from MoveAbility_BuildVisualization, which only has special case handling for AI patrol movement ( which wouldn't happen here )
		if ( Context.InputContext.MovementPaths.Length > 0 || (InteractiveObject.IsDoor() && InteractiveObject.HasDestroyAnim()) ) //Is this a closed door?
		{
			BuildData = InitData;
			//Don't necessarily have a previous state, so just use the one we know about
			BuildData.StateObject_OldState = InteractiveObject;
			BuildData.StateObject_NewState = InteractiveObject;
			BuildData.VisualizeActor = History.GetVisualizer(InteractiveObject.ObjectID);

			class'X2Action_BreakInteractActor'.static.AddToVisualizationTree(BuildData, Context);
		}
	}
	
	//Add a join so that all hit reactions and other actions will complete before the visualization sequence moves on. In the case
	// of fire but no enter cover then we need to make sure to wait for the fire since it isn't a leaf node
	VisualizationMgr.GetAllLeafNodes(VisualizationMgr.BuildVisTree, LeafNodes);

	if (!AbilityTemplate.bSkipFireAction)
	{
		if (!AbilityTemplate.bSkipExitCoverWhenFiring)
		{			
			LeafNodes.AddItem(class'X2Action_EnterCover'.static.AddToVisualizationTree(SourceData, Context, false, FireAction));
		}
		else
		{
			LeafNodes.AddItem(FireAction);
		}
	}
	
	if (VisualizationMgr.BuildVisTree.ChildActions.Length > 0)
	{
		JoinActions = X2Action_MarkerNamed(class'X2Action_MarkerNamed'.static.AddToVisualizationTree(SourceData, Context, false, none, LeafNodes));
		JoinActions.SetName("Join");
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
	local X2Condition_AbilityProperty  		AcidCondition, SiphonCondition;
	local X2Condition_UnitProperty			TargetUnitPropertyCondition;
	local RTEffect_Siphon					SiphonEffect;

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

//---------------------------------------------------------------------------------------
//---Psionic Lance-----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTPsionicLance()
{
	local X2AbilityTemplate					Template;
	local X2AbilityTarget_Cursor			CursorTarget;
	local X2AbilityMultiTarget_Line         LineMultiTarget;
	local X2Condition_UnitProperty          TargetCondition;
	local X2AbilityCost_ActionPoints        ActionCost;
	local X2Effect_ApplyWeaponDamage        DamageEffect;
	local X2AbilityCooldown_PerPlayerType	Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTPsionicLance');

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Offensive;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_nulllance";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;

	Template.CustomFireAnim = 'HL_Psi_ProjectileHigh';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	ActionCost = new class'X2AbilityCost_ActionPoints';
	ActionCost.iNumPoints = 1;   // Updated 8/18/15 to 1 action point only per Jake request.
	ActionCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionCost);

	Cooldown = new class'X2AbilityCooldown_PerPlayerType';
	Cooldown.iNumTurns = default.PSIONIC_LANCE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityToHitCalc = default.DeadEye;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = 18;
	Template.AbilityTargetStyle = CursorTarget;

	LineMultiTarget = new class'X2AbilityMultiTarget_Line';
	Template.AbilityMultiTargetStyle = LineMultiTarget;

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
	DamageEffect.EffectDamageValue = default.PSILANCE_DMG;
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
//---Close Combat Specialist-------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTCloseCombatSpecialist()
{
	local X2AbilityTemplate                 Template;

	Template = PurePassive('RTCloseCombatSpecialist', "img:///RisingTidesContentPackage.PerkIcons.LW_AbilityCloseCombatSpecialist", false, 'eAbilitySource_Perk');
	Template.AdditionalAbilities.AddItem('RTCloseCombatSpecialistAttack');
	return Template;
}

static function X2AbilityTemplate RTCloseCombatSpecialistAttack()
{
	local X2AbilityTemplate								Template;
	local X2AbilityToHitCalc_StandardAim				ToHitCalc;
	local X2AbilityTrigger_Event						Trigger;
	local X2Effect_Persistent							CloseCombatSpecialistTargetEffect;
	local X2Condition_UnitEffectsWithAbilitySource		CloseCombatSpecialistTargetCondition;
	local X2AbilityTrigger_EventListener				EventListener;
	local X2Condition_UnitProperty						SourceNotConcealedCondition;
	local X2Condition_UnitEffects						SuppressedCondition;
	local X2Condition_Visibility						TargetVisibilityCondition;
	local X2AbilityCost_Ammo							AmmoCost;
	local X2AbilityTarget_Single_CCS					SingleTarget;
	//local X2AbilityCooldown								Cooldown;	

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTCloseCombatSpecialistAttack');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.LW_AbilityCloseCombatSpecialist";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
	Template.Hostility = eHostility_Defensive;
	Template.bCrossClassEligible = false;

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.bReactionFire = true;
	Template.AbilityToHitCalc = ToHitCalc;
	 
	//Cooldown = new class'X2AbilityCooldown';
	//Cooldown.iNumTurns = 1;
	//Template.AbilityCooldown = Cooldown;

	AmmoCost = new class 'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = default.CCS_AMMO_PER_SHOT;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	//  trigger on movement
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_MovementObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_MovementObserver';
	Trigger.MethodName = 'PostBuildGameState';
	Template.AbilityTriggers.AddItem(Trigger);
	//  trigger on an attack
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_AttackObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);

	//  it may be the case that enemy movement caused a concealment break, which made Bladestorm applicable - attempt to trigger afterwards
	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitConcealmentBroken';
	EventListener.ListenerData.Filter = eFilter_Unit;
	EventListener.ListenerData.EventFn = RTCloseCombatSpecialistConcealmentListener;
	EventListener.ListenerData.Priority = 55;
	Template.AbilityTriggers.AddItem(EventListener);
	
	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bRequireBasicVisibility = true;
	TargetVisibilityCondition.bDisablePeeksOnMovement = true; //Don't use peek tiles for over watch shots	
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);	
	Template.AddShooterEffectExclusions();

	//Don't trigger when the source is concealed
	SourceNotConcealedCondition = new class'X2Condition_UnitProperty';
	SourceNotConcealedCondition.ExcludeConcealed = true;
	Template.AbilityShooterConditions.AddItem(SourceNotConcealedCondition);

	SuppressedCondition = new class'X2Condition_UnitEffects';
	SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	SuppressedCondition.AddExcludeEffect('AreaSuppression', 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(SuppressedCondition);

	SingleTarget = new class 'X2AbilityTarget_Single_CCS';
	//SingleTarget.OnlyIncludeTargetsInsideWeaponRange = true;
	Template.AbilityTargetStyle = SingleTarget;

	Template.bAllowBonusWeaponEffects = true;
	Template.AddTargetEffect(class 'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	//Prevent repeatedly hammering on a unit when CCS triggers.
	//(This effect does nothing, but enables many-to-many marking of which CCS attacks have already occurred each turn.)
	CloseCombatSpecialistTargetEffect = new class'X2Effect_Persistent';
	CloseCombatSpecialistTargetEffect.BuildPersistentEffect(1, false, true, true, eGameRule_PlayerTurnEnd);
	CloseCombatSpecialistTargetEffect.EffectName = 'CloseCombatSpecialistTarget';
	CloseCombatSpecialistTargetEffect.bApplyOnMiss = true; //Only one chance, even if you miss (prevents crazy flailing counter-attack chains with a Muton, for example)
	Template.AddTargetEffect(CloseCombatSpecialistTargetEffect);
	
	CloseCombatSpecialistTargetCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	CloseCombatSpecialistTargetCondition.AddExcludeEffect('CloseCombatSpecialistTarget', 'AA_DuplicateEffectIgnored');
	Template.AbilityTargetConditions.AddItem(CloseCombatSpecialistTargetCondition);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}

//Must be static, because it will be called with a different object (an XComGameState_Ability)
//Used to trigger Bladestorm when the source's concealment is broken by a unit in melee range (the regular movement triggers get called too soon)
static function EventListenerReturn RTCloseCombatSpecialistConcealmentListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit ConcealmentBrokenUnit;
	local StateObjectReference CloseCombatSpecialistRef;
	local XComGameState_Ability CloseCombatSpecialistState;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	ConcealmentBrokenUnit = XComGameState_Unit(EventSource);	
	if (ConcealmentBrokenUnit == None)
		return ELR_NoInterrupt;

	//Do not trigger if the CloseCombatSpecialist soldier himself moved to cause the concealment break - only when an enemy moved and caused it.
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext().GetFirstStateInEventChain().GetContext());
	if (AbilityContext != None && AbilityContext.InputContext.SourceObject != ConcealmentBrokenUnit.ConcealmentBrokenByUnitRef)
		return ELR_NoInterrupt;

	CloseCombatSpecialistRef = ConcealmentBrokenUnit.FindAbility('RTCloseCombatSpecialistAttack');
	if (CloseCombatSpecialistRef.ObjectID == 0)
		return ELR_NoInterrupt;

	CloseCombatSpecialistState = XComGameState_Ability(History.GetGameStateForObjectID(CloseCombatSpecialistRef.ObjectID));
	if (CloseCombatSpecialistState == None)
		return ELR_NoInterrupt;
	
	CloseCombatSpecialistState.AbilityTriggerAgainstSingleTarget(ConcealmentBrokenUnit.ConcealmentBrokenByUnitRef, false);
	return ELR_NoInterrupt;
}