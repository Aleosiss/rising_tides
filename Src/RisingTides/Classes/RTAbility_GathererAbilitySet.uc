//---------------------------------------------------------------------------------------
//  FILE:    RTAbility_GathererAbilitySet.uc
//  AUTHOR:  Aleosiss
//  DATE:    18 December 2016
//  PURPOSE: Defines abilities used by Nova.
//
//---------------------------------------------------------------------------------------
//	Nova's perks.
//---------------------------------------------------------------------------------------
class RTAbility_GathererAbilitySet extends RTAbility config(RisingTides);

	var localized string OTS_TITLE;
	var localized string OTS_DESC_SELF;
	var localized string OTS_DESC_ALLY;
	var localized string OTS_DESC_ENEMY;
	var localized string UV_TITLE;
	var localized string UV_DESC;
	
	var config float OTS_RADIUS;
	var config float OTS_RADIUS_SQ;
	var config int OTS_ACTION_POINT_COST;
	var config int UV_AIM_PENALTY;
	var config int UV_DEFENSE_PENALTY;
	var config int UV_WILL_PENALTY;
	var config int DOMINATION_STRENGTH;
	var config int SIBYL_STRENGTH;
	var config int GUILTY_BUILDUP_TURNS;
	var config int GUARDIAN_ANGEL_HEAL_VALUE;
	var config float GUARDIAN_ANGEL_WILL_THRESHOLD;
	var config float GUARDIAN_ANGEL_WILL_RECOVERY_AMOUNT;
	var config int MELD_INDUCTION_ACTION_POINT_COST;
	var config int MELD_INDUCTION_COOLDOWN;
	var config int MELD_INDUCTION_DURATION;
	var config bool MELD_INDUCTION_INFINITE;
	var config int EXTINCTION_EVENT_RADIUS_METERS;
	var config int EXTINCTION_EVENT_ACTION_POINT_COST;
	var config int EXTINCTION_EVENT_CHARGES;
	var config WeaponDamageValue EXTINCTION_EVENT_DMG;
	var config WeaponDamageValue RUDIMENTARY_CREATURES_DMG;
	var config WeaponDamageValue UNWILL_DMG;
	var config WeaponDamageValue PSISTORM_DMG;
	var config int RUDIMENTARY_CREATURES_INTERRUPT_ABILITY_COOLDOWN;
	var config int LIFT_COOLDOWN;
	var config int LIFT_DURATION;
	var config float LIFT_RADIUS;
	var config int KNOWLEDGE_IS_POWER_STACK_CAP;
	var config float KNOWLEDGE_IS_POWER_CRIT_PER_STACK;
	var config int PSIONICSTORM_COOLDOWN;
	var config int PSIONICSTORM_NUMSTORMS;
	var int PSIONICSTORM_RADIUS;
	var config int LASH_COOLDOWN;
	var config int UTV_ACTION_POINT_COST;
	var config int UTV_COOLDOWN;

	var name ExtinctionEventStageThreeEventName;
	var name OverTheShoulderTagName;
	var name OverTheShoulderEffectName;
	var name OverTheShoulderSourceEffectName;
	var name EchoedAgonyEffectAbilityTemplateName;
	var name GuiltyConscienceEventName;
	var name GuiltyConscienceEffectName;
	var name PostOverTheShoulderEventName;
	var name KnowledgeIsPowerEffectName;

	var name PsionicStormSustainedActivationEffectName;
	var name PsionicStormSustainedDamageEvent;
	var name PsistormMarkedEffectName;

	var config string ExtinctionEventChargingParticleString;
	var config string ExtinctionEventReleaseParticleString;
	var config string PsionicInterruptParticleString;
	var config string UnwillingConduitDamageParticleString;
	var config string UnwillingConduitRestoreParticleString;

	var localized string GuardianAngelHealText;
	var localized string KIPFriendlyName;
	var localized string KIPFriendlyDesc;
	var localized string LocPsionicallyInterruptedName;
	var localized string HarbingerShieldLostStr;
	var localized string GuardianAngelEffectDesc;

	var config string KIPIconPath;

	var config array<name> AbilityPerksToLoad;

//---------------------------------------------------------------------------------------
//---CreateTemplates---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(OverTheShoulder());
	Templates.AddItem(OverTheShoulderPassives());

	Templates.AddItem(RTForcedIntroversion());
	Templates.AddItem(PurePassive('RTUnsettlingVoices', "img:///RisingTidesContentPackage.PerkIcons.UIPerk_mind_overwatch_psi_us", false, 'eAbilitySource_Psionic'));
	Templates.AddItem(RTTheSixPathsOfPain());
	Templates.AddItem(RTTheSixPathsOfPainIcon());
	Templates.AddItem(RTTheSixPathsOfPainOverride());
	Templates.AddItem(RTMeldInduction());
	Templates.AddItem(RTGuardianAngel());
	Templates.AddItem(RTRudimentaryCreatures());
	Templates.AddItem(RTRudimentaryCreaturesEvent());
	Templates.AddItem(RTExtinctionEventPartOne());
	Templates.AddItem(RTExtinctionEventPartTwo());
	Templates.AddItem(RTExtinctionEventPartThree());
	Templates.AddItem(RTUnwillingConduits());
	Templates.AddItem(PurePassive('RTUnwillingConduitsIcon', "img:///RisingTidesContentPackage.PerkIcons.rt_unwillingconduits", false, 'eAbilitySource_Psionic'));
	Templates.AddItem(RTDomination());
	Templates.AddItem(RTTechnopathy());
	Templates.AddItem(RTConstructTechnopathyHack('RTTechnopathy_Hack'));
	Templates.AddItem(RTConstructTechnopathyHack('RTTechnopathy_Chest', 'Hack_Chest'));
	Templates.AddItem(RTConstructTechnopathyHack('RTTechnopathy_Workstation', 'Hack_Workstation'));
	Templates.AddItem(RTConstructTechnopathyHack('RTTechnopathy_ObjectiveChest', 'Hack_ObjectiveChest'));
	Templates.AddItem(RTFinalizeTechnopathyHack());
	Templates.AddItem(RTCancelTechnopathyHack());
	Templates.AddItem(RTSibyl());
	Templates.AddItem(RTEchoedAgony());
	Templates.AddItem(PurePassive('RTEchoedAgonyIcon', "img:///RisingTidesContentPackage.PerkIcons.rt_echoedagony", false, 'eAbilitySource_Psionic'));
	Templates.AddItem(RTCreateEchoedAgonyEffectAbility());
	Templates.AddItem(RTGuiltyConscience());
	Templates.AddItem(RTGuiltyConscienceEvent());
	Templates.AddItem(RTTriangulation());
	Templates.AddItem(RTTriangulationIcon());
	Templates.AddItem(RTKnowledgeIsPower());
	Templates.AddItem(RTLift());
	Templates.AddItem(RTCrushingGrasp());
	Templates.AddItem(RTPsionicStorm());
	Templates.AddItem(RTPsionicStormSustained());
	Templates.AddItem(RTEndPsistorms());
	Templates.AddItem(RTEndPsistorms_Dead());
	Templates.AddItem(RTSetPsistormCharges());
	Templates.AddItem(RTPsionicLash());
	Templates.AddItem(RTPsionicLashAnims());
	Templates.AddItem(RTUnfurlTheVeil());

	return Templates;
}

//---------------------------------------------------------------------------------------
//---Over the Shoulder-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate OverTheShoulder()
{
	local X2AbilityTemplate						Template;

	`CREATE_X2TEMPLATE(class'RTAbilityTemplate', Template, 'OverTheShoulder');

	Template = CreateOverTheShoulderAbility(Template);

	Template.AdditionalAbilities.AddItem('OverTheShoulderPassives');

	// standard ghost abilities
	Template.AdditionalAbilities.AddItem('GhostPsiSuite');
	Template.AdditionalAbilities.AddItem('JoinMeld');
	Template.AdditionalAbilities.AddItem('LeaveMeld');
	Template.AdditionalAbilities.AddItem('PsiOverload');
	Template.AdditionalAbilities.AddItem('RTFeedback');
	Template.AdditionalAbilities.AddItem('RTMindControl');
	Template.AdditionalAbilities.AddItem('RTEnterStealth');
	Template.AdditionalAbilities.AddItem('RTProgramEvacuation');
	Template.AdditionalAbilities.AddItem('RTProgramEvacuationPartOne');
	Template.AdditionalAbilities.AddItem('RTProgramEvacuationPartTwo');

	// special meld abilities
	Template.AdditionalAbilities.AddItem('LIOverwatchShot');
	Template.AdditionalAbilities.AddItem('RTUnstableConduitBurst');
	Template.AdditionalAbilities.AddItem('PsionicActivate');
	Template.AdditionalAbilities.AddItem('RTHarbingerPsionicLance');

	Template.PostActivationEvents.AddItem(default.PostOverTheShoulderEventName);

	return Template;
}

static function X2AbilityTemplate CreateOverTheShoulderAbility(X2AbilityTemplate Template, optional int AuraEffectDuration = 1) {
	local X2AbilityCost_ActionPoints			ActionPoint;
	local X2AbilityCooldown						Cooldown;
	local X2AbilityMultiTarget_Radius			Radius;
	local X2Condition_UnitProperty				AllyCondition, LivingNonAllyUnitOnlyProperty;
	local array<name>							SkipExclusions;

	local RTEffect_OverTheShoulder				OTSEffect;		// I'm unsure of how this works... but it appears that
																// this will control the application and removal of aura effects within its range

	// Over The Shoulder
	local RTEffect_MobileSquadViewer			VisionEffect;	// this lifts a small amount of the FOW around the unit	and gives vision of it
	local X2Effect_IncrementUnitValue			TagEffect;		// this tags the unit so certain OTS effects can only proc once per turn

	// Unsettling Voices
	local RTEffect_UnsettlingVoices				VoiceEffect;
	local X2Condition_AbilityProperty			VoicesCondition;

	// Guardian Angel

	// Guilty Conscience
	local RTEffect_GuiltyConscience				GuiltyEffect;

	// Knowledge is Power
	local RTEffect_KnowledgeIsPower				KIPEffect;

	local X2Effect_Persistent					/*SelfEffect, EnemyEffect,*/ AllyEffect;

	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_overtheshoulder";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;

	ActionPoint = new class'X2AbilityCost_ActionPoints';
	ActionPoint.iNumPoints = default.OTS_ACTION_POINT_COST;
	ActionPoint.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPoint);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 1;
	Template.AbilityCooldown = Cooldown;

	AllyCondition = new class 'X2Condition_UnitProperty';
	AllyCondition.ExcludeDead = true;
	AllyCondition.ExcludeCivilian = true;
	AllyCondition.ExcludeRobotic = true;
	AllyCondition.ExcludeHostileToSource = true;
	AllyCondition.ExcludeFriendlyToSource = false;
	AllyCondition.FailOnNonUnits = true;

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	LivingNonAllyUnitOnlyProperty = new class 'X2Condition_UnitProperty';
	LivingNonAllyUnitOnlyProperty.ExcludeAlive = false;
	LivingNonAllyUnitOnlyProperty.ExcludeDead = true;
	LivingNonAllyUnitOnlyProperty.ExcludeFriendlyToSource = true;
	LivingNonAllyUnitOnlyProperty.ExcludeHostileToSource = false;
	LivingNonAllyUnitOnlyProperty.TreatMindControlledSquadmateAsHostile = true;
	LivingNonAllyUnitOnlyProperty.FailOnNonUnits = true;
	LivingNonAllyUnitOnlyProperty.ExcludeCivilian = false;

	Radius = new class'X2AbilityMultiTarget_Radius';
	Radius.bUseWeaponRadius = false;
	Radius.bIgnoreBlockingCover = true;
	Radius.bExcludeSelfAsTargetIfWithinRadius = true; // for now
	Radius.fTargetRadius = 	default.OTS_RADIUS * class'XComWorldData'.const.WORLD_StepSize * class'XComWorldData'.const.WORLD_UNITS_TO_METERS_MULTIPLIER;
	Template.AbilityMultiTargetStyle = Radius;

	Template.AbilityMultiTargetConditions.Additem(default.LivingTargetUnitOnlyProperty);


	// begin enemy aura effects	---------------------------------------

	// The Default "Can see through walls" Vision Effect
	VisionEffect = new class'RTEffect_MobileSquadViewer';
	VisionEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);
	VisionEffect.SetDisplayInfo(ePerkBuff_Penalty, default.OTS_TITLE, default.OTS_DESC_ENEMY, Template.IconImage, true,,Template.AbilitySourceName);
	VisionEffect.TargetConditions.AddItem(default.PsionicTargetingProperty);
	VisionEffect.DuplicateResponse = eDupe_Ignore;
	VisionEffect.bUseTargetSightRadius = false;
	VisionEffect.bUseTargetSizeRadius = false;
	VisionEffect.iCustomTileRadius = 3;
	VisionEffect.bRemoveWhenTargetDies = true;
	VisionEffect.bRemoveWhenSourceDies = true;
	VisionEffect.EffectName = default.OverTheShoulderEffectName;
	VisionEffect.IconImage = Template.IconImage;
	Template.AddMultiTargetEffect(VisionEffect);

	// Unsettling Voices
	VoiceEffect = new class'RTEffect_UnsettlingVoices';
	VoiceEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);
	VoiceEffect.TargetConditions.AddItem(default.PsionicTargetingProperty);
	VoiceEffect.SetDisplayInfo(ePerkBuff_Penalty,default.UV_TITLE, default.UV_DESC, "img:///RisingTidesContentPackage.PerkIcons.UIPerk_mind_overwatch_psi_us", true,,Template.AbilitySourceName);
	VoiceEffect.DuplicateResponse = eDupe_Ignore;
	VoiceEffect.bRemoveWhenTargetDies = true;
	VoiceEffect.bRemoveWhenSourceDies = true;
	VoiceEffect.UV_AIM_PENALTY = default.UV_AIM_PENALTY;
	VoiceEffect.UV_DEFENSE_PENALTY = default.UV_DEFENSE_PENALTY;
	VoiceEffect.UV_WILL_PENALTY = default.UV_WILL_PENALTY;
	VoiceEffect.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_mind_overwatch_psi_us";

	VoicesCondition = new class'X2Condition_AbilityProperty';
	VoicesCondition.OwnerHasSoldierAbilities.AddItem('RTUnsettlingVoices');
	VoiceEffect.TargetConditions.AddItem(VoicesCondition);

	Template.AddMultiTargetEffect(VoiceEffect);

	// Guilty Conscience
	GuiltyEffect = CreateGuiltyConscienceEffect(default.GUILTY_BUILDUP_TURNS);
	Template.AddMultiTargetEffect(GuiltyEffect);

	// Knowledge is Power
	KIPEffect = CreateKnowledgeIsPowerEffect(default.KNOWLEDGE_IS_POWER_STACK_CAP, default.KNOWLEDGE_IS_POWER_CRIT_PER_STACK);
	Template.AddMultiTargetEffect(KIPEffect);


	// end enemy aura effects	----------------------------------------

	// begin ally aura effects	-----------------------------------------

	// general tag effect to mark all units with OTS
	AllyEffect = new class'X2Effect_Persistent';
	AllyEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);
	AllyEffect.SetDisplayInfo(ePerkBuff_Bonus,default.OTS_TITLE, default.OTS_DESC_ALLY, Template.IconImage, true,,Template.AbilitySourceName);
	AllyEffect.TargetConditions.AddItem(default.LivingFriendlyUnitOnlyProperty);
	AllyEffect.DuplicateResponse = eDupe_Ignore;
	AllyEffect.EffectName = default.OverTheShoulderEffectName;
	AllyEffect.IconImage = Template.IconImage;
	Template.AddMultiTargetEffect(AllyEffect);

	// guardian angel
	CreateGuardianAngel(Template);




	// end ally aura effects	------------------------------------------


	// aura controller effect	------------------------------------------
	OTSEffect = new class'RTEffect_OverTheShoulder';
	OTSEffect.BuildPersistentEffect(AuraEffectDuration,,,, eGameRule_PlayerTurnBegin);
	OTSEffect.SetDisplayInfo(ePerkBuff_Bonus, default.OTS_TITLE, default.OTS_DESC_SELF, Template.IconImage, true,,Template.AbilitySourceName);
	OTSEffect.DuplicateResponse = eDupe_Refresh;
	OTSEffect.EffectName = default.OverTheShoulderSourceEffectName;
	OTSEffect.VFXTemplateName = "RisingTidesContentPackage.fX.P_Nova_Psi_OTS";
	OTSEffect.VFXSocket = 'CIN_Root';
	OTSEffect.VFXSocketsArrayName = 'None';
	OTSEffect.Scale = 2.5;
	Template.AddTargetEffect(OTSEffect);

	// tag effect. add this last
	TagEffect = new class'X2Effect_IncrementUnitValue';
	TagEffect.UnitName = default.OverTheShoulderTagName;
	TagEffect.NewValueToSet = 1;
	TagEffect.CleanupType = eCleanup_BeginTurn;
	TagEffect.SetupEffectOnShotContextResult(true, true);		// mark them regardless of whether the shot hit or missed
	Template.AddMultiTargetEffect(TagEffect);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.CustomFireAnim = 'HL_Psi_SelfCast';

	if(Template.DataName == 'OverTheShoulder') {
		Template.bShowActivation = true;
		Template.bSkipFireAction = false;
	} else {
		Template.bShowActivation = false;
		Template.bSkipFireAction = true;
	}

	return Template;
}

static function X2AbilityTemplate OverTheShoulderPassives() {
	local X2AbilityTemplate					Template;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'OverTheShoulderPassives')

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_solace";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	return Template;
}

static function X2AbilityTemplate RTTriangulation() {
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;

	`CREATE_X2TEMPLATE(class'RTAbilityTemplate', Template, 'RTTriangulation');
	Template = CreateOverTheShoulderAbility(Template);
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_triangulation";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.AbilityTriggers.Length = 0;
	Template.AbilityCosts.Length = 0;
	Template.AbilityCooldown = none;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = default.PostOverTheShoulderEventName;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'RTGameState_Ability'.static.TriangulationListener;
	Trigger.ListenerData.Priority = 50;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AdditionalAbilities.AddItem('RTTriangulationIcon');

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	return Template;

}

