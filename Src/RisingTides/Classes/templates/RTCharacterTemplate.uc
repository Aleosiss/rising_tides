class RTCharacterTemplate extends X2CharacterTemplate;

var bool ReceivesProgramRankups; // if set, will be promoted at the end of OSF missions

defaultproperties
{
	ReceivesProgramRankups=false
}

function XComGameState_Unit CreateInstanceFromTemplate(XComGameState NewGameState)
{
	local RTGameState_Unit Unit;

	Unit = RTGameState_Unit(NewGameState.CreateNewStateObject(class'RTGameState_Unit', self));

	return Unit;
}