class RTEffect_ModifyTemplarFocus extends X2Effect_ModifyTemplarFocus;

var bool bSkipFocusVisualization;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Effect_TemplarFocus FocusState;
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(kNewTargetState);
	FocusState = TargetUnit.GetTemplarFocusEffectState();
	if (FocusState != none)
	{
		FocusState = XComGameState_Effect_TemplarFocus(NewGameState.ModifyStateObject(FocusState.Class, FocusState.ObjectID));
		FocusState.SetFocusLevel(FocusState.FocusLevel + GetModifyFocusValue(), TargetUnit, NewGameState, bSkipFocusVisualization);		
	}
}