static function X2AbilityTemplate RTTriangulationIcon() {
	local X2AbilityTemplate Template;

	Template = PurePassive('RTTriangulationIcon', "img:///RisingTidesContentPackage.PerkIcons.rt_triangulation", false, 'eAbilitySource_Psionic');

	return Template;
}

//---------------------------------------------------------------------------------------
//---Forced Introversion-----------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTForcedIntroversion() {
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	local RTEffect_Stealth StealthEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTForcedIntroversion');

	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_forcedintroversion";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnVisualizationBlockCompleted;
	Trigger.ListenerData.EventID = 'RTUnitFeedbacked';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Priority = 50;
	Template.AbilityTriggers.AddItem(Trigger);

	StealthEffect = class'RTEffectBuilder'.static.RTCreateStealthEffect(default.FEEDBACK_DURATION, false, 1.0f, eGameRule_PlayerTurnBegin, Template.AbilitySourceName);
	Template.AddTargetEffect(StealthEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Template.bShowPostActivation = true;
	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	// TODO: Visualization!


	return Template;
}

//---------------------------------------------------------------------------------------
//---Extinction Event--------------------------------------------------------------------
//---------------------------------------------------------------------------------------
// Extinction Event is by nature a multi-stage ability:
// Part One: A standard move ability, except that it has Charges, an increased cost, and most importantly, a PostActivationEvent.
// Part Two: A StealthEffect and DelayedAbilityActivation that responds to the PostActivationEvent fired previously.
// Part Three: Boom in response to the DelayedAbilityActivation.
static function X2AbilityTemplate RTExtinctionEventPartOne() {
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCharges Charges;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTExtinctionEventPartOne');
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';

	Template.FrameAbilityCameraType = eCameraFraming_Never;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.CinescriptCameraType = "StandardMovement";

	Template.bSkipFireAction = true;
	Template.bCrossClassEligible = false;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.Deadeye;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.EXTINCTION_EVENT_ACTION_POINT_COST;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Charges = new class'X2AbilityCharges';
	Charges.InitialCharges = default.EXTINCTION_EVENT_CHARGES;
	Template.AbilityCharges = Charges;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.PostActivationEvents.AddItem(default.UnitUsedPsionicAbilityEvent);
	Template.PostActivationEvents.AddItem('RTExtinctionEventPartTwo');
	Template.AdditionalAbilities.AddItem('RTExtinctionEventPartTwo');
	Template.AdditionalAbilities.AddItem('RTExtinctionEventPartThree');

	return Template;
}

static function X2AbilityTemplate RTExtinctionEventPartTwo() {
	local X2AbilityTemplate Template;
	local RTEffect_Stealth StealthEffect;
	local X2Effect_DelayedAbilityActivation ActivationEffect;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Effect_Persistent			VFXEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTExtinctionEventPartTwo');
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.bCrossClassEligible = false;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'RTExtinctionEventPartTwo';
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.Priority = 50;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.Deadeye;

	StealthEffect = class'RTEffectBuilder'.static.RTCreateStealthEffect(1, false, 1.0f, eGameRule_PlayerTurnBegin, Template.AbilitySourceName);
	Template.AddTargetEffect(StealthEffect);

	VFXEffect = new class'X2Effect_Persistent';
	VFXEffect.BuildPersistentEffect(1, false, false, , eGameRule_PlayerTurnBegin);
	VFXEffect.VFXTemplateName = default.ExtinctionEventChargingParticleString;
	VFXEffect.EffectAddedFn = PanicLoopBeginFn;
	VFXEffect.EffectRemovedFn = PanicLoopEndFn;
	Template.AddTargetEffect(VFXEffect);

	ActivationEffect = new class'X2Effect_DelayedAbilityActivation';
	ActivationEffect.BuildPersistentEffect(1, false, false, , eGameRule_PlayerTurnBegin);
	ActivationEffect.TriggerEventName = default.ExtinctionEventStageThreeEventName;
	Template.AddTargetEffect(ActivationEffect);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	return Template;
}

static function PanicLoopBeginFn( X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState )
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit( NewGameState.CreateStateObject( class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID ) );
	UnitState.bPanicked = true;

	NewGameState.AddStateObject( UnitState );
}

static function PanicLoopEndFn( X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed )
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit( NewGameState.CreateStateObject( class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID ) );
	UnitState.bPanicked = false;

	NewGameState.AddStateObject( UnitState );
}

static function X2AbilityTemplate RTExtinctionEventPartThree() {
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	//local X2Effect_ApplyDamageToWorld WorldDamage;
	local X2Effect_ApplyWeaponDamage WeaponDamage;
	local X2AbilityMultiTarget_Radius Radius;
	//local X2Effect_Persistent UnconsciousEffect;
	local X2Effect_Persistent DisorientedEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTExtinctionEventPartThree');
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Offensive;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.CustomFireAnim = 'HL_Psi_SelfCast';
	Template.bShowActivation = true;
	Template.bCrossClassEligible = false;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.Deadeye; // ur ded

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Priority = 40; // this way we don't conflict with automatic SquadViewer cleanup
	Trigger.ListenerData.EventID = default.ExtinctionEventStageThreeEventName;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Template.AbilityTriggers.AddItem(Trigger);

	Radius = new class'X2AbilityMultiTarget_Radius';
	Radius.fTargetRadius = default.EXTINCTION_EVENT_RADIUS_METERS * class'XComWorldData'.const.WORLD_StepSize * class'XComWorldData'.const.WORLD_UNITS_TO_METERS_MULTIPLIER;
	Radius.bUseWeaponRadius = false;
	Radius.bIgnoreBlockingCover = true;
	Radius.bExcludeSelfAsTargetIfWithinRadius = true; // for now
	Template.AbilityMultiTargetStyle = Radius;

	//UnconsciousEffect = class'X2StatusEffects'.static.CreateUnconsciousStatusEffect();
	//Template.AddTargetEffect(UnconsciousEffect);

	DisorientedEffect = class'X2StatusEffects'.static.CreateUnconsciousStatusEffect();
	Template.AddTargetEffect(DisorientedEffect);

	WeaponDamage = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamage.bIgnoreBaseDamage = true;
	WeaponDamage.EnvironmentalDamageAmount = 9999999; // good bye
	WeaponDamage.EffectDamageValue = default.EXTINCTION_EVENT_DMG;
	WeaponDamage.DamageTypes.AddItem('Psi');
	WeaponDamage.bCanBeRedirected = false;
	WeaponDamage.bApplyOnMiss = true;
	Template.AddMultiTargetEffect(WeaponDamage);

	return Template;
  }

