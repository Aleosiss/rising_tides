// This is an Unreal Script
class RTStrategyElement_StrategyCards extends X2StrategyElement config(ProgramFaction);

var config int JustPassingThroughChance;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Cards;

	Cards.AddItem(RTCreateOneSmallFavor());
	Cards.AddItem(RTCreateJustPassingThrough());
	Cards.AddItem(RTCreateProfessionalsHaveStandards());
	Cards.AddItem(RTCreatePsionicJamming());
	Cards.AddItem(RTCreateFortyYearsOfWar());

	return Cards;
}

static function X2DataTemplate RTCreateOneSmallFavor()
{
	local RTProgramStrategyCardTemplate Template;

	`CREATE_X2TEMPLATE(class'RTProgramStrategyCardTemplate', Template, 'ResCard_RTOneSmallFavor');
	Template.Category = "ResistanceCard";
	Template.OnActivatedFn = ActivateOneSmallFavor;
	Template.OnDeactivatedFn = DeactivateOneSmallFavor;

	return Template;
}

static function ActivateOneSmallFavor(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false) {
	local RTGameState_ProgramFaction Program;

	Program = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	Program.bOneSmallFavorAvailable = true;
}

static function DeactivateOneSmallFavor(XComGameState NewGameState, StateObjectReference InRef) {
	local RTGameState_ProgramFaction Program;

	Program = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	Program.bOneSmallFavorAvailable = false;
}

static function X2DataTemplate RTCreateJustPassingThrough() {
	local RTProgramStrategyCardTemplate Template;

	`CREATE_X2TEMPLATE(class'RTProgramStrategyCardTemplate', Template, 'ResCard_RTJustPassingThrough');
	Template.Category = "ResistanceCard";
	Template.ModifyTacticalStartStateFn = JustPassingThroughModifyTacStartState;

	return Template;
}

static function JustPassingThroughModifyTacStartState(XComGameState StartState) {
	local RTGameState_ProgramFaction Program;
	local XComGameState_HeadquartersXCom XComHQ;
	local array<StateObjectReference> AvailableSoldiers;
	local StateObjectReference SoldierObjRef;
	local XComGameState_MissionSite MissionState;

	if (IsSplitMission( StartState ))
		return;

	Program = class'RTHelpers'.static.GetNewProgramState(StartState);
	SoldierObjRef = Program.Master[`SYNC_RAND_STATIC(Program.Master.Length)];
	
	if(!class'RTHelpers'.static.DebuggingEnabled()) {
		if(default.JustPassingThroughChance * Program.InfluenceScore < `SYNC_RAND_STATIC(100)) //TODO: Refactor to include an Operative-based modifer (location + personality)
			return;
	} else {
		class'RTHelpers'.static.RTLog("Activating Just Passing Through via Debug Override!");
	}

	foreach StartState.IterateByClassType( class'XComGameState_HeadquartersXCom', XComHQ )
		break;
	if( XComHQ == none ) {
		`LOG("Couldn't find the HQ boss");
		return;
	}
	MissionState = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(XComHQ.MissionRef.ObjectID));
	if(!class'RTHelpers'.static.CheckIsInvalidMission(MissionState.GetMissionSource()))
		return;

	if(XComHQ.TacticalGameplayTags.Find( 'NoVolunteerArmy' ) != INDEX_NONE)
		return;

	if(XComHQ.TacticalGameplayTags.Find( 'RTOneSmallFavor' ) != INDEX_NONE)
		return;

	XComHQ.Squad.AddItem(SoldierObjRef);
	XComHQ.AllSquads[0].SquadMembers.AddItem(SoldierObjRef);
}

static function bool IsSplitMission( XComGameState StartState )
{
	local XComGameState_BattleData BattleData;

	foreach StartState.IterateByClassType( class'XComGameState_BattleData', BattleData )
		break;

	return (BattleData != none) && BattleData.DirectTransferInfo.IsDirectMissionTransfer;
}

static function X2DataTemplate RTCreateProfessionalsHaveStandards()
{
	local RTProgramStrategyCardTemplate Template;

	`CREATE_X2TEMPLATE(class'RTProgramStrategyCardTemplate', Template, 'ResCard_RTProfessionalsHaveStandards');
	Template.Category = "ResistanceCard";
	Template.GetAbilitiesToGrantFn = ProfessionalsHaveStandardsAbility;

	return Template;
}

