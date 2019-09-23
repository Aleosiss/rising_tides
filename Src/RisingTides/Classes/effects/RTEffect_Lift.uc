class RTEffect_Lift extends X2Effect;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnitState;
	local TTIle TeleportToTile;
	local X2EventManager EventManager;

	EventManager = `XEVENTMGR;

	TargetUnitState = XComGameState_Unit(kNewTargetState);
	if(TargetUnitState == none) {
		`RedScreenOnce("You messed up");
		return;
	}

	TeleportToTile = TargetUnitState.TileLocation;
	TeleportToTile.Z += 1;

	// Move the target to this space
	TargetUnitState.SetVisibilityLocation(TeleportToTile);

	EventManager.TriggerEvent('ObjectMoved', TargetUnitState, TargetUnitState, NewGameState);
	EventManager.TriggerEvent('UnitMoveFinished', TargetUnitState, TargetUnitState, NewGameState);

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, name EffectApplyResult)
{
	local XComGameState_Unit TargetUnitState;
	local vector NewUnitLoc;
	local RTAction_PsionicGetOverHereTarget GetOverHereTarget;
	local X2Action_ApplyWeaponDamageToUnit UnitAction;

	TargetUnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);
	`assert(TargetUnitState != none);

	// Move the target to this space
	if( EffectApplyResult == 'AA_Success' )
	{
		GetOverHereTarget = RTAction_PsionicGetOverHereTarget(class'RTAction_PsionicGetOverHereTarget'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		NewUnitLoc = `XWORLD.GetPositionFromTileCoordinates(TargetUnitState.TileLocation);
		GetOverHereTarget.SetDesiredLocation(NewUnitLoc, XGUnit(ActionMetadata.VisualizeActor));
	}
	else
	{
		UnitAction = X2Action_ApplyWeaponDamageToUnit(class'X2Action_ApplyWeaponDamageToUnit'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		UnitAction.OriginatingEffect = self;
	}
}