//---------------------------------------------------------------------------------------
//---The Six Paths of Pain---------------------------------------------------------------
//---------------------------------------------------------------------------------------
// The Six Paths of Pain is relatively simple compared to other abilities on the Gatherer tree:
// On PlayerTurnBegun, after CleanUpMobileSquadViewers, it activates.
// This adds a self-targeted effect, and an ally-targeted effect.
// Both add an action point to the target. This is for using Over the Shoulder.
// Next, SPoP activates OverTheShoulder on the Gatherer.
// Next, SPoP does a series of checks for Triangulation. First, it checks for the meld on both source and target.
// Then, it checks for Triangulation on the source.
// Finally, SPoP activates TriangulatedOverTheShoulder on each MultiTarget that passes.
static function X2AbilityTemplate RTTheSixPathsOfPain() {
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener EventTrigger;
	local X2Effect_GrantActionPoints ActionPointEffect;
	local X2Effect_ImmediateAbilityActivation ActivationEffect;
	local X2Effect_ImmediateMultiTargetAbilityActivation MultiActivationEffect;
	local X2Condition_AbilityProperty TriangulationCondition;
	local X2AbilityMultiTarget_AllAllies MultiTarget;
	local X2Condition_UnitEffects   MeldCondition;
	local X2Condition_UnitEffectsWithAbilitySource SourceMeldCondition;
	local X2Condition_UnitEffects FeedbackCondition;

	`CREATE_X2TEMPLATE(class'RTAbilityTemplate', Template, 'RTTheSixPathsOfPain');
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_thesixpathsofpain";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.bCrossClassEligible = false;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.Deadeye;

	// This block handles MultiTargeting for Triangulation effects:
	// Only if the Gatherer has Triangulation.
	// Only if the Gatherer is melded.
	// Only if the Target is melded.
	MeldCondition = new class'X2Condition_UnitEffects';
	MeldCondition.AddRequireEffect(class'RTEffect_Meld'.default.EffectName, 'AA_UnitNotMelded');
	SourceMeldCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	SourceMeldCondition.AddRequireEffect(class'RTEffect_Meld'.default.EffectName, 'AA_UnitNotMelded');
	TriangulationCondition = new class'X2Condition_AbilityProperty';
	TriangulationCondition.OwnerHasSoldierAbilities.AddItem('RTTriangulation');

	Template.AbilityMultiTargetConditions.AddItem(TriangulationCondition);
	Template.AbilityMultiTargetConditions.AddItem(MeldCondition);
	Template.AbilityMultiTargetConditions.AddItem(SourceMeldCondition);
	Template.AbilityMultiTargetConditions.AddItem(default.LivingFriendlyUnitOnlyProperty);

	MultiTarget = new class'X2AbilityMultiTarget_AllAllies';
	Template.AbilityMultiTargetStyle = MultiTarget;

	// OTS requires an Action Point to use, but The Six Paths of Pain makes it free. Grant an additional point here.
	ActionPointEffect = new class'X2Effect_GrantActionPoints';
	ActionPointEffect.NumActionPoints = default.OTS_ACTION_POINT_COST;
	ActionPointEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	//Template.AddMultiTargetEffect(ActionPointEffect);

	Template.AddShooterEffectExclusions();
	FeedbackCondition = new class'X2Condition_UnitEffects';
	FeedbackCondition.AddExcludeEffect(default.RTFeedbackEffectName, 'AA_UnitIsPanicked');
	FeedBackCondition.AddExcludeEffect(class'X2StatusEffects'.default.UnconsciousName, 'AA_UnitIsPanicked');
	Template.AbilityShooterConditions.AddItem(FeedbackCondition);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	ActivationEffect = new class'X2Effect_ImmediateAbilityActivation';
	ActivationEffect.AbilityName = 'RTTheSixPathsOfPainOverride';
	ActivationEffect.EffectName = 'RTTheSixPathsOfPainActivationEffect';
	Template.AddTargetEffect(ActivationEffect);

	MultiActivationEffect = new class'X2Effect_ImmediateMultiTargetAbilityActivation';
	MultiActivationEffect.AbilityName = 'TriangulatedOverTheShoulder';
	MultiActivationEffect.EffectName = 'RTTheSixPathsOfPainMultiActivationEffect';
	Template.AddMultiTargetEffect(MultiActivationEffect);

	//Template.AddTargetEffect(ActionPointEffect);				 // add this after activating OTS

	Template.AdditionalAbilities.AddItem('RTTheSixPathsOfPainIcon');
	Template.AdditionalAbilities.AddItem('RTTheSixPathsOfPainOverride');

	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventID = 'PlayerTurnBegun';
	EventTrigger.ListenerData.Filter = eFilter_None;
	EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventTrigger.ListenerData.Priority = 35;
	Template.AbilityTriggers.AddItem(EventTrigger);

	return Template;
}

static function X2AbilityTemplate RTTheSixPathsOfPainIcon() {
	return PurePassive('RTTheSixPathsOfPainIcon', "img:///RisingTidesContentPackage.PerkIcons.rt_thesixpathsofpain", false, 'eAbilitySource_Psionic');
}

static function X2AbilityTemplate RTTheSixPathsOfPainOverride() {
	local X2AbilityTemplate Template;

	`CREATE_X2TEMPLATE(class'RTAbilityTemplate', Template, 'RTTheSixPathsOfPainOverride');

	Template = CreateOverTheShoulderAbility(Template, 2);

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_thesixpathsofpain";

	// free to cast
	Template.AbilityCosts.Length = 0;
	Template.AbilityCooldown = none;

	// can't cast anyway
	Template.AbilityTriggers.Length = 0;
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

	Template.PostActivationEvents.AddItem(default.PostOverTheShoulderEventName);

	Template.OverrideAbilities.AddItem('OverTheShoulder');
	return Template;
}

//---------------------------------------------------------------------------------------
//---Meld Induction----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
// Meld Induction is a very simple ability.
// Simple single target ability with only a few conditions:
// Living Organic Unit
// that's not already melded.
static function X2AbilityTemplate RTMeldInduction() {
	local X2AbilityTemplate Template;
	local RTEffect_Meld MeldEffect;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown Cooldown;
	local X2AbilityToHitCalc_StatCheck_UnitVsUnit ToHitCalc;
	local X2Condition_UnitEffects	MeldCondition, NoMeldCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTMeldInduction');
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Offensive;
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_program_shield";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.bConsumeAllPoints = false;
	ActionPointCost.iNumPoints = default.MELD_INDUCTION_ACTION_POINT_COST;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.MELD_INDUCTION_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTargetConditions.AddItem(default.PsionicTargetingProperty);

	ToHitCalc = new class 'X2AbilityToHitCalc_StatCheck_UnitVsUnit';
	Template.AbilityToHitCalc = ToHitCalc;

	MeldCondition = new class'X2Condition_UnitEffects';
	MeldCondition.AddRequireEffect('RTEffect_Meld', 'AA_UnitNotMelded');

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();
	Template.AbilityShooterConditions.AddItem(MeldCondition);

	NoMeldCondition = new class'X2Condition_UnitEffects';
	NoMeldCondition.AddExcludeEffect('RTEffect_Meld', 'AA_UnitNotMelded');
	Template.AbilityTargetConditions.AddItem(NoMeldCondition);

	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	MeldEffect = class'RTEffectBuilder'.static.RTCreateMeldEffect(default.MELD_INDUCTION_DURATION, default.MELD_INDUCTION_INFINITE);
	MeldEffect.bRemoveWhenSourceDies = true;
	MeldEffect.bRemoveWhenTargetDies = true;
	Template.AddTargetEffect(MeldEffect);

	Template.PostActivationEvents.AddItem(default.UnitUsedPsionicAbilityEvent);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.CustomFireAnim = 'HL_Psi_MindControl';

	Template.bCrossClassEligible = false;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Guardian Angel----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTGuardianAngel() {
	return PurePassive('RTGuardianAngel', "img:///RisingTidesContentPackage.PerkIcons.UIPerk_revive_overwatch_ga", false, 'eAbilitySource_Psionic');
 }

static function CreateGuardianAngel(out X2AbilityTemplate Template) {
	Template.AddTargetEffect(CreateGuardianAngelHealEffect());
	Template.AddTargetEffect(CreateGuardianAngelCleanseEffect());
	Template.AddTargetEffect(CreateGuardianAngelImmunitiesEffect());
	Template.AddTargetEffect(CreateGuardianAngelMentalRecoveryEffect());

	Template.AddMultiTargetEffect(CreateGuardianAngelHealEffect());
	Template.AddMultiTargetEffect(CreateGuardianAngelCleanseEffect());
	Template.AddMultiTargetEffect(CreateGuardianAngelImmunitiesEffect());
	Template.AddMultiTargetEffect(CreateGuardianAngelMentalRecoveryEffect());

	Template.AddMultiTargetEffect(CreateGuardianAngelStabilizeEffectPartOne());
	Template.AddMultiTargetEffect(CreateGuardianAngelStabilizeEffectPartTwo());
}


static function X2Effect CreateGuardianAngelMentalRecoveryEffect() {
	local X2Effect_Persistent Effect;
	local X2Condition_AbilityProperty AbilityProperty;

	Effect = new class'X2Effect_Persistent';
	Effect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);

	AbilityProperty = new class'X2Condition_AbilityProperty';
	AbilityProperty.OwnerHasSoldierAbilities.AddItem('RTGuardianAngel');
	Effect.TargetConditions.AddItem(AbilityProperty);
	Effect.TargetConditions.AddItem(default.LivingFriendlyUnitOnlyProperty);

	Effect.EffectAddedFn = GuardianAngelMentalRecoveryAdded;

	return Effect;
}

function GuardianAngelMentalRecoveryAdded(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState) {
	if(XComGameState_Unit(kNewTargetState).GetCurrentStat(eStat_Will) / XComGameState_Unit(kNewTargetState).GetBaseStat(eStat_Will) <= default.GUARDIAN_ANGEL_WILL_THRESHOLD) { // if we have lost half of will (default threshold)
		XComGameState_Unit(kNewTargetState).ModifyCurrentStat(eStat_Will, (default.GUARDIAN_ANGEL_WILL_RECOVERY_AMOUNT / 5)); // for some reason, its getting multiplied by 5?
	}
}

static function RTEffect_SimpleHeal CreateGuardianAngelHealEffect() {
		local RTEffect_SimpleHeal Effect;
		local X2Condition_AbilityProperty AbilityProperty;
		local X2Condition_UnitEffects EffectProperty;

		Effect = new class'RTEffect_SimpleHeal';
		Effect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);
		Effect.HEAL_AMOUNT = default.GUARDIAN_ANGEL_HEAL_VALUE;
		Effect.bUseWeaponDamage = false;
		Effect.nAbilitySourceName = default.GuardianAngelHealText;
		Effect.DuplicateResponse = eDupe_Ignore;

		AbilityProperty = new class'X2Condition_AbilityProperty';
		AbilityProperty.OwnerHasSoldierAbilities.AddItem('RTGuardianAngel');

		Effect.TargetConditions.AddItem(AbilityProperty);

		EffectProperty = new class'X2Condition_UnitEffects';
		EffectProperty.AddExcludeEffect(class'X2StatusEffects'.default.BleedingOutName, 'AA_BleedingOut');

		Effect.TargetConditions.AddItem(EffectProperty);

		Effect.TargetConditions.AddItem(default.LivingFriendlyUnitOnlyProperty);
		Effect.TargetConditions.AddItem(CreateOverTheShoulderProperty());

		return Effect;
}
static function X2Effect_RemoveEffects CreateGuardianAngelCleanseEffect() {
		local X2Effect_RemoveEffects Effect;
		local X2Condition_AbilityProperty AbilityProperty;

		Effect = new class'X2Effect_RemoveEffects';
		Effect.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
		Effect.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.ConfusedName);
		Effect.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.PanickedName);
		Effect.EffectNamesToRemove.AddItem(class'X2AbilityTemplateManager'.default.StunnedName);


		AbilityProperty = new class'X2Condition_AbilityProperty';
		AbilityProperty.OwnerHasSoldierAbilities.AddItem('RTGuardianAngel');
		Effect.TargetConditions.AddItem(AbilityProperty);

		Effect.TargetConditions.AddItem(default.LivingFriendlyUnitOnlyProperty);

		return Effect;
}
static function X2Effect_Persistent CreateGuardianAngelStabilizeEffectPartOne() {
		local X2Effect_Persistent Effect;
		local X2Condition_AbilityProperty AbilityProperty;
		local X2Condition_UnitEffects EffectCheckCondition;

		Effect = class'X2StatusEffects'.static.CreateUnconsciousStatusEffect();

		AbilityProperty = new class'X2Condition_AbilityProperty';
		AbilityProperty.OwnerHasSoldierAbilities.AddItem('RTGuardianAngel');
		Effect.TargetConditions.AddItem(AbilityProperty);

		EffectCheckCondition = new class'X2Condition_UnitEffects';
		EffectCheckCondition.AddRequireEffect(class'X2StatusEffects'.default.BleedingOutName, 'AA_BleedingOut');

		Effect.TargetConditions.AddItem(EffectCheckCondition);

		Effect.TargetConditions.AddItem(default.LivingFriendlyUnitOnlyProperty);

		return Effect;
}
static function X2Effect_RemoveEffects CreateGuardianAngelStabilizeEffectPartTwo() {
		local X2Effect_RemoveEffects Effect;
		local X2Condition_AbilityProperty AbilityProperty;
		local X2Condition_UnitStatCheck UnitStatCheckCondition;

		Effect = new class'X2Effect_RemoveEffects';
		Effect.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.UnconsciousName);

		AbilityProperty = new class'X2Condition_AbilityProperty';
		AbilityProperty.OwnerHasSoldierAbilities.AddItem('RTGuardianAngel');

		Effect.TargetConditions.AddItem(AbilityProperty);

		//Hack: Do this instead of ExcludeDead, to only exclude properly-dead or bleeding-out units. -fxs
		UnitStatCheckCondition = new class'X2Condition_UnitStatCheck';
		UnitStatCheckCondition.AddCheckStat(eStat_HP, 0, eCheck_GreaterThan);

		Effect.TargetConditions.AddItem(UnitStatCheckCondition);

		Effect.TargetConditions.AddItem(default.LivingFriendlyUnitOnlyProperty);

		return Effect;
}
static function X2Effect_DamageImmunity CreateGuardianAngelImmunitiesEffect() {
		local X2Effect_DamageImmunity Effect;
		local X2Condition_AbilityProperty AbilityProperty;

		Effect = new class'X2Effect_DamageImmunity';
		Effect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);
		Effect.SetDisplayInfo(ePerkBuff_Bonus, default.GuardianAngelHealText, default.GuardianAngelEffectDesc, "img:///RisingTidesContentPackage.PerkIcons.UIPerk_revive_overwatch_ga", true,, 'eAbilitySource_Psionic');
		// Guardian Angel will not stop hard CC, but cleanse it next turn.
		Effect.ImmuneTypes.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
		Effect.ImmuneTypes.AddItem(class'X2AbilityTemplateManager'.default.ConfusedName);
		Effect.ImmuneTypes.AddItem(class'X2AbilityTemplateManager'.default.PanickedName);
		Effect.DuplicateResponse = eDupe_Ignore;


		AbilityProperty = new class'X2Condition_AbilityProperty';
		AbilityProperty.OwnerHasSoldierAbilities.AddItem('RTGuardianAngel');

		Effect.TargetConditions.AddItem(AbilityProperty);

		Effect.TargetConditions.AddItem(default.LivingFriendlyUnitOnlyProperty);

		return Effect;
}
//---------------------------------------------------------------------------------------
//---Rudimentary Creatures---------------------------------------------------------------
//---------------------------------------------------------------------------------------
// Rudimentary Creatures is another one of my standard "there's gotta be a better way" abilities where it's just an event listener that does everything.
static function X2AbilityTemplate RTRudimentaryCreatures() {
	local X2AbilityTemplate Template;
	local RTEffect_Rudimentary Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTRudimentaryCreatures');
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_overwatch_defense2_rc";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.bCrossClassEligible = false;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.Deadeye;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Effect = new class'RTEffect_Rudimentary';
	Effect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddShooterEffect(Effect);
	Template.AdditionalAbilities.AddItem('RTRudimentaryCreaturesEvent');


	return Template;
}

