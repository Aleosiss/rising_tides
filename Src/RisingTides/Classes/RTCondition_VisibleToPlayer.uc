// This is an Unreal Script
class RTCondition_VisibleToPlayer extends X2Condition;

var bool bRequireLOS;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) {
	return 'AA_Success';
}
event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource) {
	if(IsTargetVisibleToLocalPlayer(kTarget.GetReference(), kSource.ObjectID)) {
		if(!bRequireLOS) {
			return 'AA_Success';
		} else {
			if(DoesSourceHaveLOS(kTarget, kSource))
				return 'AA_Success';
		}
	}

	return 'AA_NotVisibleToPlayer';
}

simulated static function bool DoesSourceHaveLOS(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource) {
	local GameRulesCache_VisibilityInfo VisInfo;
	if (`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(kSource.ObjectID, kTarget.ObjectID, VisInfo)) {
		if(VisInfo.bClearLOS)  {
			return true;
		}
	}
	return false;
}

simulated static function bool IsTargetVisibleToLocalPlayer(StateObjectReference TargetUnitRef, optional int SourceUnitObjectID = -2, optional bool bDebug = false)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local EForceVisibilitySetting ForceVisibleSetting;
	local array<StateObjectReference> VisibleTargets;
	local bool b;

	local XGUnit UnitVisualizer;
	local XComUnitPawn UnitPawn;
	local XComUnitPawnNativeBase NativeUnitPawn;

	History = `XCOMHISTORY;
	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(TargetUnitRef.ObjectID));
	if( UnitState != none ) {
		ForceVisibleSetting = UnitState.ForceModelVisible(); // Checks if local player, among other things.
		if( ForceVisibleSetting == eForceVisible ) {
			if(bDebug) { class'RTHelpers'.static.RTLog("Unit is visible! Reason: eForceVisible!"); };
			return true;
		}
		else if( ForceVisibleSetting == eForceNotVisible || UnitState.IsConcealed() ) { // Have to find a better way, because we might want to shoot things only visible through OverTheShoulder
			if(bDebug) { class'RTHelpers'.static.RTLog("Unit is not visible! Reason: eForceNotVisible or concealed!"); };
			return false;
		}

		// Check if enemy can see this unit.
		// overly verbose code for debugging
		if(class'X2TacticalVisibilityHelpers'.static.GetNumEnemyViewersOfTarget(TargetUnitRef.ObjectID) > 0) {
			b = true;
			if(bDebug) { class'RTHelpers'.static.RTLog("Unit is visible! Reason: GetNumEnemyViewersOfTarget(TargetUnitRef.ObjectID) > 0!"); };
		} else {
			b = false;
			if(bDebug) { class'RTHelpers'.static.RTLog("Unit is not visible! Reason: GetNumEnemyViewersOfTarget(TargetUnitRef.ObjectID) < 0!"); };
		}
		if(bDebug) { 
			class'RTHelpers'.static.RTLog("The ForceVisibleSetting from ForceModelVisible is: " $ ForceVisibleSetting);

			UnitVisualizer = XGUnit(UnitState.GetVisualizer());
			UnitPawn = UnitVisualizer.GetPawn();
			NativeUnitPawn = UnitPawn;
			class'RTHelpers'.static.RTLog("The UnitVisualizer says... " $ UnitVisualizer.ForceVisibility);
			if(NativeUnitPawn != none) {
				class'RTHelpers'.static.RTLog("The IsPawnSeenInFOW says... " $ NativeUnitPawn.IsPawnSeenInFOW());
			}
		};
		return b;
	} else { // the target was not a unit. in this case, all we can do is a general target check
		 // because interactive objects and destructables are always technically visible to the player through the FOW
		 //class'RTHelpers'.static.RTLog("Target not a unit!");
		if(SourceUnitObjectID != -2) {
			class'X2TacticalVisibilityHelpers'.static.GetAllVisibleEnemyTargetsForUnit( SourceUnitObjectID, VisibleTargets );
			if(VisibleTargets.Find('ObjectID', TargetUnitRef.ObjectID) != INDEX_NONE) {
				if(bDebug) { class'RTHelpers'.static.RTLog("NonUnit is visible! Enemies Visible!"); };
				return true;
			}
		}
		else {
			return false;
		}

	}

	if(bDebug) { 
		class'RTHelpers'.static.RTLog("NonUnit not visible! EndofFunction Reached!");
	};

	return false;
}

defaultproperties
{

}
