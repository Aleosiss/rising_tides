class RTEffectBuilder extends X2StatusEffects config(RisingTides);

var config bool bUseEffectVisualizationOverride;

var localized string StealthFriendlyName;
var localized string StealthFriendlyDesc;
var config string StealthIconPath;
var config name StealthEffectName;
var config string StealthStartParticleName;
var config string StealthStopParticleName;
var config string StealthPersistentParticleName;
var config name StealthSocketName;
var config name StealthSocketsArrayName;

var localized string MeldFriendlyName;
var localized string MeldFriendlyDesc;
var config string MeldIconPath;
var config name MeldEffectName;
var config string MeldParticleName;
var config name MeldSocketName;
var config name MeldSocketsArrayName;

var localized string FeedbackFriendlyName;
var localized string FeedbackFriendlyDesc;
var config string FeedbackIconPath;
var config name FeedbackEffectName;
var config string FeedbackParticleName;
var config name FeedbackSocketName;
var config name FeedbackSocketsArrayName;

var config string OverTheShoulderParticleString;
var config name OverTheShoulderSocketName;
var config name OverTheShoulderArrayName;

var config string SurgeStartupParticleString;
var config string SurgePersistentParticleString;
var config name SurgeSocketName;
var config name SurgeArrayName;

var config string KillzoneStartupParticleString;
var config string KillzonePersistentParticleString;
var config name KillzoneSocketName;
var config name KillzoneArrayName;

var config string SiphonParticleString;
var config name SiphonSocketName;
var config name SiphonArrayName;

var config int AGONY_STRENGTH_TAKE_FEEDBACK;
var config int AGONY_STRENGTH_TAKE_DAMAGE;
var config int AGONY_STRENGTH_TAKE_ECHO;

var config name LiftedName;

static function RTAction_PlayEffect BuildEffectParticle(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, string ParticleName, name SocketName, name SocketsArrayName, bool _AttachToUnit, bool _bStopEffect) {
	local RTAction_PlayEffect EffectAction;

	EffectAction = RTAction_PlayEffect(class'RTAction_PlayEffect'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
	EffectAction.EffectName = ParticleName;
	EffectAction.AttachToSocketName = SocketName;
	EffectAction.AttachToSocketsArrayName = SocketsArrayName;
	EffectAction.AttachToUnit = _AttachToUnit;
	EffectAction.bStopEffect = _bStopEffect;

	return EffectAction;
}

private static function bool CheckSuccessfulUnitEffectApplication(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult) {
	local XComGameState_Unit UnitState;

	if(EffectApplyResult != 'AA_Success') {
		return false;
	}
	
	UnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);
	if(UnitState == none) {
		return false;
	}
	return true;
}


static function RTEffect_Stealth CreateStealthEffect(	int iDuration = 1,
														optional bool bInfinite = false,
														optional float fModifier = 1.0f,
														optional GameRuleStateChange WatchRule = eGameRule_PlayerTurnBegin,
														optional name AbilitySourceName = 'eAbilitySource_Psionic',
														optional EDuplicateEffect DuplicateResponse = eDupe_Refresh
) {
	local RTEffect_Stealth Effect;

	Effect = new class'RTEffect_Stealth';
	Effect.EffectName = default.StealthEffectName;
	Effect.fStealthModifier = fModifier;
	Effect.DuplicateResponse = DuplicateResponse;
	Effect.BuildPersistentEffect(iDuration, bInfinite, true, false, WatchRule);
	Effect.SetDisplayInfo(ePerkBuff_Bonus, default.StealthFriendlyName, default.StealthFriendlyDesc, default.StealthIconPath, true,, AbilitySourceName);
	Effect.VisualizationFn = StealthVisualization;
	Effect.EffectSyncVisualizationFn = StealthSyncVisualization;
	Effect.EffectRemovedVisualizationFn = StealthRemovedVisualization;

	if (default.StealthStartParticleName != "" && !default.bUseEffectVisualizationOverride) {
			Effect.VFXTemplateName = default.StealthPersistentParticleName;
			Effect.VFXSocket = default.StealthSocketName;
			Effect.VFXSocketsArrayName = default.StealthSocketsArrayName;
	}

	return Effect;
}

static function StealthVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult) {
	if(!CheckSuccessfulUnitEffectApplication(VisualizeGameState, ActionMetadata, EffectApplyResult))
		return;

	//StartActionP1 = 
	BuildEffectParticle(VisualizeGameState, ActionMetadata, default.StealthStartParticleName, default.StealthSocketName, default.StealthSocketsArrayName, true, false);
	
	//PersistentAction = 
	BuildEffectParticle(VisualizeGameState, ActionMetadata, default.StealthPersistentParticleName, default.StealthSocketName, default.StealthSocketsArrayName, true, false);
}

static function StealthSyncVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult) {
	StealthVisualization(VisualizeGameState, ActionMetadata, 'AA_Success');
}

static function StealthRemovedVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult) {
	if(!CheckSuccessfulUnitEffectApplication(VisualizeGameState, ActionMetadata, EffectApplyResult))
		return;

	//PersistentAction = 
	BuildEffectParticle(VisualizeGameState, ActionMetadata, default.StealthPersistentParticleName, default.StealthSocketName, default.StealthSocketsArrayName, true, true);

	//StopActionP1 = 
	BuildEffectParticle(VisualizeGameState, ActionMetadata, default.StealthStopParticleName, default.StealthSocketName, default.StealthSocketsArrayName, true, false);
}

