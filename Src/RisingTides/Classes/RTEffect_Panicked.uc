//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_Panicked.uc
//  AUTHOR:  Aleosiss
//  DATE:    16 May 2016
//  PURPOSE: Modified panic effect, should be similar to Long War (units simply do nothing)
//---------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------

class RTEffect_Panicked extends X2Effect_Panicked config(RTGhost);

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit UnitState;
	local Name PanicBehaviorTree;
	local bool bCivilian;

	UnitState = XComGameState_Unit(kNewTargetState);
	if (m_aStatChanges.Length > 0)
	{
		NewEffectState.StatChanges = m_aStatChanges;

		//  Civilian panic does not modify stats and does not need to call the parent functions (which will result in a RedScreen for having no stats!)
		super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
	}

	// Add two standard action points for panicking actions.
	bCivilian = UnitState.GetTeam() == eTeam_Neutral;
	if( !bCivilian )
	{
		UnitState.ActionPoints.Length = 0;
	}
	else
	{
		// Force civilians into red alert.
		if( UnitState.GetCurrentStat(eStat_AlertLevel) != `ALERT_LEVEL_RED )
		{
			UnitState.SetCurrentStat(eStat_AlertLevel, `ALERT_LEVEL_RED);
		}
	}
	UnitState.bPanicked = true;

	if( !bCivilian )
	{
		// Kick off panic behavior tree.
		PanicBehaviorTree = Name(UnitState.GetMyTemplate().strPanicBT);

		// Delayed behavior tree kick-off.  Points must be added and game state submitted before the behavior tree can
		// update, since it requires the ability cache to be refreshed with the new action points.
		UnitState.AutoRunBehaviorTree(PanicBehaviorTree, 2, `XCOMHISTORY.GetCurrentHistoryIndex() + 1, true);
	}
}
