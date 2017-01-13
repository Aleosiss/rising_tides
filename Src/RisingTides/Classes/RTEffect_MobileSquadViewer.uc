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
        `RedScreenOnce("Rising Tides: Attempting to create a SquadViewer on a non-unit target!");
        return;
    }

    ViewerTile = TargetUnitState.TileLocation;

    ViewerState = RTGameState_SquadViewer(NewGameState.CreateStateObject(class'RTGameState_SquadViewer'));
    ViewerState.AssociatedPlayer = ApplyEffectParameters.PlayerStateObjectRef;
    ViewerState.SetVisibilityLocation(ViewerTile);
    ViewerState.ViewerRadius = ViewRadius;

    NewGameState.AddStateObject(ViewerState);

    NewEffectState.CreatedObjectReference = ViewerState.GetReference();

}
// TargetUnit is the unit that just changed its tile I'm guessing.
function OnUnitChangedTile(const out TTile NewTileLocation, XComGameState_Effect EffectState, XComGameState_Unit TargetUnit) {
    local XComGameStateHistory History;
    local XComGameState_Unit SourceUnitState;
    local RTGameState_SquadViewer ViewerState;

    History = `XCOMHISTORY;
    ViewerState = RTGameState_SquadViewer(History.GetGameStateForObjectID(EffectState.CreatedObjectReference.ObjectID));

    // we only need to update the SquadViewer if it's moving.
    if(TargetUnit.ObjectID == ViewerState.AssociatedUnit.ObjectID) {
        ViewerState.ViewerTile = NewTileLocation;

    } 
}
