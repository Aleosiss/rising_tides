// This is an Unreal Script

class RTAbilityTemplate extends X2AbilityTemplate;

function XComGameState_Ability CreateInstanceFromTemplate(XComGameState NewGameState)
{
	local RTGameState_Ability Ability;

	Ability = RTGameState_Ability(NewGameState.CreateStateObject(class'RTGameState_Ability'));
	Ability.OnCreation(self);

	return Ability;
}
