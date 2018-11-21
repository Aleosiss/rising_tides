class RTGameState_Effect extends XComGameState_Effect dependson(RTHelpers);

// RTEffect_OverTheShoulder
var array<StateObjectReference> EffectsAddedList;
var array<StateObjectReference> EffectsRemovedList;

// RTEffect_Repositioning
var array<TTile> PreviousTilePositions;
var bool bRepositioningActive;

// RTEffect_LinkedIntelligence
var bool bCanTrigger;

// RTEffect_Stealth
var bool bWasPreviouslyConcealed;

var localized string LocPsionicallyInterruptedName;

// OnTacticalGameEnd (Don't need this anymore)
function EventListenerReturn OnTacticalGameEnd(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local X2EventManager EventManager;
	local Object ListenerObj;
	local XComGameState NewGameState;

	//`LOG("Rising Tides: 'TacticalGameEnd' event listener delegate invoked.");

	EventManager = `XEVENTMGR;

	// Unregister our callbacks
	ListenerObj = self;

	EventManager.UnRegisterFromAllEvents(ListenerObj);

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RTGameState_Effect states cleanup");
	NewGameState.RemoveStateObject(ObjectID);
	`GAMERULES.SubmitGameState(NewGameState);

	//`LOG("RisingTides: RTGameState_Effect of type " @ self.class @" passive effect unregistered from events.");

	return ELR_NoInterrupt;
}

// ActivateAbility
protected function ActivateAbility(XComGameState_Ability AbilityState, StateObjectReference TargetRef) {
	local XComGameStateContext_Ability	AbilityContext;
	local XComGameState					NewGameState;

	if(AbilityState.CanActivateAbilityForObserverEvent(XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(TargetRef.ObjectID))) != 'AA_Success') {
		`LOG("Rising Tides: Couldn't Activate "@ AbilityState.GetMyTemplateName() @ " for observer event.");
	} else {
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Activating Ability " $ AbilityState.GetMyTemplateName());
		AbilityState = XComGameState_Ability(NewGameState.CreateStateObject(AbilityState.Class, AbilityState.ObjectID));
		NewGameState.AddStateObject(AbilityState);
		`TACTICALRULES.SubmitGameState(NewGameState);
	}

	AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(AbilityState, TargetRef.ObjectID);

	if( AbilityContext.Validate() ) {
		`TACTICALRULES.SubmitGameStateContext(AbilityContext);
	} else {
		`LOG("Rising Tides: Couldn't validate AbilityContext, " @ AbilityState.GetMyTemplateName() @ " not activated.");
	}
}

// InitializeAbilityForActivation
protected function InitializeAbilityForActivation(out XComGameState_Ability AbilityState, XComGameState_Unit AbilityOwnerUnit, Name AbilityName, XComGameStateHistory History) {
	local StateObjectReference AbilityRef;

	AbilityRef = AbilityOwnerUnit.FindAbility(AbilityName);
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));
	if(AbilityState == none) {
		`LOG("Rising Tides: Couldn't initialize ability for activation!");
	}
}

// EffectAddedBuildVisualizationFn
function EffectAddedBuildVisualizationFn (XComGameState VisualizeGameState) {
	local VisualizationActionMetadata SourceMetadata;
	local VisualizationActionMetadata TargetMetadata;
	local XComGameStateHistory History;
	local X2VisualizerInterface VisualizerInterface;
	local XComGameState_Effect EffectState;
	local XComGameState_BaseObject EffectTarget;
	local XComGameState_BaseObject EffectSource;
	local X2Effect_Persistent EffectTemplate;
	local int i;

	local XComGameState AssociatedState;
	local array<StateObjectReference> AddedEffects;


	History = `XCOMHISTORY;

	AddedEffects = EffectsAddedList;
	AssociatedState = VisualizeGameState;

	for (i = 0; i < AddedEffects.Length; ++i)
	{
		EffectState = XComGameState_Effect(History.GetGameStateForObjectID(AddedEffects[i].ObjectID));
		if (EffectState != none)
		{
			EffectSource = History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID);
			EffectTarget = History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID);

			if (EffectTarget != none)
			{
				TargetMetadata.VisualizeActor = History.GetVisualizer(EffectTarget.ObjectID);
				VisualizerInterface = X2VisualizerInterface(TargetMetadata.VisualizeActor );
				if (TargetMetadata.VisualizeActor != none)
				{
					History.GetCurrentAndPreviousGameStatesForObjectID(EffectTarget.ObjectID, TargetMetadata.StateObject_OldState, TargetMetadata.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
					if (TargetMetadata.StateObject_NewState == none)
					TargetMetadata.StateObject_NewState = TargetMetadata.StateObject_OldState;

					if (VisualizerInterface != none)
					VisualizerInterface.BuildAbilityEffectsVisualization(AssociatedState, TargetMetadata);

					EffectTemplate = EffectState.GetX2Effect();
					EffectTemplate.AddX2ActionsForVisualization(AssociatedState, TargetMetadata, 'AA_Success');
				}

				if (EffectTarget.ObjectID == EffectSource.ObjectID)
				{
					SourceMetadata = TargetMetadata;
				}

				SourceMetadata.VisualizeActor = History.GetVisualizer(EffectSource.ObjectID);
				if (SourceMetadata.VisualizeActor != none)
				{
					History.GetCurrentAndPreviousGameStatesForObjectID(EffectSource.ObjectID, SourceMetadata.StateObject_OldState, SourceMetadata.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
					if (SourceMetadata.StateObject_NewState == none)
						SourceMetadata.StateObject_NewState = SourceMetadata.StateObject_OldState;

					EffectTemplate.AddX2ActionsForVisualizationSource(AssociatedState, SourceMetadata, 'AA_Success');
				}
			}
		}
	}
}