//---------------------------------------------------------------------------------------
//---Rudimentary Creatures Event---------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTRudimentaryCreaturesEvent() {
	local X2AbilityTemplate Template;
	local X2Effect_ApplyWeaponDamage DamageEffect;
	local X2Effect_Persistent VFXEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTRudimentaryCreaturesEvent');

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_overwatch_defense2_rc";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bCrossClassEligible = false;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityToHitCalc = default.Deadeye;
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder'); // triggered by listener return

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetConditions.AddItem(default.LivingTargetOnlyProperty);

	VFXEffect = new class'X2Effect_Persistent';
	VFXEffect.BuildPersistentEffect(1, false);
	VFXEffect.VisualizationFn = RudimentaryCreaturesAffectTargetVisualization;
	Template.AddTargetEffect(VFXEffect);

	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	DamageEffect.bIgnoreBaseDamage = true;
	DamageEffect.EffectDamageValue = default.RUDIMENTARY_CREATURES_DMG;
	DamageEffect.bIgnoreArmor = true;
	DamageEffect.bBypassSustainEffects = true;
	DamageEffect.DamageTypes.AddItem('Psi');
	Template.AddTargetEffect(DamageEffect);

	Template.AddTargetEffect(class'X2StatusEffects'.static.CreateStunnedStatusEffect(3, 100, true));

	Template.CustomFireAnim = 'HL_Psi_SelfCast';
	Template.bShowActivation = true;

	return Template;
}

function RudimentaryCreaturesAffectTargetVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult) {
	local XComGameState_Unit TargetState;
	local XComGameState_Ability AbilityState;
	local int ObjectID;
	local UnitValue UnitVal;

	if (EffectApplyResult != 'AA_Success')
	{
		return;
	}

	TargetState = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(ActionMetadata.StateObject_NewState.ObjectID));
	if (TargetState == none)
		return;
	TargetState.GetUnitValue('RT_InterruptAbilityStateObjectID', UnitVal);
	ObjectID = UnitVal.fValue;

	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(ObjectID));
	if(AbilityState == none) {
		`RTLOG("RudimentaryCreaturesAffectTargetVisualization failed to find an abilitystate for object ID " $ ObjectID);
		return;
	}

	class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ActionMetadata, VisualizeGameState.GetContext(), AbilityState.GetMyTemplate().LocFriendlyName $ ": " $ default.LocPsionicallyInterruptedName, '', eColor_Attention, class'UIUtilities_Image'.const.UnitStatus_Stunned);
	class'X2StatusEffects'.static.UpdateUnitFlag(ActionMetadata, VisualizeGameState.GetContext());
}

//---------------------------------------------------------------------------------------
//---Unwilling Conduits------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTUnwillingConduits() {
	local RTAbilityTemplate							Template;
	local X2Effect_ApplyWeaponDamage				DamageEffect;
	local X2AbilityTrigger_EventListener			Trigger;
	local X2AbilityMultiTarget_AllUnits				MultiTarget;
	local X2Condition_UnitEffects					UnitEffectCondition;
	local X2Condition_UnitProperty					UnitPropertyCondition;
	local X2Effect_Persistent						VFXEffect;

	`CREATE_X2TEMPLATE(class'RTAbilityTemplate', Template, 'RTUnwillingConduits');

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_unwillingconduits";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.ConcealmentRule = eConceal_Always;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bCrossClassEligible = false;
	// Template.bSkipFireAction = true;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.Deadeye;

	MultiTarget = new class'X2AbilityMultiTarget_AllUnits';
	MultiTarget.bDontAcceptNeutralUnits = false;
	MultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	Template.AbilityMultiTargetStyle = MultiTarget;

	UnitEffectCondition = new class'X2Condition_UnitEffects';
	UnitEffectCondition.AddRequireEffect(default.OverTheShoulderEffectName, 'AA_NotAUnit');
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.RequireWithinRange = true;
	UnitPropertyCondition.WithinRange = default.OTS_RADIUS * class'XComWorldData'.const.WORLD_StepSize; // unreal units

	Template.AbilityMultiTargetConditions.AddItem(UnitEffectCondition);
	Template.AbilityMultiTargetConditions.AddItem(UnitPropertyCondition);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	DamageEffect.bIgnoreBaseDamage = true;
	DamageEffect.bIgnoreArmor = true;
	DamageEffect.bBypassShields = true;
	DamageEffect.EffectDamageValue = default.UNWILL_DMG;
	Template.AddMultiTargetEffect(DamageEffect);

	VFXEffect = new class'X2Effect_Persistent';
	VFXEffect.VFXTemplateName = default.UnwillingConduitDamageParticleString;
	Template.AddMultiTargetEffect(VFXEffect);

	VFXEffect.VFXTemplateName = default.UnwillingConduitRestoreParticleString;
	Template.AddShooterEffect(VFXEffect);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = default.UnitUsedPsionicAbilityEvent;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'RTGameState_Ability'.static.UnwillingConduitEvent;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.CinescriptCameraType = "Psionic_FireAtUnit";
	Template.CustomFireAnim = 'HL_Psi_SelfCast';

	Template.AdditionalAbilities.AddItem('RTUnwillingConduitsIcon');

	return Template;
}

//---------------------------------------------------------------------------------------
//---Domination--------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTDomination() {
	local X2AbilityTemplate Template;
	local RTEffect_ExtendEffectDuration Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTDomination');

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_domination";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bCrossClassEligible = false;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.Deadeye;

	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	Effect = new class'RTEffect_ExtendEffectDuration';
	Effect.BuildPersistentEffect(1, true, true, false);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Effect.bSelfBuff = true;
	Effect.AbilityToExtendName = default.RTMindControlTemplateName;
	Effect.EffectToExtendName = default.RTMindControlEffectName;
	Effect.iDurationExtension = default.DOMINATION_STRENGTH;

	Template.AddTargetEffect(Effect);

	return Template;
}
//---------------------------------------------------------------------------------------
//---Technopathy-------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTTechnopathy() {
	local X2AbilityTemplate Template;

	Template = PurePassive(default.RTTechnopathyTemplateName, "img:///RisingTidesContentPackage.PerkIcons.rt_technopathy", true, 'eAbilitySource_Psionic');

	Template.AdditionalAbilities.AddItem('RTFinalizeTechnopathyHack');
	Template.AdditionalAbilities.AddItem('RTCancelTechnopathyHack');
	Template.AdditionalAbilities.AddItem('RTTechnopathy_Hack');
	Template.AdditionalAbilities.AddItem('RTTechnopathy_Chest');
	Template.AdditionalAbilities.AddItem('RTTechnopathy_Workstation');
	Template.AdditionalAbilities.AddItem('RTTechnopathy_ObjectiveChest');

	return Template;
}

