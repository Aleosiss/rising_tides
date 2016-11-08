//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_Stealth.uc
//  AUTHOR:  Aleosiss
//	DATE:	 7/14/16
//  PURPOSE: True stealth ability, which is simply normal Ranger Stealth + 
//			 a DetectionModifier bump.
//           
//---------------------------------------------------------------------------------------
//  
//---------------------------------------------------------------------------------------
class RTEffect_Stealth extends X2Effect_PersistentStatChange;
	
var float fStealthModifier;


simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit UnitState;
	local bool bWasPreviouslyConcealed;

	AddPersistentStatChange(eStat_DetectionModifier, fStealthModifier);
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);

	UnitState = XComGameState_Unit(kNewTargetState);
	bWasPreviouslyConcealed = UnitState.IsConcealed();
	if(bWasPreviouslyConcealed) {
		UnitState.SetUnitFloatValue('UnitPreviouslyConcealed', 1, eCleanUp_BeginTactical);	
	} else {
		UnitState.SetUnitFloatValue('UnitPreviouslyConcealed', 0, eCleanUp_BeginTactical);
	}
	
	if (UnitState != none && !bWasPreviouslyConcealed) {
		// special stealth-only notification for abilities that trigger on stealth gain.
		// in this block so that we don't have Persisting Images procing when ghosting
		`XEVENTMGR.TriggerEvent('UnitEnteredRTSTealth', UnitState, UnitState, NewGameState);
		`XEVENTMGR.TriggerEvent('EffectEnterUnitConcealment', UnitState, UnitState, NewGameState);
		
		
	}
	
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_Unit UnitState;
	local bool bWasPreviouslyConcealed;
	local UnitValue PreviousValue;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	UnitState.GetUnitValue('UnitPreviouslyConcealed', PreviousValue);
	if(PreviousValue.fValue == 1) {
		bWasPreviouslyConcealed = true;
	} else {
		bWasPreviouslyConcealed = false;
	}
	UnitState.SetUnitFloatValue('UnitPreviouslyConcealed', 0, eCleanUp_BeginTactical);
	
	// Stealth can wear off naturally and not break concealment
	if (UnitState != none && !bWasPreviouslyConcealed && UnitState.IsConcealed())
	{
		`XEVENTMGR.TriggerEvent('EffectBreakUnitConcealment', UnitState, UnitState, NewGameState);
	}
	
	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);
}

DefaultProperties
{
	EffectName = "RTStealth"
	fStealthModifier=0.9f
	DuplicateResponse = eDupe_Refresh
	bStackOnRefresh = true
	bRemoveWhenTargetConcealmentBroken = true
}