// EffectRemovedBuildVisualizationFn
function EffectRemovedBuildVisualizationFn(XComGameState VisualizeGameState) {
	local VisualizationActionMetadata SourceMetadata;
	local VisualizationActionMetadata TargetMetadata;

	local XComGameStateHistory History;
	local X2VisualizerInterface VisualizerInterface;
	local XComGameState_Effect EffectState;
	local XComGameState_BaseObject EffectTarget;
	local XComGameState_BaseObject EffectSource;
	local X2Effect_Persistent EffectTemplate;
	local int i;

	local XComGameState AssociatedState;
	local array<StateObjectReference> RemovedEffects;

	History = `XCOMHISTORY;

	RemovedEffects = EffectsRemovedList;
	AssociatedState = VisualizeGameState;

	for (i = 0; i < RemovedEffects.Length; ++i)
	{
		EffectState = XComGameState_Effect(History.GetGameStateForObjectID(RemovedEffects[i].ObjectID));
		if (EffectState != none)
		{
			EffectSource = History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID);
			EffectTarget = History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID);

			if (EffectTarget != none)
			{
				TargetMetadata.VisualizeActor = History.GetVisualizer(EffectTarget.ObjectID);
				VisualizerInterface = X2VisualizerInterface(TargetMetadata.VisualizeActor);
				if (TargetMetadata.VisualizeActor != none)
				{
					History.GetCurrentAndPreviousGameStatesForObjectID(EffectTarget.ObjectID, TargetMetadata.StateObject_OldState, TargetMetadata.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
					if (TargetMetadata.StateObject_NewState == none)
						TargetMetadata.StateObject_NewState = TargetMetadata.StateObject_OldState;

					if (VisualizerInterface != none)
						VisualizerInterface.BuildAbilityEffectsVisualization(AssociatedState, TargetMetadata);

					EffectTemplate = EffectState.GetX2Effect();
					EffectTemplate.AddX2ActionsForVisualization_Removed(AssociatedState, TargetMetadata, 'AA_Success', EffectState);

				}

				if (EffectTarget.ObjectID == EffectSource.ObjectID)
				{
					SourceMetadata = TargetMetadata;
				}

				SourceMetadata.VisualizeActor = History.GetVisualizer(EffectSource.ObjectID);
				if (SourceMetadata.VisualizeActor != none)
				{
					History.GetCurrentAndPreviousGameStatesForObjectID(EffectSource.ObjectID, SourceMetadata.StateObject_OldState, SourceMetadata.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
					if (SourceMetadata.StateObject_NewState == none)
						SourceMetadata.StateObject_NewState = SourceMetadata.StateObject_OldState;

					EffectTemplate.AddX2ActionsForVisualization_RemovedSource(AssociatedState, SourceMetadata, 'AA_Success', EffectState);
				}
			}
		}
	}
}

// EffectsModifiedBuildVisualizationFn
function EffectsModifiedBuildVisualizationFn(XComGameState VisualizeGameState) {
	local VisualizationActionMetadata SourceMetadata;
	local VisualizationActionMetadata TargetMetadata;
	local XComGameStateHistory History;
	local X2VisualizerInterface VisualizerInterface;
	local XComGameState_Effect EffectState;
	local XComGameState_BaseObject EffectTarget;
	local XComGameState_BaseObject EffectSource;
	local X2Effect_Persistent EffectTemplate;
	local int i;

	local XComGameState AssociatedState;
	local array<StateObjectReference> RemovedEffects;
	local array<StateObjectReference> AddedEffects;

	History = `XCOMHISTORY;

	AddedEffects = EffectsAddedList;
	RemovedEffects = EffectsRemovedList;
	AssociatedState = VisualizeGameState;

	// remove the effects...
	for (i = 0; i < RemovedEffects.Length; ++i)
	{
		EffectState = XComGameState_Effect(History.GetGameStateForObjectID(RemovedEffects[i].ObjectID));
		if (EffectState != none)
		{
			EffectSource = History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID);
			EffectTarget = History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID);

			if (EffectTarget != none)
			{
				TargetMetadata.VisualizeActor = History.GetVisualizer(EffectTarget.ObjectID);
				VisualizerInterface = X2VisualizerInterface(TargetMetadata.VisualizeActor);
				if (TargetMetadata.VisualizeActor != none)
				{
					History.GetCurrentAndPreviousGameStatesForObjectID(EffectTarget.ObjectID, TargetMetadata.StateObject_OldState, TargetMetadata.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
					if (TargetMetadata.StateObject_NewState == none)
						TargetMetadata.StateObject_NewState = TargetMetadata.StateObject_OldState;

					if (VisualizerInterface != none)
						VisualizerInterface.BuildAbilityEffectsVisualization(AssociatedState, TargetMetadata);

					EffectTemplate = EffectState.GetX2Effect();
					EffectTemplate.AddX2ActionsForVisualization_Removed(AssociatedState, TargetMetadata, 'AA_Success', EffectState);
				}

				if (EffectTarget.ObjectID == EffectSource.ObjectID)
				{
					SourceMetadata = TargetMetadata;
				}

				SourceMetadata.VisualizeActor = History.GetVisualizer(EffectSource.ObjectID);
				if (SourceMetadata.VisualizeActor != none)
				{
					History.GetCurrentAndPreviousGameStatesForObjectID(EffectSource.ObjectID, SourceMetadata.StateObject_OldState, SourceMetadata.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
					if (SourceMetadata.StateObject_NewState == none)
						SourceMetadata.StateObject_NewState = SourceMetadata.StateObject_OldState;

					EffectTemplate.AddX2ActionsForVisualization_RemovedSource(AssociatedState, SourceMetadata, 'AA_Success', EffectState);
				}
			}
		}
	}
	// end remove effects
	// add new effects...
	for (i = 0; i < AddedEffects.Length; ++i)
	{
		EffectState = XComGameState_Effect(History.GetGameStateForObjectID(AddedEffects[i].ObjectID));
		if (EffectState != none)
		{
			EffectSource = History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID);
			EffectTarget = History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID);

			if (EffectTarget != none)
			{
				TargetMetadata.VisualizeActor = History.GetVisualizer(EffectTarget.ObjectID);
				VisualizerInterface = X2VisualizerInterface(TargetMetadata.VisualizeActor );
				if (TargetMetadata.VisualizeActor != none)
				{
					History.GetCurrentAndPreviousGameStatesForObjectID(EffectTarget.ObjectID, TargetMetadata.StateObject_OldState, TargetMetadata.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
					if (TargetMetadata.StateObject_NewState == none)
						TargetMetadata.StateObject_NewState = TargetMetadata.StateObject_OldState;

					if (VisualizerInterface != none)
						VisualizerInterface.BuildAbilityEffectsVisualization(AssociatedState, TargetMetadata);

					EffectTemplate = EffectState.GetX2Effect();
					EffectTemplate.AddX2ActionsForVisualization(AssociatedState, TargetMetadata, 'AA_Success');
				}

				if (EffectTarget.ObjectID == EffectSource.ObjectID)
				{
					SourceMetadata = TargetMetadata;
				}

				SourceMetadata.VisualizeActor = History.GetVisualizer(EffectSource.ObjectID);
				if (SourceMetadata.VisualizeActor != none)
				{
					History.GetCurrentAndPreviousGameStatesForObjectID(EffectSource.ObjectID, SourceMetadata.StateObject_OldState, SourceMetadata.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
					if (SourceMetadata.StateObject_NewState == none)
						SourceMetadata.StateObject_NewState = SourceMetadata.StateObject_OldState;

					EffectTemplate.AddX2ActionsForVisualizationSource(AssociatedState, SourceMetadata, 'AA_Success');
				}
			}
		}
	}	
	// end add effects
	ClearEffectLists();
}

// ClearEffectLists
function ClearEffectLists() {
	EffectsAddedList.Length = 0;
	EffectsRemovedList.Length = 0;
}

// CleanupMobileSquadViewers
function EventListenerReturn CleanupMobileSquadViewers(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameStateHistory History;
	local RTGameState_SquadViewer ViewerState;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RTGameState_Effect cleaning up OTS SquadViewers!");

	foreach History.IterateByClassType(class'RTGameState_SquadViewer', ViewerState) {
		if(XComGameState_Unit(History.GetGameStateForObjectID(ViewerState.AssociatedUnit.ObjectID)).AffectedByEffectNames.Find(class'RTEffect_TimeStop'.default.EffectName) != INDEX_NONE) {
			ViewerState.bRequiresVisibilityUpdate = true;
			ViewerState.DestroyVisualizer();
		}
	}

	SubmitNewGameState(NewGameState);
	return ELR_NoInterrupt;
}

// OnUpdateAuraCheck
function EventListenerReturn OnUpdateAuraCheck(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local X2Effect_AuraSource AuraTemplate;
	local XComGameState_Unit UpdatedUnitState, AuraSourceUnitState;
	local XComGameStateHistory History;
	local XComGameState_Effect ThisEffect;
	local XComGameState NewGameState;

	UpdatedUnitState = XComGameState_Unit(EventData);
	`assert(UpdatedUnitState != none);

	if (ApplyEffectParameters.TargetStateObjectRef.ObjectID == UpdatedUnitState.ObjectID)
	{
		// If the Target Unit (Owning Unit of the aura) is the same as the Updated unit, then a comprehensive check must be done
		OnTotalAuraCheck(EventData, EventSource, GameState, EventID, CallbackData);
	}
	else
	{
		History = `XCOMHISTORY;
		ThisEffect = self;

		AuraSourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
		`assert(AuraSourceUnitState != none);

		AuraTemplate = X2Effect_AuraSource(GetX2Effect());

		`assert(AuraTemplate != none);

		// Create a new gamestate
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("X2Effect_AuraSource: Affecting Target");

		// The Target Unit different than the Owning Unit of the aura, so only it needs to be checked
		AuraTemplate.UpdateBasedOnAuraTarget(AuraSourceUnitState, UpdatedUnitState, ThisEffect, NewGameState);

		// Submit the new gamestate
		SubmitNewGameState(NewGameState);

	}



	return ELR_NoInterrupt;
}

// OnTotalAuraCheck
function EventListenerReturn OnTotalAuraCheck(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local X2Effect_AuraSource AuraTemplate;
	local XComGameState_Unit TargetUnitState, AuraSourceUnitState;
	local XComGameStateHistory History;
	local XComGameState_Effect ThisEffect;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;

	AuraSourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	`assert(AuraSourceUnitState != none);

	AuraTemplate = X2Effect_AuraSource(GetX2Effect());
	`assert(AuraTemplate != none);

	ThisEffect = self;

	// Create a new gamestate
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RTEffect_OverTheShoulder: Affecting Target");

	/// All Units must be checked and possibly have the aura effects added or removed
	foreach History.IterateByClassType(class'XComGameState_Unit', TargetUnitState)
	{
		if ((TargetUnitState.ObjectID != AuraSourceUnitState.ObjectID))
		{
			AuraTemplate.UpdateBasedOnAuraTarget(AuraSourceUnitState, TargetUnitState, ThisEffect, NewGameState);
		}
	}

	// Submit the new gamestate
	SubmitNewGameState(NewGameState);

	return ELR_NoInterrupt;
}

// Overkill Damage Recorder (KillMail);
function EventListenerReturn RTOverkillDamageRecorder(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameState_Unit DeadUnitState, PreviousDeadUnitState, KillerUnitState, NewKillerUnitState;
	local UnitValue LastEffectDamageValue;
	local int iOverKillDamage, i, iHPValue;
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_BaseObject PreviousObject, CurrentObject;

	History = `XCOMHISTORY;

	DeadUnitState = XComGameState_Unit(EventData);
	KillerUnitState = XComGameState_Unit(EventSource);
	if(DeadUnitState == none || KillerUnitState == none) {
		`RedScreenOnce("Rising Tides: OverkillDamageRecorder received invalid Killer or Dead Unit from KillMail");
		return ELR_NoInterrupt;
	}

	if(KillerUnitState.ObjectID != ApplyEffectParameters.TargetStateObjectRef.ObjectID) {
		// not me! (teehee)
		return ELR_NoInterrupt;
	}

	DeadUnitState.GetUnitValue('LastEffectDamage', LastEffectDamageValue);
	PreviousDeadUnitState = XComGameState_Unit(History.GetPreviousGameStateForObject(DeadUnitState));

	while(iHPValue == 0 && i != 20) {
		i++;
		History.GetCurrentAndPreviousGameStatesForObjectID(DeadUnitState.GetReference().ObjectID, PreviousObject, CurrentObject,, GameState.HistoryIndex - i);
		PreviousDeadUnitState = XComGameState_Unit(PreviousObject);
		iHPValue = PreviousDeadUnitState.GetCurrentStat( eStat_HP );
		//`LOG("Rising Tides: iHPValue"@iHPValue);
	}

	iOverKillDamage = abs(PreviousDeadUnitState.GetCurrentStat( eStat_HP ) - LastEffectDamageValue.fValue);

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: Recording Overkill Damage!");
	NewKillerUnitState = XComGameState_Unit(NewGameState.CreateStateObject(KillerUnitState.class, KillerUnitState.ObjectID));
	NewKillerUnitState.SetUnitFloatValue('RTLastOverkillDamage', iOverKillDamage, eCleanup_BeginTactical);
	// `LOG("Rising Tides: Logging overkill damage =" @iOverkillDamage);
	NewGameState.AddStateObject(NewKillerUnitState);
	SubmitNewGameState(NewGameState);

	return ELR_NoInterrupt;
}

