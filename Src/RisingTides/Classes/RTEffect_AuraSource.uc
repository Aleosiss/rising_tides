class RTEffect_AuraSource extends X2Effect_AuraSource;

var float fScale;
var float fRadius;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local Object EffectObj;
	local RTGameState_Effect RTEffectState;

	EventMgr = `XEVENTMGR;
	RTEffectState = RTGameState_Effect(EffectGameState);
	EffectObj = RTEffectState;

	// Register for the required events

	// Check when anything moves. OnUpdateAuraCheck will handle a total update check as well as a single update check.
	EventMgr.RegisterForEvent(EffectObj, 'UnitMoveFinished', RTEffectState.OnUpdateAuraCheck, ELD_OnStateSubmitted, 60);

	// Check when anything spawns.
	EventMgr.RegisterForEvent(EffectObj, 'OnUnitBeginPlay', RTEffectState.OnUpdateAuraCheck, ELD_OnStateSubmitted, 40);
}

protected function bool CheckAuraConditions(XComGameState_Unit SourceUnitState, XComGameState_Unit TargetUnitState, XComGameState_Effect SourceAuraEffectGameState, X2AbilityTemplate AuraEffectTemplate) {
	if(class'Helpers'.static.IsTileInRange(SourceUnitState.TileLocation, TargetUnitState.TileLocation, Square(fRadius))) {
		return true;
	}
	return false;
}

protected function X2AbilityTemplate GetAuraTemplate(XComGameState_Unit SourceUnitState, XComGameState_Unit TargetUnitState, XComGameState_Effect SourceAuraEffectGameState, XComGameState NewGameState) {
	local X2AbilityTemplate Template;
	local XComGameState_Ability AbilityState;

	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(SourceAuraEffectGameState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	Template = AbilityState.GetMyTemplate();

	return Template;
}

function UpdateBasedOnAuraTarget(XComGameState_Unit SourceUnitState, XComGameState_Unit TargetUnitState, XComGameState_Effect SourceAuraEffectGameState, XComGameState NewGameState)
{
	local XComGameState_Unit NewTargetState;
	local EffectAppliedData AuraTargetApplyData;
	local X2AbilityTemplate AbilityTemplate;
	local int i;
	local name EffectAttachmentResult;
	local X2Effect_Persistent PersistentAuraEffect;
	local XComGameState_Effect NewAuraEffectState;
	local RTGameState_Effect RTSourceAuraEffectGameState;

	AuraTargetApplyData = SourceAuraEffectGameState.ApplyEffectParameters;
	AuraTargetApplyData.EffectRef.LookupType = TELT_AbilityMultiTargetEffects;
	AuraTargetApplyData.TargetStateObjectRef = TargetUnitState.GetReference();

	AbilityTemplate = GetAuraTemplate(SourceUnitState, TargetUnitState, SourceAuraEffectGameState, NewGameState);

	RTSourceAuraEffectGameState = RTGameState_Effect(SourceAuraEffectGameState);
	if(RTSourceAuraEffectGameState == none) {
		`RedScreenOnce("The source aura isn't of type RTGameState_Effect! The Visualization may fail!");
	}

	if(CheckAuraConditions(SourceUnitState, NewTargetState, SourceAuraEffectGameState, AbilityTemplate)) {
		NewTargetState = XComGameState_Unit(NewGameState.CreateStateObject(TargetUnitState.Class, TargetUnitState.ObjectID));
		NewTargetState.bRequiresVisibilityUpdate = true;
		NewGameState.AddStateObject(NewTargetState);

		for (i = 0; i < AbilityTemplate.AbilityMultiTargetEffects.Length; ++i)
		{
			// Apply each of the aura's effects to the target
			AuraTargetApplyData.EffectRef.TemplateEffectLookupArrayIndex = i;
			EffectAttachmentResult = AbilityTemplate.AbilityMultiTargetEffects[i].ApplyEffect(AuraTargetApplyData, NewTargetState, NewGameState);

			// If it attached, add it to the list of effects to visualize
			if(EffectAttachmentResult == 'AA_Success') {
				PersistentAuraEffect = X2Effect_Persistent(AbilityTemplate.AbilityMultiTargetEffects[i]);
				if(PersistentAuraEffect != none) {
					NewAuraEffectState = NewTargetState.GetUnitAffectedByEffectState(PersistentAuraEffect.EffectName);
					RTSourceAuraEffectGameState.EffectsAddedList.AddItem(NewAuraEffectState.GetReference());
				}
			}

		}

		// Need a custom 'effects modified' buildvisualizationfn to handle both removing and adding effects in a single context
		XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = RTSourceAuraEffectGameState.EffectsModifiedBuildVisualizationFn;
	}
	else {
		RemoveAuraTargetEffects(SourceUnitState, NewTargetState, SourceAuraEffectGameState, NewGameState);
	}
}

