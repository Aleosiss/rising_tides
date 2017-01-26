class RTGameState_Effect extends XComGameState_Effect;

var array<StateObjectReference> EffectsAddedList;
var array<StateObjectReference> EffectsRemovedList;

// OnTacticalGameEnd (Don't need this anymore)
function EventListenerReturn OnTacticalGameEnd(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
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

	`LOG("RisingTides: RTGameState_Effect of type " @ self.class @" passive effect unregistered from events.");
	
	return ELR_NoInterrupt;
}

// ActivateAbility
protected function ActivateAbility(XComGameState_Ability AbilityState, StateObjectReference TargetRef) {
	local XComGameStateContext_Ability AbilityContext;
	
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
function EffectAddedBuildVisualizationFn (XComGameState VisualizeGameState, out array<VisualizationTrack> VisualizationTracks) {
  local VisualizationTrack SourceTrack;
  local VisualizationTrack TargetTrack;
  local XComGameStateHistory History;
  local X2VisualizerInterface VisualizerInterface;
  local XComGameState_Effect EffectState;
  local XComGameState_BaseObject EffectTarget;
  local XComGameState_BaseObject EffectSource;
  local X2Effect_Persistent EffectTemplate;
  local int i;
  local int n;
  local bool FoundSourceTrack;
  local bool FoundTargetTrack;
  local int SourceTrackIndex;   
  local int TargetTrackIndex;


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

      FoundSourceTrack = False;
      FoundTargetTrack = False;
      for (n = 0; n < VisualizationTracks.Length; ++n)
      {
        if (EffectSource.ObjectID == XGUnit(VisualizationTracks[n].TrackActor).ObjectID)
        {
          SourceTrack = VisualizationTracks[n];
          FoundSourceTrack = true;
          SourceTrackIndex = n;
        }

        if (EffectTarget.ObjectID == XGUnit(VisualizationTracks[n].TrackActor).ObjectID)
        {
          TargetTrack = VisualizationTracks[n];
          FoundTargetTrack = true;
          TargetTrackIndex = n;
        }
      }

      if (EffectTarget != none)
      {
        TargetTrack.TrackActor = History.GetVisualizer(EffectTarget.ObjectID);
        VisualizerInterface = X2VisualizerInterface(TargetTrack.TrackActor);
        if (TargetTrack.TrackActor != none)
        {
          History.GetCurrentAndPreviousGameStatesForObjectID(EffectTarget.ObjectID, TargetTrack.StateObject_OldState, TargetTrack.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
          if (TargetTrack.StateObject_NewState == none)
          TargetTrack.StateObject_NewState = TargetTrack.StateObject_OldState;

          if (VisualizerInterface != none)
          VisualizerInterface.BuildAbilityEffectsVisualization(AssociatedState, TargetTrack);

          EffectTemplate = EffectState.GetX2Effect();
          EffectTemplate.AddX2ActionsForVisualization(AssociatedState, TargetTrack, 'AA_Success');
          if (FoundTargetTrack)
          {
            VisualizationTracks[TargetTrackIndex] = TargetTrack;
          }
          else
          {
            TargetTrackIndex = VisualizationTracks.AddItem(TargetTrack);
          }
        }

        if (EffectTarget.ObjectID == EffectSource.ObjectID)
        {
          SourceTrack = TargetTrack;
          FoundSourceTrack = True;
          SourceTrackIndex = TargetTrackIndex;
        }

        SourceTrack.TrackActor = History.GetVisualizer(EffectSource.ObjectID);
        if (SourceTrack.TrackActor != none)
        {
          History.GetCurrentAndPreviousGameStatesForObjectID(EffectSource.ObjectID, SourceTrack.StateObject_OldState, SourceTrack.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
          if (SourceTrack.StateObject_NewState == none)
          SourceTrack.StateObject_NewState = SourceTrack.StateObject_OldState;

          EffectTemplate.AddX2ActionsForVisualizationSource(AssociatedState, SourceTrack, 'AA_Success');
          if (FoundSourceTrack)
          {
            VisualizationTracks[SourceTrackIndex] = SourceTrack;
          }
          else
          {
            SourceTrackIndex = VisualizationTracks.AddItem(SourceTrack);
          }
        }

      }
    }
  }
}

// EffectRemovedBuildVisualizationFn
function EffectRemovedBuildVisualizationFn(XComGameState VisualizeGameState, out array<VisualizationTrack> VisualizationTracks) {
  local VisualizationTrack SourceTrack;
  local VisualizationTrack TargetTrack;
  local XComGameStateHistory History;
  local X2VisualizerInterface VisualizerInterface;
  local XComGameState_Effect EffectState;
  local XComGameState_BaseObject EffectTarget;
  local XComGameState_BaseObject EffectSource;
  local X2Effect_Persistent EffectTemplate;
  local int i;
  local int n;
  local bool FoundSourceTrack;
  local bool FoundTargetTrack;
  local int SourceTrackIndex;
  local int TargetTrackIndex;

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

      FoundSourceTrack = False;
      FoundTargetTrack = False;
      for (n = 0; n < VisualizationTracks.Length; ++n)
      {
        if (EffectSource.ObjectID == XGUnit(VisualizationTracks[n].TrackActor).ObjectID)
        {
          SourceTrack = VisualizationTracks[n];
          FoundSourceTrack = true;
          SourceTrackIndex = n;
        }

        if (EffectTarget.ObjectID == XGUnit(VisualizationTracks[n].TrackActor).ObjectID)
        {
          TargetTrack = VisualizationTracks[n];
          FoundTargetTrack = true;
          TargetTrackIndex = n;
        }
      }

      if (EffectTarget != none)
      {
        TargetTrack.TrackActor = History.GetVisualizer(EffectTarget.ObjectID);
        VisualizerInterface = X2VisualizerInterface(TargetTrack.TrackActor);
        if (TargetTrack.TrackActor != none)
        {
          History.GetCurrentAndPreviousGameStatesForObjectID(EffectTarget.ObjectID, TargetTrack.StateObject_OldState, TargetTrack.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
          if (TargetTrack.StateObject_NewState == none)
          TargetTrack.StateObject_NewState = TargetTrack.StateObject_OldState;

          if (VisualizerInterface != none)
          VisualizerInterface.BuildAbilityEffectsVisualization(AssociatedState, TargetTrack);

          EffectTemplate = EffectState.GetX2Effect();
          EffectTemplate.AddX2ActionsForVisualization_Removed(AssociatedState, TargetTrack, 'AA_Success', EffectState);
          if (FoundTargetTrack)
          {
            VisualizationTracks[TargetTrackIndex] = TargetTrack;
          }
          else
          {
            TargetTrackIndex = VisualizationTracks.AddItem(TargetTrack);
          }
        }

        if (EffectTarget.ObjectID == EffectSource.ObjectID)
        {
          SourceTrack = TargetTrack;
          FoundSourceTrack = True;
          SourceTrackIndex = TargetTrackIndex;
        }

        SourceTrack.TrackActor = History.GetVisualizer(EffectSource.ObjectID);
        if (SourceTrack.TrackActor != none)
        {
          History.GetCurrentAndPreviousGameStatesForObjectID(EffectSource.ObjectID, SourceTrack.StateObject_OldState, SourceTrack.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
          if (SourceTrack.StateObject_NewState == none)
          SourceTrack.StateObject_NewState = SourceTrack.StateObject_OldState;

          EffectTemplate.AddX2ActionsForVisualization_RemovedSource(AssociatedState, SourceTrack, 'AA_Success', EffectState);
          if (FoundSourceTrack)
          {
            VisualizationTracks[SourceTrackIndex] = SourceTrack;
          }
          else
          {
            SourceTrackIndex = VisualizationTracks.AddItem(SourceTrack);
          }
        }
      }
    }
  }
}

// EffectsModifiedBuildVisualizationFn
function EffectsModifiedBuildVisualizationFn(XComGameState VisualizeGameState, out array<VisualizationTrack> VisualizationTracks) {
  local VisualizationTrack SourceTrack;
  local VisualizationTrack TargetTrack;
  local XComGameStateHistory History;
  local X2VisualizerInterface VisualizerInterface;
  local XComGameState_Effect EffectState;
  local XComGameState_BaseObject EffectTarget;
  local XComGameState_BaseObject EffectSource;
  local X2Effect_Persistent EffectTemplate;
  local int i;
  local int n;
  local bool FoundSourceTrack;
  local bool FoundTargetTrack;
  local int SourceTrackIndex;
  local int TargetTrackIndex;

  local XComGameState AssociatedState;
  local array<StateObjectReference> RemovedEffects;
  local array<StateObjectReference> AddedEffects;

  History = `XCOMHISTORY;

  AddedEffects = EffectsAddedList;
  RemovedEffects = EffectsRemovedList;
  AssociatedState = VisualizeGameState;
  
  // remove the effects...
  for (i = 0; i < RemovedEffects.Length; ++i) {
    EffectState = XComGameState_Effect(History.GetGameStateForObjectID(RemovedEffects[i].ObjectID));
    if (EffectState != none)
    {
      EffectSource = History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID);
      EffectTarget = History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID);

      FoundSourceTrack = False;
      FoundTargetTrack = False;
      for (n = 0; n < VisualizationTracks.Length; ++n)
      {
        if (EffectSource.ObjectID == XGUnit(VisualizationTracks[n].TrackActor).ObjectID)
        {
          SourceTrack = VisualizationTracks[n];
          FoundSourceTrack = true;
          SourceTrackIndex = n;
        }

        if (EffectTarget.ObjectID == XGUnit(VisualizationTracks[n].TrackActor).ObjectID)
        {
          TargetTrack = VisualizationTracks[n];
          FoundTargetTrack = true;
          TargetTrackIndex = n;
        }
      }

      if (EffectTarget != none)
      {
        TargetTrack.TrackActor = History.GetVisualizer(EffectTarget.ObjectID);
        VisualizerInterface = X2VisualizerInterface(TargetTrack.TrackActor);
        if (TargetTrack.TrackActor != none)
        {
          History.GetCurrentAndPreviousGameStatesForObjectID(EffectTarget.ObjectID, TargetTrack.StateObject_OldState, TargetTrack.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
          if (TargetTrack.StateObject_NewState == none)
          TargetTrack.StateObject_NewState = TargetTrack.StateObject_OldState;

          if (VisualizerInterface != none)
          VisualizerInterface.BuildAbilityEffectsVisualization(AssociatedState, TargetTrack);

          EffectTemplate = EffectState.GetX2Effect();
          EffectTemplate.AddX2ActionsForVisualization_Removed(AssociatedState, TargetTrack, 'AA_Success', EffectState);
          if (FoundTargetTrack)
          {
            VisualizationTracks[TargetTrackIndex] = TargetTrack;
          }
          else
          {
            TargetTrackIndex = VisualizationTracks.AddItem(TargetTrack);
          }
        }

        if (EffectTarget.ObjectID == EffectSource.ObjectID)
        {
          SourceTrack = TargetTrack;
          FoundSourceTrack = True;
          SourceTrackIndex = TargetTrackIndex;
        }

        SourceTrack.TrackActor = History.GetVisualizer(EffectSource.ObjectID);
        if (SourceTrack.TrackActor != none)
        {
          History.GetCurrentAndPreviousGameStatesForObjectID(EffectSource.ObjectID, SourceTrack.StateObject_OldState, SourceTrack.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
          if (SourceTrack.StateObject_NewState == none)
          SourceTrack.StateObject_NewState = SourceTrack.StateObject_OldState;

          EffectTemplate.AddX2ActionsForVisualization_RemovedSource(AssociatedState, SourceTrack, 'AA_Success', EffectState);
          if (FoundSourceTrack)
          {
            VisualizationTracks[SourceTrackIndex] = SourceTrack;
          }
          else
          {
            SourceTrackIndex = VisualizationTracks.AddItem(SourceTrack);
          }
        }
      }
    }
  } // end remove effects
  // add new effects...
  for (i = 0; i < AddedEffects.Length; ++i)
  {
    EffectState = XComGameState_Effect(History.GetGameStateForObjectID(AddedEffects[i].ObjectID));
    if (EffectState != none)
    {
      EffectSource = History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID);
      EffectTarget = History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID);

      FoundSourceTrack = False;
      FoundTargetTrack = False;
      for (n = 0; n < VisualizationTracks.Length; ++n)
      {
        if (EffectSource.ObjectID == XGUnit(VisualizationTracks[n].TrackActor).ObjectID)
        {
          SourceTrack = VisualizationTracks[n];
          FoundSourceTrack = true;
          SourceTrackIndex = n;
        }

        if (EffectTarget.ObjectID == XGUnit(VisualizationTracks[n].TrackActor).ObjectID)
        {
          TargetTrack = VisualizationTracks[n];
          FoundTargetTrack = true;
          TargetTrackIndex = n;
        }
      }

      if (EffectTarget != none)
      {
        TargetTrack.TrackActor = History.GetVisualizer(EffectTarget.ObjectID);
        VisualizerInterface = X2VisualizerInterface(TargetTrack.TrackActor);
        if (TargetTrack.TrackActor != none)
        {
          History.GetCurrentAndPreviousGameStatesForObjectID(EffectTarget.ObjectID, TargetTrack.StateObject_OldState, TargetTrack.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
          if (TargetTrack.StateObject_NewState == none)
          TargetTrack.StateObject_NewState = TargetTrack.StateObject_OldState;

          if (VisualizerInterface != none)
          VisualizerInterface.BuildAbilityEffectsVisualization(AssociatedState, TargetTrack);

          EffectTemplate = EffectState.GetX2Effect();
          EffectTemplate.AddX2ActionsForVisualization(AssociatedState, TargetTrack, 'AA_Success');
          if (FoundTargetTrack)
          {
            VisualizationTracks[TargetTrackIndex] = TargetTrack;
          }
          else
          {
            TargetTrackIndex = VisualizationTracks.AddItem(TargetTrack);
          }
        }

        if (EffectTarget.ObjectID == EffectSource.ObjectID)
        {
          SourceTrack = TargetTrack;
          FoundSourceTrack = True;
          SourceTrackIndex = TargetTrackIndex;
        }

        SourceTrack.TrackActor = History.GetVisualizer(EffectSource.ObjectID);
        if (SourceTrack.TrackActor != none)
        {
          History.GetCurrentAndPreviousGameStatesForObjectID(EffectSource.ObjectID, SourceTrack.StateObject_OldState, SourceTrack.StateObject_NewState, eReturnType_Reference, AssociatedState.HistoryIndex);
          if (SourceTrack.StateObject_NewState == none)
          SourceTrack.StateObject_NewState = SourceTrack.StateObject_OldState;

          EffectTemplate.AddX2ActionsForVisualizationSource(AssociatedState, SourceTrack, 'AA_Success');
          if (FoundSourceTrack)
          {
            VisualizationTracks[SourceTrackIndex] = SourceTrack;
          }
          else
          {
            SourceTrackIndex = VisualizationTracks.AddItem(SourceTrack);
          }
        }

      }
    }
  }	// end add effects
   ClearEffectLists();
}