// intended event id = AbilityActivated filter = none
// intended EventData = Ability we're going to try to interrupt
// intended EventSource = Unit we're going to try to interrupt
function EventListenerReturn RTPsionicInterrupt(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameStateHistory History;
	local XComGameState_Ability AbilityState;
	local XComGameState_Ability InterruptAbilityState;
	local XComGameState_Unit TargetUnitState, SourceUnitState;
	local XComGameStateContext AbilityContext;
	local XComGameState	NewGameState;

	AbilityContext = GameState.GetContext();
	if(AbilityContext == none) {
		return ELR_NoInterrupt;
	}

	if (AbilityContext.InterruptionStatus != eInterruptionStatus_Interrupt) {
			return ELR_NoInterrupt;
	}

	History = `XCOMHISTORY;
	AbilityState = XComGameState_Ability(EventData);
	if(AbilityState == none) {
		//`LOG("Rising Tides: " @ GetFuncName() @ " has invalid EventData!");
		return ELR_NoInterrupt;
	}

	TargetUnitState = XComGameState_Unit(EventSource);
	if(TargetUnitState == none) {
		//`LOG("Rising Tides: " @ GetFuncName() @ " has invalid EventSource!");
		return ELR_NoInterrupt;
	}

	SourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	if(SourceUnitState == none) {
		//`LOG("Rising Tides: " @ GetFuncName() @ " has no SourceUnit?! ");
		return ELR_NoInterrupt;
	}

	if(TargetUnitState.AffectedByEffectNames.Find(class'RTAbility_GathererAbilitySet'.default.OverTheShoulderEffectName) == INDEX_NONE)
		return ELR_NoInterrupt;

	if(!TargetUnitState.IsEnemyUnit(SourceUnitState)) {
		return ELR_NoInterrupt;
	}

	if(class'RTHelpers'.static.CheckAbilityActivated(AbilityState.GetMyTemplateName(), eChecklist_PsionicAbilities)) {
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: recording interrupted AbilityStateObjectRef: " $ AbilityState.ObjectID);
		TargetUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(TargetUnitState.class, TargetUnitState.ObjectID));
		TargetUnitState.SetUnitFloatValue('RT_InterruptAbilityStateObjectID', AbilityState.ObjectID, eCleanup_BeginTurn);
		AbilityState = XComGameState_Ability(NewGameState.ModifyStateObject(AbilityState.class, AbilityState.ObjectID));
		AbilityState.iCooldown = class'RTAbility_GathererAbilitySet'.default.RUDIMENTARY_CREATURES_INTERRUPT_ABILITY_COOLDOWN;
		SubmitNewGameState(NewGameState);

		InitializeAbilityForActivation(InterruptAbilityState, SourceUnitState, 'RTRudimentaryCreaturesEvent', History);
		ActivateAbility(InterruptAbilityState, TargetUnitState.GetReference());
		return ELR_InterruptEventAndListeners;
	}

	return ELR_NoInterrupt;
}

// intended event id AbilityActivated filter = unit with Harbinger attached
// intended EventData is the ability we're going to add bonus damage to
// intended EventSource is the unit with Harbinger attached
function EventListenerReturn RTHarbingerBonusDamage(Object EventData, Object EventSource, XComGameState GameState, Name EventID) {
	local XComGameStateHistory History;
	local XComGameState_Ability AbilityState, AdditionalDamageState;
	local XComGameState_Unit TargetUnitState, SourceUnitState;
	local XComGameStateContext Context;
	local XComGameStateContext_Ability AbilityContext;

	Context = GameState.GetContext();
	if(Context == none) {
		//`LOG("Rising Tides: No Context!");
		return ELR_NoInterrupt;
	}
	AbilityContext = XComGameStateContext_Ability(Context);
	if(AbilityContext == none) {
		//`LOG("Rising Tides: No Ability Context!");
		return ELR_NoInterrupt;
	}

	// we want to do the additional damage before, i think
	if(AbilityContext.InterruptionStatus != eInterruptionStatus_Interrupt) {
		//`LOG("Rising Tides: only on interrupt stage!");
		return ELR_NoInterrupt;
	}

	History = `XCOMHISTORY;
	AbilityState = XComGameState_Ability(EventData);
	if(AbilityState == none) {
		//`LOG("Rising Tides: " @ GetFuncName() @ " has invalid EventData!");
		return ELR_NoInterrupt;
	}

	if(AbilityState.GetMyTemplateName() != 'DaybreakFlame') {
	// don't add bonus damage to an attack that missed...
		if(AbilityContext.ResultContext.HitResult != eHit_Success || AbilityContext.ResultContext.HitResult != eHit_Crit || AbilityContext.ResultContext.HitResult != eHit_Graze) {
			//`LOG("Rising Tides: Shot didn't hit!");
			return ELR_NoInterrupt;
		}
	}

	SourceUnitState = XComGameState_Unit(EventSource);
	if(SourceUnitState == none) {
		//`LOG("Rising Tides: " @ GetFuncName() @ " has invalid EventSource!");
		return ELR_NoInterrupt;
	}

	TargetUnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	if(TargetUnitState == none) {
		//`LOG("Rising Tides: " @ GetFuncName() @ " has no TargetUnit?! ");
		return ELR_NoInterrupt;

	}
	//`LOG("Rising Tides: RTHarbingerBonusDamage is checking for the current ability to add damage to...");
	if(class'RTHelpers'.static.CheckAbilityActivated(AbilityState.GetMyTemplateName(), eChecklist_SniperShots)   ||
	 class'RTHelpers'.static.CheckAbilityActivated(AbilityState.GetMyTemplateName(), eChecklist_StandardShots) ||
	 class'RTHelpers'.static.CheckAbilityActivated(AbilityState.GetMyTemplateName(), eChecklist_MeleeAbilities) ) {
		InitializeAbilityForActivation(AdditionalDamageState, SourceUnitState, 'RTHarbingerBonusDamage', History);
		ActivateAbility(AdditionalDamageState, TargetUnitState.GetReference());
		return ELR_NoInterrupt;
	}

	//`LOG("Rising Tides: RTHarbingerBonusDamage failed!");

	return ELR_NoInterrupt;
}

// intended event id = AbilityActivated filter = Unit
// intended EventData = Ability we're going to try to extend the effect of
// intended EventSource = Unit casting the ability
function EventListenerReturn ExtendEffectDuration(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameState_Effect IteratorEffectState, ExtendedEffectState;
	local XComGameStateContext_Ability AbilityContext;
	local RTEffect_ExtendEffectDuration EffectTemplate;
	local XComGameState					NewGameState;
	local XComGameStateHistory			History;

	local bool bDebug;

	EffectTemplate = RTEffect_ExtendEffectDuration(GetX2Effect());
	if(EffectTemplate == none) {
		`LOG("Rising Tides: ExtendEffectDuration had no template!");
	return ELR_NoInterrupt;
	}

	//`LOG("Rising Tides: Extend Effect Duration activated on EVENTID: " @ EventID);

	if(EventID == 'AbilityActivated') {
		AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
		if(AbilityContext == none) {
			return ELR_NoInterrupt;
		}

		if(AbilityContext.InputContext.AbilityTemplateName != EffectTemplate.AbilityToExtendName) {
			//`LOG("Incorrect AbilityTemplateName; was " @ AbilityContext.InputContext.AbilityTemplateName @ ", expected " @ EffectTemplate.AbilityToExtendName);
			return ELR_NoInterrupt;
		}
	}
	bDebug = false;
	//`LOG("Rising Tides: Attempting to extend " @ EffectTemplate.AbilityToExtendName);
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: Extending " @ EffectTemplate.EffectToExtendName);
	foreach GameState.IterateByClassType(class'XComGameState_Effect', IteratorEffectState) {
	if(IteratorEffectState == none) {
		//`RedScreen("Rising Tides: What the heck, iterating through gamestate_effects returned a non-gamestate_effect object?");
		continue;
	}

	if(IteratorEffectState.bRemoved) {
		continue;
	}

	if(IteratorEffectState.GetX2Effect().EffectName == EffectTemplate.EffectToExtendName) {
		//`LOG("Rising TIdes: EED proced on " @ EffectTemplate.AbilityToExtendName @ " for effect " @	EffectTemplate.EffectToExtendName);
		bDebug = true;
		ExtendedEffectState = XComGameState_Effect(NewGameState.CreateStateObject(class'XComGameState_Effect', IteratorEffectState.ObjectID));
		ExtendedEffectState.iTurnsRemaining += EffectTemplate.iDurationExtension;
		NewGameState.AddStateObject(ExtendedEffectState);
		continue;
	}
	}

	History = `XCOMHISTORY;

	if(NewGameState.GetNumGameStateObjects() > 0) {
		SubmitNewGameState(NewGameState);
	} else {
		History.CleanupPendingGameState(NewGameState);
	}



	if(!bDebug) {
	//`LOG("Rising Tides: ExtendEffectDuration fired on the right ability / event, but there was no effects on the gamestate?");
	}

	//`LOG("Rising Tides: ExtendEffectDuration was successful!");

	return ELR_NoInterrupt;
}