protected function RemoveAuraTargetEffects(XComGameState_Unit SourceUnitState, XComGameState_Unit TargetUnitState, XComGameState_Effect SourceAuraEffectGameState, XComGameState NewGameState)
{
	local XComGameState_Effect TargetUnitAuraEffect;
	local XComGameState_Ability AuraAbilityStateObject;
	local X2AbilityTemplate AuraAbilityTemplate;
	local XComGameStateHistory History;
	local int i;
	local array<XComGameState_Effect> EffectsToRemove;
	local X2Effect_Persistent PersistentAuraEffect;
	local RTGameState_Effect RTSourceAuraEffectGameState;

	History = `XCOMHISTORY;

	RTSourceAuraEffectGameState = RTGameState_Effect(SourceAuraEffectGameState);
	if(RTSourceAuraEffectGameState == none) {
		`RedScreenOnce("The source aura isn't of type RTGameState_Effect! The Visualization may fail!");
	}

	AuraAbilityStateObject = XComGameState_Ability(History.GetGameStateForObjectID(SourceAuraEffectGameState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	AuraAbilityTemplate = AuraAbilityStateObject.GetMyTemplate();

	for (i = 0; i < AuraAbilityTemplate.AbilityMultiTargetEffects.Length; ++i)
	{
		// Loop over all of the aura ability's multi effects and if they are persistent, save it off
		PersistentAuraEffect = X2Effect_Persistent(AuraAbilityTemplate.AbilityMultiTargetEffects[i]);

		if (PersistentAuraEffect != none && TargetUnitState.IsUnitAffectedByEffectName(PersistentAuraEffect.EffectName))
		{
			TargetUnitAuraEffect = TargetUnitState.GetUnitAffectedByEffectState(PersistentAuraEffect.EffectName);

			if (TargetUnitAuraEffect != none && (TargetUnitAuraEffect.ApplyEffectParameters.SourceStateObjectRef.ObjectID == SourceUnitState.ObjectID) && TargetUnitAuraEffect.iTurnsRemaining < 2)	// only remove effects that drop immediately
			{
				// This effect should be removed if it is affecting this Target Unit and the Source Unit of the
				// effect is the same as the SourceUnitStateout VisualizationActionM
				EffectsToRemove.AddItem(TargetUnitAuraEffect);
				RTSourceAuraEffectGameState.EffectsRemovedList.AddItem(TargetUnitAuraEffect.GetReference());
			}
		}
	}

	// Remove each of the aura's effects from the target
	for (i = 0; i < EffectsToRemove.Length; ++i)
	{
		EffectsToRemove[i].RemoveEffect(NewGameState, NewGameState);
	}
	// Visualization
	XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = RTSourceAuraEffectGameState.EffectsModifiedBuildVisualizationFn;

}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, name EffectApplyResult)
{
	local XComGameState_Effect EffectState, TickedEffectState;
	local X2Action_PersistentEffect PersistentEffectAction;
	local RTAction_PlayEffect PlayEffectAction;
	local int i;

	if( (EffectApplyResult == 'AA_Success') && (XComGameState_Unit(ActionMetadata.StateObject_NewState) != none) )
	{
		if (CustomIdleOverrideAnim != '')
		{
			// We started an idle override so this will clear it
			PersistentEffectAction = X2Action_PersistentEffect(class'X2Action_PersistentEffect'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
			PersistentEffectAction.IdleAnimName = CustomIdleOverrideAnim;
		}

		if (VFXTemplateName != "")
		{
			PlayEffectAction = RTAction_PlayEffect( class'RTAction_PlayEffect'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));

			PlayEffectAction.AttachToUnit = true;
			PlayEffectAction.EffectName = VFXTemplateName;
			PlayEffectAction.AttachToSocketName = VFXSocket;
			PlayEffectAction.AttachToSocketsArrayName = VFXSocketsArrayName;
			PlayEffectAction.Scale = fScale;
		}

		//  anything inside of ApplyOnTick needs handling here because when bTickWhenApplied is true, there is no separate context (which normally handles the visualization)
		if (bTickWhenApplied)
		{
			foreach VisualizeGameState.IterateByClassType(class'XComGameState_Effect', EffectState)
			{
				if (EffectState.GetX2Effect() == self)
				{
					TickedEffectState = EffectState;
					break;
				}
			}
			if (TickedEffectState != none)
			{
				for (i = 0; i < ApplyOnTick.Length; ++i)
				{
					ApplyOnTick[i].AddX2ActionsForVisualization_Tick(VisualizeGameState, ActionMetadata, i, TickedEffectState);
				}
			}
		}
	}

	if (VisualizationFn != none)
		VisualizationFn(VisualizeGameState, ActionMetadata, EffectApplyResult);
}

simulated function AddX2ActionsForVisualization_Sync( XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata )
{
	local RTAction_PlayEffect PlayEffectAction;

	if (VFXTemplateName != "")
	{
		PlayEffectAction = RTAction_PlayEffect( class'RTAction_PlayEffect'.static.AddToVisualizationTree( ActionMetadata, VisualizeGameState.GetContext( ) ) );

		PlayEffectAction.AttachToUnit = true;
		PlayEffectAction.EffectName = VFXTemplateName;
		PlayEffectAction.AttachToSocketName = VFXSocket;
		PlayEffectAction.AttachToSocketsArrayName = VFXSocketsArrayName;
		PlayEffectAction.Scale = fScale;
	}
}




defaultproperties
{
	EffectName = "OverTheShoulder"
	DuplicateResponse = eDupe_Ignore
	GameStateEffectClass = class'RTGameState_Effect'
}
