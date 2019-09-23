class RTCharacterTemplate extends X2CharacterTemplate;

function XComGameState_Unit CreateInstanceFromTemplate(XComGameState NewGameState)
{
	local RTGameState_Unit Unit;

	Unit = RTGameState_Unit(NewGameState.CreateNewStateObject(class'RTGameState_Unit', self));

	return Unit;
}