// this check grants the mobility change described in for the "Bump In The Night" ability
function EventListenerReturn BumpInTheNightStatCheck(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState NewGameState;
	local RTGameState_Effect TempEffect;


	UnitState = XComGameState_Unit(GameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	if (UnitState == None)
		UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	`assert(UnitState != None);

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
	NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));

	TempEffect = self;
	NewUnitState.UnApplyEffectFromStats(TempEffect, NewGameState);

	StatChanges.Length = 0;
	TempEffect.StatChanges.Length = 0;

	if(UnitState.HasSoldierAbility('RTQueenOfBlades')) {
		AddPersistentStatChange(StatChanges, eStat_Mobility, (RTEffect_Bloodlust(GetX2Effect()).iMobilityMod) * iStacks);
		TempEffect.AddPersistentStatChange(StatChanges, eStat_Mobility, (RTEffect_Bloodlust(GetX2Effect()).iMobilityMod) * iStacks);
	} else {
		AddPersistentStatChange(StatChanges, eStat_Mobility, -(RTEffect_Bloodlust(GetX2Effect()).iMobilityMod) * iStacks);
		TempEffect.AddPersistentStatChange(StatChanges, eStat_Mobility, -(RTEffect_Bloodlust(GetX2Effect()).iMobilityMod) * iStacks);
	}


	//XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = BloodlustStackVisualizationFn;		//TODO: this

	NewUnitState.ApplyEffectToStats(TempEffect, NewGameState);


	NewGameState.AddStateObject(NewUnitState);
	`TACTICALRULES.SubmitGameState(NewGameState);



	return ELR_NoInterrupt;
}

// AddPersistentStatChange(out array<StatChange> m_aStatChanges, ECharStatType StatType, float StatAmount, optional EStatModOp InModOp=MODOP_Addition )
simulated function AddPersistentStatChange(out array<StatChange> m_aStatChanges, ECharStatType StatType, float StatAmount, optional EStatModOp InModOp=MODOP_Addition ) {
	local StatChange NewChange;

	NewChange.StatType = StatType;
	NewChange.StatAmount = StatAmount;
	NewChange.ModOp = InModOp;

	m_aStatChanges.AddItem(NewChange);
}

function EventListenerReturn EveryMomentMattersCheck(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState NewGameState;
	local XComGameState_Unit SourceUnit;
	local XComGameStateHistory History;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext != none) {
		if (AbilityContext.InputContext.SourceObject.ObjectID == ApplyEffectParameters.SourceStateObjectRef.ObjectID) {
			History = `XCOMHISTORY;
			SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
			if (`TACTICALRULES.GetCachedUnitActionPlayerRef().ObjectID == SourceUnit.ControllingPlayer.ObjectID) {

				// We only want to grant points when the source is actually shooting a shot
				if( !class'RTHelpers'.static.CheckAbilityActivated(AbilityContext.InputContext.AbilityTemplateName, eChecklist_SniperShots)) {
						return ELR_NoInterrupt;
				}

				if(SourceUnit.GetItemInSlot(eInvSlot_PrimaryWeapon).Ammo == 0) {
					NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
					XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = EveryMomentMattersVisualizationFn;
					SourceUnit = XComGameState_Unit(NewGameState.CreateStateObject(SourceUnit.Class, SourceUnit.ObjectID));
					SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.MoveActionPoint);
					NewGameState.AddStateObject(SourceUnit);
					`TACTICALRULES.SubmitGameState(NewGameState);
				}
			}
		}
	}

	return ELR_NoInterrupt;
}

function EveryMomentMattersVisualizationFn(XComGameState VisualizeGameState) {
	local XComGameState_Unit UnitState;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local VisualizationActionMetadata ActionMetadata;
	local XComGameStateHistory History;
	local X2AbilityTemplate AbilityTemplate;

	History = `XCOMHISTORY;
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState, , VisualizeGameState.HistoryIndex);
		ActionMetadata.StateObject_NewState = UnitState;
		ActionMetadata.VisualizeActor  = UnitState.GetVisualizer();

		AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('RTEveryMomentMatters');
		if (AbilityTemplate != none)
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFriendlyName, '', eColor_Good, AbilityTemplate.IconImage);

		} else {
			class'RTHelpers'.static.RTLog("Rising Tides - Every Moment Matters: Couldn't find AbilityTemplate for visualization!");
		}
		break;
	}
}

function EventListenerReturn GhostInTheShellCheck(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameStateHistory History;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability GhostAbilityState;
	local XComGameState_Ability AbilityState;
	local XComGameState_Unit NewAttacker, Attacker;
	local XComGameState NewGameState;
	local bool	bShouldTrigger;

	History = `XCOMHISTORY;
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext == none)
		return ELR_NoInterrupt;

	// Check if the source object was the source unit for this effect, and make sure the target was not
	if (AbilityContext.InputContext.SourceObject.ObjectID != ApplyEffectParameters.SourceStateObjectRef.ObjectID ||
		AbilityContext.InputContext.SourceObject.ObjectID == AbilityContext.InputContext.PrimaryTarget.ObjectID)
		return ELR_NoInterrupt;

	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
	if (AbilityState == none || AbilityState.ObjectID == 0)
		return ELR_NoInterrupt;

	if(AbilityState.GetMyTemplateName() == 'Interact_OpenChest' || AbilityState.GetMyTemplateName() == 'Interact_TakeVial' || AbilityState.GetMyTemplateName() == 'Interact_StasisTube')
			bShouldTrigger = true;
	if(AbilityState.GetMyTemplateName() == 'Interact' || AbilityState.GetMyTemplateName() == 'Interact_PlantBomb' /*|| AbilityState.GetMyTemplateName() == 'Interact_OpenDoor'*/)
			bShouldTrigger = true;
	if(AbilityState.GetMyTemplateName() == 'FinalizeHack' || AbilityState.GetMyTemplateName() == 'GatherEvidence' || AbilityState.GetMyTemplateName() == 'PlantExplosiveMissionDevice')
			bShouldTrigger = true;

	if(!bShouldTrigger) {
		return ELR_NoInterrupt;
	}

	Attacker = XComGameState_Unit(EventSource);

	if (Attacker != none) {
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
		NewAttacker = XComGameState_Unit(NewGameState.CreateStateObject(Attacker.Class, Attacker.ObjectID));
		//XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = TriggerBumpInTheNightFlyoverVisualizationFn;
		NewGameState.AddStateObject(NewAttacker);

		NewAttacker.ModifyCurrentStat(eStat_DetectionModifier, 0);
		`TACTICALRULES.SubmitGameState(NewGameState);

		InitializeAbilityForActivation(GhostAbilityState, NewAttacker, 'RTGhostInTheShellEffect', History);
		ActivateAbility(GhostAbilityState, NewAttacker.GetReference());
		NewAttacker = XComGameState_Unit(History.GetGameStateForObjectID(NewAttacker.ObjectID));

	}

	return ELR_NoInterrupt;
}

function TriggerGhostInTheShellFlyoverVisualizationFn(XComGameState VisualizeGameState) {
	local XComGameState_Unit UnitState;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local VisualizationActionMetadata ActionMetadata;
	local XComGameStateHistory History;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Ability AbilityState;

	History = `XCOMHISTORY;
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		foreach VisualizeGameState.IterateByClassType(class'XComGameState_Ability', AbilityState)
		{
			break;
		}
		if (AbilityState == none)
		{
			`RedScreenOnce("Ability state missing from" @ GetFuncName() @ "-jbouscher @gameplay");
			//`LOG("Rising Tides: ITS BROKEN");
			return;
		}

		History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState, , VisualizeGameState.HistoryIndex);
		ActionMetadata.StateObject_NewState = UnitState;
		ActionMetadata.VisualizeActor  = UnitState.GetVisualizer();

		AbilityTemplate = AbilityState.GetMyTemplate();
		if (AbilityTemplate != none)
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFriendlyName, '', eColor_Good, AbilityTemplate.IconImage);

		}
		break;
	}
}