//---------------------------------------------------------------------------------------
//---Sibyl's Gaze------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTSibyl() {
	local X2AbilityTemplate Template;
	local RTEffect_ExtendEffectDuration Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTSibyl');

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_sibylsgaze";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bCrossClassEligible = false;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.Deadeye;

	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	Effect = new class'RTEffect_ExtendEffectDuration';
	Effect.BuildPersistentEffect(1, true, true, false);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Effect.bSelfBuff = true;
	Effect.AdditionalEvents.AddItem('UnitMoveFinished');
	Effect.AbilityToExtendName = 'OverTheShoulder';
	Effect.EffectToExtendName = default.OverTheShoulderEffectName;
	Effect.iDurationExtension = default.SIBYL_STRENGTH;
	Template.AddTargetEffect(Effect);

	Effect = new class'RTEffect_ExtendEffectDuration';
	Effect.BuildPersistentEffect(1, true, true, false);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Effect.bSelfBuff = true;
	Effect.AdditionalEvents.AddItem('UnitMoveFinished');
	Effect.AbilityToExtendName = 'RTTriangulation';
	Effect.EffectToExtendName = default.OverTheShoulderEffectName;
	Effect.iDurationExtension = default.SIBYL_STRENGTH;
	Template.AddTargetEffect(Effect);

	Effect = new class'RTEffect_ExtendEffectDuration';
	Effect.BuildPersistentEffect(1, true, true, false);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Effect.bSelfBuff = true;
	Effect.AdditionalEvents.AddItem('UnitMoveFinished');
	Effect.AbilityToExtendName = 'RTTheSixPathsOfPainOverride';
	Effect.EffectToExtendName = default.OverTheShoulderEffectName;
	Effect.iDurationExtension = default.SIBYL_STRENGTH;
	Template.AddTargetEffect(Effect);

	return Template;
}
//---------------------------------------------------------------------------------------
//---Echoed Agony------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTEchoedAgony() {
	local X2AbilityTemplate Template;
	local X2Condition_UnitEffects OTSCondition;
	local X2Condition_UnitProperty Condition;
	local RTAbilityToHitCalc_PanicCheck PanicHitCalc;
	local X2AbilityTrigger_EventListener Trigger;

	`CREATE_X2TEMPLATE(class'RTAbilityTemplate', Template, 'RTEchoedAgony');

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_echoedagony";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';

	PanicHitCalc = new class'RTAbilityToHitCalc_PanicCheck'; // modified to test robotic hacking defense instead of their will
	Template.AbilityToHitCalc = PanicHitCalc;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityMultiTargetStyle = new class'X2AbilityMultiTarget_AllUnits'; // otscondition will handle 'range check', psionic property will handle enemy check

	Template.AbilityMultiTargetConditions.AddItem(default.PsionicTargetingProperty);

	Template.AddMultiTargetEffect(CreateEchoedAgonyPanicEventEffect());
	// Template.AddMultiTargetEffect(class'X2StatusEffects'.static.CreatePanickedStatusEffect());

	Template.AddShooterEffectExclusions();
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	OTSCondition = new class'X2Condition_UnitEffects';
	OTSCondition.AddRequireEffect(default.OverTheShoulderEffectName, 'AA_AbilityUnavailable');
	Template.AbilityMultiTargetConditions.AddItem(OTSCondition);

	Condition = new class'X2Condition_UnitProperty';
	Condition.ExcludeImpaired = true;
	Condition.ExcludePanicked = true;
	// Template.AbilityShooterConditions.AddItem(Condition);
	Condition.ExcludeImpaired = false;
	Template.AbilityMultiTargetConditions.AddItem(Condition);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'UnitTakeEffectDamage';  // low to moderate panic chance
	Trigger.ListenerData.EventFn = class'RTGameState_Ability'.static.EchoedAgonyListener;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'UnitPanicked';          // moderate panic chance
	Trigger.ListenerData.EventFn = class'RTGameState_Ability'.static.EchoedAgonyListener;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'RTFeedback';            // moderate to high panic chance
	Trigger.ListenerData.EventFn = class'RTGameState_Ability'.static.EchoedAgonyListener;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	// Template.bShowActivation = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;

	Template.AdditionalAbilities.AddItem('RTEchoedAgonyIcon');
	Template.AdditionalAbilities.AddItem(default.EchoedAgonyEffectAbilityTemplateName);
	return Template;
}

static function X2Effect_ImmediateMultiTargetAbilityActivation CreateEchoedAgonyPanicEventEffect()
{
	local X2Effect_ImmediateMultiTargetAbilityActivation	EchoedAgonyEffect;

	EchoedAgonyEffect = new class 'X2Effect_ImmediateMultiTargetAbilityActivation';

	EchoedAgonyEffect.BuildPersistentEffect(1, false, false, , eGameRule_PlayerTurnBegin);
	EchoedAgonyEffect.EffectName = 'TriggerEchoedAgonyEffect';
	EchoedAgonyEffect.AbilityName = default.EchoedAgonyEffectAbilityTemplateName;
	EchoedAgonyEffect.bRemoveWhenTargetDies = true;
	EchoedAgonyEffect.DuplicateResponse = eDupe_Allow;

	return EchoedAgonyEffect;
}

static function X2AbilityTemplate RTCreateEchoedAgonyEffectAbility()
{
	local X2AbilityTemplate             Template;
	local X2Effect_Panicked             PanicEffect;
	local RTAbilityToHitCalc_PanicCheck	PanicHitCalc;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.EchoedAgonyEffectAbilityTemplateName);

	Template.bDontDisplayInAbilitySummary = true;
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');      //  ability is activated by another ability that hits

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	PanicHitCalc = new class'RTAbilityToHitCalc_PanicCheck'; // modified to test robotic hacking defense instead of their will
	Template.AbilityToHitCalc = PanicHitCalc;

	PanicEffect = class'X2StatusEffects'.static.CreatePanickedStatusEffect();
	PanicEffect.MinStatContestResult = 1;
	PanicEffect.MaxStatContestResult = 0;
	PanicEffect.bRemoveWhenSourceDies = true;
	Template.AddTargetEffect(PanicEffect);

	Template.bSkipPerkActivationActions = true;
	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Guilty Conscience-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTGuiltyConscience() {
	return PurePassive('RTGuiltyConscience', "img:///RisingTidesContentPackage.PerkIcons.rt_guiltyconscience", false, 'eAbilitySource_Psionic');
}

static function RTEffect_GuiltyConscience CreateGuiltyConscienceEffect(int TriggerThreshold) {
	local RTEffect_GuiltyConscience Effect;
	local X2Condition_AbilityProperty Condition;

	Effect = new class'RTEffect_GuiltyConscience';
	Effect.iTriggerThreshold = TriggerThreshold;
	Effect.BuildPersistentEffect(2, false, true, false, eGameRule_PlayerTurnBegin); // 2 turn duration means it won't get removed by OTS
	Effect.DuplicateResponse = eDupe_Refresh;
	Effect.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_guiltyconscience";
	Effect.EffectName = default.GuiltyConscienceEffectName;
	Effect.GuiltyConscienceEventName = default.GuiltyConscienceEventName;
	Effect.TargetConditions.AddItem(default.PsionicTargetingProperty);

	Condition = new class'X2Condition_AbilityProperty';
	Condition.OwnerHasSoldierAbilities.AddItem('RTGuiltyConscience');
	Effect.TargetConditions.AddItem(Condition);

	return Effect;
}

static function X2AbilityTemplate RTGuiltyConscienceEvent() {
	local X2AbilityTemplate					Template;
	local X2AbilityTrigger_EventListener	Trigger;
	local X2Effect_PersistentStatChange		Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTGuiltyConscienceEvent');

	Template.bDontDisplayInAbilitySummary = true;
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_guiltyconscience";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetConditions.AddItem(default.PsionicTargetingProperty);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	Effect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect(false,,true);
	Effect.TargetConditions.Length = 0; // we handle this on the abilty itself
	Template.AddTargetEffect(Effect);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = default.GuiltyConscienceEventName;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.VoidRiftInsanityListener;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.AdditionalAbilities.AddItem('RTGuiltyConscience');
	return Template;
}

//---------------------------------------------------------------------------------------
//---Lift--------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTLift() {
	local X2AbilityTemplate 					Template;
	//local X2Effect_Stunned 						StunEffect;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2AbilityCooldown						Cooldown;
	//local RTCondition_UnitSize					UnitSizeCondition;
	local X2AbilityTarget_Cursor				CursorTarget;
	local X2AbilityMultiTarget_Radius			RadiusMultiTarget;
	local X2Effect_PersistentTraversalChange	TraversalEffect;
	local RTCondition_VerticalClearance			HeightCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTLift');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash"; //TODO: Change this
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Offensive;

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.LIFT_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	HeightCondition = new class'RTCondition_VerticalClearance';
	HeightCondition.fVerticalSpaceRequirement = class'XComWorldData'.const.WORLD_FloorHeight * 2;

	Template.AbilityMultiTargetConditions.AddItem(HeightCondition);
	Template.AbilityMultiTargetConditions.AddItem(default.LivingHostileUnitOnlyProperty);


	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = 24;            //  meters
	Template.AbilityTargetStyle = CursorTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = default.LIFT_RADIUS; // 2.5 default
	RadiusMultiTarget.bAddPrimaryTargetAsMultiTarget = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	Template.TargetingMethod = class'X2TargetingMethod_GremlinAOE';

	TraversalEffect = new class'X2Effect_PersistentTraversalChange';
	TraversalEffect.AddTraversalChange(eTraversal_Launch, true);
	TraversalEffect.AddTraversalChange(eTraversal_Flying, true);

	Template.AddMultiTargetEffect(TraversalEffect);
	Template.AddMultiTargetEffect(class'RTEffectBuilder'.static.RTCreateLiftEffect(default.LIFT_DURATION * 2));

	Template.ModifyNewContextFn = RTLift_ModifyActivatedAbilityContext;
	Template.BuildNewGameStateFn = RTLift_BuildGameState;

	// TODO: Change this
	Template.bSkipFireAction = true;
	Template.BuildVisualizationFn = RTLift_BuildVisualization;

	// This ability is 'offensive' and can be interrupted!
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	return Template;
}

simulated function RTLift_ModifyActivatedAbilityContext(XComGameStateContext Context) {
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameStateHistory History;
	local TTile EndTileLocation;
	//local XComWorldData World;
	local PathingInputData InputData, EmptyInput;
	local PathingResultData ResultData, EmptyResult;
	local int i;

	History = `XCOMHISTORY;
	//World = `XWORLD;

	AbilityContext = XComGameStateContext_Ability(Context);
	for(i = 0; i < AbilityContext.InputContext.MultiTargets.Length; i++) {

		InputData = EmptyInput;
		ResultData = EmptyResult;

		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.MultiTargets[i].ObjectID));


		EndTileLocation = UnitState.TileLocation;
		EndTileLocation.Z = UnitState.TileLocation.Z + 2;

		// solve the path to get it to the target location
		class'X2PathSolver'.static.BuildPath(UnitState, UnitState.TileLocation, EndTileLocation, InputData.MovementTiles, false);

		// get the path points
		class'X2PathSolver'.static.GetPathPointsFromPath(UnitState, InputData.MovementTiles, InputData.MovementData);

		// make the flight path nice and smooth
		class'XComPath'.static.PerformStringPulling(XGUnitNativeBase(UnitState.GetVisualizer()), InputData.MovementData);

		//Now add the path to the input context
		InputData.MovingUnitRef = UnitState.GetReference();
		AbilityContext.InputContext.MovementPaths.AddItem(InputData);

		// Update the result context's PathTileData, without this the AI doesn't know it has been seen and will use the invisible teleport move action
		class'X2TacticalVisibilityHelpers'.static.FillPathTileData(UnitState.ObjectID, InputData.MovementTiles, ResultData.PathTileData);
		AbilityContext.ResultContext.PathResults.AddItem(ResultData);
	}
}

