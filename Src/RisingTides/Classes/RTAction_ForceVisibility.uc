// This is an Unreal Script

class RTAction_ForceVisibility extends X2Action;

var EForceVisibilitySetting Visibility;

event bool BlocksAbilityActivation() {
	return false;
}

function Init(const out VisualizationTrack InTrack) {
	super.Init(InTrack);
}

simulated state Executing {
	Begin:
			Unit.SetForceVisibility(Visibility);
			Unit.GetPawn().UpdatePawnVisibility();

			CompleteAction();
}

defaultproperties
{
	Visibility = eForceNone;
}
