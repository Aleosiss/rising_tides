class RTEffect_Lift extends X2Effect;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnitState;
	local XComGameStateHistory History;
	local TTIle TeleportToTile;
	local X2EventManager EventManager;

	History = `XCOMHISTORY;
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

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, name EffectApplyResult)
{
	local XComGameState_Unit TargetUnitState;
	local vector NewUnitLoc;
	local RTAction_PsionicGetOverHereTarget GetOverHereTarget;
	local X2Action_ApplyWeaponDamageToUnit UnitAction;

	TargetUnitState = XComGameState_Unit(BuildTrack.StateObject_NewState);
	`assert(TargetUnitState != none);

	// Move the target to this space
	if( EffectApplyResult == 'AA_Success' )
	{
		GetOverHereTarget = RTAction_PsionicGetOverHereTarget(class'RTAction_PsionicGetOverHereTarget'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
		NewUnitLoc = `XWORLD.GetPositionFromTileCoordinates(TargetUnitState.TileLocation);
		GetOverHereTarget.SetDesiredLocation(NewUnitLoc, XGUnit(BuildTrack.TrackActor));
	}
	else
	{
		UnitAction = X2Action_ApplyWeaponDamageToUnit(class'X2Action_ApplyWeaponDamageToUnit'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
		UnitAction.OriginatingEffect = self;
	}
}
