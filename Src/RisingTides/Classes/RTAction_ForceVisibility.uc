// This is an Unreal Script

class RTAction_ForceVisibility extends X2Action;

var EForceVisibilitySetting ForcedVisible;
var bool bResetVisibility;
var protected TTile CurrentTile;

event bool BlocksAbilityActivation() {
	return false;
}

simulated state Executing {
	Begin:
			if(bResetVisibility) {
				Unit.SetForceVisibility(eForceNone);
				Unit.m_bForceHidden = false;
				CurrentTile = `XWORLD.GetTileCoordinatesFromPosition(Unit.Location);
				`TACTICALRULES.VisibilityMgr.ActorVisibilityMgr.VisualizerUpdateVisibility(Unit, CurrentTile);
				Unit.GetPawn().UpdatePawnVisibility();
			} else {
				Unit.SetForceVisibility(ForcedVisible);
				Unit.GetPawn().UpdatePawnVisibility();
			}

			CompleteAction();
}

defaultproperties
{
	ForcedVisible = eForceNone;
	bResetVisibility = false;
}
