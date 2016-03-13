///---------------------------------------------------------------------------------------
//  FILE:    RTEffect_SlowIsSmooth.uc
//  AUTHOR:  Aleosiss
//  DATE:    11 March 2016
//  PURPOSE: Count the number of turns until Whisper can reenter concealment (and enter it). 
//           
//---------------------------------------------------------------------------------------
//	Slow Is Smooth effect
//---------------------------------------------------------------------------------------
class RTEffect_SlowIsSmooth extends X2Effect_Persistent;

// Copied straight from RangerStealth
simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit UnitState;

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
	
	UnitState = XComGameState_Unit(kNewTargetState);
	UnitState.SetUnitFloatValue('SISCounter', 0, eCleanup_Never);
	if (UnitState != none)
		`XEVENTMGR.TriggerEvent('EffectEnterUnitConcealment', UnitState, UnitState, NewGameState);
}

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
	local XComGameState_Unit			EffectTargetUnit;
	local UnitValue						Count;
	local array<StateObjectReference>	VisibleUnits;
	
	EffectTargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if(!EffectTargetUnit.GetUnitValue('SISCounter', Count))		   // If there somehow is no SISCounter, make one
		EffectTargetUnit.SetUnitFloatValue('SISCounter', 0, eCleanup_Never);
	if(!EffectTargetUnit.IsConcealed())
	{
		class'X2TacticalVisibilityHelpers'.static.GetEnemyViewersOfTarget(EffectTargetUnit.ObjectID, VisibleUnits);
		if(VisibleUnits.Length < 1)								   // Don't tick if enemies have LOS
		{
			EffectTargetUnit.GetUnitValue('SISCounter', Count);
			EffectTargetUnit.SetUnitFloatValue('SISCounter', (Count.fValue + 1), eCleanup_Never);
			if(Count.fValue > 3)								   // Four turns of this and we reenter concealment
			{
				OnEffectAdded(ApplyEffectParameters, EffectTargetUnit, NewGameState, kNewEffectState);	
			}
		}
		else
		{
		   EffectTargetUnit.SetUnitFloatValue('SISCounter', 0, eCleanup_Never);
		}
	}
	return super.OnEffectTicked(ApplyEffectParameters, kNewEffectState, NewGameState, FirstApplication);
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "SlowIsSmoothEffect"
	
}