class RTEffect_MobileSquadViewer extends X2Effect_PersistentSquadViewer;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState) {
  local XComGameStateHistory History;
  local XComGameState_Unit SourceUnitState, TargetUnitState;
  local RTGameState_SquadViewer ViewerState;
  local XComGameState_Ability AbilityState;
  local Vector ViewerLocation;
  local float fViewRadius;
  local TTile ViewerTile;

  
  `LOG("Rising Tides: Adding ViewerState in GameState StateObjectRef " @ NewGameState.HistoryIndex);

  History = `XCOMHISTORY;

  TargetUnitState = XComGameState_Unit(kNewTargetState);
  if(TargetUnitState == none) {
    `RedScreenOnce("Rising Tides: Attempting to create a SquadViewer on a non-unit target!");
    return;
  }

  ViewerTile = TargetUnitState.TileLocation;
  fViewRadius = TargetUnitState.GetBaseStat(eStat_SightRadius) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;

  ViewerState = RTGameState_SquadViewer(NewGameState.CreateStateObject(class'RTGameState_SquadViewer'));
  ViewerState.AssociatedPlayer = ApplyEffectParameters.PlayerStateObjectRef;
  ViewerState.AssociatedUnit = TargetUnitState.GetReference();
  ViewerState.SetVisibilityLocation(ViewerTile);
  ViewerState.ViewerTile = ViewerTile;
  ViewerState.ViewerRadius = fViewRadius;

  NewGameState.AddStateObject(ViewerState);
  NewEffectState.CreatedObjectReference = ViewerState.GetReference();

}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local RTGameState_SquadViewer Viewer;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	Viewer = RTGameState_SquadViewer(History.GetGameStateForObjectID(RemovedEffectState.CreatedObjectReference.ObjectID));	

	if(Viewer == none)
	{
		`Redscreen("X2Effect_PersistentSquadViewer::OnEffectRemoved: Could not find associated viewer object to remove!");
		return;
	}

	NewGameState.RemoveStateObject(RemovedEffectState.CreatedObjectReference.ObjectID);
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, name EffectApplyResult)
{
	local XComGameState_Effect EffectState, VisualizeEffect;
	local RTGameState_SquadViewer SquadViewer;


	`LOG("Rising Tides: Looking for ViewerState in GameState StateObjectRef " @ VisualizeGameState.HistoryIndex);
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Effect', EffectState)
	{
		if (EffectState.GetX2Effect() == self)
		{
			VisualizeEffect = EffectState;
			break;
		}
	}
	if (VisualizeEffect == none)
	{
		`RedScreen("Could not find Squad Viewer effect - FOW will not be lifted. Author: jbouscher Contact: @gameplay");
		return;
	}
	SquadViewer = RTGameState_SquadViewer(VisualizeGameState.GetGameStateForObjectID(EffectState.CreatedObjectReference.ObjectID));
	if (SquadViewer == none)
	{
		`RedScreen("Could not find Squad Viewer game state - FOW will not be lifted. Author: jbouscher Contact: @gameplay");
		return;
	}
	SquadViewer.FindOrCreateVisualizer(VisualizeGameState);
	SquadViewer.SyncVisualizer(VisualizeGameState);     //  @TODO - use an action instead, but the incoming track will not have the right object to sync
}

simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
	local RTGameState_SquadViewer SquadViewer;
	local X2Action_AbilityPerkDurationEnd PerkEnded;

	SquadViewer = RTGameState_SquadViewer(`XCOMHISTORY.GetGameStateForObjectID(RemovedEffect.CreatedObjectReference.ObjectID));
	if (SquadViewer != none)
	{
		SquadViewer.DestroyVisualizer();        //  @TODO - use an action instead
	}

	PerkEnded = X2Action_AbilityPerkDurationEnd( class'X2Action_AbilityPerkDurationEnd'.static.AddToVisualizationTrack( BuildTrack, VisualizeGameState.GetContext() ) );
	PerkEnded.EndingEffectState = RemovedEffect;
}



// TargetUnit is the unit that just changed its tile I'm guessing.
// EffectState is the effect that contains the SquadViewer.
function OnUnitChangedTile(const out TTile NewTileLocation, XComGameState_Effect EffectState, XComGameState_Unit TargetUnit) {
  local XComGameStateHistory History;
  local XComGameState_Unit SourceUnitState;
  local RTGameState_SquadViewer ViewerState, NewViewerState;
  local XComGameState         NewGameState;

  History = `XCOMHISTORY;
  ViewerState = RTGameState_SquadViewer(History.GetGameStateForObjectID(EffectState.CreatedObjectReference.ObjectID));
  SourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
  // It appears Over the Shoulder will handle the creation and removal of all MobileSquadViewers, all we need to do is update our position. If it's too far, OTS will remove us.
  if(ViewerState != none) {
    // if the unit that was moving is the one that had this SquadViewer, we need to update its position.
    if(TargetUnit.ObjectID == ViewerState.AssociatedUnit.ObjectID) {
      class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: Updating MobileSquadViewer position...");
      NewViewerState = RTGameState_SquadViewer(NewGameState.CreateStateObject(ViewerState.class, ViewerState.ObjectID));
      NewViewerState.ViewerTile = TargetUnit.TileLocation;
	  NewViewerState.SetVisibilityLocation(TargetUnit.TileLocation);
		
      NewGameState.AddStateObject(NewViewerState);
      `TACTICALRULES.SubmitGameState(NewGameState);
    }
  }
}

defaultproperties
{
    DuplicateResponse = eDupe_Refresh
}
