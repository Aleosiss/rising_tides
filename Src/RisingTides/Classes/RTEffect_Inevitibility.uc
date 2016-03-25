// This is an Unreal Script

class RTEffect_Inevitibility extends X2Effect_Persistent config(RTMarksman);

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit UnitState;

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
	
	UnitState = XComGameState_Unit(kNewTargetState);
	UnitState.SetUnitFloatValue('RTICounter', 0, eCleanup_Never);
	
}