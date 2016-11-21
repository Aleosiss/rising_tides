// This is an Unreal Script

class RTAbilityTemplate extends X2AbilityTemplate;

function XComGameState_Ability CreateInstanceFromTemplate(XComGameState NewGameState)
{
	local RTGameState_AbilityMultiTarget Ability;	

	Ability = RTGameState_AbilityMultiTarget(NewGameState.CreateStateObject(class'RTGameState_AbilityMultiTarget'));
	Ability.OnCreation(self);

	return Ability;
}