simulated function XComGameState RTLift_BuildGameState(XComGameStateContext Context) {
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability AbilityContext;
	//local vector NewLocation;
	local TTile NewTileLocation;
	//local XComWorldData World;
	local X2EventManager EventManager;
	local int i;

	//World = `XWORLD;
	EventManager = `XEVENTMGR;

	//Build the new game state frame
	NewGameState = TypicalAbility_BuildGameState(Context);

	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());
	for(i = 0; i < AbilityContext.InputContext.MultiTargets.Length; i++) {
		UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', AbilityContext.InputContext.MultiTargets[i].ObjectID));

		NewTileLocation = UnitState.TileLocation;
		NewTileLocation.Z += 2;
		UnitState.SetVisibilityLocation(NewTileLocation);

		NewGameState.AddStateObject(UnitState);


		EventManager.TriggerEvent('ObjectMoved', UnitState, UnitState, NewGameState);
		EventManager.TriggerEvent('UnitMoveFinished', UnitState, UnitState, NewGameState);
	}



	//Return the game state we have created
	return NewGameState;
}

simulated function RTLift_BuildVisualization(XComGameState VisualizeGameState) {
	local XComGameStateHistory History;
	local XComGameStateContext_Ability  AbilityContext;
	local StateObjectReference InteractingUnitRef;
	local VisualizationActionMetadata BuildData, InitData;
	local int i;

	TypicalAbility_BuildVisualization(VisualizeGameState);

	History = class'XComGameStateHistory'.static.GetGameStateHistory();

	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());

	for(i = 0; i < AbilityContext.InputContext.MultiTargets.Length; i++) {
		InteractingUnitRef = AbilityContext.InputContext.MultiTargets[i];

		BuildData = InitData;
		BuildData.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
		BuildData.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
		BuildData.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

		// Fly up actions
		class'X2VisualizerHelpers'.static.ParsePath(AbilityContext, BuildData);
	}
}

//---------------------------------------------------------------------------------------
//---Knowledge is Power------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTKnowledgeIsPower() {
	return PurePassive('RTKnowledgeIsPower', "img:///RisingTidesContentPackage.PerkIcons.UIPerk_overwatch_cycle_kip", false, 'eAbilitySource_Psionic');
}


static function RTEffect_KnowledgeIsPower CreateKnowledgeIsPowerEffect(int _StackCap, float _CritChancePerStack) {
	local RTEffect_KnowledgeIsPower Effect;
	local X2Condition_AbilityProperty Condition;

	Effect = new class'RTEffect_KnowledgeIsPower';
	Effect.BuildPersistentEffect(2, false, true, false, eGameRule_PlayerTurnEnd);
	Effect.TargetConditions.AddItem(class'RTAbility_GhostAbilitySet'.default.PsionicTargetingProperty);
	Effect.DuplicateResponse = eDupe_Refresh;
	Effect.bRemoveWhenTargetDies = true;
	Effect.bRemoveWhenSourceDies = true;
	Effect.SetDisplayInfo(ePerkBuff_Penalty, default.KIPFriendlyName, default.KIPFriendlyDesc, default.KIPIconPath, true,,'eAbilitySource_Psionic');
	Effect.StackCap = _StackCap;
	Effect.CritChancePerStack = _CritChancePerStack;
	Effect.EffectName = default.KnowledgeIsPowerEffectName;
	Effect.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_overwatch_cycle_kip";


	Condition = new class'X2Condition_AbilityProperty';
	Condition.OwnerHasSoldierAbilities.AddItem('RTKnowledgeIsPower');
	Effect.TargetConditions.AddItem(Condition);

	return Effect;
}

//---------------------------------------------------------------------------------------
//---Crushing Grasp----------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTCrushingGrasp() {
	local X2AbilityTemplate 					Template;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2AbilityCooldown						Cooldown;
	local X2AbilityTarget_Cursor				CursorTarget;
	local X2AbilityMultiTarget_Radius			RadiusMultiTarget;
	local X2Effect_ApplyWeaponDamage			WorldDamage;
	local X2Effect_Stunned						StunnedEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTCrushingGrasp');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_stasis_psi_crushinggrasp";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Offensive;

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.LIFT_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityMultiTargetConditions.AddItem(default.LivingHostileUnitOnlyProperty);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = 24;            //  meters

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = default.LIFT_RADIUS; // 2.5 default
	RadiusMultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	RadiusMultiTarget.bAddPrimaryTargetAsMultiTarget = true;

	Template.AbilityTargetStyle = CursorTarget;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;
	Template.TargetingMethod = class'X2TargetingMethod_GremlinAOE';

	WorldDamage = new class'X2Effect_ApplyWeaponDamage';
	WorldDamage.bIgnoreBaseDamage = true;
	WorldDamage.bApplyWorldEffectsForEachTargetLocation = true;
	WorldDamage.EnvironmentalDamageAmount = 50;
	Template.AddMultiTargetEffect(WorldDamage);

	StunnedEffect = class'X2StatusEffects'.static.CreateStunnedStatusEffect(default.LIFT_DURATION * 2, 100, false);
	StunnedEffect.SetDisplayInfo(ePerkBuff_Penalty, class'X2StatusEffects'.default.StunnedFriendlyName, class'X2StatusEffects'.default.StunnedFriendlyDesc, "img:///UILibrary_PerkIcons.UIPerk_stun");
	StunnedEffect.bRemoveWhenSourceDies = true;
	StunnedEffect.EffectHierarchyValue = 955;
	StunnedEffect.EffectName = 'RTCrushingGraspEffect';
	Template.AddMultiTargetEffect(StunnedEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	Template.CustomFireAnim = 'HL_Psi_ProjectileMedium';
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	// Template.BuildVisualizationFn = class'X2Ability_PsiOperativeAbilitySet'.static.Stasis_BuildVisualization;

	// This ability is 'offensive' and can be interrupted!
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.PostActivationEvents.AddItem(default.UnitUsedPsionicAbilityEvent);

	return Template;


}

//---------------------------------------------------------------------------------------
//---Psionic Storm-----------------------------------------------------------------------
//---------------------------------------------------------------------------------------

// place storm ability
// mark tiles
// add delayed damage activation effect	to shooter
// damage effect immediately activates (against unmarked enemies)
// mark units hit (PsionicStormMark, removed PlayerEndTurn)
// use charges

// sustained damage ability
// next turn (PlayerBeginTurn), damage effect activates on all marked tiles (against unmarked enemies), it also adds the delayed damage activation effect to shooter
// remark all tiles
// mark units hit (PsionicStormMark, removed PlayerEndTurn)

// while the shooter is affected by the delayed damage activation effect
// enemy units that start a move outside of the marked tiles and passes through them are hit by the sustained damage ability

// end storms ability
// unmark all tiles
// remove all delayed damage activation effects
// deal final damage and perk fx
// restore place storm ability charges

static function X2AbilityTemplate RTPsionicStorm() {
	local X2AbilityTemplate 						Template;
	local X2AbilityCost_ActionPoints				ActionPointCost;
	local X2AbilityCost_Charges						Charges;
	local X2AbilityCooldown							Cooldown;
	local X2AbilityTarget_Cursor					CursorTarget;
	local X2AbilityMultiTarget_Radius				RadiusMultiTarget;
	local X2Effect_ApplyWeaponDamage				ImmediateDamageEffect;
	local X2Effect_DelayedAbilityActivation			SustainedDamageEffect;
	local RTEffect_MarkValidActivationTiles			MarkTilesEffect;
	local X2Effect_Persistent						MarkEffect;
	local X2Condition_UnitEffectsWithAbilitySource	MarkCondition;


	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTPsionicStorm');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_psi_lightning_psistorm";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Offensive;

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.PSIONICSTORM_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Charges = new class'X2AbilityCost_Charges';
	Charges.NumCharges = 1;
	Template.AbilityCosts.AddItem(Charges);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = 24;            //  meters

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = default.PSIONICSTORM_RADIUS; // 7.5 default
	RadiusMultiTarget.bAddPrimaryTargetAsMultiTarget = true;
	RadiusMultiTarget.bIgnoreBlockingCover = true;

	Template.AbilityTargetStyle = CursorTarget;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;
	Template.TargetingMethod = class'X2TargetingMethod_VoidRift';

	MarkTilesEffect = new class'RTEffect_MarkValidActivationTiles';
	MarkTilesEffect.AbilityToMark = 'RTPsionicStormSustained';
	MarkTilesEffect.OnlyUseTargetLocation = true;
	MarkTilesEffect.bResetMarkedTiles = false;
	Template.AddShooterEffect(MarkTilesEffect);

	SustainedDamageEffect = new class 'X2Effect_DelayedAbilityActivation';
	SustainedDamageEffect.BuildPersistentEffect(1, false, false, , eGameRule_PlayerTurnBegin);
	SustainedDamageEffect.EffectName = default.PsionicStormSustainedActivationEffectName;
	SustainedDamageEffect.TriggerEventName = default.PsionicStormSustainedDamageEvent;
	SustainedDamageEffect.DuplicateResponse = eDupe_Ignore;
	SustainedDamageEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true, , Template.AbilitySourceName);
	Template.AddShooterEffect(SustainedDamageEffect);

	ImmediateDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	ImmediateDamageEffect.bIgnoreBaseDamage = true;
	ImmediateDamageEffect.bIgnoreArmor = true;
	ImmediateDamageEffect.EffectDamageValue = default.PSISTORM_DMG;

	//  Do not shoot targets that were already hit by this unit this turn with this ability
	MarkCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	MarkCondition.AddExcludeEffect(default.PsistormMarkedEffectName, 'AA_UnitIsImmune');
	ImmediateDamageEffect.TargetConditions.AddItem(MarkCondition);

	Template.AddMultiTargetEffect(ImmediateDamageEffect);

	//  Mark the target as shot by this unit so it cannot be shot again this turn
	MarkEffect = new class'X2Effect_Persistent';
	MarkEffect.EffectName = default.PsistormMarkedEffectName;
	MarkEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
	MarkEffect.SetupEffectOnShotContextResult(true, true);      //  mark them regardless of whether the shot hit or missed
	Template.AddMultiTargetEffect(MarkEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.CustomFireAnim = 'HL_Psi_MindControl';
	//Template.CustomFireAnim = 'HL_Psi_ProjectileMedium';

	Template.BuildVisualizationFn = DimensionalRiftStage1_BuildVisualization;
	Template.BuildAffectedVisualizationSyncFn = DimensionalRigt1_BuildAffectedVisualization;
	Template.CinescriptCameraType = "Psionic_FireAtLocation";

	// This ability is 'offensive' and can be interrupted!
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.AdditionalAbilities.AddItem('RTPsionicStormSustained');
	Template.AdditionalAbilities.AddItem('RTEndPsistorms');
	Template.AdditionalAbilities.AddItem('RTEndPsistorms_Dead');
	Template.AdditionalAbilities.AddItem('RTSetPsistormCharges');
	Template.PostActivationEvents.AddItem(default.UnitUsedPsionicAbilityEvent);

	return Template;
}

simulated function DimensionalRiftStage1_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;
	local X2VisualizerInterface Visualizer;
	local VisualizationActionMetadata BuildData, AvatarBuildData, InitData;
	local X2Action_PlayEffect EffectAction;
	local X2Action_StartStopSound SoundAction;
	local XComGameState_Unit AvatarUnit;
	local XComWorldData World;
	local vector TargetLocation;
	local TTile TargetTile;
	local X2Action_TimedWait WaitAction;
	local X2Action_PlaySoundAndFlyOver SoundCueAction;
	local int i, j;
	local X2VisualizerInterface TargetVisualizerInterface;
	local X2Action_ExitCover ExitCoverAction;
	local XComGameState_BaseObject Placeholder_old, Placeholder_new;
	local XComGameState_Ability Ability;
	local X2Action_Fire_CloseUnfinishedAnim CloseFireAction;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());

	//Configure the visualization track for the shooter
	//****************************************************************************************
	InteractingUnitRef = Context.InputContext.SourceObject;
	AvatarBuildData.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	AvatarBuildData.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	AvatarBuildData.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	AvatarUnit = XComGameState_Unit(AvatarBuildData.StateObject_NewState);
	History.GetCurrentAndPreviousGameStatesForObjectID(AvatarUnit.FindAbility('RTPsionicStorm').ObjectID,
														 Placeholder_old, Placeholder_new,
														 eReturnType_Reference,
														 VisualizeGameState.HistoryIndex);

	Ability = XComGameState_Ability(Placeholder_old);

	if( AvatarUnit != none )
	{
		World = `XWORLD;

		// Exit cover
		ExitCoverAction = X2Action_ExitCover(class'X2Action_ExitCover'.static.AddToVisualizationTree(AvatarBuildData, VisualizeGameState.GetContext(), false, AvatarBuildData.LastActionAdded));

		//If we were interrupted, insert a marker node for the interrupting visualization code to use. In the move path version above, it is expected for interrupts to be 
		//done during the move.
		if (Context.InterruptionStatus != eInterruptionStatus_None)
		{
			//Insert markers for the subsequent interrupt to insert into
			class'X2Action'.static.AddInterruptMarkerPair(AvatarBuildData, Context, ExitCoverAction);
		}

		//class'X2Action_Fire'.static.AddToVisualizationTree(AvatarBuildData, VisualizeGameState.GetContext(), false, AvatarBuildData.LastActionAdded);
		class'X2Action_Fire_OpenUnfinishedAnim'.static.AddToVisualizationTree(AvatarBuildData, Context);

		// Wait to time the start of the warning FX
		WaitAction = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(AvatarBuildData, VisualizeGameState.GetContext(), false, AvatarBuildData.LastActionAdded));
		WaitAction.DelayTimeSec = 3.5;

		EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(AvatarBuildData, VisualizeGameState.GetContext(), false, AvatarBuildData.LastActionAdded));
		EffectAction.EffectName = "FX_Psi_Void_Rift.P_Psi_Void_Rift_Activation";
		TargetLocation = Context.InputContext.TargetLocations[0];
		TargetTile = World.GetTileCoordinatesFromPosition(TargetLocation);
		EffectAction.EffectLocation = World.GetPositionFromTileCoordinates(TargetTile);

		//WaitAction = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(AvatarBuildData, VisualizeGameState.GetContext(), false, AvatarBuildData.LastActionAdded));
		//WaitAction.DelayTimeSec = 1.5;

		// Display the Warning FX (covert to tile and back to vector because stage 2 is at the GetPositionFromTileCoordinates coord
		EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(AvatarBuildData, VisualizeGameState.GetContext(), false, AvatarBuildData.LastActionAdded));
		EffectAction.EffectName = "FX_Psi_Void_Rift.P_Psi_Void_Rift";
		TargetLocation = Context.InputContext.TargetLocations[0];
		TargetTile = World.GetTileCoordinatesFromPosition(TargetLocation);
		EffectAction.EffectLocation = World.GetPositionFromTileCoordinates(TargetTile);

		if(Ability.GetCharges() == default.PSIONICSTORM_NUMSTORMS) {// checking if this is not the first storm or not
			SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(AvatarBuildData, VisualizeGameState.GetContext(), false, AvatarBuildData.LastActionAdded));
			SoundAction.Sound = new class'SoundCue';
			SoundAction.Sound.AkEventOverride = AkEvent'SoundX2AvatarFX.Avatar_Ability_Dimensional_Rift_Target_Activate';
			SoundAction.iAssociatedGameStateObjectId = AvatarUnit.ObjectID;
			SoundAction.bStartPersistentSound = true;
			SoundAction.bIsPositional = true;
			SoundAction.vWorldPosition = EffectAction.EffectLocation;

			SoundCueAction = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(AvatarBuildData, Context));
			SoundCueAction.SetSoundAndFlyOverParameters(SoundCue'SoundX2AvatarFX.Avatar_Ability_Dimensional_Rift_Target_Activate_Cue', "", '', eColor_Good);
		}

		CloseFireAction = X2Action_Fire_CloseUnfinishedAnim(class'X2Action_Fire_CloseUnfinishedAnim'.static.AddToVisualizationTree(AvatarBuildData, Context));
		CloseFireAction.bNotifyTargets = true;

		Visualizer = X2VisualizerInterface(AvatarBuildData.VisualizeActor);
		if( Visualizer != none )
		{
			Visualizer.BuildAbilityEffectsVisualization(VisualizeGameState, AvatarBuildData);
		}

		class'X2Action_EnterCover'.static.AddToVisualizationTree(AvatarBuildData, VisualizeGameState.GetContext(), false, AvatarBuildData.LastActionAdded);

		// Wait to time the damage
		WaitAction = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(AvatarBuildData, Context, false, WaitAction));
		WaitAction.DelayTimeSec = 4;
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
			BuildData = AvatarBuildData;
		}
		else
		{
			BuildData = InitData;
			BuildData.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
			BuildData.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
			BuildData.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

			class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(BuildData, VisualizeGameState.GetContext(), false, BuildData.LastActionAdded);
		}
		for( j = 0; j < Context.ResultContext.MultiTargetEffectResults[i].Effects.Length; ++j )
		{
			Context.ResultContext.MultiTargetEffectResults[i].Effects[j].AddX2ActionsForVisualization(VisualizeGameState, BuildData, Context.ResultContext.MultiTargetEffectResults[i].ApplyResults[j]);
		}

		TargetVisualizerInterface = X2VisualizerInterface(BuildData.VisualizeActor);
		if( TargetVisualizerInterface != none )
		{
			//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
			TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, BuildData);
		}
	}


	TypicalAbility_AddEffectRedirects(VisualizeGameState, AvatarBuildData);
}

