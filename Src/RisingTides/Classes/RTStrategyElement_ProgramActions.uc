// This is an Unreal Script
class RTStrategyElement_ProgramActions extends X2StrategyElement config(ProgramFaction);

var config float JustPassingThroughChance;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Cards;

	Cards.AddItem(RTCreateOneSmallFavorTemplate());
	Cards.AddItem(RTCreateJustPassingThrough());

	return Cards;

}

static function X2DataTemplate RTCreateOneSmallFavorTemplate()
{
	local X2StrategyCardTemplate Template;

	`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'RTResCard_OneSmallFavor');
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
	local X2StrategyCardTemplate Template;

	`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'RTResCard_JustPassingThrough');
	Template.Category = "ResistanceCard";
	Template.ModifyTacticalStartStateFn = ActivateJustPassingThrough;
}

static function ActivateJustPassingThrough(XComGameState StartState) {
	local RTGameState_ProgramFaction Program;
	local XComGameState_HeadquartersXCom XComHQ;
	local StateObjectReference SoldierObjRef;

	if (IsSplitMission( StartState ))
		return;

	Program = class'RTHelpers'.static.GetNewProgramState(StartState);
	if(default.JustPassingThroughChance * Program.InfluenceScore < `SYNC_RAND_STATIC(100)) //TODO: Refactor to include an Operative-based modifer (location + personality)
		return;

	foreach StartState.IterateByClassType( class'XComGameState_HeadquartersXCom', XComHQ )
		break;
	if( XComHQ == none ) {
		`LOG("Couldn't find the HQ boss");
		return;
	}

	if(XComHQ.TacticalGameplayTags.Find( 'NoVolunteerArmy' ) != INDEX_NONE)
		return;

	if(XComHQ.TacticalGameplayTags.Find( 'NoRisingTides' ) != INDEX_NONE)
		return;

	SoldierObjRef = Program.Master[`SYNC_RAND_STATIC(Program.Master.Length)].StateObjectRef;

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
