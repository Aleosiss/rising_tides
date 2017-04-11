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

var name StealthPreviousUnitValName;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit UnitState, NewUnitState;
	local bool bWasPreviouslyConcealed;
	local float fCurrentModifier, fFinalModifier;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	fCurrentModifier = UnitState.GetCurrentStat(eStat_DetectionModifier);
	fFinalModifier = fStealthModifier - fCurrentModifier; // newcurrentstat = currentstat + finalmodifier

	m_aStatChanges.Length = 0;
	AddPersistentStatChange(eStat_DetectionModifier, fFinalModifier);
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);


	bWasPreviouslyConcealed = UnitState.IsConcealed();
	if(bWasPreviouslyConcealed) {
		UnitState.SetUnitFloatValue(StealthPreviousUnitValName, 1, eCleanUp_BeginTactical);
	} else {
		UnitState.SetUnitFloatValue(StealthPreviousUnitValName, 0, eCleanUp_BeginTactical);
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
	local XComGameState_Unit OldUnitState, NewUnitState;
	local bool bWasPreviouslyConcealed;
	local UnitValue PreviousValue;

	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);

	OldUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	OldUnitState.GetUnitValue(StealthPreviousUnitValName, PreviousValue);
	if(PreviousValue.fValue == 1) {
		bWasPreviouslyConcealed = true;
	} else {
		bWasPreviouslyConcealed = false;
	}

	NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', OldUnitState.ObjectID));
	NewUnitState.SetUnitFloatValue(StealthPreviousUnitValName, 0, eCleanUp_BeginTactical);

	// Stealth can wear off naturally and not break concealment
	if (NewUnitState != none && !bWasPreviouslyConcealed && OldUnitState.IsConcealed()) {
		`XEVENTMGR.TriggerEvent('EffectBreakUnitConcealment', NewUnitState, NewUnitState, NewGameState);
	}

	NewGameState.AddStateObject(NewUnitState);

}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, name EffectApplyResult)
{
	local XComGameStateHistory			History;
	local XComGameStateContext_Ability	Context;
	local StateObjectReference			InteractingUnitRef;
	local XComGameState_Unit			UnitState;
	local XGUnit						UnitActor;
	local XComUnitPawn					UnitPawn;
	local MaterialInstanceTimeVarying	MITV;

	local RTAction_ApplyMITV	MITVAction;

	super.AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, EffectApplyResult);

	MITVAction = RTAction_ApplyMITV(class'RTAction_ApplyMITV'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
	MITVAction.MITVPath = "FX_Wraith_Armor.M_Wraith_Armor_Overlay_On_MITV";

	/*
	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	MITV = MaterialInstanceTimeVarying(DynamicLoadObject("FX_Wraith_Armor.M_Wraith_Armor_Overlay_On_MITV", class'MaterialInstanceTimeVarying'));
	//MITV.SetScalarParameterValue('Ghost',1);

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(InteractingUnitRef.ObjectID));
	UnitActor = XGUnit(UnitState.GetVisualizer());
	UnitPawn = UnitActor.GetPawn();
	UnitPawn.ApplyMITV(MITV);
	*/
}

simulated function AddX2ActionsForVisualization_Sync(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack)
{
	AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, 'AA_Success');
}


simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
	local XComGameState_Unit		UnitState;
	local XComGameState_Effect		SilentMeleeEffect, EffectState;
	local X2Action_StartStopSound	SoundAction;

	local RTAction_RemoveMITV		MITVAction;
	local X2Action_Delay			DelayAction;

	MITVAction = RTAction_RemoveMITV(class'RTAction_RemoveMITV'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
	super.AddX2ActionsForVisualization_Removed(VisualizeGameState, BuildTrack, EffectApplyResult, RemovedEffect);

	DelayAction = X2Action_Delay(class'X2Action_Delay'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
	DelayAction.Duration = 0.33f;
	DelayAction.bIgnoreZipMode = true;


	/*
	if (EffectApplyResult != 'AA_Success' || BuildTrack.TrackActor == none)
	{
		return;
	}

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Effect', EffectState)
	{
		if (EffectState.GetX2Effect() == self)
		{
			SilentMeleeEffect = EffectState;
			break;
		}
	}
	`assert(SilentMeleeEffect != none);

	SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
	SoundAction.Sound = new class'SoundCue';
	SoundAction.Sound.AkEventOverride = AkEvent'SoundX2CharacterFX.MimicBeaconDeactivate';
	SoundAction.iAssociatedGameStateObjectId = SilentMeleeEffect.ObjectID;
	SoundAction.bStartPersistentSound = true;
	SoundAction.bIsPositional = false;
	SoundAction.vWorldPosition = SilentMeleeEffect.ApplyEffectParameters.AbilityInputContext.TargetLocations[0];

	UnitState = XComGameState_Unit(BuildTrack.StateObject_OldState);
	CleanUpMITV(UnitState);
	*/

}
/*
static function CleanUpMITV(XComGameState_Unit UnitState)
{
	local XGUnit					UnitActor;
	local XComUnitPawn				UnitPawn;
	local MeshComponent MeshComp;
	local int i;

	if((UnitState != none) && UnitState.IsAlive())
	{
		UnitActor = XGUnit(UnitState.GetVisualizer());
		UnitPawn = UnitActor.GetPawn();

		foreach UnitPawn.AllOwnedComponents(class'MeshComponent', MeshComp)
		{
			for (i = 0; i < MeshComp.Materials.Length; i++)
			{
				if (MeshComp.GetMaterial(i).IsA('MaterialInstanceTimeVarying'))
				{
					MeshComp.SetMaterial(i, none);
				}
			}
		}

		UnitPawn.UpdateAllMeshMaterials();
	}
}
*/



DefaultProperties
{
	EffectName = "RTStealth"
	fStealthModifier=0.9f
	DuplicateResponse = eDupe_Refresh
	bStackOnRefresh = true
	bRemoveWhenTargetConcealmentBroken = true
	StealthPreviousUnitValName= "UnitPreviouslyConcealed"


}
