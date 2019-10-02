// This is an Unreal Script

class RTAbilityTemplate extends X2AbilityTemplate;

// RTTargetingMethod_AimedLineSkillshot
var int LineLengthTiles; // if greater than 0, the line with have this length instead of the default
var bool bOriginateAtTargetLocation; // if set, the line will originate from the target instead of the shooter

defaultproperties
{
	LineLengthTiles = 0;
	bOriginateAtTargetLocation = false;
}

function XComGameState_Ability CreateInstanceFromTemplate(XComGameState NewGameState)
{
	local RTGameState_Ability Ability;

	Ability = RTGameState_Ability(NewGameState.CreateStateObject(class'RTGameState_Ability'));
	Ability.OnCreation(self);

	return Ability;
}