function EventListenerReturn RemoveHarbingerEffect(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameStateContext_EffectRemoved RemoveContext;
	local XComGameState_Effect EffectState, NewEffectState;
	local StateObjectReference EffectRef;
	local XComGameState_Unit	SourceUnitState;
	local XComGameState NewGameState;
	local XComGameStateHistory History;

	if (!bRemoved)
	{
		`LOG("Rising Tides: Removing the Harbinger Effect due to Meld Loss!");

		History = `XCOMHISTORY;
		RemoveContext = class'XComGameStateContext_EffectRemoved'.static.CreateEffectRemovedContext(self);
		NewGameState = History.CreateNewGameState(true, RemoveContext);
		// remove effect
		RemoveEffect(NewGameState, GameState);

		// remove tag effect from source
		SourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
		foreach SourceUnitState.AffectedByEffects(EffectRef) {
			EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
			if(EffectState.GetX2Effect().EffectName == 'HarbingerTagEffect') {
				NewEffectState = XComGameState_Effect(NewGameState.CreateStateObject(EffectState.class, EffectState.ObjectID));
				NewEffectState.RemoveEffect(NewGameState, GameState);
			}
		}

		SubmitNewGameState(NewGameState);
	} else {
		`LOG("Rising Tides: Harbinger effect tried to remove itself, but it was already bRemoved?!");
	}

	return ELR_NoInterrupt;
}

function EventListenerReturn HeatChannelCheck(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
  local XComGameState_Unit OldSourceUnit, NewSourceUnit;
  local XComGameStateHistory History;
  local XComGameState_Ability OldAbilityState, NewAbilityState;
  local XComGameStateContext_Ability AbilityContext;
  local XComGameState_Item OldWeaponState, NewWeaponState;
  local XComGameState NewGameState;
  local UnitValue HeatChannelValue;
  local int iHeatChanneled;

  local XComGameState_Ability CooldownAbilityState;

  //`LOG("Rising Tides: Starting HeatChannel");
  // EventData = AbilityState to Channel
  OldAbilityState = XComGameState_Ability(EventData);
  // Event Source = UnitState of AbilityState
  OldSourceUnit = XComGameState_Unit(EventSource);

  if(OldAbilityState == none) {
	`RedScreenOnce("Rising Tides: EventData was not an XComGameState_Ability!");
	return ELR_NoInterrupt;
  }

  // immediately return if the event did not originate from ourselves
  if(ApplyEffectParameters.SourceStateObjectRef.ObjectID != OldSourceUnit.ObjectID) {
	`RedScreenOnce("Rising Tides: EventSource was not unit with Heat Channel!");
	return ELR_NoInterrupt;
  }
  // check the cooldown on HeatChannel
  if(!OldSourceUnit.GetUnitValue('RTEffect_HeatChannel_Cooldown', HeatChannelValue)) {
	`RedScreenOnce("Rising Tides: No HeatChannel Cooldown found!");
	return ELR_NoInterrupt;
  }
  OldSourceUnit.GetUnitValue('RTEffect_HeatChannel_Cooldown', HeatChannelValue);
  if(HeatChannelValue.fValue > 0) {
	// still on cooldown
	//`LOG("Rising Tides: Heat Channel was on cooldown! @" @ HeatChannelValue.fValue);
	return ELR_NoInterrupt;
  }

  History = `XCOMHISTORY;
  AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
  if (AbilityContext == none) {
	return ELR_NoInterrupt;
  }

  OldWeaponState = OldSourceUnit.GetPrimaryWeapon();

  // return if there's no heat to be channeled
  if(OldWeaponState.Ammo == OldWeaponState.GetClipSize()) {
	return ELR_NoInterrupt;
  }

  if(!OldAbilityState.IsCoolingDown()) {
	`RedScreenOnce("Rising Tides: The ability was used but isn't on cooldown?");
	return ELR_NoInterrupt;
  }

  NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
  NewWeaponState = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', OldWeaponState.ObjectID));
  NewSourceUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', OldSourceUnit.ObjectID));
  NewAbilityState = XComGameState_Ability(NewGameState.CreateStateObject(class'XComGameState_Ability', OldAbilityState.ObjectID));


  // get amount of heat channeled
  iHeatChanneled = OldWeaponState.GetClipSize() - OldWeaponState.Ammo;

  // channel heat
  if(OldAbilityState.iCooldown < iHeatChanneled) {
	NewAbilityState.iCooldown = 0;
  } else {
	NewAbilityState.iCooldown -= iHeatChanneled;
  }

  //  refill the weapon's ammo
  NewWeaponState.Ammo = NewWeaponState.GetClipSize();

  // put the ability on cooldown
  NewSourceUnit.SetUnitFloatValue('RTEffect_HeatChannel_Cooldown', class'RTAbility_MarksmanAbilitySet'.default.HEATCHANNEL_COOLDOWN, eCleanUp_BeginTactical);

  //`LOG("Rising Tides: Finishing HeatChannel");


  // submit gamestate
  NewGameState.AddStateObject(NewWeaponState);
  NewGameState.AddStateObject(NewAbilityState);
  NewGameState.AddStateObject(NewSourceUnit);

  XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = TriggerHeatChannelFlyoverVisualizationFn;

  `TACTICALRULES.SubmitGameState(NewGameState);
	// trigger cooldown ability
	InitializeAbilityForActivation(CooldownAbilityState, NewSourceUnit, 'HeatChannelCooldown', History);
	ActivateAbility(CooldownAbilityState, NewSourceUnit.GetReference());
	NewSourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(NewSourceUnit.ObjectID));



  return ELR_NoInterrupt;
}

function TriggerHeatChannelFlyoverVisualizationFn(XComGameState VisualizeGameState) {
	local XComGameState_Unit UnitState;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local VisualizationActionMetadata ActionMetadata;
	local XComGameStateHistory History;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Ability AbilityState;

	History = `XCOMHISTORY;
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		foreach VisualizeGameState.IterateByClassType(class'XComGameState_Ability', AbilityState)
		{
			break;
		}
		if (AbilityState == none)
		{
			`RedScreenOnce("Ability state missing from" @ GetFuncName() @ "-jbouscher @gameplay");
			return;
		}

		History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState, , VisualizeGameState.HistoryIndex);
		ActionMetadata.StateObject_NewState = UnitState;
		ActionMetadata.VisualizeActor  = UnitState.GetVisualizer();

		AbilityTemplate = AbilityState.GetMyTemplate();
		if (AbilityTemplate != none)
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFriendlyName, '', eColor_Good, AbilityTemplate.IconImage);


		}
		break;
	}
}

function EventListenerReturn LinkedFireCheck (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameState_Unit TargetUnit, LinkedSourceUnit, LinkedUnit;
	local XComGameStateHistory History;
	local RTEffect_LinkedIntelligence LinkedEffect;
	local StateObjectReference AbilityRef;
	local GameRulesCache_VisibilityInfo	VisInfo;
	local XComGameState_Ability AbilityState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState NewGameState;
	local RTGameState_Effect NewLinkedEffectState;

	if(!bCanTrigger) {
		`LOG("Rising Tides: this should never happen");
		return ELR_NoInterrupt;
	}


	History = `XCOMHISTORY;
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext == none) {
		return ELR_NoInterrupt;
	}


	// We only want to link fire when the source is actually shooting a reaction shot
	// wrote this before I made those "nice" helper methods.
	// TODO: Change this to use RTHelpers.CheckAbilityActivated
	if( AbilityContext.InputContext.AbilityTemplateName != 'RTOverwatchShot' &&
		AbilityContext.InputContext.AbilityTemplateName != 'KillZoneShot' &&
		AbilityContext.InputContext.AbilityTemplateName != 'OverwatchShot' &&
		AbilityContext.InputContext.AbilityTemplateName != 'CloseCombatSpecialistAttack') {
		return ELR_NoInterrupt;
	}

	// The LinkedSourceUnit should be the unit that is currently attacking
	LinkedSourceUnit = class'X2TacticalGameRulesetDataStructures'.static.GetAttackingUnitState(GameState);

	// The Linked Unit is the one responding to the call to arms
	LinkedUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	// Only other units can shoot
	if(LinkedUnit.ObjectID == LinkedSourceUnit.ObjectID) {
		return ELR_NoInterrupt;
	}
	// make sure we're on the same team
	if(LinkedSourceUnit.IsEnemyUnit(LinkedUnit)) {
		return ELR_NoInterrupt;
	}
	// meld check
	if(!LinkedUnit.IsUnitAffectedByEffectName('RTEffect_Meld')|| !LinkedSourceUnit.IsUnitAffectedByEffectName('RTEffect_Meld')) {
		return ELR_NoInterrupt;
	}
	// Don't reveal ourselves
	if(LinkedUnit.IsConcealed()) {
		return ELR_NoInterrupt;
	}
	// The TargetUnit is the unit targeted by the source unit
	TargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));

	// The parent template of this RTGameState_LinkedEffect
	LinkedEffect = RTEffect_LinkedIntelligence(GetX2Effect());

	// We only shoot Linked shots to not make infinite overwatch chains
	AbilityRef = LinkedUnit.FindAbility(LinkedEffect.AbilityToActivate);
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));

	if(AbilityState == none) {
		`RedScreenOnce("Couldn't find an ability to shoot!");
		`LOG("Rising Tides: AbilityContext.InputContext.AbilityTemplateName = " @ AbilityContext.InputContext.AbilityTemplateName);
	}

	// if we allowed shots at this step, we'd interrupt our own linked shot chain. Looks neater this way.
	if (AbilityContext.InterruptionStatus == eInterruptionStatus_Interrupt)	{
		return ELR_NoInterrupt;
	}

	// only shoot enemy units
	if (TargetUnit != none && TargetUnit.IsEnemyUnit(LinkedUnit)) {
		// for some reason, standard target visibility conditions weren't preventing units from shooting
		// 9 months later NOTE: I think this is because the activation method doesn't check conditions before activating. NICE
		// leading to annoying situations involving shooting through walls
		`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(LinkedUnit.ObjectID, TargetUnit.ObjectID, VisInfo);
		if(!VisInfo.bClearLOS && !LinkedUnit.HasSoldierAbility('DaybreakFlame')) {
			// only whisper can shoot through walls...
			return ELR_NoInterrupt;
		}

		// break out if we can't shoot
		if (AbilityState != none) {
				// break out if we can't grant an action point to shoot with
				// this is to tell the difference between stuff like normal Covering Fire, which uses ReserveActionPoints that have already been allocated,
				// and stuff like Return Fire, which are free and should be allocated a point to shoot with.
				// Linked Fire is free; this should always be valid
				if (LinkedEffect.GrantActionPoint != '') {
					// create an new gamestate and increment the number of grants
					NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
					NewLinkedEffectState = RTGameState_Effect(NewGameState.CreateStateObject(Class, ObjectID));
					//NewLinkedEffectState.GrantsThisTurn++;
					NewGameState.AddStateObject(NewLinkedEffectState);

					// add a action point to shoot with
					LinkedUnit = XComGameState_Unit(NewGameState.CreateStateObject(LinkedUnit.Class, LinkedUnit.ObjectID));
					if(LinkedUnit.ReserveActionPoints.Length < 1) {
						LinkedUnit.ReserveActionPoints.AddItem(class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint);
					}
					NewGameState.AddStateObject(LinkedUnit);
					// check if we can shoot. if we can't, clean up the gamestate from history
					if (AbilityState.CanActivateAbilityForObserverEvent(TargetUnit, LinkedUnit) != 'AA_Success')
					{
						History.CleanupPendingGameState(NewGameState);
					}
					else
					{
						bCanTrigger = false;

						AbilityState = XComGameState_Ability(NewGameState.CreateStateObject(AbilityState.Class, AbilityState.ObjectID));
						NewGameState.AddStateObject(AbilityState);
						XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = TriggerLinkedEffectFlyoverVisualizationFn;
						`TACTICALRULES.SubmitGameState(NewGameState);

						if (LinkedEffect.bUseMultiTargets)
						{
							AbilityState.AbilityTriggerAgainstSingleTarget(LinkedUnit.GetReference(), true);
						}
						else
						{
							AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(AbilityState, TargetUnit.ObjectID);
							if( AbilityContext.Validate() )
							{
								`TACTICALRULES.SubmitGameStateContext(AbilityContext);
							}
						}


					}
				}
				else if (AbilityState.CanActivateAbilityForObserverEvent(TargetUnit) == 'AA_Success')
				{
					if (LinkedEffect.bUseMultiTargets)
					{
						AbilityState.AbilityTriggerAgainstSingleTarget(LinkedUnit.GetReference(), true);
					}
					else
					{
						AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(AbilityState, TargetUnit.ObjectID);
						if( AbilityContext.Validate() )
						{
							`TACTICALRULES.SubmitGameStateContext(AbilityContext);
						}
					}
				}
		}
	}
	bCanTrigger = true;
	return ELR_NoInterrupt;
}

function TriggerLinkedEffectFlyoverVisualizationFn(XComGameState VisualizeGameState) {
	local XComGameState_Unit UnitState;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local VisualizationActionMetadata ActionMetadata;
	local XComGameStateHistory History;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Ability AbilityState;

	History = `XCOMHISTORY;
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		foreach VisualizeGameState.IterateByClassType(class'XComGameState_Ability', AbilityState)
		{
			break;
		}
		if (AbilityState == none)
		{
			`RedScreenOnce("Ability state missing from" @ GetFuncName() @ "-jbouscher @gameplay");
			return;
		}

		History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState, , VisualizeGameState.HistoryIndex);
		ActionMetadata.StateObject_NewState = UnitState;
		ActionMetadata.VisualizeActor  = UnitState.GetVisualizer();

		AbilityTemplate = AbilityState.GetMyTemplate();
		if (AbilityTemplate != none)
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFriendlyName, '', eColor_Good, AbilityTemplate.IconImage);

		}
		break;
	}
}

function EventListenerReturn ReprobateWaltzCheck( Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit WaltzUnit, TargetUnit;
	local XComGameState_Ability	AbilityState;
	local int iStackCount, iRandom;
	local float fStackModifier, fFinalPercentChance;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	WaltzUnit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
	TargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));

	fStackModifier = 1;
	if(AbilityContext != none) {
		iStackCount = class'RTGameState_Ability'.static.getBloodlustStackCount(WaltzUnit);
		fFinalPercentChance = (class'RTAbility_BerserkerAbilitySet'.default.REPROBATE_WALTZ_BASE_CHANCE + ( class'RTAbility_BerserkerAbilitySet'.default.REPROBATE_WALTZ_BLOODLUST_STACK_CHANCE * iStackCount  * fStackModifier));
		iRandom = `SYNC_RAND(100);
		if(iRandom <= int(fFinalPercentChance)) {
			InitializeAbilityForActivation(AbilityState, WaltzUnit, 'RTReprobateWaltz', History);
			ActivateAbility(AbilityState, TargetUnit.GetReference());
		}
	}
	return ELR_NoInterrupt;
}

function EventListenerReturn TwitchFireCheck (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameState_Unit AttackingUnit, TwitchAttackingUnit, TwitchLinkedUnit;
	local XComGameStateHistory History;
	local RTEffect_TwitchReaction TwitchEffect;
	local StateObjectReference AbilityRef;
	local XComGameState_Ability AbilityState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState NewGameState;
	local RTGameState_Effect NewTwitchEffectState;
	local StateObjectReference	EmptyRef;

	if(!bCanTrigger) {
		`LOG("Rising Tides: TwitchEffect is probably being called before it finishes resolving!");
		return ELR_NoInterrupt;
	}

	EmptyRef.ObjectID = 0;

	`LOG("Rising Tides: Twitch Fire Check startup.");
	History = `XCOMHISTORY;
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext == none) {
		return ELR_NoInterrupt;
	}
	`LOG("Rising Tides: Twitch Fire Check Stage 1");
	// The AttackingUnit should be the unit that is currently attacking
	AttackingUnit = class'X2TacticalGameRulesetDataStructures'.static.GetAttackingUnitState(GameState);

	// The TwitchAttackingUnit is the one responding to the call to arms
	TwitchAttackingUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	// The TwitchLinkedUnit is the unit targeted by the source unit
	TwitchLinkedUnit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	if(TwitchLinkedUnit == none) {
		return ELR_NoInterrupt;
	}

	// meld check
	if(!TwitchLinkedUnit.IsUnitAffectedByEffectName('RTEffect_Meld')|| !TwitchAttackingUnit.IsUnitAffectedByEffectName('RTEffect_Meld')) {
		return ELR_NoInterrupt;
	}
	`LOG("Rising Tides: Twitch Fire Check Stage 2");
	// Don't reveal ourselves
	if(TwitchAttackingUnit.IsConcealed()) {
		return ELR_NoInterrupt;
	}
	`LOG("Rising Tides: Twitch Fire Check Stage 3");


	// The parent template of this RTGameState_TwitchEffect
	TwitchEffect = RTEffect_TwitchReaction(GetX2Effect());

	// do standard checks here
	//STUFF
	//STUFF
	//STUFF

	// Get the AbilityToActivate (TwitchReactionShot)
	AbilityRef = TwitchAttackingUnit.FindAbility(TwitchEffect.AbilityToActivate, EmptyRef);
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));

	if(AbilityState == none) {
		`RedScreenOnce("Couldn't find an ability to shoot!");
		`LOG("Rising Tides: TwitchEffect.AbilityToActivate = " @ TwitchEffect.AbilityToActivate);
	}

	`LOG("Rising Tides: Twitch Fire Check Stage 4");
	// only shoot enemy units
	if (AttackingUnit != none && AttackingUnit.IsEnemyUnit(TwitchAttackingUnit)) {
		`LOG("Rising Tides: Twitch Fire Check Stage 5");
		// break out if we can't shoot
		if (AbilityState != none) {
				`LOG("Rising Tides: Twitch Fire Check Stage 6");
				// break out if we can't grant an action point to shoot with
				if (TwitchEffect.GrantActionPoint != '') {
					`LOG("Rising Tides: Twitch Fire Check Stage 7");
					// create an new gamestate and increment the number of grants
					NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
					NewTwitchEffectState = RTGameState_Effect(NewGameState.CreateStateObject(Class, ObjectID));
					//NewTwitchEffectState.GrantsThisTurn++;
					NewGameState.AddStateObject(NewTwitchEffectState);

					// add a action point to shoot with
					TwitchAttackingUnit = XComGameState_Unit(NewGameState.CreateStateObject(TwitchAttackingUnit.Class, TwitchAttackingUnit.ObjectID));
					TwitchAttackingUnit.ReserveActionPoints.AddItem(TwitchEffect.GrantActionPoint);
					NewGameState.AddStateObject(TwitchAttackingUnit);
					`LOG("Rising Tides: Twitch Fire Check Stage 8");
					// check if we can shoot. if we can't, clean up the gamestate from history
					if (AbilityState.CanActivateAbilityForObserverEvent(AttackingUnit, TwitchAttackingUnit) != 'AA_Success')
					{
						`LOG(AbilityState.CanActivateAbilityForObserverEvent(AttackingUnit, TwitchAttackingUnit));
						History.CleanupPendingGameState(NewGameState);
					}
					else
					{
						`LOG("Rising Tides: Twitch Fire Check Stage 9");
						bCanTrigger = false;
						AbilityState = XComGameState_Ability(NewGameState.CreateStateObject(AbilityState.Class, AbilityState.ObjectID));
						NewGameState.AddStateObject(AbilityState);
						XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = TriggerAbilityFlyoverVisualizationFn;
						`TACTICALRULES.SubmitGameState(NewGameState);

						if (TwitchEffect.bUseMultiTargets)
						{
							AbilityState.AbilityTriggerAgainstSingleTarget(TwitchAttackingUnit.GetReference(), true);
						}
						else
						{
							AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(AbilityState, AttackingUnit.ObjectID);
							if( AbilityContext.Validate() )
							{
								`LOG("Rising Tides: Twitch Fire Check Stage 11");
								`TACTICALRULES.SubmitGameStateContext(AbilityContext);
								`LOG("Rising Tides: Twitch Fire Check Stage 12");
							}
						}
						bCanTrigger = true;
					}
				}
				else if (AbilityState.CanActivateAbilityForObserverEvent(AttackingUnit) == 'AA_Success')
				{
					if (TwitchEffect.bUseMultiTargets)
					{
						AbilityState.AbilityTriggerAgainstSingleTarget(TwitchAttackingUnit.GetReference(), true);
					}
					else
					{
						AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(AbilityState, AttackingUnit.ObjectID);
						if( AbilityContext.Validate() )
						{
							`TACTICALRULES.SubmitGameStateContext(AbilityContext);
						}
					}
				}
		}
	}

	return ELR_NoInterrupt;
}

