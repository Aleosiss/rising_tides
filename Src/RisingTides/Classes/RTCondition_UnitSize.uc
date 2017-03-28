// This is an Unreal Script
class RTCondition_UnitSize extends X2Condition;

var int iMaximumSize;
var int iMinimumSize;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) {
	if(CheckTarget(kTarget)) {
		return 'AA_Success';
	}
	return 'AA_NoTargets';
}


private function bool CheckTarget(XComGameState_BaseObject kTarget) {
	local XComGameState_Unit    TargetUnitState;
	local int 					iTargetUnitSize;

	// Size check should always be against a unit for now. This is because I'm too lazy to figure out a size check for other objects.
	TargetUnitState = XComGameState_Unit(kTarget);
	if(TargetUnitState == none) {
		return false;
	}

	iTargetUnitSize = TargetUnitState.UnitSize;

	if(iTargetUnitSize > iMaximumSize) {
		return false;
	}

	if(iTargetUnitSize < iMinimumSize) {
		return false;
	}

	return true;
}

defaultproperties
{
	iMinimumSize = 1
	iMaximumSize = 1
}
