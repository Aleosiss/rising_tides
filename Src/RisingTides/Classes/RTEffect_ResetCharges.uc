class RTEffect_ResetCharges extends X2Effect;

var name AbilityToReset;
var int BaseCharges;		    

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Ability AbilityState, SourceAbilityState;
	local StateObjectReference AbilityRef;
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability AbilityContext;
	local X2AbilityTemplate AbilityTemplate;

	UnitState = XComGameState_Unit(kNewTargetState);
	`assert(UnitState != none);
	AbilityRef = UnitState.FindAbility(AbilityToReset);
	if (AbilityRef.ObjectID == 0)
	{
		`RedScreen("RTEffect_ResetChargesEffect wanted to find ability '" $ AbilityToReset $ "' but the unit doesn't have it." @ UnitState.ToString());
		return;
	}
		AbilityState = XComGameState_Ability(NewGameState.GetGameStateForObjectID(AbilityRef.ObjectID));
	if (AbilityState == none)
	{
		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityRef.ObjectID));
		if (AbilityState == none)
		{
			`RedScreen("Ability reference found for" @ AbilityToReset @ "Object ID" @ AbilityRef.ObjectID @ "but could not find the state object!" @ UnitState.ToString());
			return;
		}
		AbilityState = XComGameState_Ability(NewGameState.CreateStateObject(AbilityState.Class, AbilityState.ObjectID));
		NewGameState.AddStateObject(AbilityState);
	}

	AbilityState.iCharges = BaseCharges;
}