simulated function DimensionalRigt1_BuildAffectedVisualization(name EffectName, XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata)
{
	local XComGameStateContext_Ability Context;
	local X2Action_PlayEffect EffectAction;
	local X2Action_StartStopSound SoundAction;
	local XComGameState_Unit AvatarUnit;
	local XComWorldData World;
	local vector Location;
	local TTile Tile;
	local XComGameState_Ability	SustainedAbility;
	local XComGameState_BaseObject Placeholder_new, Placeholder_old;

	if( !`XENGINE.IsMultiplayerGame() && EffectName == 'RTPsionicStorm')
	{
		Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
		AvatarUnit = XComGameState_Unit(ActionMetadata.StateObject_NewState);

		if( (Context == none) || (AvatarUnit == none) )
		{
			return;
		}

		World = `XWORLD;


		`XCOMHISTORY.GetCurrentAndPreviousGameStatesForObjectID(AvatarUnit.FindAbility('RTPsionicStormSustained').ObjectID,
													 Placeholder_old, Placeholder_new,
													 eReturnType_Reference,
													 VisualizeGameState.HistoryIndex);

		SustainedAbility = XComGameState_Ability(Placeholder_old);


		foreach SustainedAbility.ValidActivationTiles(Tile) {
			Location = World.GetPositionFromTileCoordinates(Tile);
			// Stop the Warning FX
			EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
			EffectAction.EffectName = "FX_Psi_Void_Rift.P_Psi_Void_Rift";
			EffectAction.EffectLocation = Location;

		}

		//Play Target Activate Sound
		SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		SoundAction.Sound = new class'SoundCue';
		SoundAction.Sound.AkEventOverride = AkEvent'SoundX2AvatarFX.Avatar_Ability_Dimensional_Rift_Target_Activate';
		SoundAction.iAssociatedGameStateObjectId = AvatarUnit.ObjectID;
		SoundAction.bStartPersistentSound = true;
		SoundAction.bIsPositional = true;
		SoundAction.vWorldPosition = EffectAction.EffectLocation;
	}
}

static function X2AbilityTemplate RTPsionicStormSustained() {
	local X2AbilityTemplate								Template;
	local X2AbilityTrigger_EventListener				Trigger;
	local X2Effect_DelayedAbilityActivation				SustainedDamageEffect;
	local X2Effect_ApplyWeaponDamage					ImmediateDamageEffect;
	local X2Condition_UnitEffectsWithAbilitySource		MarkCondition;
	local X2Effect_Persistent							MarkEffect;
	local X2AbilityMultiTarget_Radius					RadiusMultiTarget;

	`CREATE_X2TEMPLATE(class'RTAbilityTemplate', Template, 'RTPsionicStormSustained');

	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_psi_lightning_psistorm";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// TODO: This doesn't actually target self but needs an AbilityTargetStyle
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = default.PSIONICSTORM_RADIUS;
	RadiusMultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = default.PsionicStormSustainedDamageEvent;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'RTGameState_Ability'.static.RTAbilityTriggerEventListener_ValidAbilityLocations;
	Template.AbilityTriggers.AddItem(Trigger);

	SustainedDamageEffect = new class 'X2Effect_DelayedAbilityActivation';
	SustainedDamageEffect.BuildPersistentEffect(1, false, false, , eGameRule_PlayerTurnBegin);
	SustainedDamageEffect.EffectName = default.PsionicStormSustainedActivationEffectName;
	SustainedDamageEffect.TriggerEventName = default.PsionicStormSustainedDamageEvent;
	SustainedDamageEffect.DuplicateResponse = eDupe_Ignore;
	SustainedDamageEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true, , Template.AbilitySourceName);
	Template.AddShooterEffect(SustainedDamageEffect);

	ImmediateDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	ImmediateDamageEffect.bIgnoreBaseDamage = true;
	ImmediateDamageEffect.bIgnoreArmor = true;
	ImmediateDamageEffect.EffectDamageValue = default.PSISTORM_DMG;

	//  Do not shoot targets that were already hit by this unit this turn with this ability
	MarkCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	MarkCondition.AddExcludeEffect(default.PsistormMarkedEffectName, 'AA_UnitIsImmune');
	ImmediateDamageEffect.TargetConditions.AddItem(MarkCondition);

	Template.AddMultiTargetEffect(ImmediateDamageEffect);

	//  Mark the target as shot by this unit so it cannot be shot again this turn
	MarkEffect = new class'X2Effect_Persistent';
	MarkEffect.EffectName = default.PsistormMarkedEffectName;
	MarkEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
	MarkEffect.SetupEffectOnShotContextResult(true, true);      //  mark them regardless of whether the shot hit or missed
	Template.AddMultiTargetEffect(MarkEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	// TODO: Change this
	Template.bSkipFireAction = true;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate RTEndPsistorms() {
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Effect_RemoveEffects		RemoveEffect;
	local X2Condition_UnitEffects		EffectCondition;
	local RTEffect_RemoveValidActivationTiles RemoveTargetedAreaEffect;
	local RTEffect_ResetCharges					ResetChargesEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTEndPsistorms');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_defend_panic";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityCosts.AddItem(default.FreeActionCost);

	EffectCondition = new class'X2Condition_UnitEffects';
	EffectCondition.AddRequireEffect(default.PsionicStormSustainedActivationEffectName, 'AA_UnitIsImmune');
	Template.AbilityShooterConditions.AddItem(EffectCondition);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'UnitDied';
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter  = eFilter_Unit;
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Template.AbilityTriggers.AddItem(Trigger);

	RemoveEffect = new class'X2Effect_RemoveEffects';
	RemoveEffect.EffectNamesToRemove.AddItem(default.PsionicStormSustainedActivationEffectName);
	Template.AddShooterEffect(RemoveEffect);

	ResetChargesEffect = new class'RTEffect_ResetCharges';
	ResetChargesEffect.BaseCharges = default.PSIONICSTORM_NUMSTORMS;
	ResetChargesEffect.AbilityToReset = 'RTPsionicStorm';
	Template.AddShooterEffect(ResetChargesEffect);

	RemoveTargetedAreaEffect = new class'RTEffect_RemoveValidActivationTiles';
	RemoveTargetedAreaEffect.AbilityToUnmark = 'RTPsionicStormSustained';
	Template.AddShooterEffect(RemoveTargetedAreaEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	// TODO:
	Template.bSkipFireAction = true;
	Template.BuildVisualizationFn = DimensionalRiftStage2_BuildVisualization;


	return Template;
}

static function X2AbilityTemplate RTEndPsistorms_Dead() {
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Effect_RemoveEffects		RemoveEffect;
	//local X2Condition_UnitEffects		EffectCondition;
	local RTEffect_RemoveValidActivationTiles RemoveTargetedAreaEffect;
	local RTEffect_ResetCharges					ResetChargesEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTEndPsistorms_Dead');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_defend_panic";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'UnitDied';
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter  = eFilter_Unit;
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Template.AbilityTriggers.AddItem(Trigger);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'UnitRemovedFromPlay';
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter  = eFilter_Unit;
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Template.AbilityTriggers.AddItem(Trigger);

	RemoveEffect = new class'X2Effect_RemoveEffects';
	RemoveEffect.EffectNamesToRemove.AddItem(default.PsionicStormSustainedActivationEffectName);
	Template.AddShooterEffect(RemoveEffect);

	ResetChargesEffect = new class'RTEffect_ResetCharges';
	ResetChargesEffect.BaseCharges = default.PSIONICSTORM_NUMSTORMS;
	ResetChargesEffect.AbilityToReset = 'RTPsionicStorm';
	Template.AddShooterEffect(ResetChargesEffect);

	RemoveTargetedAreaEffect = new class'RTEffect_RemoveValidActivationTiles';
	RemoveTargetedAreaEffect.AbilityToUnmark = 'RTPsionicStormSustained';
	Template.AddShooterEffect(RemoveTargetedAreaEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	// TODO:
	Template.bSkipFireAction = true;
	Template.BuildVisualizationFn = DimensionalRiftStage2_BuildVisualization;


	return Template;
}

simulated function DimensionalRiftStage2_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability  Context;
	local StateObjectReference InteractingUnitRef;
	local X2AbilityTemplate AbilityTemplate;
	local VisualizationActionMetadata AvatarBuildData, BuildData, InitData;
	local int i, j;
	local X2VisualizerInterface TargetVisualizerInterface;
	local XComGameState_EnvironmentDamage EnvironmentDamageEvent;
	local XComGameState_WorldEffectTileData WorldDataUpdate;
	local XComGameState_InteractiveObject InteractiveObject;
	local X2Action_PlayEffect EffectAction;
	local X2Action_StartStopSound SoundAction;
	local XComGameState_Unit AvatarUnit;
	local X2Action_TimedInterTrackMessageAllMultiTargets MultiTargetMessageAction;
	local X2Action_TimedWait WaitAction;
	local int EffectIndex;

	local XComGameState_BaseObject Placeholder_old, Placeholder_new;
	local XComGameState_Ability SustainedAbility;
	local TTile					Tile;
	local vector				Location;

	History = `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(Context.InputContext.AbilityTemplateName);

	//****************************************************************************************
	//Configure the visualization track for the source
	//****************************************************************************************
	AvatarBuildData = InitData;
	History.GetCurrentAndPreviousGameStatesForObjectID(	InteractingUnitRef.ObjectID,
														AvatarBuildData.StateObject_OldState, AvatarBuildData.StateObject_NewState,
														eReturnType_Reference,
														VisualizeGameState.HistoryIndex);
	AvatarBuildData.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	AvatarUnit = XComGameState_Unit(AvatarBuildData.StateObject_OldState);
	History.GetCurrentAndPreviousGameStatesForObjectID(	AvatarUnit.FindAbility('RTPsionicStormSustained').ObjectID,
														Placeholder_old, Placeholder_new,
														eReturnType_Reference,
														VisualizeGameState.HistoryIndex);

	SustainedAbility = XComGameState_Ability(Placeholder_old);
	if(SustainedAbility.ValidActivationTiles.Length < 1)
		`RedScreenOnce("No Valid Activation Tiles remaining! You will have to find another way.");



	if( AvatarUnit != none )
	{
		// Wait to time the start of the warning FX
		WaitAction = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(AvatarBuildData, VisualizeGameState.GetContext(), false, AvatarBuildData.LastActionAdded));
		WaitAction.DelayTimeSec = class'X2Ability_PsiWitch'.default.DIMENSIONAL_RIFT_STAGE1_START_WARNING_FX_SEC / 10;

		foreach SustainedAbility.ValidActivationTiles(Tile) {
			SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(AvatarBuildData, VisualizeGameState.GetContext(), false, AvatarBuildData.LastActionAdded));
			SoundAction.Sound = new class'SoundCue';
			SoundAction.Sound.AkEventOverride = AkEvent'SoundX2AvatarFX.Stop_AvatarDimensionalRiftLoop';
			SoundAction.iAssociatedGameStateObjectId = AvatarUnit.ObjectID;
			SoundAction.bIsPositional = true;
			SoundAction.bStopPersistentSound = true;

			Location = `XWORLD.GetPositionFromTileCoordinates(Tile);
			// Stop the Warning FX
			EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(AvatarBuildData, VisualizeGameState.GetContext(), false, AvatarBuildData.LastActionAdded));
			EffectAction.EffectName = "FX_Psi_Void_Rift.P_Psi_Void_Rift";
			EffectAction.EffectLocation = Location;
			EffectAction.bStopEffect = true;

			EffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(AvatarBuildData, VisualizeGameState.GetContext(), false, AvatarBuildData.LastActionAdded));
			EffectAction.EffectName = "FX_Psi_Void_Rift.P_Psi_Void_Rift_Deactivation";
			EffectAction.EffectLocation = Location;
		}

		// Notify multi targets of explosion
		MultiTargetMessageAction = X2Action_TimedInterTrackMessageAllMultiTargets(class'X2Action_TimedInterTrackMessageAllMultiTargets'.static.AddToVisualizationTree(AvatarBuildData, VisualizeGameState.GetContext(), false, AvatarBuildData.LastActionAdded));
		MultiTargetMessageAction.SendMessagesAfterSec = class'X2Ability_PsiWitch'.default.DIMENSIONAL_RIFT_STAGE2_NOTIFY_TARGETS_SEC;
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
			BuildData = AvatarBuildData;

			WaitAction = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(BuildData, Context, false, BuildData.LastActionAdded));
			WaitAction.DelayTimeSec = class'X2Ability_PsiWitch'.default.DIMENSIONAL_RIFT_STAGE2_NOTIFY_TARGETS_SEC;
		}
		else
		{
			BuildData = InitData;
			BuildData.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
			BuildData.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
			BuildData.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

			class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(BuildData, Context, false, BuildData.LastActionAdded);
		}

		for( j = 0; j < Context.ResultContext.MultiTargetEffectResults[i].Effects.Length; ++j )
		{
			Context.ResultContext.MultiTargetEffectResults[i].Effects[j].AddX2ActionsForVisualization(VisualizeGameState, BuildData, Context.ResultContext.MultiTargetEffectResults[i].ApplyResults[j]);
		}

		TargetVisualizerInterface = X2VisualizerInterface(BuildData.VisualizeActor);
		if( TargetVisualizerInterface != none )
		{
			//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
			TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, BuildData);
		}
	}

	//****************************************************************************************
	//Configure the visualization tracks for the environment
	//****************************************************************************************

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_EnvironmentDamage', EnvironmentDamageEvent)
	{
		BuildData = InitData;
		BuildData.VisualizeActor = none;
		BuildData.StateObject_NewState = EnvironmentDamageEvent;
		BuildData.StateObject_OldState = EnvironmentDamageEvent;

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityShooterEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityMultiTargetEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityMultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');
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

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityMultiTargetEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityMultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');
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


	TypicalAbility_AddEffectRedirects(VisualizeGameState, AvatarBuildData);
}

static function X2AbilityTemplate RTSetPsistormCharges() {
	local X2AbilityTemplate								Template;
	local X2Effect_RemoveEffects						RemoveEffect;
	local RTEffect_RemoveValidActivationTiles			RemoveTargetedAreaEffect;
	local RTEffect_ResetCharges							ResetChargesEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTSetPsistormCharges');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_psi_lightning_psistorm";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	RemoveEffect = new class'X2Effect_RemoveEffects';
	RemoveEffect.EffectNamesToRemove.AddItem(default.PsionicStormSustainedActivationEffectName);
	Template.AddShooterEffect(RemoveEffect);

	ResetChargesEffect = new class'RTEffect_ResetCharges';
	ResetChargesEffect.BaseCharges = default.PSIONICSTORM_NUMSTORMS;
	ResetChargesEffect.AbilityToReset = 'RTPsionicStorm';
	Template.AddShooterEffect(ResetChargesEffect);

	RemoveTargetedAreaEffect = new class'RTEffect_RemoveValidActivationTiles';
	RemoveTargetedAreaEffect.AbilityToUnmark = 'RTPsionicStormSustained';
	Template.AddShooterEffect(RemoveTargetedAreaEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	Template.bSkipFireAction = true;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Technopathy-------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTFinalizeTechnopathyHack(name FinalizeName = 'RTFinalizeTechnopathyHack')
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityTarget_Single            SingleTarget;

	`CREATE_X2ABILITY_TEMPLATE(Template, FinalizeName);
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_intrusionprotocol";
	Template.bDisplayInUITooltip = false;
	Template.bLimitTargetIcons = true;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.Hostility = eHostility_Neutral;

	// successfully completing the hack requires and costs an action point
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityToHitCalc = new class'X2AbilityToHitCalc_Hacking';
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	Template.AddShooterEffectExclusions();
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.bAllowInteractiveObjects = true;
	Template.AbilityTargetStyle = SingleTarget;

	Template.CinescriptCameraType = "Hack";

	Template.BuildNewGameStateFn = class'X2Ability_DefaultAbilitySet'.static.FinalizeHackAbility_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_DefaultAbilitySet'.static.FinalizeHackAbility_BuildVisualization;

	Template.OverrideAbilities.AddItem( 'FinalizeHack' );

	return Template;
}

static function X2AbilityTemplate RTCancelTechnopathyHack(Name TemplateName = 'RTCancelTechnopathyHack')
{
	local X2AbilityTemplate                 Template;
	local X2AbilityTarget_Single            SingleTarget;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_intrusionprotocol";
	Template.bDisplayInUITooltip = false;
	Template.bLimitTargetIcons = true;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.bAllowInteractiveObjects = true;
	Template.AbilityTargetStyle = SingleTarget;

	Template.CinescriptCameraType = "Hack";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = None;

	Template.OverrideAbilities.AddItem( 'CancelHack' );

	return Template;
}

static function X2AbilityTemplate RTConstructTechnopathyHack(name TemplateName, optional name OverrideTemplateName = 'Hack')
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityTarget_Single            SingleTarget;
	local RTCondition_HackingTarget         HackingTargetCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_comm_hack";
	Template.bDisplayInUITooltip = false;
	Template.bLimitTargetIcons = true;
	Template.bStationaryWeapon = true;
	if(OverrideTemplateName != 'Hack')
	{
		Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.OBJECTIVE_INTERACT_PRIORITY;
		Template.AbilitySourceName = 'eAbilitySource_Psionic';
	}
	else
	{
		Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
		Template.AbilitySourceName = 'eAbilitySource_Psionic';
	}
	Template.Hostility = eHostility_Neutral;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bFreeCost = true;                   //  the FinalizeIntrusion ability will consume the action point
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	HackingTargetCondition = new class'RTCondition_HackingTarget';
	HackingTargetCondition.RequiredAbilityName = OverrideTemplateName; // filter based on the "normal" hacking ability we are replacing
	Template.AbilityTargetConditions.AddItem(HackingTargetCondition);
	Template.AddShooterEffectExclusions();
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;


	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.bAllowInteractiveObjects = true;
	Template.AbilityTargetStyle = SingleTarget;

	Template.FinalizeAbilityName = 'RTFinalizeTechnopathyHack';
	Template.CancelAbilityName = 'RTCancelTechnopathyHack';


	Template.ActivationSpeech = 'AttemptingHack';  // This seems to have the most appropriate lines, mdomowicz 2015_07_09

	Template.CinescriptCameraType = "Hack";

	Template.BuildNewGameStateFn = class'X2Ability_DefaultAbilitySet'.static.HackAbility_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_DefaultAbilitySet'.static.HackAbility_BuildVisualization;

	Template.OverrideAbilities.AddItem( OverrideTemplateName );

	return Template;
}

//---------------------------------------------------------------------------------------
//---Psionic Lash------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTPsionicLash() {
	local X2AbilityTemplate Template;
	local RTEffect_PsionicLash	LashEffect;
	local X2AbilityCooldown Cooldown;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local RTAbilityToHitCalc_StatCheck_UnitVsUnit HitCalc;
	local X2Condition_UnblockedNeighborTile UnblockedNeighborTileCondition;
	local X2Condition_Visibility TargetVisibilityCondition;
	local X2Condition_UnitProperty UnitPropertyCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTPsionicLash');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.UIPerk_loot_psi_psioniclash";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.Hostility = eHostility_Offensive;

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.LASH_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	UnblockedNeighborTileCondition = new class'X2Condition_UnblockedNeighborTile';
	Template.AbilityShooterConditions.AddItem(UnblockedNeighborTileCondition);
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	// the target must be a human. I WILL FIND A WAY TO FIX THIS.
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.FailOnNonUnits = true;
	UnitPropertyCondition.ExcludeRobotic = true;
	UnitPropertyCondition.ExcludeAlien = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	UnitPropertyCondition.ExcludeHostileToSource = false;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(default.StandardSizeProperty);

	Template.AbilityTargetStyle = new class'X2AbilityTarget_Single';

	HitCalc = new class'RTAbilityToHitCalc_StatCheck_UnitVsUnit';
	Template.AbilityToHitCalc = HitCalc;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	LashEffect = new class'RTEffect_PsionicLash';
	Template.AddTargetEffect(LashEffect);

	Template.BuildVisualizationFn = PsionicLash_BuildVisualization;
	Template.CinescriptCameraType = "Viper_StranglePull";
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	// This ability is 'offensive' and can be interrupted!
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.AdditionalAbilities.AddItem('RTPsionicLashAnims');


	Template.PostActivationEvents.AddItem(default.UnitUsedPsionicAbilityEvent);

	return Template;
}

static function X2AbilityTemplate RTPsionicLashAnims()
{
	local X2AbilityTemplate						Template;
	local X2Effect_AdditionalAnimSets	AnimSets;

	//Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTPsionicLashAnims');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aggression";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	//Apply perk at the start of the mission.
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	AnimSets = new class'X2Effect_AdditionalAnimSets';
	AnimSets.AddAnimSetWithPath("DLC_60_ViperSuit.Anims.AS_ViperSuit_F");
	AnimSets.BuildPersistentEffect(1, true, false, false);
	AnimSets.EffectName = 'RTNovaAnimSet';
	Template.AddShooterEffect(AnimSets);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

static simulated function PsionicLash_BuildVisualization(XComGameState VisualizeGameState) {
	local XComGameStateHistory			History;
	local XComGameStateContext_Ability  Context;
	local X2AbilityTemplate             AbilityTemplate;
	local StateObjectReference          InteractingUnitRef;
	local RTAction_PsionicGetOverHere	GetOverHereAction;
	local X2Action_PlaySoundAndFlyOver	SoundAndFlyover;
	local X2VisualizerInterface			Visualizer;
	local XComGameState_Unit            TargetUnit;


	local VisualizationActionMetadata	BuildData, InitData;

	local int							EffectIndex;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(Context.InputContext.AbilityTemplateName);


	//Configure the visualization track for the shooter
	//****************************************************************************************
	InteractingUnitRef = Context.InputContext.SourceObject;
	BuildData = InitData;
	BuildData.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	BuildData.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	BuildData.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	class'X2Action_ExitCover'.static.AddToVisualizationTree(BuildData, VisualizeGameState.GetContext(), false, BuildData.LastActionAdded);
	GetOverHereAction = RTAction_PsionicGetOverHere(class'RTAction_PsionicGetOverHere'.static.AddToVisualizationTree(BuildData, VisualizeGameState.GetContext(), false, BuildData.LastActionAdded));
	GetOverHereAction.SetFireParameters(Context.IsResultContextHit());


	Visualizer = X2VisualizerInterface(BuildData.VisualizeActor);
	if(Visualizer != none)
	{
		Visualizer.BuildAbilityEffectsVisualization(VisualizeGameState, BuildData);
	}

	class'X2Action_EnterCover'.static.AddToVisualizationTree(BuildData, VisualizeGameState.GetContext(), false, BuildData.LastActionAdded);

	//****************************************************************************************

	//Configure the visualization track for the target
	//****************************************************************************************
	InteractingUnitRef = Context.InputContext.PrimaryTarget;
	BuildData = InitData;
	BuildData.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	BuildData.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	BuildData.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	TargetUnit = XComGameState_Unit(BuildData.StateObject_OldState);
	if( (TargetUnit != none) && (TargetUnit.IsUnitApplyingEffectName('Suppression')))
	{
		class'X2Action_StopSuppression'.static.AddToVisualizationTree(BuildData, VisualizeGameState.GetContext(), false, BuildData.LastActionAdded);
	}

	class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(BuildData, VisualizeGameState.GetContext(), false, BuildData.LastActionAdded);

	for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
	{
		AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, Context.FindTargetEffectApplyResult(AbilityTemplate.AbilityTargetEffects[EffectIndex]));
	}

	if (Context.IsResultContextMiss() && AbilityTemplate.LocMissMessage != "")
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(BuildData, VisualizeGameState.GetContext(), false, BuildData.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocMissMessage, '', eColor_Bad);
	}
	//****************************************************************************************
}

