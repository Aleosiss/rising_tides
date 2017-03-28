// This is an Unreal Script
class RTCondition_VerticalClearance extends X2Condition;

var float fVerticalSpaceRequirement;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) {
	if(CheckTarget(kTarget)) {
		return 'AA_Success';
	}
	return 'AA_TileIsBlocked';
}

private function bool CheckTarget(XComGameState_BaseObject kTarget) {
	local XComGameState_Unit TargetUnitState;
	local Vector InitialTargetUnitLocation
	local float DesiredTargetUnitHeight;

	TargetUnitState = XComGameState_Unit(kTarget);
	if(TargetUnitState == none) {
		return false;
	}


	InitialTargetUnitLocation = `XWORLD.GetPositionFromTileCoordinates(TargetUnitState.TileLocation);
	DesiredTargetUnitHeight = `XWORLD.GetFloorZForPosition(TargetUnitLocation) + fVerticalSpaceRequirement;

	if (!`XWORLD.HasOverheadClearance(InitialTargetUnitLocation, DesiredTargetUnitHeight)) {
			return false;
	}

	return true;
}

defaultproperties
{
	fVerticalSpaceRequirement = 128.0f // WORLD_FloorHeight * 2
}
