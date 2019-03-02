class RTGameState_MissionSiteTemplarAmbush extends XComGameState_MissionSite;

var() StateObjectReference CovertActionRef;

function bool RequiresAvenger()
{
	// Templar Ambush does not require the Avenger at the mission site
	return false;
}

function SelectSquad()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_CovertAction ActionState;
	local XComGameState_StaffSlot SlotState;
	local array<StateObjectReference> MissionSoldiers;
	local int idx, NumSoldiers;
	local RTGameState_ProgramFaction ProgramState;
	
	/* TODO: Modify SelectSquad with the following parameters:
		1. Add civilians to the squad
		2. Add Kaga to the squad
	*/
	

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	ActionState = XComGameState_CovertAction(History.GetGameStateForObjectID(CovertActionRef.ObjectID));

	NumSoldiers = class'X2StrategyGameRulesetDataStructures'.static.GetMaxSoldiersAllowedOnMission(self);

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Set up Ambush Squad");
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	
	for (idx = 0; idx < NumSoldiers; idx++)
	{
		if (idx < ActionState.StaffSlots.Length)
		{
			SlotState = ActionState.GetStaffSlot(idx);
			if (SlotState != none && /*SlotState.IsSoldierSlot() &&*/ SlotState.IsSlotFilled()) // we want the civilians too...
			{
				MissionSoldiers.AddItem(SlotState.GetAssignedStaffRef());
			}
		}
	}

	// Get Kaga
	ProgramState = class'RTHelpers'.static.GetProgramState(NewGameState);
	GeneratedMission.Mission.SpecialSoldiers.AddItem(ProgramState.GetOperative("Kaga").GetMyTemplateName());
	
	// Replace the squad with the soldiers who were on the Covert Action
	XComHQ.Squad = MissionSoldiers;
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

function StartMission()
{
	local XGStrategy StrategyGame;
	
	BeginInteraction();
	
	StrategyGame = `GAME;
	StrategyGame.PrepareTacticalBattle(ObjectID);
	ConfirmMission(); // Transfer directly to the mission, no squad select. Squad is set up based on the covert action soldiers.
}