class RTEffect_MobileSquadViewer extends X2Effect_Persistent;

var bool bUseTargetSightRadius;
var int iCustomTileRadius;
var float ViewRadius;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState) {
	local XComGameStateHistory History;
	local XComGameState_Unit SourceUnitState, TargetUnitState;
	local RTGameState_SquadViewer ViewerState;
	local XComGameState_Ability AbilityState;
	local Vector ViewerLocation;
	local float fViewRadius;
	local TTile ViewerTile;

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
	kNewTargetState.bRequiresVisibilityUpdate = true;

	History = `XCOMHISTORY;

	TargetUnitState = XComGameState_Unit(kNewTargetState);
	if(TargetUnitState == none) {
		`RedScreenOnce("Rising Tides: Attempting to create a SquadViewer on a non-unit target!");
		return;
	}

	ViewerTile = TargetUnitState.TileLocation;

	if(bUseTargetSightRadius) {
		fViewRadius = TargetUnitState.GetBaseStat(eStat_SightRadius) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	} else {
		fViewRadius = float(iCustomTileRadius) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	}

	ViewerState = RTGameState_SquadViewer(NewGameState.CreateStateObject(class'RTGameState_SquadViewer'));
	ViewerState.AssociatedPlayer = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID)).ControllingPlayer;
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
	local XComGameState_Unit NewUnitState;

	History = `XCOMHISTORY;
	Viewer = RTGameState_SquadViewer(History.GetGameStateForObjectID(RemovedEffectState.CreatedObjectReference.ObjectID));
	Viewer.bRequiresVisibilityUpdate = true;
	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);

	//Effects that change visibility must actively indicate it
	NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	NewUnitState.bRequiresVisibilityUpdate = true;
	NewGameState.AddStateObject(NewUnitState);

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
	local RTAction_ForceVisibility VisAction;

	if (EffectApplyResult == 'AA_Success' && XComGameState_Unit(BuildTrack.StateObject_NewState) != none)
	{
		VisAction = RTAction_ForceVisibility( class'RTAction_ForceVisibility'.static.AddToVisualizationTrack( BuildTrack, VisualizeGameState.GetContext( ) ) );
		VisAction.Visibility = eForceVisible;
	}


	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Effect', EffectState)
	{
		if (EffectState.GetX2Effect() == self)
		{
			VisualizeEffect = EffectState;

			if (VisualizeEffect == none)
			{
				`RedScreen("Could not find Squad Viewer effect - FOW will not be lifted. Author: jbouscher Contact: @gameplay");
				continue;
			}
			SquadViewer = RTGameState_SquadViewer(VisualizeGameState.GetGameStateForObjectID(EffectState.CreatedObjectReference.ObjectID));
			if (SquadViewer == none)
			{
				`RedScreen("Could not find Squad Viewer game state - FOW will not be lifted. Author: jbouscher Contact: @gameplay");
				continue;
			}
			SquadViewer.FindOrCreateVisualizer(VisualizeGameState);
			SquadViewer.SyncVisualizer(VisualizeGameState);     //  @TODO - use an action instead, but the incoming track will not have the right object to sync

		}
	}

}

simulated function AddX2ActionsForVisualization_Sync( XComGameState VisualizeGameState, out VisualizationTrack BuildTrack )
{
	local RTAction_ForceVisibility VisAction;

	VisAction = RTAction_ForceVisibility( class'RTAction_ForceVisibility'.static.AddToVisualizationTrack( BuildTrack, VisualizeGameState.GetContext( ) ) );
	VisAction.Visibility = eForceVisible;


}

simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
	local RTGameState_SquadViewer SquadViewer;
	local X2Action_AbilityPerkDurationEnd PerkEnded;
	local RTAction_ForceVisibility VisAction;

	SquadViewer = RTGameState_SquadViewer(`XCOMHISTORY.GetGameStateForObjectID(RemovedEffect.CreatedObjectReference.ObjectID));
	if (SquadViewer != none)
	{
		SquadViewer.bRequiresVisibilityUpdate = true;
		SquadViewer.DestroyVisualizer();        //  @TODO - use an action instead
	}

	PerkEnded = X2Action_AbilityPerkDurationEnd( class'X2Action_AbilityPerkDurationEnd'.static.AddToVisualizationTrack( BuildTrack, VisualizeGameState.GetContext() ) );
	PerkEnded.EndingEffectState = RemovedEffect;

	if (XComGameState_Unit(BuildTrack.StateObject_NewState) != none)
	{
		VisAction = RTAction_ForceVisibility( class'RTAction_ForceVisibility'.static.AddToVisualizationTrack( BuildTrack, VisualizeGameState.GetContext( ) ) );
	}
}


// TargetUnit is the unit that just changed its tile I'm guessing.
// EffectState is the effect that contains the SquadViewer.
function OnUnitChangedTile(const out TTile NewTileLocation, XComGameState_Effect EffectState, XComGameState_Unit TargetUnit) {
	local XComGameStateHistory History;
	local XComGameState_Unit SourceUnitState, NewUnitState;
	local RTGameState_SquadViewer ViewerState, NewViewerState;
	local XComGameState         NewGameState;

	History = `XCOMHISTORY;
	ViewerState = RTGameState_SquadViewer(History.GetGameStateForObjectID(EffectState.CreatedObjectReference.ObjectID));
	SourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	// It appears Over the Shoulder will handle the creation and removal of all MobileSquadViewers, all we need to do is update our position. If it's too far, OTS will remove us.

	if(ViewerState != none) {
		// if the unit that was moving is the one that had this SquadViewer, we need to update its position.
		if(TargetUnit.ObjectID == ViewerState.AssociatedUnit.ObjectID) {
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: Updating MobileSquadViewer position...");
			NewViewerState = RTGameState_SquadViewer(NewGameState.CreateStateObject(ViewerState.class, ViewerState.ObjectID));
			NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(TargetUnit.class, TargetUnit.ObjectID));

			NewUnitState.bRequiresVisibilityUpdate = true;
			NewViewerState.bRequiresVisibilityUpdate = true;

			NewViewerState.ViewerTile = TargetUnit.TileLocation;
			NewViewerState.SetVisibilityLocation(TargetUnit.TileLocation);

			NewViewerState.DestroyVisualizer();

			NewViewerState.FindOrCreateVisualizer(NewGameState);
			NewViewerState.SyncVisualizer(NewGameState);

			NewGameState.AddStateObject(NewViewerState);
			NewGameState.AddStateObject(NewUnitState);


			`TACTICALRULES.SubmitGameState(NewGameState);
	}
  }
}

defaultproperties
{
	EffectName = "RTMobileSquadViewer"
	DuplicateResponse = eDupe_Refresh
	iCustomTileRadius = 3
	bUseTargetSightRadius = true;
}