static function RTEffect_Meld CreateMeldEffect(int iDuration = 1, optional bool bInfinite = true) {
	local RTEffect_Meld Effect;

	Effect = new class'RTEffect_Meld';
	Effect.EffectName = default.MeldEffectName;
	Effect.DuplicateResponse = eDupe_Ignore;
	Effect.BuildPersistentEffect(iDuration, bInfinite, true, false,  eGameRule_PlayerTurnEnd);
	Effect.SetDisplayInfo(ePerkBuff_Bonus, default.MeldFriendlyName, default.MeldFriendlyDesc, default.MeldIconPath, true,,'eAbilitySource_Psionic');
	//Effect.VisualizationFn = MeldVisualization;
	//Effect.EffectRemovedVisualizationFn = MeldRemovedVisualization;

	if (default.MeldParticleName != "") {
			Effect.VFXTemplateName = default.MeldParticleName;
			Effect.VFXSocket = default.MeldSocketName;
			Effect.VFXSocketsArrayName = default.MeldSocketsArrayName;
	}

	return Effect;
}

static function RTEffect_Panicked CreateFeedbackEffect(int _EffectDuration, name _EffectName, string _EffectDisplayTitle, string _EffectDisplayDesc, string _IconImage) {
	local RTEffect_Panicked	PanickedEffect;

	PanickedEffect = new class'RTEffect_Panicked';
	PanickedEffect.EffectName = _EffectName;
	PanickedEffect.BuildPersistentEffect(_EffectDuration, false, true, false, eGameRule_PlayerTurnBegin);
	PanickedEffect.EffectHierarchyValue = class'X2StatusEffects'.default.PANICKED_HIERARCHY_VALUE;
	PanickedEffect.EffectAppliedEventName = 'PanickedEffectApplied';
	PanickedEffect.SetDisplayInfo(ePerkBuff_Penalty, _EffectDisplayTitle, _EffectDisplayDesc, _IconImage);
	PanickedEffect.DamageTypes.Length = 0;
	PanickedEffect.DamageTypes.AddItem('Panic');
	return PanickedEffect;
}


static function X2Effect_Stunned CreateLiftEffect(int StunLevel) {
	local X2Effect_Stunned Effect;
	local RTCondition_UnitSize Condition;

	Effect = new class'X2Effect_Stunned';
	Effect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	Effect.SetDisplayInfo(ePerkBuff_Penalty, "Lifted", "Embrace eternity.", default.FeedbackIconPath, true,,'eAbilitySource_Standard');
	Effect.StunLevel = StunLevel;
	Effect.bIsImpairing = true;
	Effect.EffectHierarchyValue = default.STUNNED_HIERARCHY_VALUE + 1;
	Effect.EffectName = default.LiftedName;
	//Effect.VisualizationFn = LiftVisualization;
	//Effect.EffectTickedVisualizationFn = LiftVisualizationTicked;
	//Effect.EffectRemovedVisualizationFn = LiftVisualizationRemoved;
	Effect.bRemoveWhenTargetDies = true;
	Effect.bCanTickEveryAction = false;

	// Can't lift big stuff. FAT
	Condition = new class'RTCondition_UnitSize';
	Effect.TargetConditions.AddItem(Condition);

	return Effect;
}

static function RTEffect_Siphon CreateSiphonEffect(float fMultiplier, int iMinVal, int iMaxVal) {
	local RTEffect_Siphon SiphonEffect;
	local X2Condition_UnitProperty TargetUnitPropertyCondition;
	local X2Condition_AbilityProperty SiphonCondition;

	// Siphon Effect
	SiphonEffect = new class'RTEffect_Siphon';
	SiphonEffect.SiphonAmountMultiplier = fMultiplier;
	SiphonEffect.SiphonMinVal = iMinVal;
	SiphonEffect.SiphonMaxVal = iMaxVal;
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

	return SiphonEffect;
}

static function X2Effect_RangerStealth CreateConcealmentEffect() {
	local X2Effect_RangerStealth Effect;

	Effect = new class'X2Effect_RangerStealth';
	Effect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	Effect.bRemoveWhenTargetConcealmentBroken = true;
	
	return Effect;
}

static function AddStilettoRoundsEffect(out RTAbilityTemplate AbilityTemplate, bool bMultiTarget = false)
{
	local X2Effect_Persistent BleedingEffect;
	local X2Condition_UnitEffectsOnSource StilettoRoundsEffect;
	BleedingEffect = class'X2StatusEffects'.static.CreateBleedingStatusEffect(class'X2StrategyElement_XpackDarkEvents'.default.STILETTO_BLEEDING_NUM_TURNS, class'X2StrategyElement_XpackDarkEvents'.default.STILETTO_BLEEDING_TICK_DMG);

	// Only add the bleeding effect if the shooter has the stiletto rounds effect
	StilettoRoundsEffect = new class'X2Condition_UnitEffectsOnSource';
	StilettoRoundsEffect.AddRequireEffect('AdventStilettoRoundsEffect', 'AA_MissingRequiredEffect');
	BleedingEffect.TargetConditions.AddItem(StilettoRoundsEffect);
	
	AbilityTemplate.AddTargetEffect(BleedingEffect);
	if(bMultiTarget) {
		AbilityTemplate.AddMultiTargetEffect(BleedingEffect);
	}
}