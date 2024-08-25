class RTAbility_TemplarAbilitySet extends RTAbility_GhostAbilitySet config (RisingTides);

var config int SCHOLAR_IONIC_STORM_RANGE;
var config int TEMPLAR_PEON_EXTRA_GRENADES;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(RTUnwaveringResolve());
	Templates.AddItem(RTUnwaveringResolveIcon());
	Templates.AddItem(RTScholarVolt());
	Templates.AddItem(RTScholarIonicStorm());
	Templates.AddItem(RTTemplarExtraOrdnance());

	return Templates;
}

// Passive - Gain one focus when it is drained to 0
static function X2AbilityTemplate RTUnwaveringResolve()
{
	local X2AbilityTemplate						Template;
	local RTEffect_ModifyTemplarFocus			Effect;
	local X2AbilityTrigger_EventListener		EventTrigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTUnwaveringResolve');
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_InnerFocus";

	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventID = 'FocusLevelChanged';
	EventTrigger.ListenerData.EventFn = UnwaveringResolveListener;
	Template.AbilityTriggers.AddItem(EventTrigger);

	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	Effect = new class'RTEffect_ModifyTemplarFocus';
	Effect.bSkipFocusVisualizationInFOW = true;
	Effect.TargetConditions.AddItem(new class'X2Condition_GhostShooter');
	Template.AddTargetEffect(Effect);

	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = UnwaveringResolve_BuildVisualization;
	Template.MergeVisualizationFn = DesiredVisualizationBlock_MergeVisualization;
	Template.bShowActivation = false;
	Template.bFrameEvenWhenUnitIsHidden = false;
	
	Template.AdditionalAbilities.AddItem('RTUnwaveringResolveIcon');

	return Template;
}

simulated function UnwaveringResolve_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;
	local XComGameState_Unit UnitState;
	local XComGameState_Ability Ability;
	local X2AbilityTemplate AbilityTemplate;

	local VisualizationActionMetadata ActionMetadata, EmptyTrack;

	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;
	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1));

	Ability = XComGameState_Ability(History.GetGameStateForObjectID(Context.InputContext.AbilityRef.ObjectID));
	AbilityTemplate = Ability.GetMyTemplate();

	//Configure the visualization track for the shooter
	//****************************************************************************************
	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(Context.InputContext.SourceObject.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(Context.InputContext.SourceObject.ObjectID);
	ActionMetadata.VisualizeActor = History.GetVisualizer(Context.InputContext.SourceObject.ObjectID);


	if(UnitState.GetTeam() != eTeam_XCom) {
		if(class'RTCondition_VisibleToPlayer'.static.IsTargetVisibleToLocalPlayer(UnitState.GetReference())) {
			`RTLOG("Unwavering Resolve: Visualizing, unit is visible!");
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', eColor_Bad);
		} else {
			`RTLOG("Unwavering Resolve: Not visualizing, unit is not visible!");
		}
	} else {
		`RTLOG("Unwavering Resolve: Visualizing, unit on XCOM!");
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', eColor_Good);
	}
}

static function EventListenerReturn UnwaveringResolveListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_Unit				UnitState;
	local XComGameState_Effect_TemplarFocus EffectState;
	local XComGameState_Ability				AbilityState;

	if (GameState.GetContext().InterruptionStatus == eInterruptionStatus_Interrupt)
	{
		return ELR_NoInterrupt;
	}

	UnitState = XComGameState_Unit(EventSource);
	EffectState = XComGameState_Effect_TemplarFocus(EventData);
	if(UnitState == none || EffectState == none) {
		`RTLOG("UnwaveringResolveListener recieved data that was either none or invalid!", true, false);
		return ELR_NoInterrupt;
	}

	AbilityState = XComGameState_Ability(CallbackData);
	if(AbilityState.OwnerStateObject.ObjectID != EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID) {
		//`RTLOG("UnwaveringResolveListener activated against the wrong target, expected, returning.", false, false);
		return ELR_NoInterrupt;
	}

	// validated, check the focus level
	if(EffectState.FocusLevel < 1) {
		AbilityState.AbilityTriggerAgainstSingleTarget(UnitState.GetReference(), false);
	}

	return ELR_NoInterrupt;
}

static function X2AbilityTemplate RTUnwaveringResolveIcon()
{
	return PurePassive('RTUnwaveringResolveIcon', "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_InnerFocus", false, 'eAbilitySource_Psionic');
}

