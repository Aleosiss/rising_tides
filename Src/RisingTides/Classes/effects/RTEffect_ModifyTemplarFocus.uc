class RTEffect_ModifyTemplarFocus extends X2Effect_ModifyTemplarFocus;

var bool bSkipFocusVisualizationInFOW;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Effect_TemplarFocus FocusState;
	local XComGameState_Unit TargetUnit;
	local bool bVisualizeFocusChange;

	TargetUnit = XComGameState_Unit(kNewTargetState);
	FocusState = TargetUnit.GetTemplarFocusEffectState();

	if(bSkipFocusVisualizationInFOW) {
		bVisualizeFocusChange = !class'RTCondition_VisibleToPlayer'.static.IsTargetVisibleToLocalPlayer(TargetUnit.GetReference());
		if(bVisualizeFocusChange) {
			`RTLOG("Unit is not visible to the player. Will NOT visualize focus change.");
		} else {
			`RTLOG("Unit is visible to the player. Will visualize focus change.");
		}
	}


	if (FocusState != none)
	{
		FocusState = XComGameState_Effect_TemplarFocus(NewGameState.ModifyStateObject(FocusState.Class, FocusState.ObjectID));
		FocusState.SetFocusLevel(FocusState.FocusLevel + GetModifyFocusValue(), TargetUnit, NewGameState, bVisualizeFocusChange);		
	}
}