function EventListenerReturn RTBumpInTheNight(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameStateHistory History;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability BloodlustAbilityState, StealthAbilityState, RemoveMeldAbilityState, PsionicActivationAbilityState;
	local XComGameState_Ability AbilityState;
	local XComGameState_Unit TargetUnit, OldTargetUnitState, NewAttacker, Attacker;
	local XComGameState NewGameState;
	local RTEffect_BumpInTheNight BITNEffect;
	local bool	bShouldTriggerMelee, bShouldTriggerStandard, bTargetIsDead, bShouldTriggerWaltz;
	local int i, j, iNumPreviousActionPoints, iNumWaltzActionPoints;

	local XComGameState_BaseObject PreviousObject, CurrentObject;
	local XComGameState_Unit AttackerStatePrevious;


	History = `XCOMHISTORY;
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext == none)
		return ELR_NoInterrupt;

	if(AbilityContext.InterruptionStatus == eInterruptionStatus_Interrupt) {
		//`LOG("Rising Tides: not on the interrupt stage!");
		return ELR_NoInterrupt;
	}

	// Check if the source object was the source unit for this effect, and make sure the target was not
	if (AbilityContext.InputContext.SourceObject.ObjectID != ApplyEffectParameters.SourceStateObjectRef.ObjectID ||
		AbilityContext.InputContext.SourceObject.ObjectID == AbilityContext.InputContext.PrimaryTarget.ObjectID)
		return ELR_NoInterrupt;

	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
	if (AbilityState == none || AbilityState.ObjectID == 0)
		return ELR_NoInterrupt;

	if(class'RTHelpers'.default.StandardShots.Find(AbilityState.GetMyTemplateName()) != INDEX_NONE) {
		bShouldTriggerStandard = true;
	}

	if(class'RTHelpers'.default.OverwatchShots.Find(AbilityState.GetMyTemplateName()) != INDEX_NONE) {
		bShouldTriggerStandard = true;
	}

	if(class'RTHelpers'.default.MeleeAbilities.Find(AbilityState.GetMyTemplateName()) != INDEX_NONE) {
		bShouldTriggerMelee = true;
	}

	if(AbilityState.GetMyTemplateName() == 'RTReprobateWaltz')
			bShouldTriggerWaltz = true;

	// We only want to trigger BITN when the source is actually using the right ability
	if(!bShouldTriggerStandard && !bShouldTriggerMelee) {
		return ELR_NoInterrupt;
	}

	BITNEffect = RTEffect_BumpInTheNight(GetX2Effect());
	OldTargetUnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	TargetUnit = XComGameState_Unit(GameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	if (OldTargetUnitState != none && OldTargetUnitState.ObjectID > 0 &&
		TargetUnit != none && TargetUnit.ObjectID > 0) {
			bTargetIsDead = TargetUnit.IsDead();
			if(!bTargetIsDead) {
				bTargetIsDead = TargetUnit.IsBleedingOut(); // not going to fuck around with a oneliner if im not ever gonna test this code LUL
			}
	}

	Attacker = XComGameState_Unit(EventSource);
	if(Attacker != none && bShouldTriggerMelee) {
		// trigger psionic activation if psionic blades were present and used or on shadow strike
		if(Attacker.HasSoldierAbility('RTPsionicBlade') || AbilityState.GetMyTemplateName() == 'RTShadowStrike') {
			InitializeAbilityForActivation(PsionicActivationAbilityState, Attacker, 'PsionicActivate', History);
			ActivateAbility(PsionicActivationAbilityState, Attacker.GetReference());
		}
	}


	if (bTargetIsDead)
	{

		if(bShouldTriggerWaltz) {
			iNumWaltzActionPoints = 0;
			j = 0;
			// the first gamestate we find where we find action points on the unit
			// or 20 times at maximum
			while(iNumWaltzActionPoints == 0 && j != 20) {
				j++;
				History.GetCurrentAndPreviousGameStatesForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID, PreviousObject, CurrentObject,, GameState.HistoryIndex - j);
				AttackerStatePrevious = XComGameState_Unit(PreviousObject);
				iNumWaltzActionPoints = AttackerStatePrevious.ActionPoints.Length;
			}

		}
		else {
			AttackerStatePrevious = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID,, GameState.HistoryIndex - 1));
		}

		iNumPreviousActionPoints = AttackerStatePrevious.ActionPoints.Length;
		if (Attacker != none)
		{
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
			//TODO: Visualization
			NewAttacker = XComGameState_Unit(NewGameState.CreateStateObject(Attacker.Class, Attacker.ObjectID));
			//XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = TriggerBumpInTheNightFlyoverVisualizationFn;
			NewGameState.AddStateObject(NewAttacker);

			if(Attacker.HasSoldierAbility('RTQueenOfBlades', true) && bShouldTriggerMelee) {
				for(i = 0; i < iNumPreviousActionPoints; i++) {
					NewAttacker.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
				}
			}

			// reset the detection modifier to 0
			NewAttacker.ModifyCurrentStat(eStat_DetectionModifier, 0);
			`TACTICALRULES.SubmitGameState(NewGameState);

			if(Attacker.TileDistanceBetween(TargetUnit) < BITNEffect.iTileDistanceToActivate) {

				// melee kills additionally give bloodlust stacks and proc queen of blades
				if(bShouldTriggerMelee || NewAttacker.HasSoldierAbility('RTContainedFury')) {
					// t-t-t-t-triggered
					InitializeAbilityForActivation(BloodlustAbilityState, NewAttacker, 'BumpInTheNightBloodlustListener', History);
					ActivateAbility(BloodlustAbilityState, NewAttacker.GetReference());
					NewAttacker = XComGameState_Unit(History.GetGameStateForObjectID(NewAttacker.ObjectID));

					// since we've added a bloodlust stack, we need to check if we should leave the meld
					if(!Attacker.HasSoldierAbility('RTContainedFury', false) && Attacker.IsUnitAffectedByEffectName('RTEffect_Meld')) {
						if(class'RTGameState_Ability'.static.getBloodlustStackCount(NewAttacker) > class'RTAbility_BerserkerAbilitySet'.default.MAX_BLOODLUST_MELDJOIN) {
							InitializeAbilityForActivation(RemoveMeldAbilityState, NewAttacker, 'LeaveMeld', History);
							ActivateAbility(RemoveMeldAbilityState, NewAttacker.GetReference());
							NewAttacker = XComGameState_Unit(History.GetGameStateForObjectID(NewAttacker.ObjectID));
						}
					}
				} else {
					// all of the kills give stealth...
					InitializeAbilityForActivation(StealthAbilityState, NewAttacker, 'BumpInTheNightStealthListener', History);
					ActivateAbility(StealthAbilityState, NewAttacker.GetReference());
					NewAttacker = XComGameState_Unit(History.GetGameStateForObjectID(NewAttacker.ObjectID));
				}
			}
		}
	}

	return ELR_NoInterrupt;
}

function TriggerBumpInTheNightFlyoverVisualizationFn(XComGameState VisualizeGameState) {
	local XComGameState_Unit UnitState;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local VisualizationActionMetadata ActionMetadata;
	local XComGameStateHistory History;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Ability AbilityState;
	local string					s;

	History = `XCOMHISTORY;
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		foreach VisualizeGameState.IterateByClassType(class'XComGameState_Ability', AbilityState)
		{
			break;
		}
		if (AbilityState == none)
		{
			`RedScreenOnce("Ability state missing from" @ GetFuncName() @ "-jbouscher @gameplay");
			`LOG("Rising Tides: ITS BROKEN");
			return;
		}

		History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState, , VisualizeGameState.HistoryIndex);
		ActionMetadata.StateObject_NewState = UnitState;
		ActionMetadata.VisualizeActor  = UnitState.GetVisualizer();

		AbilityTemplate = AbilityState.GetMyTemplate();
		if (AbilityTemplate != none)
		{
			s = XComGameState_Ability(History.GetGameStateForObjectID(UnitState.FindAbility('BumpInTheNight').ObjectID)).GetMyTemplate().LocFriendlyName;

			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, s, '', eColor_Good, AbilityTemplate.IconImage);

		}
		break;
	}
}

