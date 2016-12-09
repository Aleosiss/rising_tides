// This is an Unreal Script

class RTGameState_Effect extends XComGameState_Effect;

protected function ActivateAbility(XComGameState_Ability AbilityState, StateObjectReference TargetRef) {
	local XComGameStateContext_Ability AbilityContext;
	
	AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(AbilityState, TargetRef.ObjectID);
	
	if( AbilityContext.Validate() ) {
		`TACTICALRULES.SubmitGameStateContext(AbilityContext);
	} else {
		`LOG("Rising Tides: Couldn't validate AbilityContext, " @ AbilityState.GetMyTemplateName() @ " not activated.");
	}
}



protected function InitializeAbilityForActivation(out XComGameState_Ability AbilityState, XComGameState_Unit AbilityOwnerUnit, Name AbilityName, XComGameStateHistory History) {
	local StateObjectReference AbilityRef;

	AbilityRef = AbilityOwnerUnit.FindAbility(AbilityName);
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));
	if(AbilityState == none) {
		`LOG("Rising Tides: Couldn't initialize ability for activation!");
	}

}