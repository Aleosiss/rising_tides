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
	Cards.AddItem(RTCreateDirectNeuralManipulation());
	Cards.AddItem(RTCreateResistanceSabotage());

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
	local DynamicPropertySet PropertySet; //need to delay it when the player can see it

	Program = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	Program.MakeOneSmallFavorAvailable();
	Program.bShouldResetOSFMonthly = true;
}

static function DeactivateOneSmallFavor(XComGameState NewGameState, StateObjectReference InRef) {
	local RTGameState_ProgramFaction Program;

	Program = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	Program.bOneSmallFavorAvailable = false;
	Program.bShouldResetOSFMonthly = false;
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
	local XComGameState_Unit CopyUnitState, OriginalUnitState;
	local name CharTemplateName;
	local X2CharacterTemplate Template;
	local XComGameState_Player PlayerState;

	if (IsSplitMission( StartState ))
		return;

	Program = class'RTHelpers'.static.GetNewProgramState(StartState);
	Program.bShouldPerformPostMissionCleanup = true;
	SoldierObjRef = Program.Master[`SYNC_RAND_STATIC(Program.Master.Length)];
	
	if(default.JustPassingThroughChance * (int(Program.Influence) + 1) < `SYNC_RAND_STATIC(100) /*|| true*/ ) //TODO: Refactor to include an Operative-based modifer (location + personality)
		return;

	foreach StartState.IterateByClassType( class'XComGameState_HeadquartersXCom', XComHQ )
		break;
	if( XComHQ == none ) {
		`LOG("Couldn't find the HQ boss");
		return;
	}
	MissionState = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(XComHQ.MissionRef.ObjectID));
	if(class'RTHelpers'.static.IsInvalidMission(MissionState.GetMissionSource())) {
		//class'RTHelpers'.static.RTLog("Invalid Mission Type for JPT!");
		return;
	}

	if(XComHQ.TacticalGameplayTags.Find( 'NoVolunteerArmy' ) != INDEX_NONE) {
		//class'RTHelpers'.static.RTLog("JPT: No Volunteer Army allowed!");
		return;
	}

	if(XComHQ.TacticalGameplayTags.Find( 'RTOneSmallFavor' ) != INDEX_NONE) {
		//class'RTHelpers'.static.RTLog("JPT: One Small Favor already active!");
		return;
	}

	//class'RTHelpers'.static.RTLog("All checks passed, adding a operative to the XCOM squad!");
	OriginalUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(SoldierObjRef.ObjectID));
	CharTemplateName = OriginalUnitState.GetMyTemplateName();

	Template = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate( CharTemplateName );

	CopyUnitState = Program.CreateRTOperative(CharTemplateName, StartState);
	CopyUnitState.bMissionProvided = true;

	// assign to player
	foreach StartState.IterateByClassType(class'XComGameState_Player', PlayerState)
	{
		if(PlayerState.GetTeam() == eTeam_XCom)
		{
			CopyUnitState.SetControllingPlayer(PlayerState.GetReference());
			break;
		}
	}
	CopyUnitState.SetSoldierProgression(OriginalUnitState.m_SoldierProgressionAbilties);
	//class'RTHelpers'.static.RTLog("Successfully built a copy of an operative!");


	XComHQ.Squad.AddItem(CopyUnitState.GetReference());
	XComHQ.AllSquads[0].SquadMembers.AddItem(CopyUnitState.GetReference());
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
	local XComGameState_WorldRegion RegionState;
	local Object Obj;

	Program = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	Obj = Program;

	class'RTHelpers'.static.RTLog("Activating Forty Years of War!");
	`XEVENTMGR.RegisterForEvent(Obj, 'RegionOutpostBuildStart', Program.FortyYearsOfWarEventListener, ELD_Immediate);

	// Build outposts in any regions which are currently being scanned
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
		if (RegionState.bCanScanForOutpost)
		{
			RegionState = XComGameState_WorldRegion(NewGameState.ModifyStateObject(class'XComGameState_WorldRegion', RegionState.ObjectID));
			RegionState.SetResistanceLevel(NewGameState, eResLevel_Outpost);
			RegionState.bResLevelPopup = true;
			RegionState.bCanScanForOutpost = false;
		}
	}
}

static function DeactivateFortyYearsOfWar(XComGameState NewGameState, StateObjectReference InRef) {
	local RTGameState_ProgramFaction Program;
	local Object Obj;

	Program = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	Obj = Program;
	class'RTHelpers'.static.RTLog("Deactivating Forty Years of War!");
	`XEVENTMGR.UnRegisterFromEvent(Obj, 'AvengerLandedScanRegion');
	`XEVENTMGR.UnRegisterFromEvent(Obj, 'RegionOutpostBuildStart');
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

static function X2DataTemplate RTCreateResistanceSabotage()
{
	local RTProgramStrategyCardTemplate Template;

	`CREATE_X2TEMPLATE(class'RTProgramStrategyCardTemplate', Template, 'ResCard_RTResistanceSabotage');
	Template.Category = "ResistanceCard";

	Template.OnActivatedFn = ActivateResistanceSabotage;
	Template.OnDeactivatedFn = DeactivateResistanceSabotage;

	return Template;
}

static function ActivateResistanceSabotage(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false) {
	local XComGameStateHistory History;
	local XComGameState_ResistanceFaction IteratorFactionState, NewFactionState;
	local RTGameState_ProgramFaction ProgramState;

	//class'RTHelpers'.static.RTLog("Activating Resistance Sabotage!");
	History = `XCOMHISTORY;
	ProgramState = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	if(ProgramState.bResistanceSabotageActivated) {
		//class'RTHelpers'.static.RTLog("Oops, it's already activated. Aborting.");
		return;
	} else {
		ProgramState.bResistanceSabotageActivated = true;
	}

	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', IteratorFactionState) {
		if(IteratorFactionState.ObjectID == ProgramState.ObjectID) {
			continue;
		}

		NewFactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', IteratorFactionState.ObjectID));
		NewFactionState.AddCardSlot();
	}
}

static function DeactivateResistanceSabotage(XComGameState NewGameState, StateObjectReference InRef) {
	local XComGameStateHistory History;
	local XComGameState_ResistanceFaction IteratorFactionState, NewFactionState;
	local RTGameState_ProgramFaction ProgramState;
	local StateObjectReference CardRef, EmptyRef; 
	local bool bFoundEmptySlot;

	//class'RTHelpers'.static.RTLog("Deactivating Resistance Sabotage!");
	History = `XCOMHISTORY;
	ProgramState = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	if(!ProgramState.bResistanceSabotageActivated) {
		//class'RTHelpers'.static.RTLog("Wait, it's not activated. Aborting.");
		return;
	} else {
		ProgramState.bResistanceSabotageActivated = false;
	}

	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', IteratorFactionState) {
		if(IteratorFactionState.ObjectID == ProgramState.ObjectID) {
			continue;
		}

		foreach IteratorFactionState.CardSlots(CardRef) {
			if(CardRef.ObjectID == 0) {
				// found an empty slot, can remove
				bFoundEmptySlot = true;
				break;
			}
		}

		NewFactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', IteratorFactionState.ObjectID));
		if(bFoundEmptySlot) {
			// remove the empty slot
			NewFactionState.CardSlots.RemoveItem(EmptyRef);
		} else {
			// remove the last slot
			CardRef = IteratorFactionState.CardSlots[IteratorFactionState.CardSlots.Length - 1];
			NewFactionState.PlayableCards.AddItem(CardRef);
			NewFactionState.CardSlots.RemoveItem(CardRef);
		}
		
	}
}