static function X2AbilityTemplate RTScholarVolt()
{
	local X2AbilityTemplate				Template;
	local X2AbilityCost_ActionPoints	ActionPointCost;
	local X2Condition_UnitProperty		TargetCondition;
	local X2Effect_ApplyWeaponDamage	DamageEffect;
	local X2Effect_ToHitModifier		HitModEffect;
	local X2Condition_AbilityProperty	AbilityCondition;
	local X2AbilityTag                  AbilityTag;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTScholarVolt');

	Template.AbilityCosts.AddItem(new class'X2AbilityCost_Focus');

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityMultiTargetStyle = new class'X2AbilityMultiTarget_Volt';
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	//	NOTE: visibility is NOT required for multi targets as it is required between each target (handled by multi target class)

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeAlive = false;
	TargetCondition.ExcludeDead = true;
	TargetCondition.ExcludeFriendlyToSource = true;
	TargetCondition.ExcludeHostileToSource = false;
	TargetCondition.TreatMindControlledSquadmateAsHostile = false;
	TargetCondition.FailOnNonUnits = true;
	TargetCondition.ExcludeCivilian = true;
	TargetCondition.ExcludeCosmetic = true;
	TargetCondition.ExcludeRobotic = true;
	Template.AbilityTargetConditions.AddItem(TargetCondition);
	Template.AbilityMultiTargetConditions.AddItem(TargetCondition);

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludePsionic = true;
	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	DamageEffect.bIgnoreBaseDamage = true;
	DamageEffect.DamageTag = 'Volt';
	DamageEffect.bIgnoreArmor = true;
	DamageEffect.TargetConditions.AddItem(TargetCondition);
	Template.AddTargetEffect(DamageEffect);
	Template.AddMultiTargetEffect(DamageEffect);

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeNonPsionic = true;
	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	DamageEffect.bIgnoreBaseDamage = true;
	DamageEffect.DamageTag = 'Volt_Psi';
	DamageEffect.bIgnoreArmor = true;
	DamageEffect.TargetConditions.AddItem(TargetCondition);
	Template.AddTargetEffect(DamageEffect);
	Template.AddMultiTargetEffect(DamageEffect);

	HitModEffect = new class'X2Effect_ToHitModifier';
	HitModEffect.BuildPersistentEffect(2, , , , eGameRule_PlayerTurnBegin);
	HitModEffect.AddEffectHitModifier(eHit_Success, class'X2Ability_TemplarAbilitySet'.default.VoltHitMod, class'X2Ability_TemplarAbilitySet'.default.RecoilEffectName);
	HitModEffect.bApplyAsTarget = true;
	HitModEffect.bRemoveWhenTargetDies = true;
	HitModEffect.bUseSourcePlayerState = true;
	
	AbilityTag = X2AbilityTag(`XEXPANDCONTEXT.FindTag("Ability"));
	AbilityTag.ParseObj = HitModEffect;
	HitModEffect.SetDisplayInfo(ePerkBuff_Penalty, class'X2Ability_TemplarAbilitySet'.default.RecoilEffectName, `XEXPAND.ExpandString(class'X2Ability_TemplarAbilitySet'.default.RecoilEffectDesc), "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Recoil");
	
	AbilityTag.ParseObj = none;
	
	AbilityCondition = new class'X2Condition_AbilityProperty';
	AbilityCondition.OwnerHasSoldierAbilities.AddItem('Reverberation');
	HitModEffect.TargetConditions.AddItem(default.LivingTargetOnlyProperty);
	HitModEffect.TargetConditions.AddItem(AbilityCondition);
	Template.AddTargetEffect(HitModEffect);
	Template.AddMultiTargetEffect(HitModEffect);

//BEGIN AUTOGENERATED CODE: Template Overrides 'Volt'
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.CustomFireAnim = 'HL_Volt';
	Template.ActivationSpeech = 'Volt';
//END AUTOGENERATED CODE: Template Overrides 'Volt'
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Offensive;
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_volt";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	Template.TargetingMethod = class'X2TargetingMethod_Volt';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.ActionFireClass = class'X2Action_Fire_Volt';
	
	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	Template.DamagePreviewFn = VoltDamagePreview;

	return Template;
}

