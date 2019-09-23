class RTEffect_RemoveValidActivationTiles extends X2Effect;

// the default effect always reset the marked tiles. psi storm requires the opposite of that.


var name AbilityToUnmark;		  

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Ability AbilityState;
	local StateObjectReference AbilityRef;
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability AbilityContext;
//	local TTile DebugTile;        //  used for debug visualization

	UnitState = XComGameState_Unit(kNewTargetState);
	`assert(UnitState != none);
	AbilityRef = UnitState.FindAbility(AbilityToUnmark);
	if (AbilityRef.ObjectID == 0)
	{
		`RedScreen("MarkValidActivationTiles wanted to find ability '" $ AbilityToUnmark $ "' but the unit doesn't have it." @ UnitState.ToString());
		return;
	}
	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());
	if (AbilityContext == none)
	{
		`RedScreen("MarkValidActiationTiles is only valid from an ability context." @ NewGameState.ToString());
		return;
	}
	AbilityState = XComGameState_Ability(NewGameState.GetGameStateForObjectID(AbilityRef.ObjectID));
	if (AbilityState == none)
	{
		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityRef.ObjectID));
		if (AbilityState == none)
		{
			`RedScreen("Ability reference found for" @ AbilityToUnmark @ "Object ID" @ AbilityRef.ObjectID @ "but could not find the state object!" @ UnitState.ToString());
			return;
		}
		AbilityState = XComGameState_Ability(NewGameState.CreateStateObject(AbilityState.Class, AbilityState.ObjectID));
		NewGameState.AddStateObject(AbilityState);
	}

	AbilityState.ValidActivationTiles.Length = 0;
}

defaultproperties
{

}