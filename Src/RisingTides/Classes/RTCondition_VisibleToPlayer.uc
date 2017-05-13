// This is an Unreal Script																			   
class RTCondition_VisibleToPlayer extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) {
	if(IsTargetVisibleToLocalPlayer(kTarget.GetReference())) {
		return 'AA_Success';
	} else {
		return 'AA_NotVisible';
	}
}
event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource) {
	if(IsTargetVisibleToLocalPlayer(kTarget.GetReference(), kSource.ObjectID)) {
		return 'AA_Success';
	} else {
		return 'AA_NotVisible';
	}
}

simulated static function bool IsTargetVisibleToLocalPlayer(StateObjectReference TargetUnitRef, optional int SourceUnitObjectID = -2)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local EForceVisibilitySetting ForceVisibleSetting;
	local array<StateObjectReference> VisibleTargets;

	History = `XCOMHISTORY;
	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(TargetUnitRef.ObjectID));
	if( UnitState != None ) {
		ForceVisibleSetting = UnitState.ForceModelVisible(); // Checks if local player, among other things.
		if( ForceVisibleSetting == eForceVisible )
		{
			return true;
		}
		else if( ForceVisibleSetting == eForceNotVisible || UnitState.IsConcealed() )
		{
			return false;
		}

		// Check if enemy can see this unit.
		return class'X2TacticalVisibilityHelpers'.static.GetNumEnemyViewersOfTarget(TargetUnitRef.ObjectID) > 0;
	} else { // the target was not a unit. in this case, all we can do is a general target check
		 // because interactive objects and destructables are always technically visible to the player through the FOW
		if(SourceUnitObjectID != -2) {
			class'X2TacticalVisibilityHelpers'.static.GetAllVisibleEnemyTargetsForUnit( SourceUnitObjectID, VisibleTargets );
			if(VisibleTargets.Find('ObjectID', TargetUnitRef.ObjectID) != INDEX_NONE) {
				return true;
			}
		}
		else {
			return false;
		}

	}

}

defaultproperties
{

}
