class RTEffect_PsionicLash extends X2Effect_GetOverHere;

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, name EffectApplyResult)
{
	local XComGameState_Unit TargetUnitState;
	local vector NewUnitLoc;
	local RTAction_PsionicGetOverHereTarget GetOverHereTarget;

	TargetUnitState = XComGameState_Unit(BuildTrack.StateObject_NewState);
	`assert(TargetUnitState != none);

	// Move the target to this space
	if( EffectApplyResult == 'AA_Success' )
	{
		GetOverHereTarget = RTAction_PsionicGetOverHereTarget(class'RTAction_PsionicGetOverHereTarget'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
		NewUnitLoc = `XWORLD.GetPositionFromTileCoordinates(TargetUnitState.TileLocation);
		GetOverHereTarget.SetDesiredLocation(NewUnitLoc, XGUnit(BuildTrack.TrackActor));
	}
}
