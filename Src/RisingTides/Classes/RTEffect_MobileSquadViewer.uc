class RTEffect_MobileSquadViewer extends X2Effect_Persistent;

var bool bUseTargetSizeRadius;
var bool bUseTargetSightRadius;
var int iCustomTileRadius;
var float ViewRadius;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState) {
	local XComGameStateHistory History;
	local XComGameState_Unit TargetUnitState;
	local XComGameState_SquadViewer ViewerState;
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

	TargetUnitState = XComGameState_Unit(kNewTargetState);
	
	if (TargetUnitState.AffectedByEffectNames.Find(class'X2AbilityTemplateManager'.default.BurrowedName) != INDEX_NONE) {
		TargetUnitState.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.UnburrowActionPoint);
	}

	// should find a better way soon, since the chosen can conceal, but for now, this will work
	`XEVENTMGR.TriggerEvent(class'X2Ability_Chryssalid'.default.UnburrowTriggerEventName, kNewTargetState, kNewTargetState, NewGameState);
	`XEVENTMGR.TriggerEvent(class'X2Ability_Faceless'.default.ChangeFormTriggerEventName, kNewTargetState, kNewTargetState, NewGameState);
	



	ViewerTile = TargetUnitState.TileLocation;

	if(bUseTargetSightRadius) {
		fViewRadius = TargetUnitState.GetBaseStat(eStat_SightRadius) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	} else if(bUseTargetSizeRadius) {
		fViewRadius = float(TargetUnitState.UnitSize) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	} else {
		fViewRadius = float(iCustomTileRadius) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	}

	ViewerState = XComGameState_SquadViewer(NewGameState.CreateStateObject(class'XComGameState_SquadViewer'));
	ViewerState.AssociatedPlayer = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID)).ControllingPlayer;
	ViewerState.SetVisibilityLocation(ViewerTile);
	ViewerState.ViewerTile = ViewerTile;
	ViewerState.ViewerRadius = fViewRadius;

	NewGameState.AddStateObject(ViewerState);
	NewEffectState.CreatedObjectReference = ViewerState.GetReference();

}

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
	local XComGameState_Unit TargetUnitState;
	local XComGameStateHistory History;
	local XComGameState_SquadViewer ViewerState, OldViewerState;
	local float fViewRadius;
	local TTile ViewerTile;

	History = `XCOMHISTORY;

	TargetUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	

	if (TargetUnitState.AffectedByEffectNames.Find(class'X2AbilityTemplateManager'.default.BurrowedName) != INDEX_NONE) {
		TargetUnitState.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.UnburrowActionPoint);
	}

	// should find a better way soon, since the chosen can conceal, but for now, this will work
	`XEVENTMGR.TriggerEvent(class'X2Ability_Chryssalid'.default.UnburrowTriggerEventName, TargetUnitState, TargetUnitState, NewGameState);
	`XEVENTMGR.TriggerEvent(class'X2Ability_Faceless'.default.ChangeFormTriggerEventName, TargetUnitState, TargetUnitState, NewGameState);

	TargetUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	// TargetUnitState.bRequiresVisibilityUpdate = true;
	

	ViewerTile = TargetUnitState.TileLocation;

	if(bUseTargetSightRadius) {
		fViewRadius = TargetUnitState.GetBaseStat(eStat_SightRadius) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	} else if(bUseTargetSizeRadius) {
		fViewRadius = float(TargetUnitState.UnitSize) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	} else {
		fViewRadius = float(iCustomTileRadius) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	}

	OldViewerState = XComGameState_SquadViewer(History.GetGameStateForObjectID(kNewEffectState.CreatedObjectReference.ObjectID));
	OldViewerState.bRequiresVisibilityUpdate = true;
	OldViewerState.DestroyVisualizer();
	NewGameState.RemoveStateObject(OldViewerState.ObjectID);

	ViewerState = XComGameState_SquadViewer(NewGameState.CreateStateObject(class'XComGameState_SquadViewer'));
	ViewerState.AssociatedPlayer = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID)).ControllingPlayer;
	ViewerState.SetVisibilityLocation(ViewerTile);
	ViewerState.ViewerTile = ViewerTile;
	ViewerState.ViewerRadius = fViewRadius;
	ViewerState.bRequiresVisibilityUpdate = true;

	ViewerState.FindOrCreateVisualizer(NewGameState);
	ViewerState.SyncVisualizer(NewGameState);

	NewGameState.AddStateObject(TargetUnitState);
	NewGameState.AddStateObject(ViewerState);
	kNewEffectState.CreatedObjectReference = ViewerState.GetReference();

	return true;
}

simulated function AddX2ActionsForVisualization_Tick(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const int TickIndex, XComGameState_Effect EffectState)
{
	local RTAction_ForceVisibility VisAction;

	if (XComGameState_Unit(BuildTrack.StateObject_NewState) != none)
	{
		VisAction = RTAction_ForceVisibility( class'RTAction_ForceVisibility'.static.AddToVisualizationTrack( BuildTrack, VisualizeGameState.GetContext( ) ) );
		VisAction.Visibility = eForceVisible;
	}
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_SquadViewer Viewer;
	local XComGameStateHistory History;
	local XComGameState_Unit NewUnitState;

	History = `XCOMHISTORY;
	Viewer = XComGameState_SquadViewer(History.GetGameStateForObjectID(RemovedEffectState.CreatedObjectReference.ObjectID));
	Viewer.bRequiresVisibilityUpdate = true;
	Viewer.DestroyVisualizer();
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
	local XComGameState_SquadViewer SquadViewer;
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
			SquadViewer = XComGameState_SquadViewer(VisualizeGameState.GetGameStateForObjectID(EffectState.CreatedObjectReference.ObjectID));
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
	local XComGameState_SquadViewer SquadViewer;
	local X2Action_AbilityPerkDurationEnd PerkEnded;
	// local RTAction_ForceVisibility VisAction;

	SquadViewer = XComGameState_SquadViewer(`XCOMHISTORY.GetGameStateForObjectID(RemovedEffect.CreatedObjectReference.ObjectID));
	if (SquadViewer != none)
	{
		SquadViewer.bRequiresVisibilityUpdate = true;
		SquadViewer.DestroyVisualizer();        //  @TODO - use an action instead
	}

	PerkEnded = X2Action_AbilityPerkDurationEnd( class'X2Action_AbilityPerkDurationEnd'.static.AddToVisualizationTrack( BuildTrack, VisualizeGameState.GetContext() ) );
	PerkEnded.EndingEffectState = RemovedEffect;

	if (XComGameState_Unit(BuildTrack.StateObject_NewState) != none)
	{
		class'RTAction_ForceVisibility'.static.AddToVisualizationTrack( BuildTrack, VisualizeGameState.GetContext( ) );
	}
}


// TargetUnit is the unit that just changed its tile I'm guessing.
// EffectState is the effect that contains the SquadViewer.
function OnUnitChangedTile(const out TTile NewTileLocation, XComGameState_Effect EffectState, XComGameState_Unit TargetUnit) {
	local XComGameStateHistory History;
	local XComGameState_Unit NewUnitState;
	local XComGameState_SquadViewer ViewerState, NewViewerState;
	local XComGameState         NewGameState;

	History = `XCOMHISTORY;
	ViewerState = XComGameState_SquadViewer(History.GetGameStateForObjectID(EffectState.CreatedObjectReference.ObjectID));
	// It appears Over the Shoulder will handle the creation and removal of all MobileSquadViewers, all we need to do is update our position. If it's too far, OTS will remove us.
	`LOG("Rising Tides: Effect updating on move!");
	if(ViewerState != none) {
		// if the unit that was moving is the one that had this SquadViewer, we need to update its position.
		if(TargetUnit.ObjectID == EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID) {
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: Updating MobileSquadViewer position...");
			NewViewerState = XComGameState_SquadViewer(NewGameState.CreateStateObject(ViewerState.class, ViewerState.ObjectID));
			NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(TargetUnit.class, TargetUnit.ObjectID));

			NewUnitState.bRequiresVisibilityUpdate = true;
			NewViewerState.bRequiresVisibilityUpdate = true;

			NewViewerState.ViewerTile = NewTileLocation;
			NewViewerState.SetVisibilityLocation(NewTileLocation);

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
	bUseTargetSizeRadius = true;
}