// ClearEffectLists
function ClearEffectLists() {
	EffectsAddedList.Length = 0;
	EffectsRemovedList.Length = 0;
}

// CleanupMobileSquadViewers
function EventListenerReturn CleanupMobileSquadViewers(Object EventData, Object EventSource, XComGameState GameState, Name EventID) {
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
function EventListenerReturn OnUpdateAuraCheck(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
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
		OnTotalAuraCheck(EventData, EventSource, GameState, EventID);
	}
	else
	{
		History = `XCOMHISTORY;
		ThisEffect = self;

		AuraSourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
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
function EventListenerReturn OnTotalAuraCheck(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local X2Effect_AuraSource AuraTemplate;
	local XComGameState_Unit TargetUnitState, AuraSourceUnitState;
	local XComGameStateHistory History;
	local XComGameState_Effect ThisEffect;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;

	AuraSourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
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

private function SubmitNewGameState(out XComGameState NewGameState)
{
	local X2TacticalGameRuleset TacticalRules;
	local XComGameStateHistory History;

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		TacticalRules = `TACTICALRULES;
		TacticalRules.SubmitGameState(NewGameState);

		//  effects may have changed action availability - if a unit died, took damage, etc.
	}
	else
	{
		History = `XCOMHISTORY;
		History.CleanupPendingGameState(NewGameState);
	}
}


