class RTAbility_TemplarAbilitySet extends RTAbility_GhostAbilitySet config (RisingTides);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(RTUnwaveringResolve());
	Templates.AddItem(RTUnwaveringResolveIcon());

	return Templates;
}


// Passive - Gain one focus when it is drained to 0
static function X2AbilityTemplate RTUnwaveringResolve()
{
	local X2AbilityTemplate						Template;
	local X2Effect_ModifyTemplarFocus			Effect;
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
	
	Effect = new class'X2Effect_ModifyTemplarFocus';
	Effect.TargetConditions.AddItem(new class'X2Condition_GhostShooter');
	Template.AddTargetEffect(Effect);

	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.MergeVisualizationFn = DesiredVisualizationBlock_MergeVisualization;
	Template.bShowActivation = true;
	
	Template.AdditionalAbilities.AddItem('RTUnwaveringResolveIcon');

	return Template;
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