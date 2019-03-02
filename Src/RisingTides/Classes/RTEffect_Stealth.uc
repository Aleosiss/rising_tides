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
	//local bool bWasPreviouslyConcealed;
	local float fCurrentModifier, fFinalModifier;
	local RTGameState_Effect StealthEffectState;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	fCurrentModifier = UnitState.GetCurrentStat(eStat_DetectionModifier);
	fFinalModifier = fStealthModifier - fCurrentModifier; // newcurrentstat = currentstat + finalmodifier

	m_aStatChanges.Length = 0;
	AddPersistentStatChange(eStat_DetectionModifier, fFinalModifier);
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);

	StealthEffectState = RTGameState_Effect(NewEffectState);
	if(StealthEffectState == none) {
		class'RTHelpers'.static.RTLog("Couldn't find RTGameState_Effect for RTEffect_Stealth!", true);
	}

	StealthEffectState.bWasPreviouslyConcealed = UnitState.IsConcealed();

	if (UnitState != none && !StealthEffectState.bWasPreviouslyConcealed) {
		// special stealth-only notification for abilities that trigger on stealth gain.
		// in this block so that we don't have Persisting Images procing when ghosting
		`XEVENTMGR.TriggerEvent('UnitEnteredRTSTealth', UnitState, UnitState, NewGameState);
		`XEVENTMGR.TriggerEvent('EffectEnterUnitConcealment', UnitState, UnitState, NewGameState);
	}

}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_Unit OldUnitState, NewUnitState;
	//local bool bWasPreviouslyConcealed;
	//local UnitValue PreviousValue;
	local RTGameState_Effect StealthEffectState;

	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);

	OldUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	StealthEffectState = RTGameState_Effect(RemovedEffectState);
	if(StealthEffectState == none) {
		class'RTHelpers'.static.RTLog("Couldn't find RTGameState_Effect for RTEffect_Stealth!", true);
	}

	NewUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', OldUnitState.ObjectID));

	// Stealth can wear off naturally and not break concealment
	if (NewUnitState != none && !StealthEffectState.bWasPreviouslyConcealed && OldUnitState.IsConcealed()) {
		`XEVENTMGR.TriggerEvent('EffectBreakUnitConcealment', NewUnitState, NewUnitState, NewGameState);
	}
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, name EffectApplyResult)
{
	local RTAction_ApplyMITV	MITVAction;

	super.AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, EffectApplyResult);

	MITVAction = RTAction_ApplyMITV(class'RTAction_ApplyMITV'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
	MITVAction.MITVPath = "FX_Wraith_Armor.M_Wraith_Armor_Overlay_On_MITV";
}

simulated function AddX2ActionsForVisualization_Sync(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata)
{
	AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, 'AA_Success');
}


simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
	local X2Action_Delay			DelayAction;

	class'RTAction_RemoveMITV'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded);
	
	super.AddX2ActionsForVisualization_Removed(VisualizeGameState, ActionMetadata, EffectApplyResult, RemovedEffect);

	DelayAction = X2Action_Delay(class'X2Action_Delay'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
	DelayAction.Duration = 0.33f;
	DelayAction.bIgnoreZipMode = true;

}

DefaultProperties
{
	EffectName = "RTStealth"
	fStealthModifier=0.9f
	DuplicateResponse = eDupe_Refresh
	bStackOnRefresh = true
	bRemoveWhenTargetConcealmentBroken = true
	GameStateEffectClass = class'RTGameState_Effect'
}
