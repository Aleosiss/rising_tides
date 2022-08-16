class RTEffect_OverTheShoulder extends X2Effect_Persistent;

var privatewrite name OverTheShoulderAppliedEventName;
var EMatPriority overlayMaterialPriority;
var string overlayMaterialPath;
var name overlayMaterialName;

function EffectAddedCallback(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
{
	local X2EventManager EventMan;
	local XComGameState_Unit UnitState;

	EventMan = `XEVENTMGR;
	UnitState = XComGameState_Unit(kNewTargetState);
	if (UnitState != none)
	{
		UnitState.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.UnburrowActionPoint);      //  will be useless for units without unburrow, just add it blindly

		EventMan.TriggerEvent(default.OverTheShoulderAppliedEventName, kNewTargetState, kNewTargetState, NewGameState);
	}
}

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);

	//Effects that change visibility must actively indicate it
	kNewTargetState.bRequiresVisibilityUpdate = true;
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_Unit Unit;

	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);

	//Effects that change visibility must actively indicate it
	Unit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	Unit.bRequiresVisibilityUpdate = true;
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata BuildTrack, name EffectApplyResult)
{
	local X2Action_ForceUnitVisiblity ForceVisiblityAction;
	local RTAction_ApplyMITV ApplyMITVAction;

	super.AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, EffectApplyResult);

	ForceVisiblityAction = X2Action_ForceUnitVisiblity(class'X2Action_ForceUnitVisiblity'.static.AddToVisualizationTree(BuildTrack, VisualizeGameState.GetContext()));
	ForceVisiblityAction.ForcedVisible = eForceVisible;

	ApplyMITVAction = RTAction_ApplyMITV(class'RTAction_ApplyMITV'.static.AddToVisualizationTree(BuildTrack, VisualizeGameState.GetContext()));
	ApplyMITVAction.MITVPath = overlayMaterialPath;
	ApplyMITVAction.MITVName = overlayMaterialName;
	ApplyMITVAction.eMaterialType = eMatType_MIC;
	ApplyMITVAction.eMaterialPriority = overlayMaterialPriority;
}

protected function OnAddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationActionMetadata BuildTrack, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
	local X2Action_ForceUnitVisiblity ForceVisiblityAction;
	local XComGameState_Unit TestUnit;
	local RTAction_RemoveMITV RemoveMITVAction;

	TestUnit = XComGameState_Unit(BuildTrack.StateObject_NewState);
	if( !(TestUnit.bRemovedFromPlay) )
	{

		super.AddX2ActionsForVisualization_Removed(VisualizeGameState, BuildTrack, EffectApplyResult, RemovedEffect);

		ForceVisiblityAction = X2Action_ForceUnitVisiblity(class'X2Action_ForceUnitVisiblity'.static.AddToVisualizationTree(BuildTrack, VisualizeGameState.GetContext()));
		ForceVisiblityAction.ForcedVisible = eForceNone;
		ForceVisiblityAction.bMatchToGameStateLoc = true;

		RemoveMITVAction = RTAction_RemoveMITV(class'RTAction_RemoveMITV'.static.AddToVisualizationTree(BuildTrack, VisualizeGameState.GetContext()));
		RemoveMITVAction.eMaterialPriority = overlayMaterialPriority;
		RemoveMITVAction.eMaterialType = eMatType_MIC;
		RemoveMITVAction.MITVName = overlayMaterialName;
	}
}
	
simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationActionMetadata BuildTrack, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
	OnAddX2ActionsForVisualization_Removed(VisualizeGameState, BuildTrack, EffectApplyResult, RemovedEffect);
}

simulated function AddX2ActionsForVisualization_Sync(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata)
{
	local X2Action_ForceUnitVisiblity ForceVisiblityAction;

	ForceVisiblityAction = X2Action_ForceUnitVisiblity(class'X2Action_ForceUnitVisiblity'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext()));
	ForceVisiblityAction.ForcedVisible = eForceVisible;
}

DefaultProperties
{
	EffectName = "OverTheShoulder"
	DuplicateResponse = eDupe_Ignore
	EffectAddedFn = EffectAddedCallback
	OverTheShoulderAppliedEventName = "OverTheShoulderApplied"
	overlayMaterialPath = "RisingTidesContentPackage.Materials"
	overlayMaterialName = "Gatherer_OverTheShoulder_TargetDefinition"
	//overlayMaterialPriority = eMatPriority_TargetDefinition
	overlayMaterialPriority = eMatPriority_AnimNotify
}