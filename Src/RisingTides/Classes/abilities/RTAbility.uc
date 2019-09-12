//---------------------------------------------------------------------------------------
//  FILE:    RTAbility.uc
//  AUTHOR:  Aleosiss
//  DATE:    8 February 2016
//  PURPOSE: Defines methods used by all Rising Tides ability sets.
//
//---------------------------------------------------------------------------------------

class RTAbility extends X2Ability config(RisingTides);
	var protected X2Condition_UnitProperty						LivingFriendlyUnitOnlyProperty;
	var protected X2Condition_UnitEffectsWithAbilitySource		OverTheShoulderProperty;
	var protected X2Condition_UnitProperty						LivingHostileUnitOnlyNonRoboticProperty;
	var protected RTCondition_PsionicTarget						PsionicTargetingProperty;
	var protected RTCondition_UnitSize							StandardSizeProperty;
	var protected EffectReason									TagReason;

	var name UnitUsedPsionicAbilityEvent;
	var name ForcePsionicAbilityEvent;
	var name RTFeedbackEffectName;
	var name RTFeedbackWillDebuffName;
	var name RTTechnopathyTemplateName;
	var name RTGhostTagEffectName;
	var name RTMindControlEffectName;
	var name RTMindControlTemplateName;

	var config string BurstParticleString;
	var config name BurstSocketName;
	var config name BurstArrayName;
	var config name BurstAnimName;

	var config int FEEDBACK_DURATION;
	var config int MAX_BLOODLUST_MELDJOIN;

	var float DefaultPsionicAnimDelay;

// helpers
static function X2Condition_UnitValue CreateOverTheShoulderProperty() {
	local X2Condition_UnitValue Condition;

	Condition = new class'X2Condition_UnitValue';
	Condition.AddCheckValue(class'RTAbility_GathererAbilitySet'.default.OverTheShoulderTagName, 1, eCheck_LessThan);

	return Condition;

}

static function X2AbilityTemplate AddStandardMovementCost(X2AbilityTemplate Template) {
	local X2AbilityCost_ActionPoints ActionPointCost;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.bMoveCost = true;
	ActionPointCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.MoveActionPoint);
	ActionPointCost.AllowedTypes.RemoveItem(class'X2CharacterTemplateManager'.default.RunAndGunActionPoint);
	ActionPointCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.MomentumActionPoint);
	Template.AbilityCosts.AddItem(ActionPointCost);

	return Template;
}

static function array<X2Condition> CreateStandardMovementConditions() {
	local X2Condition_UnitProperty UnitPropertyCondition;
	local X2Condition_UnitValue IsNotImmobilized;
	local X2Condition_UnitStatCheck UnitStatCheckCondition;
	local array<X2Condition> Conditions;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeCosmetic = false; //Cosmetic units are allowed movement
	Conditions.AddItem(UnitPropertyCondition);

	IsNotImmobilized = new class'X2Condition_UnitValue';
	IsNotImmobilized.AddCheckValue(class'X2Ability_DefaultAbilitySet'.default.ImmobilizedValueName, 0);
	Conditions.AddItem(IsNotImmobilized);

	// Unit might not be mobilized but have zero mobility
	UnitStatCheckCondition = new class'X2Condition_UnitStatCheck';
	UnitStatCheckCondition.AddCheckStat(eStat_Mobility, 0, eCheck_GreaterThan);
	Conditions.AddItem(UnitStatCheckCondition);

	return Conditions;
}

static function X2AbilityTemplate AddDefaultWOTCFields(X2AbilityTemplate Template) {
	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentMoveLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.MoveChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.MoveLostSpawnIncreasePerUse;

	return Template;
}

// This method does not include the required multitarget style or the targeting method
static function RTAbilityTemplate BeginGroupMoveCreation(RTAbilityTemplate Template, name TemplateName) {
	local X2AbilityTarget_Path PathTarget;
	local X2AbilityTrigger_PlayerInput InputTrigger;

	Template.bDisplayInUITooltip = false;
	Template.bDontDisplayInAbilitySummary = true;
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.Hostility = eHostility_Movement;
	Template.FrameAbilityCameraType = eCameraFraming_Never;
	Template.AssociatedPlayTiming = SPT_AfterSequential;
	Template.CinescriptCameraType = "StandardMovement"; 
	
	AddDefaultWOTCFields(Template);
	AddStandardMovementCost(Template);
	
	Template.AbilityShooterConditions = CreateStandardMovementConditions();

	PathTarget = new class'X2AbilityTarget_Path';
	Template.AbilityTargetStyle = PathTarget;

	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);

	Template.BuildNewGameStateFn = class'X2Ability_DefaultAbilitySet'.static.MoveAbility_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_DefaultAbilitySet'.static.MoveAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = class'X2Ability_DefaultAbilitySet'.static.MoveAbility_BuildInterruptGameState;

	return Template;
}

