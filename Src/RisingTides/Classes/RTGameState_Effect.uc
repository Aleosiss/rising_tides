// This is an Unreal Script

class RTGameState_Effect extends XComGameState_Effect;

// Tactical Game Cleanup
function EventListenerReturn OnTacticalGameEnd(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local X2EventManager EventManager;
	local Object ListenerObj;
    local XComGameState NewGameState;
	
    //`LOG("Rising Tides: 'TacticalGameEnd' event listener delegate invoked.");
	
	EventManager = `XEVENTMGR;

	// Unregister our callbacks
	ListenerObj = self;
	
	EventManager.UnRegisterFromAllEvents(ListenerObj);
	
    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RTGameState_Effect states cleanup");
	NewGameState.RemoveStateObject(ObjectID);
	`GAMERULES.SubmitGameState(NewGameState);

	`LOG("RisingTides: RTGameState_Effect of type " @ self.class @" passive effect unregistered from events.");
	
	return ELR_NoInterrupt;
}


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
