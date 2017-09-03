class RTEffect_PsionicLash extends X2Effect_GetOverHere;

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, name EffectApplyResult)
{
	local XComGameState_Unit TargetUnitState;
	local vector NewUnitLoc;
	local RTAction_PsionicGetOverHereTarget GetOverHereTarget;

	TargetUnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);
	`assert(TargetUnitState != none);

	// Move the target to this space
	if( EffectApplyResult == 'AA_Success' )
	{
		GetOverHereTarget = RTAction_PsionicGetOverHereTarget(class'RTAction_PsionicGetOverHereTarget'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		NewUnitLoc = `XWORLD.GetPositionFromTileCoordinates(TargetUnitState.TileLocation);
		GetOverHereTarget.SetDesiredLocation(NewUnitLoc, XGUnit(ActionMetadata.VisualizeActor));
	}
}
