class RTEffect_MobileSquadViewer extends X2Effect_PersistentSquadViewer;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState) {
  local XComGameStateHistory History;
  local XComGameState_Unit SourceUnitState, TargetUnitState;
  local RTGameState_SquadViewer ViewerState;
  local XComGameState_Ability AbilityState;
  local Vector ViewerLocation;
  local TTile ViewerTile;

  History = `XCOMHISTORY;

  TargetUnitState = XComGameState_Unit(kNewTargetState);
  if(TargetUnitState == none) {
    `RedScreenOnce("Rising Tides: Attempting to create a SquadViewer on a non-unit target!")
    return;
  }

  ViewerLocation = TargetUnitState.GetLocation();
  ViewerTile = `XWORLD.GetTileCoordinatesFromPosition(ViewerLocation);

  ViewerState = RTGameState_SquadViewer(NewGameState.CreateStateObject(class'RTGameState_SquadViewer'));
  ViewerState.AssociatedPlayer = ApplyEffectParameters.PlayerStateObjectRef;
  ViewerState.AssociatedUnit = TargetUnitState.GetReference();
  ViewerState.SetVisibilityLocation(ViewerTile);
  ViewerState.ViewerRadius = ViewRadius;

  NewGameState.AddStateObject(ViewerState);
  NewEffectState.CreatedObjectReference = ViewerState.GetReference();

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
      NewGameState.AddStateObject(NewViewerState);
      `TACTICALRULES.SubmitGameState(NewGameState);
    }
  }
}

defaultproperties
{
    IgnoreRule = eDupe_Refresh
}