function bool VoltDamagePreview(XComGameState_Ability AbilityState, StateObjectReference TargetRef, out WeaponDamageValue MinDamagePreview, out WeaponDamageValue MaxDamagePreview, out int AllowsShield)
{
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(TargetRef.ObjectID));
	if (TargetUnit != none)
	{
		if (TargetUnit.IsPsionic())
		{
			AbilityState.GetMyTemplate().AbilityTargetEffects[1].GetDamagePreview(TargetRef, AbilityState, false, MinDamagePreview, MaxDamagePreview, AllowsShield);
		}
		else
		{
			AbilityState.GetMyTemplate().AbilityTargetEffects[0].GetDamagePreview(TargetRef, AbilityState, false, MinDamagePreview, MaxDamagePreview, AllowsShield);
		}		
	}
	return true;
}

static function X2AbilityTemplate RTScholarIonicStorm()
{
	local X2AbilityTemplate						Template;
	local X2AbilityMultiTarget_Radius           MultiTargetRadius;
	local X2Effect_ApplyWeaponDamage            DamageEffect;
	local X2AbilityCost_Focus					ConsumeAllFocusCost;
	local X2Condition_UnitProperty				TargetCondition;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2AbilityCooldown						Cooldown;
	local X2AbilityTarget_Cursor 				CursorTarget;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTScholarIonicStorm');
//BEGIN AUTOGENERATED CODE: Template Overrides 'IonicStorm'
	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.CustomFireKillAnim = 'HL_IonicStorm';
	Template.ActivationSpeech = 'IonicStorm';
	Template.CinescriptCameraType = "Templar_IonicStorm";
//END AUTOGENERATED CODE: Template Overrides 'IonicStorm'
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Offensive;
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_IonicStorm";
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.bFriendlyFireWarning = false;

	ConsumeAllFocusCost = new class'X2AbilityCost_Focus';
	ConsumeAllFocusCost.FocusAmount = 1;
	ConsumeAllFocusCost.ConsumeAllFocus = true;
	Template.AbilityCosts.AddItem(ConsumeAllFocusCost);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = class'X2Ability_TemplarAbilitySet'.default.IONICSTORM_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.DeadEye;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToSquadsightRange = true;
	CursorTarget.FixedAbilityRange = default.SCHOLAR_IONIC_STORM_RANGE;
	Template.AbilityTargetStyle = CursorTarget;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	//Template.TargetingMethod = class'X2TargetingMethod_PathTarget';
	Template.TargetingMethod = class'X2TargetingMethod_VoidRift';

	MultiTargetRadius = new class'X2AbilityMultiTarget_RadiusTimesFocus';
	MultiTargetRadius.fTargetRadius = class'X2Ability_TemplarAbilitySet'.default.IONICSTORM_RADIUS_METERS;
	MultiTargetRadius.bExcludeSelfAsTargetIfWithinRadius = true;
	Template.AbilityMultiTargetStyle = MultiTargetRadius;

	Template.AddShooterEffectExclusions();
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityMultiTargetConditions.AddItem(default.LivingHostileUnitOnlyProperty);

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludePsionic = true;
	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	DamageEffect.bIgnoreBaseDamage = true;
	DamageEffect.DamageTag = 'IonicStorm';
	DamageEffect.bIgnoreArmor = true;
	DamageEffect.TargetConditions.AddItem(TargetCondition);
	Template.AddMultiTargetEffect(DamageEffect);

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeNonPsionic = true;
	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	DamageEffect.bIgnoreBaseDamage = true;
	DamageEffect.DamageTag = 'IonicStorm_Psi';
	DamageEffect.bIgnoreArmor = true;
	DamageEffect.TargetConditions.AddItem(TargetCondition);
	Template.AddMultiTargetEffect(DamageEffect);

	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = IonicStorm_BuildVisualization;

	Template.bSkipExitCoverWhenFiring = false;
	Template.CustomFireAnim = 'HL_IonicStorm';
	Template.DamagePreviewFn = IonicStormDamagePreview;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;

	return Template;
}