static function ProfessionalsHaveStandardsAbility(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant) {
	if (UnitState.GetTeam() == eTeam_XCom && UnitState.GetSoldierClassTemplateName() != 'Reaper' /* Whisper's training would mess up a Reaper's 'mojo' */)	{
		AbilitiesToGrant.AddItem( 'RTProfessionalsHaveStandards' );
	}
}

static function X2DataTemplate RTCreatePsionicJamming()
{
	local RTProgramStrategyCardTemplate Template;

	`CREATE_X2TEMPLATE(class'RTProgramStrategyCardTemplate', Template, 'ResCard_RTPsionicJamming');
	Template.Category = "ResistanceCard";
	Template.GetAbilitiesToGrantFn = PsionicJammingAbility;

	return Template;
}

static function PsionicJammingAbility(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant) {
	if (UnitState.GetTeam() == eTeam_Alien)	{
		AbilitiesToGrant.AddItem( 'RTPsionicJamming' );
	}
}

static function X2DataTemplate RTCreateFortyYearsOfWar()
{
	local RTProgramStrategyCardTemplate Template;

	`CREATE_X2TEMPLATE(class'RTProgramStrategyCardTemplate', Template, 'ResCard_RTFortyYearsOfWar');
	Template.Category = "ResistanceCard";

	Template.OnActivatedFn = ActivateFortyYearsOfWar;
	Template.OnDeactivatedFn = DeactivateFortyYearsOfWar;

	return Template;
}

static function ActivateFortyYearsOfWar(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false) {
	local RTGameState_ProgramFaction Program;
	local Object Obj;

	Program = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	Obj = Program;

	class'RTHelpers'.static.RTLog("Activating Forty Years of War!");
	`XEVENTMGR.RegisterForEvent(Obj, 'AvengerLandedScanRegion', Program.FortyYearsOfWarEventListener, ELD_OnStateSubmitted);
}

static function DeactivateFortyYearsOfWar(XComGameState NewGameState, StateObjectReference InRef) {
	local RTGameState_ProgramFaction Program;
	local Object Obj;

	Program = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	Obj = Program;
	class'RTHelpers'.static.RTLog("Deactivating Forty Years of War!");
	`XEVENTMGR.UnRegisterFromEvent(Obj, 'AvengerLandedScanRegion');
}

static function X2DataTemplate RTCreateDirectNeuralManipulation()
{
	local RTProgramStrategyCardTemplate Template;

	`CREATE_X2TEMPLATE(class'RTProgramStrategyCardTemplate', Template, 'ResCard_RTDirectNeuralManipulation');
	Template.Category = "ResistanceCard";

	Template.OnActivatedFn = ActivateDirectNeuralManipulation;
	Template.OnDeactivatedFn = DeactivateDirectNeuralManipulation;

	return Template;
}

static function ActivateDirectNeuralManipulation(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false) {
	local RTGameState_ProgramFaction Program;

	Program = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	class'RTHelpers'.static.RTLog("Activating Direct Neural Manipulation!");
	Program.bDirectNeuralManipulation = true;

}

static function DeactivateDirectNeuralManipulation(XComGameState NewGameState, StateObjectReference InRef) {
	local RTGameState_ProgramFaction Program;

	Program = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	class'RTHelpers'.static.RTLog("Deactivating Direct Neural Manipulation!");
	Program.bDirectNeuralManipulation = false;


}