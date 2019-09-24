class SeqAct_TemplarBetrayalReaction extends SequenceAction;

var() ETeam DestinationTeam;
var protected SeqVar_GameStateList List; 

event Activated()
{
	local array<StateObjectReference>	UnitRefs;
	local XComGameStateHistory			History;
	local StateObjectReference			UnitRef;
	local XComGameState_Unit			UnitState;

	History = `XCOMHISTORY;

	UnitRefs = GetXComSquad();
	foreach UnitRefs(UnitRef) {
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));
		if(UnitState != none) {
			if(UnitState.GetMyTemplateName() == 'TemplarSoldier') {
				`BATTLE.SwapTeams(UnitState, DestinationTeam);
			}
		}
	}
	
	OutputLinks[0].bHasImpulse = true;
}


protected function array<StateObjectReference> GetXComSquad() {
	`RTLOG("GetXComSquad");

	List = none;
	foreach LinkedVariables(class'SeqVar_GameStateList', List, "Game State List") {
		break;
	}

	if(List == none) {
		`RTLOG("No SeqVar_GameStateList attached to " $ string(name), true, false);
	}

	return List.GameStates;
}

static event int GetObjClassVersion()
{
	return super.GetObjClassVersion() + 1;
}

defaultproperties
{
	ObjCategory="RisingTides"
	ObjName="Templar Betryal Reaction"
	bCallHandler = false
	DestinationTeam = eTeam_Alien

	bConvertedForReplaySystem=true
	bCanBeUsedForGameplaySequence=true

	bAutoActivateOutputLinks = true
	OutputLinks(0)=(LinkDesc="Out")

	VariableLinks(0)=(ExpectedType=class'SeqVar_GameStateList',LinkDesc="Game State List",bWriteable=true,MinVars=1,MaxVars=1)
}