simulated function IonicStorm_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateVisualizationMgr VisMgr;
	local XComGameStateContext_Ability AbilityContext;
	local VisualizationActionMetadata SourceMetadata;
	local VisualizationActionMetadata ActionMetadata;
	local VisualizationActionMetadata BlankMetadata;
	local XGUnit SourceVisualizer;
	local X2Action_Fire FireAction;
	local X2Action_ExitCover ExitCoverAction;
	local StateObjectReference CurrentTarget;
	local int ScanTargets;
	local X2Action ParentAction;
	local X2Action_Delay CurrentDelayAction;
	local X2Action_ApplyWeaponDamageToUnit UnitDamageAction;
	local X2Effect CurrentEffect;
	local int ScanEffect;
	local Array<X2Action> LeafNodes;
	local X2Action_MarkerNamed JoinActions;
	local XComGameState_Effect_TemplarFocus FocusState;
	local int NumActualTargets;

	History = `XCOMHISTORY;
	VisMgr = `XCOMVISUALIZATIONMGR;

	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());

	SourceVisualizer = XGUnit(History.GetVisualizer(AbilityContext.InputContext.SourceObject.ObjectID));

	SourceMetadata.StateObject_OldState = History.GetGameStateForObjectID(SourceVisualizer.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	SourceMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(SourceVisualizer.ObjectID);
	SourceMetadata.StateObjectRef = AbilityContext.InputContext.SourceObject;
	SourceMetadata.VisualizeActor = SourceVisualizer;

	if( AbilityContext.InputContext.MovementPaths.Length > 0 )
	{
		class'X2VisualizerHelpers'.static.ParsePath(AbilityContext, SourceMetadata);
	}

	ExitCoverAction = X2Action_ExitCover(class'X2Action_ExitCover'.static.AddToVisualizationTree(SourceMetadata, AbilityContext, false, SourceMetadata.LastActionAdded));
	FireAction = X2Action_Fire(class'X2Action_Fire'.static.AddToVisualizationTree(SourceMetadata, AbilityContext, false, ExitCoverAction));
	class'X2Action_EnterCover'.static.AddToVisualizationTree(SourceMetadata, AbilityContext, false, FireAction);

	FocusState = XComGameState_Unit(SourceMetadata.StateObject_OldState).GetTemplarFocusEffectState();
	// Jwats: We care about the focus that was used to cast this ability
	FocusState = XComGameState_Effect_TemplarFocus(History.GetGameStateForObjectID(FocusState.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1));
	NumActualTargets = AbilityContext.InputContext.MultiTargets.Length / FocusState.FocusLevel;

	ParentAction = FireAction;
	for (ScanTargets = 0; ScanTargets < AbilityContext.InputContext.MultiTargets.Length; ++ScanTargets)
	{
		CurrentTarget = AbilityContext.InputContext.MultiTargets[ScanTargets];
		ActionMetadata = BlankMetadata;

		ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(CurrentTarget.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
		ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(CurrentTarget.ObjectID);
		ActionMetadata.StateObjectRef = CurrentTarget;
		ActionMetadata.VisualizeActor = History.GetVisualizer(CurrentTarget.ObjectID);

		if (ScanTargets == 0)
		{
			ParentAction = class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(ActionMetadata, AbilityContext, false, ParentAction);
		}
		else
		{
			CurrentDelayAction = X2Action_Delay(class'X2Action_Delay'.static.AddToVisualizationTree(ActionMetadata, AbilityContext, false, ParentAction));
			CurrentDelayAction.Duration = (`SYNC_FRAND() * (class'X2Ability_TemplarAbilitySet'.default.IonicStormTargetMaxDelay - 
															class'X2Ability_TemplarAbilitySet'.default.IonicStormTargetMinDelay)) + 
															class'X2Ability_TemplarAbilitySet'.default.IonicStormTargetMinDelay;
			ParentAction = CurrentDelayAction;
		}

		UnitDamageAction = X2Action_ApplyWeaponDamageToUnit(class'X2Action_ApplyWeaponDamageToUnit'.static.AddToVisualizationTree(ActionMetadata, AbilityContext, false, ParentAction));
		for (ScanEffect = 0; ScanEffect < AbilityContext.ResultContext.MultiTargetEffectResults[ScanTargets].Effects.Length; ++ScanEffect)
		{
			if (AbilityContext.ResultContext.MultiTargetEffectResults[ScanTargets].ApplyResults[ScanEffect] == 'AA_Success')
			{
				CurrentEffect = AbilityContext.ResultContext.MultiTargetEffectResults[ScanTargets].Effects[ScanEffect];
				break;
			}
		}
		UnitDamageAction.OriginatingEffect = CurrentEffect;
		UnitDamageAction.bShowFlyovers = false;

		// Jwats: Only add death during the last apply weapon damage pass
		if (ScanTargets + NumActualTargets >= AbilityContext.InputContext.MultiTargets.Length)
		{
			UnitDamageAction.bShowFlyovers = true;
			UnitDamageAction.bCombineFlyovers = true;
			XGUnit(ActionMetadata.VisualizeActor).BuildAbilityEffectsVisualization(VisualizeGameState, ActionMetadata);
		}

	}

	VisMgr.GetAllLeafNodes(VisMgr.BuildVisTree, LeafNodes);
	JoinActions = X2Action_MarkerNamed(class'X2Action_MarkerNamed'.static.AddToVisualizationTree(SourceMetadata, AbilityContext, false, , LeafNodes));
	JoinActions.SetName("Join");
}

function bool IonicStormDamagePreview(XComGameState_Ability AbilityState, StateObjectReference TargetRef, out WeaponDamageValue MinDamagePreview, out WeaponDamageValue MaxDamagePreview, out int AllowsShield)
{
	local XComGameState_Unit SourceUnit;
	local int FocusLevel;
	
	// Call the default damage preview first, but only for the organic ability target effect
	AbilityState.GetMyTemplate().AbilityMultiTargetEffects[0].GetDamagePreview(TargetRef, AbilityState, false, MinDamagePreview, MaxDamagePreview, AllowsShield); 

	SourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));

	if( SourceUnit != None && SourceUnit.ObjectID != TargetRef.ObjectID )
	{
		FocusLevel = SourceUnit.GetTemplarFocusLevel();
		
		// Then modify based on current Focus level
		MinDamagePreview.Damage = MinDamagePreview.Damage * FocusLevel;
		MaxDamagePreview.Damage = MaxDamagePreview.Damage * FocusLevel;
	}

	return true;
}

static function X2AbilityTemplate RTTemplarExtraOrdnance()
{
	local X2AbilityTemplate         Template;

	Template = PurePassive('RTTemplarExtraOrdnance', "img:///UILibrary_PerkIcons.UIPerk_aceinthehole");	
	
	Template.bCrossClassEligible = false;
	Template.GetBonusWeaponAmmoFn = TemplarExtraOrdnance_BonusWeaponAmmo;

	return Template;
}

function int TemplarExtraOrdnance_BonusWeaponAmmo(XComGameState_Unit UnitState, XComGameState_Item ItemState)
{
	if (ItemState.InventorySlot == eInvSlot_Utility)
		return default.TEMPLAR_PEON_EXTRA_GRENADES;

	return 0;
}

static function PatchTemplarFocusVisualization() {
	local name AbilityTemplateName;
	local X2AbilityTemplate AbilityTemplate;
	local array<X2AbilityTemplate> AbilityTemplates;
	local X2AbilityTemplateManager AbilityTemplateMgr;
	local array<name> AbilityTemplateNames;

	local X2Effect_TemplarFocus	FocusEffect;
	local X2Effect EffectTemplate;

	//`RTLOG("Patching Templar Focus X2AbiliyTemplate - changing visualization!");
	AbilityTemplateMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityTemplateMgr.GetTemplateNames(AbilityTemplateNames);
	foreach AbilityTemplateNames(AbilityTemplateName) {
		AbilityTemplates.Length = 0;
		AbilityTemplateMgr.FindAbilityTemplateAllDifficulties(AbilityTemplateName, AbilityTemplates);

		foreach AbilityTemplates(AbilityTemplate) {

			if(AbilityTemplate.DataName != 'TemplarFocus')
				continue;

			foreach AbilityTemplate.AbilityTargetEffects(EffectTemplate) {
				FocusEffect = X2Effect_TemplarFocus(EffectTemplate);
				if(FocusEffect == none) {
					continue;
				}

				FocusEffect.EffectSyncVisualizationFn = PatchedFocusEffectVisualization;
				FocusEffect.VisualizationFn = PatchedFocusEffectVisualization;
			}
			
		}
	}
}

static function PatchedFocusEffectVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local XComGameState_Unit UnitState;
	local XComGameState_Effect_TemplarFocus FocusState;

	`RTLOG("Patched Focus Effect Visualization invoked!");

	UnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);
	if( UnitState != None )
	{
		FocusState = UnitState.GetTemplarFocusEffectState();
		if( FocusState != None )
		{
			if(class'RTCondition_VisibleToPlayer'.static.IsTargetVisibleToLocalPlayer(UnitState.GetReference())) {
				class'X2Ability_TemplarAbilitySet'.static.PlayFocusFX(VisualizeGameState, ActionMetadata, "ADD_StartFocus", FocusState.FocusLevel);
			}
			class'X2Ability_TemplarAbilitySet'.static.UpdateFocusUI(VisualizeGameState, ActionMetadata);
		}
	}
}