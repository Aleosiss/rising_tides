class RTGameState_MissionSiteAvengerAssault extends XComGameState_MissionSite config(ProgramFaction);

function bool RequiresAvenger() {
	// this mission is not executed by XCOM
	return false;
}

function SelectSquad() {
    // squad is prepared by the Program XCGS
}

function StartMission() {
	local XGStrategy StrategyGame;

	BeginInteraction();

	StrategyGame = `GAME;
	StrategyGame.PrepareTacticalBattle(ObjectID);
	ConfirmMission(); // Transfer directly to the mission, no squad select. Squad is set up based on the covert action soldiers.
}