static function X2AbilityTemplate RTUnfurlTheVeil() {
	local X2AbilityTemplate						Template;
	local X2Effect_RangerStealth				StealthEffect;
	local RTCondition_UnfurlTheVeil				VeilCondition;
	local X2AbilityCost_ActionPoints			Cost;
	local X2AbilityCooldown						Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTUnfurlTheVeil');
	Template.IconImage = "img:///RisingTidesContentPackage.PerkIcons.rt_unfurltheveil";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Defensive;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.UTV_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Cost = new class'X2AbilityCost_ActionPoints';
	Cost.iNumPoints = default.UTV_ACTION_POINT_COST;
	Cost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(Cost);

	VeilCondition = new class'RTCondition_UnfurlTheVeil';
	Template.AbilityShooterConditions.AddItem(VeilCondition);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(new class'X2Condition_Stealth');
	Template.AddShooterEffectExclusions();

	StealthEffect = new class'X2Effect_RangerStealth';
	StealthEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	StealthEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true);
	StealthEffect.bRemoveWhenTargetConcealmentBroken = true;

	Template.AddTargetEffect(StealthEffect);
	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CustomFireAnim = 'HL_Psi_SelfCast';

	return Template;
}

defaultproperties
{
	ExtinctionEventStageThreeEventName = "RTExtinctionEventStageThree"
	OverTheShoulderEffectName = "OverTheShoulderEffect"
	OverTheShoulderSourceEffectName = "OverTheShoulderSourceEffect"
	OverTheShoulderTagName = "OverTheShoulderTag"
	EchoedAgonyEffectAbilityTemplateName = "EchoedAgonyEffect"
	GuiltyConscienceEventName = "GuiltyConscienceEvent"
	GuiltyConscienceEffectName = "GuiltyConscienceEffect"
	PostOverTheShoulderEventName = "TriangulationEvent"
	KnowledgeIsPowerEffectName = "KnowledgeIsPowerEffectName"
	PsionicStormSustainedActivationEffectName = "PsionicStormSustainedDamageEffectName"
	PsionicStormSustainedDamageEvent = "PsionicStormSustainedDamageEventName"
	PsistormMarkedEffectName = "PsionicStormDamageMarkName"

	PSIONICSTORM_RADIUS = 7.5
}

static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	local name Tag;

	Tag = name(InString);

	switch(Tag)
	{

	}

	return false;
}
