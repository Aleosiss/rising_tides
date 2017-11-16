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


	class'RTHelpers'.static.RTLog("RTEffect_Panicked applied to unit!");
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


simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata BuildTrack, name EffectApplyResult)
{
	local XComGameState_Unit UnitState;

	if( EffectApplyResult != 'AA_Success' )
	{
		return;
	}

	// pan to the panicking unit (but only if it isn't a civilian)
	UnitState = XComGameState_Unit(BuildTrack.StateObject_NewState);
	if (UnitState == none)
		return;

	if(!UnitState.IsCivilian())
	{
		class'X2StatusEffects'.static.AddEffectCameraPanToAffectedUnitToTrack(BuildTrack, VisualizeGameState.GetContext());
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(BuildTrack, VisualizeGameState.GetContext(), EffectFriendlyName, 'PanicScream', eColor_Bad, class'UIUtilities_Image'.const.UnitStatus_Panicked);
		
	}

	class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}

simulated function AddX2ActionsForVisualization_Tick(XComGameState VisualizeGameState, out VisualizationActionMetadata BuildTrack, const int TickIndex, XComGameState_Effect EffectState)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(BuildTrack.StateObject_NewState);
	if (UnitState == none)
		return;

	// dead units should not be reported, nor civilians
	if( !UnitState.IsAlive() )
	{
		return;
	}

	if( !UnitState.IsCivilian() )
	{
		class'X2StatusEffects'.static.AddEffectCameraPanToAffectedUnitToTrack(BuildTrack, VisualizeGameState.GetContext());
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(BuildTrack, VisualizeGameState.GetContext(), EffectFriendlyName, 'PanickedBreathing', eColor_Bad, class'UIUtilities_Image'.const.UnitStatus_Panicked);
	}

	class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}

simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationActionMetadata BuildTrack, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(BuildTrack.StateObject_NewState);
	if (UnitState == none)
		return;

	// dead units should not be reported. Also, rescued civilians should not display the fly-over.
	if( !UnitState.IsAlive() || UnitState.bRemovedFromPlay )
	{
		return;
	}

	class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(BuildTrack, VisualizeGameState.GetContext(), EffectLostFriendlyName, '', eColor_Good, class'UIUtilities_Image'.const.UnitStatus_Panicked, 2.0f);
	class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}
