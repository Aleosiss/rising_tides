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
	
	ViewerState = XComGameState_SquadViewer(NewGameState.CreateStateObject(class'XComGameState_SquadViewer'));
	ViewerState.AssociatedPlayer = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID)).ControllingPlayer;
	ViewerState.SetVisibilityLocation(ViewerTile);
	ViewerState.ViewerTile = ViewerTile;
	ViewerState.ViewerRadius = fViewRadius;

	NewGameState.AddStateObject(ViewerState);
	NewEffectState.CreatedObjectReference = ViewerState.GetReference();
	// end create spotlight

}

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication, XComGameState_Player Player) 
{
	local XComGameState_Unit TargetUnitState;
	local XComGameStateHistory History;
	local XComGameState_SquadViewer ViewerState, OldViewerState;
	local float fViewRadius;
	local TTile ViewerTile;

	History = `XCOMHISTORY;
	class'RTHelpers'.static.RTLog("Ticking a MobileSquadViewer!");

	TargetUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	TargetUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', TargetUnitState.ObjectID));

	if (TargetUnitState.AffectedByEffectNames.Find(class'X2AbilityTemplateManager'.default.BurrowedName) != INDEX_NONE) {
		TargetUnitState.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.UnburrowActionPoint);
	}

	// should find a better way soon, since the chosen can conceal, but for now, this will work
	`XEVENTMGR.TriggerEvent(class'X2Ability_Chryssalid'.default.UnburrowTriggerEventName, TargetUnitState, TargetUnitState, NewGameState);
	`XEVENTMGR.TriggerEvent(class'X2Ability_Faceless'.default.ChangeFormTriggerEventName, TargetUnitState, TargetUnitState, NewGameState);

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

	ViewerState = XComGameState_SquadViewer(NewGameState.CreateNewStateObject(class'XComGameState_SquadViewer'));
	ViewerState.AssociatedPlayer = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID)).ControllingPlayer;
	ViewerState.SetVisibilityLocation(ViewerTile);
	ViewerState.ViewerTile = ViewerTile;
	ViewerState.ViewerRadius = fViewRadius;
	ViewerState.bRequiresVisibilityUpdate = true;

	ViewerState.FindOrCreateVisualizer(NewGameState);
	ViewerState.SyncVisualizer(NewGameState);
	kNewEffectState.CreatedObjectReference = ViewerState.GetReference();

	return super.OnEffectTicked(ApplyEffectParameters, kNewEffectState, NewGameState, FirstApplication, Player);
}

simulated function AddX2ActionsForVisualization_Tick(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const int TickIndex, XComGameState_Effect EffectState)
{
	local X2Action_ForceUnitVisiblity ForceVisiblityAction;

	if (XComGameState_Unit(ActionMetadata.StateObject_NewState) != none)
	{
		ForceVisiblityAction = X2Action_ForceUnitVisiblity(class'X2Action_ForceUnitVisiblity'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
		ForceVisiblityAction.ForcedVisible = eForceVisible;
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


simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, name EffectApplyResult)
{
	local XComGameState_Effect EffectState, VisualizeEffect;
	local XComGameState_SquadViewer SquadViewer;
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

simulated function AddX2ActionsForVisualization_Sync( XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata )
{
	local X2Action_ForceUnitVisiblity ForceVisiblityAction;

	ForceVisiblityAction = X2Action_ForceUnitVisiblity(class'X2Action_ForceUnitVisiblity'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
	ForceVisiblityAction.ForcedVisible = eForceVisible;


}

simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
	local XComGameState_SquadViewer SquadViewer;
	local X2Action_AbilityPerkDurationEnd PerkEnded;
	//local X2Action_ForceUnitVisiblity ForceVisiblityAction_Hide, ForceVisiblityAction_Reset;
	local RTAction_ForceVisibility RTForceVisibilityAction_Reset;
	local XComGameState_Unit EffectedUnitState;

	local XGUnit			RobotUnit;
	local TTile				CurrentTile;

	SquadViewer = XComGameState_SquadViewer(`XCOMHISTORY.GetGameStateForObjectID(RemovedEffect.CreatedObjectReference.ObjectID));
	if (SquadViewer != none)
	{
		SquadViewer.bRequiresVisibilityUpdate = true;
		SquadViewer.DestroyVisualizer();        //  @TODO - use an action instead
	}

	PerkEnded = X2Action_AbilityPerkDurationEnd( class'X2Action_AbilityPerkDurationEnd'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
	PerkEnded.EndingEffectState = RemovedEffect;

	EffectedUnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);

	if (EffectedUnitState != none)
	{
		super.AddX2ActionsForVisualization_Removed(VisualizeGameState, ActionMetadata, EffectApplyResult, RemovedEffect);

		//ForceVisiblityAction_Hide = X2Action_ForceUnitVisiblity(class'X2Action_ForceUnitVisiblity'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
		//ForceVisiblityAction_Hide.ForcedVisible = eForceNotVisible;

		//ForceVisiblityAction_Reset = X2Action_ForceUnitVisiblity(class'X2Action_ForceUnitVisiblity'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
		//ForceVisiblityAction_Reset.ForcedVisible = eForceNone;

		RTForceVisibilityAction_Reset = RTAction_ForceVisibility(class'RTAction_ForceVisibility'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
		RTForceVisibilityAction_Reset.bResetVisibility = true;
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