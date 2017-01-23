class RTGameState_Effect extends XComGameState_Effect;

var array<StateObjectReference> EffectList;

// Tactical Game Cleanup
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


protected function ActivateAbility(XComGameState_Ability AbilityState, StateObjectReference TargetRef) {
	local XComGameStateContext_Ability AbilityContext;
	
	AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(AbilityState, TargetRef.ObjectID);
	
	if( AbilityContext.Validate() ) {
		`TACTICALRULES.SubmitGameStateContext(AbilityContext);
	} else {
		`LOG("Rising Tides: Couldn't validate AbilityContext, " @ AbilityState.GetMyTemplateName() @ " not activated.");
	}
}

protected function InitializeAbilityForActivation(out XComGameState_Ability AbilityState, XComGameState_Unit AbilityOwnerUnit, Name AbilityName, XComGameStateHistory History) {
	local StateObjectReference AbilityRef;

	AbilityRef = AbilityOwnerUnit.FindAbility(AbilityName);
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));
	if(AbilityState == none) {
		`LOG("Rising Tides: Couldn't initialize ability for activation!");
	}

}

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

  local array<StateObjectReference> AddedEffects;


  History = `XCOMHISTORY;

  AddedEffects = EffectList;

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

  local array<StateObjectReference> RemovedEffects;

  History = `XCOMHISTORY;

  RemovedEffects = EffectList;

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