function EventListenerReturn RTApplyTimeStop(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameState_Unit TargetState;
	local XComGameState_Unit SourceState;
	local XComGameState_Ability AbilityState;

	TargetState = XComGameState_Unit(EventData);
	if(TargetState == none) {
		`LOG("Rising Tides: Couldn't apply time stop, target was not an XComGameState_Unit");
		return ELR_NoInterrupt;
	}

	SourceState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	if(SourceState.AffectedByEffectNames.Find('TimeStopMasterEffect') != INDEX_NONE) {
		InitializeAbilityForActivation(AbilityState, SourceState, 'TimeStandsStillInterruptListener', `XCOMHISTORY);
		ActivateAbility(AbilityState, TargetState.GetReference());
	}

	return ELR_NoInterrupt;
}

// Event ID: AbilityActivated
// EventData: AbilityState
// EventSource: SourceUnitState
// Passed a NewGameState
// When we shoot, we need to update the tile cache.
function EventListenerReturn HandleRepositioning(Object EventData, Object EventSource, XComGameState NewGameState, Name EventID, Object CallbackData)
{
	local XComGameState_Unit UnitState;
	local TTile CurrentTile;
	local XComGameStateHistory History;
	local RTEffect_Repositioning EffectTemplate;
	local RTGameState_Effect RTEffectState;
	local XComGameState_Ability AbilityState; // what just activated
	local array<ERTChecklist> Checklists;
	local XComGameStateContext AbilityContext;

	AbilityContext = NewGameState.GetContext();
	if(AbilityContext == none) {
		return ELR_NoInterrupt;
	}

	if (AbilityContext.InterruptionStatus == eInterruptionStatus_Interrupt) {
			return ELR_NoInterrupt;
	}
	
	AbilityState = XComGameState_Ability(EventData);
	
	// if we fired a shot, we need to update repositioning
	// ...for some reason, the normal syntax doesn't work here?
	Checklists.AddItem(eChecklist_StandardShots);
	Checklists.AddItem(eChecklist_SniperShots);
	Checklists.AddItem(eChecklist_OverwatchShots);

	if(!class'RTHelpers'.static.MultiCatCheckAbilityActivated(AbilityState.GetMyTemplateName(), Checklists))
	{
		`RTLOG("HandlingRepositioning triggered by an invalid ability: " $ AbilityState.GetMyTemplateName());
		return ELR_NoInterrupt;
	}

	EffectTemplate = RTEffect_Repositioning(GetX2Effect());
	if(EffectTemplate == none)
	{
		`RTLOG("HandleRepositioning triggered by an invalid X2Effect!", true, false);
		return ELR_NoInterrupt;
	}

	UnitState = XComGameState_Unit(EventSource);
	if(UnitState == none || ApplyEffectParameters.TargetStateObjectRef.ObjectID != UnitState.ObjectID)
	{
		`RTLOG("HandleRepositioning triggered by an invalid unit!", true, false);
		return ELR_NoInterrupt;
	}
	
	CurrentTile = UnitState.TileLocation;
	RTEffectState = RTGameState_Effect(NewGameState.ModifyStateObject(Class, ObjectID));

	// remove the last tile
	if(PreviousTilePositions.Length < EffectTemplate.MaxPositionsSaved)
	{
		RTEffectState.PreviousTilePositions.Remove(0, 1);
	}
	RTEffectState.PreviousTilePositions.AddItem(CurrentTile);

	return ELR_NoInterrupt;
}

// Event ID: RetainConcealmentOnActivation
// Event Data: XComLWTuple containing 1 bool
// Event Source ActivatedAbilityStateContext 
// When we're about to break concealment, check to see if we can trigger Repositioning
function EventListenerReturn HandleRetainConcealmentRepositioning(Object EventData, Object EventSource, XComGameState GameState, name EventID, Object CallbackData)
{
	local XComLWTuple Tuple;
	local XComGameStateContext_Ability ActivatedAbilityStateContext;
	local XComGameState_Unit UnitState;
	local bool bTooClose;
	local XComGameState NewGameState;
	local TTile CurrentTile, IteratorTile;
	local RTEffect_Repositioning EffectTemplate;
	local RTGameState_Effect EffectState;

	if(ActivatedAbilityStateContext.InputContext.SourceObject.ObjectID != ApplyEffectParameters.TargetStateObjectRef.ObjectID)
	{
		//`RTLOG("RTEffct_Repositioning attempted to trigger on a unit that doesn't have it.", true, false);
		return ELR_NoInterrupt;
	}

	//`RTLOG("HandleRetainConcealmentRepositioning");

	Tuple = XComLWTuple(EventData);
	ActivatedAbilityStateContext = XComGameStateContext_Ability(EventSource);

	if(Tuple == none || ActivatedAbilityStateContext == none)
	{
		`RTLOG("One of the event objectives for RTE_Repositioning::HandleRetainConcealment was invalid!", true, false);
		return ELR_NoInterrupt;
	}

	// if what broke concealment ISN'T what has this effect
	if(ActivatedAbilityStateContext.InputContext.SourceObject.ObjectID != ApplyEffectParameters.TargetStateObjectRef.ObjectID)
	{
		`RTLOG("RTEffct_Repositioning attempted to trigger on a unit that doesn't have it.", true, false);
		return ELR_NoInterrupt;
	}

	if(Tuple.Data[0].b == true) {
		// already going to retain concealment
		// might want to take the current tile out of the cache...
		`RTLOG("Already going to retain concealment, no need to process Repositioning...");
		return ELR_NoInterrupt;
	}	

	if(bRepositioningActive) {
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
		XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = RepositoningVisualizationFn;
		EffectState = RTGameState_Effect(NewGameState.ModifyStateObject(Class, ObjectID));
		bRepositioningActive = false;
		`TACTICALRULES.SubmitGameState(NewGameState);
		Tuple.Data[0].b = true;
	}

	return ELR_NoInterrupt;
}

