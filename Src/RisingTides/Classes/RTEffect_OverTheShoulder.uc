class RTEffect_OverTheShoulder extends X2Effect_AuraSource;

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
	EventMgr.RegisterForEvent(EffectObj, 'UnitMoveFinished', RTEffectState.OnUpdateAuraCheck, ELD_OnStateSubmitted, 50);
	EventMgr.RegisterForEvent(EffectObj, 'PlayerTurnBegun', RTEffectState.CleanupMobileSquadViewers, ELD_OnStateSubmitted, 50);
}

protected function bool CheckAuraConditions(XComGameState_Unit SourceUnitState, XComGameState_Unit TargetUnitState, XComGameState_Effect SourceAuraEffectGameState) {
	if(class'Helpers'.static.IsTileInRange(SourceUnitState.TileLocation, TargetUnitState.TileLocation, class'RTAbility_GathererAbilitySet'.default.OTS_RADIUS_SQ, 100)) {
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
	local XComGameStateHistory History;
	local XComGameState_Ability AbilityStateObject;
	local X2AbilityTemplate AbilityTemplate;
	local int i;
	local name EffectAttachmentResult;
	local bool bIsAtLeastOneEffectAttached;
	local bool bShouldAffect;

	local X2Effect_Persistent PersistentAuraEffect;
	local XComGameState_Effect NewAuraEffectState;
	local array<StateObjectReference> EffectsToAdd;
	local XComGameStateContext_EffectAdded EffectAddedContext;

	local RTGameState_Effect RTSourceAuraEffectGameState;

	History = `XCOMHISTORY;

	NewTargetState = XComGameState_Unit(NewGameState.CreateStateObject(TargetUnitState.Class, TargetUnitState.ObjectID));
	NewTargetState.bRequiresVisibilityUpdate = true;
	NewGameState.AddStateObject(NewTargetState);

	AuraTargetApplyData = SourceAuraEffectGameState.ApplyEffectParameters;
	AuraTargetApplyData.EffectRef.LookupType = TELT_AbilityMultiTargetEffects;
	AuraTargetApplyData.TargetStateObjectRef = TargetUnitState.GetReference();

	AbilityTemplate = GetAuraTemplate(SourceUnitState, TargetUnitState, SourceAuraEffectGameState, NewGameState);

	bIsAtLeastOneEffectAttached = false;

	RTSourceAuraEffectGameState = RTGameState_Effect(SourceAuraEffectGameState);
	if(RTSourceAuraEffectGameState == none) {
		`RedScreenOnce("The source aura isn't of type RTGameState_Effect! The Visualization may fail!");
	}


	if(CheckAuraConditions(SourceUnitState, NewTargetState, SourceAuraEffectGameState)) {

		// EffectAddedContext = class'XComGameStateContext_EffectAdded'.static.CreateEffectsAddedState(EffectsToAdd);
		// NewGameState = History.CreateGameState(true, EffectAddedContext);


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
					EffectsToAdd.AddItem(NewAuraEffectState.GetReference());
				}
			}

		}

		// Visualization
		//XComGameStateContext_EffectAdded(NewGameState.GetContext()).EffectsToAdd = EffectsToAdd;
		//NewGameState.AddStateObject(NewTargetState);
		//`TACTICALRULES.SubmitGameState(NewGameState);
		XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = RTSourceAuraEffectGameState.EffectsModifiedBuildVisualizationFn;
	}
	else {
		// RemoveAuraTargetEffects(SourceUnitState, NewTargetState, SourceAuraEffectGameState, GameState);
		RemoveAuraTargetEffects(SourceUnitState, NewTargetState, SourceAuraEffectGameState, NewGameState);
	}
}

private function RemoveAuraTargetEffects(XComGameState_Unit SourceUnitState, XComGameState_Unit TargetUnitState, XComGameState_Effect SourceAuraEffectGameState, XComGameState NewGameState)
{
	local XComGameState_Effect TargetUnitAuraEffect;
	local XComGameState_Ability AuraAbilityStateObject;
	local X2AbilityTemplate AuraAbilityTemplate;
	local XComGameStateHistory History;
	local int i;

	local array<XComGameState_Effect> EffectsToRemove;
	local X2Effect_Persistent PersistentAuraEffect;
	local XComGameStateContext_EffectRemoved RemoveContext;

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

			if (TargetUnitAuraEffect != none && (TargetUnitAuraEffect.ApplyEffectParameters.SourceStateObjectRef.ObjectID == SourceUnitState.ObjectID))
			{
				// This effect should be removed if it is affecting this Target Unit and the Source Unit of the
				// effect is the same as the SourceUnitState
				EffectsToRemove.AddItem(TargetUnitAuraEffect);
				RTSourceAuraEffectGameState.EffectsRemovedList.AddItem(TargetUnitAuraEffect.GetReference());
			}
		}
	}
	// EffectRemovedContext = class'XComGameStateContext_EffectRemoved'.static.CreateEffectsRemovedState(EffectsToRemove);
	// NewGameState = History.CreateGameState(true, EffectRemovedContext);
	// NewGameState.AddStateObject(TargetUnitState);


	for (i = 0; i < EffectsToRemove.Length; ++i)
	{
		// Remove each of the aura's effects from the target
		EffectsToRemove[i].RemoveEffect(NewGameState, NewGameState);
	}
	// Visualization
	//
	XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = RTSourceAuraEffectGameState.EffectsModifiedBuildVisualizationFn;

}

defaultproperties
{
	EffectName = "OverTheShoulder"
	DuplicateResponse = eDupe_Ignore
	GameStateEffectClass = class'RTGameState_Effect'
}
