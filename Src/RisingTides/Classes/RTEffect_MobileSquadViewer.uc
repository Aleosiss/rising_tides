class RTEffect_MobileSquadViewer extends X2Effect_Persistent;

var bool bUseTargetSizeRadius;
var bool bUseTargetSightRadius;
var int iCustomTileRadius;
var float ViewRadius;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState) {
	local XComGameStateHistory History;
	local XComGameState_Unit TargetUnitState;
	local RTGameState_SquadViewer ViewerState;
	local float fViewRadius;
	local TTile ViewerTile;

	// indicate unitvis change
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
	kNewTargetState.bRequiresVisibilityUpdate = true;
	// end indicate unitvis change

	// unconceal unit
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
	`XEVENTMGR.TriggerEvent('EffectBreakUnitConcealment', kNewTargetState, kNewTargetState, NewGameState);
	`XEVENTMGR.TriggerEvent(class'X2Effect_ScanningProtocol'.default.ScanningProtocolTriggeredEventName, kNewTargetState, kNewTargetState, NewGameState);
	// end unconceal unit

	// create the spotlight around the unit
	ViewerTile = TargetUnitState.TileLocation;

	if(bUseTargetSightRadius) {
		fViewRadius = TargetUnitState.GetBaseStat(eStat_SightRadius) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	} else if(bUseTargetSizeRadius) {
		fViewRadius = float(TargetUnitState.UnitSize) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	} else {
		fViewRadius = float(iCustomTileRadius) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	}
	
	ViewerState = RTGameState_SquadViewer(NewGameState.CreateStateObject(class'RTGameState_SquadViewer'));
	ViewerState.AssociatedPlayer = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID)).ControllingPlayer;
	ViewerState.AssociatedUnit = ApplyEffectParameters.TargetStateObjectRef;
	ViewerState.SetVisibilityLocation(ViewerTile);
	ViewerState.ViewerTile = ViewerTile;
	ViewerState.ViewerRadius = fViewRadius;

	NewGameState.AddStateObject(ViewerState);
	NewEffectState.CreatedObjectReference = ViewerState.GetReference();
	// end create spotlight

}

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication, XComGameState_Player Player) {
	local XComGameState_Unit TargetUnitState;
	local XComGameStateHistory History;
	local RTGameState_SquadViewer ViewerState/*, OldViewerState*/;
	local float fViewRadius;
	local TTile ViewerTile;

	History = `XCOMHISTORY;

	TargetUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	TargetUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', TargetUnitState.ObjectID));

	if (TargetUnitState.AffectedByEffectNames.Find(class'X2AbilityTemplateManager'.default.BurrowedName) != INDEX_NONE) {
		TargetUnitState.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.UnburrowActionPoint);
	}

	// should find a better way soon, since the chosen can conceal, but for now, this will work
	`XEVENTMGR.TriggerEvent(class'X2Ability_Chryssalid'.default.UnburrowTriggerEventName, TargetUnitState, TargetUnitState, NewGameState);
	`XEVENTMGR.TriggerEvent(class'X2Ability_Faceless'.default.ChangeFormTriggerEventName, TargetUnitState, TargetUnitState, NewGameState);
	`XEVENTMGR.TriggerEvent('EffectBreakUnitConcealment', TargetUnitState, TargetUnitState, NewGameState);
	`XEVENTMGR.TriggerEvent(class'X2Effect_ScanningProtocol'.default.ScanningProtocolTriggeredEventName, TargetUnitState, TargetUnitState, NewGameState);

	ViewerTile = TargetUnitState.TileLocation;

	if(bUseTargetSightRadius) {
		fViewRadius = TargetUnitState.GetBaseStat(eStat_SightRadius) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	} else if(bUseTargetSizeRadius) {
		fViewRadius = float(TargetUnitState.UnitSize) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	} else {
		fViewRadius = float(iCustomTileRadius) * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	}

	ViewerState = RTGameState_SquadViewer(NewGameState.ModifyStateObject(class'RTGameState_SquadViewer', kNewEffectState.CreatedObjectReference.ObjectID));
	if(ViewerState != none) {
		ViewerState.AssociatedPlayer = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID)).ControllingPlayer;
		ViewerState.AssociatedUnit = ApplyEffectParameters.TargetStateObjectRef;
		ViewerState.SetVisibilityLocation(ViewerTile);
		ViewerState.ViewerTile = ViewerTile;
		ViewerState.ViewerRadius = fViewRadius;
		//ViewerState.bRequiresVisibilityUpdate = true;
		ViewerState.SyncVisualizer(NewGameState);
		//kNewEffectState.CreatedObjectReference = ViewerState.GetReference();
	} else {
		class'RTHelpers'.static.RTLog("kNewEffectState.CreatedObjectReference.ObjectID couldn't be found @ RTEffect_MobileSquadViewer::OnEffectTicked!");
	}


	return super.OnEffectTicked(ApplyEffectParameters, kNewEffectState, NewGameState, FirstApplication, Player);
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState) {
	local RTGameState_SquadViewer Viewer;
	local XComGameStateHistory History;
	local XComGameState_Unit NewUnitState;

	History = `XCOMHISTORY;
	Viewer = RTGameState_SquadViewer(History.GetGameStateForObjectID(RemovedEffectState.CreatedObjectReference.ObjectID));
	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);

	if(Viewer == none) {
		`Redscreen("RTEffect_MobileSquadViewer::OnEffectRemoved: Could not find associated viewer object to remove!");
		return;
	} else {
		class'RTHelpers'.static.RTLog("Removing RTGameState_SquadViewer ObjectID: " $ Viewer.GetReference().ObjectID);
		NewGameState.RemoveStateObject(RemovedEffectState.CreatedObjectReference.ObjectID);
	}

	//Effects that change visibility must actively indicate it
	NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	NewUnitState.bRequiresVisibilityUpdate = true;
	NewGameState.AddStateObject(NewUnitState);
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, name EffectApplyResult) {
	local XComGameState_Effect EffectState, VisualizeEffect;
	local RTGameState_SquadViewer SquadViewer;
	local X2Action_ForceUnitVisiblity ForceVisiblityAction;

	super.AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, EffectApplyResult);

	if (EffectApplyResult == 'AA_Success' && XComGameState_Unit(ActionMetadata.StateObject_NewState) != none)
	{
		ForceVisiblityAction = X2Action_ForceUnitVisiblity(class'X2Action_ForceUnitVisiblity'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
		ForceVisiblityAction.ForcedVisible = eForceVisible;
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
			SquadViewer.SyncVisualizer(VisualizeGameState);     //  @TODO - use an action instead, but the incoming track will not have the right object to sync
		}
	}

}

simulated function AddX2ActionsForVisualization_Tick(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const int TickIndex, XComGameState_Effect EffectState) {
	local X2Action_ForceUnitVisiblity ForceVisiblityAction;
	local RTGameState_SquadViewer Viewer;

	Viewer = RTGameState_SquadViewer(`XCOMHISTORY.GetGameStateForObjectID(EffectState.CreatedObjectReference.ObjectID));
	if(Viewer != none) {
			Viewer.FindOrCreateVisualizer(VisualizeGameState);
			Viewer.SyncVisualizer(VisualizeGameState);
	}

	if (XComGameState_Unit(ActionMetadata.StateObject_NewState) != none)
	{
		ForceVisiblityAction = X2Action_ForceUnitVisiblity(class'X2Action_ForceUnitVisiblity'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
		ForceVisiblityAction.ForcedVisible = eForceVisible;
	}
}

simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult, XComGameState_Effect RemovedEffect) {
	local RTGameState_SquadViewer SquadViewer;
	local X2Action_AbilityPerkDurationEnd PerkEnded;
	//local X2Action_ForceUnitVisiblity ForceVisiblityAction_Hide, ForceVisiblityAction_Reset;
	local RTAction_ForceVisibility RTForceVisibilityAction_Reset;
	local XComGameState_Unit EffectedUnitState;

	SquadViewer = RTGameState_SquadViewer(`XCOMHISTORY.GetGameStateForObjectID(RemovedEffect.CreatedObjectReference.ObjectID));
	if (SquadViewer != none)
	{
		SquadViewer.DestroyVisualizer();        //  @TODO - use an action instead
	}

	PerkEnded = X2Action_AbilityPerkDurationEnd( class'X2Action_AbilityPerkDurationEnd'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
	PerkEnded.EndingEffectState = RemovedEffect;

	EffectedUnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);

	if (EffectedUnitState != none)
	{
		super.AddX2ActionsForVisualization_Removed(VisualizeGameState, ActionMetadata, EffectApplyResult, RemovedEffect);

		RTForceVisibilityAction_Reset = RTAction_ForceVisibility(class'RTAction_ForceVisibility'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
		RTForceVisibilityAction_Reset.bResetVisibility = true;
	}
}

simulated function AddX2ActionsForVisualization_Sync( XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata ) {
	AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, 'AA_Success');
}

defaultproperties
{
	EffectName = "RTMobileSquadViewer"
	DuplicateResponse = eDupe_Refresh
	iCustomTileRadius = 3
	bUseTargetSightRadius = true;
	bUseTargetSizeRadius = true;
}