function RepositoningVisualizationFn(XComGameState VisualizeGameState) {
	local XComGameState_Unit UnitState;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local VisualizationActionMetadata ActionMetadata;
	local XComGameStateHistory History;
	local X2AbilityTemplate AbilityTemplate;

	History = `XCOMHISTORY;

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState, , VisualizeGameState.HistoryIndex);
	ActionMetadata.StateObject_NewState = UnitState;
	ActionMetadata.VisualizeActor  = UnitState.GetVisualizer();

	AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('RTRepositioning');
	if (AbilityTemplate != none)
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', eColor_Good, AbilityTemplate.IconImage);

	} else {
		class'RTHelpers'.static.RTLog("Rising Tides - Repositioning: Couldn't find AbilityTemplate for visualization!");
	}
}

function EventListenerReturn HandleRepositioningAvaliable(Object EventData, Object EventSource, XComGameState GameState, name EventID, Object CallbackData)
{
	local XComGameStateContext_Ability ActivatedAbilityStateContext;
	local XComGameState_Unit UnitState;
	local bool bTooClose;
	local XComGameState NewGameState;
	local TTile CurrentTile, IteratorTile;
	local RTEffect_Repositioning EffectTemplate;
	local RTGameState_Effect EffectState;

	`RTLOG("HandleRepositioningAvaliable");

	UnitState = XComGameState_Unit(EventData);

	// if what broke concealment ISN'T what has this effect
	if(UnitState.ObjectID != ApplyEffectParameters.TargetStateObjectRef.ObjectID)
	{
		`RTLOG("HandleRepositioningAvaliable attempted to trigger on a unit that doesn't have it.", true, false);
		return ELR_NoInterrupt;
	}

	bTooClose = false;
	EffectTemplate = RTEffect_Repositioning(GetX2Effect());
	CurrentTile = UnitState.TileLocation;
	foreach PreviousTilePositions(IteratorTile)
	{
		if(class'Helpers'.static.DistanceBetweenTiles(CurrentTile, IteratorTile) < Square(`TILESTOUNITS(EffectTemplate.TilesMovedRequired)))
		{
			bTooClose = true;
		}
	}

	// if we're too close to our last position and it is active, deactivate.
	// if we're far enough away from our last position and it is not active, activate.
	// otherwise do nothing.
	if(bTooClose == bRepositioningActive)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
		EffectState = RTGameState_Effect(NewGameState.ModifyStateObject(Class, ObjectID));
		EffectState.bRepositioningActive = !bRepositioningActive;
		XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = RepositoningCheckVisualizationFn;
		`TACTICALRULES.SubmitGameState(NewGameState);
	}


	return ELR_NoInterrupt;
}

function RepositoningCheckVisualizationFn(XComGameState VisualizeGameState) {
	local XComGameState_Unit UnitState;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local VisualizationActionMetadata ActionMetadata;
	local XComGameStateHistory History;
	local X2AbilityTemplate AbilityTemplate;
	local RTGameState_Effect RTEffectState;

	History = `XCOMHISTORY;

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	//History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState, , VisualizeGameState.HistoryIndex);
	ActionMetadata.StateObject_NewState = UnitState;
	ActionMetadata.VisualizeActor  = UnitState.GetVisualizer();

	foreach VisualizeGameState.IterateByClassType(class'RTGameState_Effect', RTEffectState)
	{
		if(RTEffectState.ObjectID == ObjectID) {
			break;
		}
	}

	if(RTEffectState == none) {
		`RTLOG("Couldn't find EffectState for RepositoningCheckVisualizationFn!", true, false);
	}

	AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('RTRepositioning');
	if (AbilityTemplate != none)
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		if(RTEffectState.bRepositioningActive) {
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocHitMessage, '', eColor_Good, AbilityTemplate.IconImage);
		} else {
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocMissMessage, '', eColor_Bad, AbilityTemplate.IconImage);
		}
	} else {
		class'RTHelpers'.static.RTLog("Rising Tides - Repositioning: Couldn't find AbilityTemplate for visualization!");
	}
}

defaultproperties
{
	bCanTrigger=true
}