static function X2AbilityTemplate CreateRTCooldownCleanse(name TemplateName, name EffectNameToRemove, name EventIDToListenFor) {
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

static function Passive(X2AbilityTemplate Template) {
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
}

static function array<X2AbilityTemplate> CreateUnitValueToggle(name TemplateName, name UnitValName) {
	local array<X2AbilityTemplate> Templates;
	local name TemplateNameMaster, TemplateNameOn, TemplateNameOff;
	
	TemplateNameMaster = `RTS.ConcatName(TemplateName, '_master');
	TemplateNameOn = `RTS.ConcatName(TemplateName, '_on');
	TemplateNameOff = `RTS.ConcatName(TemplateName, '_off');

	Templates.AddItem(CreateUnitValueToggleMaster(TemplateNameMaster, UnitValName, TemplateNameOn, TemplateNameOff));
	Templates.AddItem(CreateUnitValueToggleOn(TemplateNameOn, UnitValName));
	Templates.AddItem(CreateUnitValueToggleOff(TemplateNameOff, UnitValName));

	return Templates;
}

private static function X2AbilityTemplate CreateUnitValueToggleMaster(name TemplateName, name UnitValName, name TemplateNameOn, name TemplateNameOff) {
	local X2AbilityTemplate Template;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.ConcealmentRule = eConceal_Always;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	Template.AdditionalAbilities.AddItem(TemplateNameOn);
	Template.AdditionalAbilities.AddItem(TemplateNameOff);

	return Template;
}

private static function X2AbilityTemplate CreateUnitValueToggleInternal(name TemplateName, name UnitValName, int ConditionValue, int EffectValue) {
	local X2AbilityTemplate Template;
	local X2Condition_UnitValue UnitValueCondition;
	local X2Effect_SetUnitValue UnitValueEffect;
	local X2AbilityTrigger_PlayerInput InputTrigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.Hostility = eHostility_Neutral;
	Template.ConcealmentRule = eConceal_Always;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityCosts.AddItem(default.FreeActionCost);

	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);

	Template.AddShooterEffectExclusions();

	UnitValueCondition = new class'X2Condition_UnitValue';
	UnitValueCondition.AddCheckValue(UnitValName, ConditionValue);
	Template.AbilityTargetConditions.AddItem(UnitValueCondition);

	UnitValueEffect = new class'X2Effect_SetUnitValue';
	UnitValueEffect.UnitName = UnitValName;
	UnitValueEffect.NewValueToSet = EffectValue;
	UnitValueEffect.CleanupType = eCleanup_BeginTactical;
	Template.AddTargetEffect(UnitValueEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = ReloadAbility_BuildVisualization;
	Template.ActivationSpeech = 'Reloading';

	return Template;
}

private static function X2AbilityTemplate CreateUnitValueToggleOn(name TemplateName, name UnitValName) {
	return CreateUnitValueToggleInternal(TemplateName, UnitValName, 0, 1);
}

private static function X2AbilityTemplate CreateUnitValueToggleOff(name TemplateName, name UnitValName) {
	return CreateUnitValueToggleInternal(TemplateName, UnitValName, 1, 0);
}

static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
//	local name Tag;

//	Tag = name(InString);

	return false;
}

static function TestAbilitySetValues() {
	
}

static function AddSpectrePsionicSuite(X2AbilityTemplate Template) {
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
}

static function AddMeldedAbilityHelpers(X2AbilityTemplate Template) {
	Template.AdditionalAbilities.AddItem('LIOverwatchShot');
	Template.AdditionalAbilities.AddItem('RTUnstableConduitBurst');
	Template.AdditionalAbilities.AddItem('PsionicActivate');
	Template.AdditionalAbilities.AddItem('RTHarbingerPsionicLance');
}

function DebugEffectAdded(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState) {
	`RTLOG("DebugEffectAdded! to " $ kNewTargetState.GetMyTemplateName(), false, true);
}

function name DebugApplyChanceCheck(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
{
	`RTLOG("DebugApplyChanceCheck for " $ kNewTargetState.GetMyTemplateName(), false, true);
	return 'AA_Success';
}

defaultproperties
{
	DefaultPsionicAnimDelay = 4.0
	RTGhostTagEffectName = "RTGhostOperative"
	UnitUsedPsionicAbilityEvent = "UnitUsedPsionicAbility"
	ForcePsionicAbilityEvent = "ForcePsionicAbilityEvent"
	RTFeedbackEffectName = "RTFeedback"
	RTFeedbackWillDebuffName = "RTFeedbackWillDebuff"
	RTTechnopathyTemplateName = "RTTechnopathy"
	RTMindControlEffectName = "MindControl"
	RTMindControlTemplateName = "RTMindControl"
	


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
}