class RTGameState_ProgramFaction extends XComGameState_ResistanceFaction config(ProgramFaction);

// a lot of the DeathRecordData code is from Xyl's Anatomist Perk. Thanks to him!

/* *********************************************************************** */

/* BEGIN KILL RECORD */

// each type of unit has an RTDeathRecord
// in this DeathRecord, there is an individual killcount array that lists all the units
// that have ever killed this one, and how many they'd defeated.
// the NumDeaths variable in the DeathRecord is the sum of all of the IndividualKillCounts.KillCount values.
// Additionally, whenever a critical hit is landed, it increments the NumCrits value.

// required methods:
// void UpdateDeathRecordData(name CharacterTemplateName, StateObjectReference UnitRef, bool bWasCrit)
// RTDeathRecord GetDeathRecord(name CharacterTemplateName)
// RTKillCount GetKillCount(StateObjectReference UnitRef, name CharacterTemplateName)

struct RTKillCount
{
	var StateObjectReference      UnitRef;				// The owner of this kill count
	var int                       KillCount;			// the number of kills
};

struct RTDeathRecord
{
	var name                      CharacterTemplateName;	// the type of unit that died
	var int                       NumDeaths;              	// number of times the unit has been killed by a friendly unit
	var int                       NumCrits;               	// number of times the unit has been critically hit
	var array<RTKillCount>        IndividualKillCounts;   	// per-unit kill counts ( worth more to VitalPointTargeting than other kills ); the sum of these should always equal NumDeaths
};

var() array<RTDeathRecord> DeathRecordData;					// Program Datavault contianing information on every kill made by deployed actor

/* END KILL RECORD   */

/* *********************************************************************** */

/* *********************************************************************** */

/* BEGIN OPERATIVE RECORD */

struct RTGhostOperative
{
	var name 						SoldierClassTemplateName;
	var name						CharacterTemplateName;
	var array<name>					WeaponUpgrades;

	var StateObjectReference 		StateObjectRef;

	var name						ExternalID;
	var localized string			FirstName;
	var localized string			NickName;
	var localized string			LastName;
	var localized string			preBackground;
	var localized string			finBackGround;
};

// SPECTRE
var localized string SquadOneName;
var localized string SquadOneBackground;
var config array<name> SquadOneMembers;
var config name SquadOneSitRepName;


struct Squad
{

};

var const config array<RTGhostOperative>	GhostTemplates;

var() array<RTGhostOperative>									Master; 			// master list of operatives
var() array<StateObjectReference> 								Active;				// ghosts active
var() RTGameState_PersistentGhostSquad							Deployed; 			// ghosts that will be on the next mission
var() array<StateObjectReference>								Captured;			// ghosts not available
var() array<StateObjectReference>								Squads;				// list of ghost teams (only one for now)
var() int 														iOperativeLevel;	// all ghosts get level ups after a mission, even if they weren't on it. lorewise, they're constantly running missions; the player only sees a fraction of them
var bool														bSetupComplete;		// if we should rebuild the ghost array from config

/* END OPERATIVE RECORD   */


// FACTION VARIABLES
var bool														bOneSmallFavorAvailable;	// can send squad on a mission, replacing XCOM
var bool														bOneSmallFavorActivated; 	// player has chosen to send squad on next mission
var bool														bTemplarsDestroyed;
var config array<name>											InvalidMissionNames; 		// list of mission types ineligible for Program support


/* *********************************************************************** */

// SetUpProgramFaction(XComGameState StartState)
 function SetUpProgramFaction(XComGameState StartState)
{
	InitListeners();
	if(!bSetupComplete) {
		CreateRTOperatives(StartState);
		CreateRTSquads(StartState);
		//Program.CreateRTDeathRecord(StartState);
		bSetupComplete = true;
	}
}

// CreateRTOperatives(XComGameState NewGameState)
function CreateRTOperatives(XComGameState StartState) {
	local RTGhostOperative IteratorGhostTemplate;

	foreach default.GhostTemplates(IteratorGhostTemplate) {
		CreateRTOperative(IteratorGhostTemplate, StartState);

	}
}

function CreateRTOperative(RTGhostOperative IteratorGhostTemplate, XComGameState StartState) {
	local XComGameState_Unit UnitState;
	local X2ItemTemplateManager ItemTemplateMgr;
	local X2CharacterTemplateManager CharMgr;
	local X2CharacterTemplate CharTemplate;
	local XComGameState_Item WeaponState;
	local X2WeaponUpgradeTemplate UpgradeTemplate;
	local name WeaponUpgradeName;
	local RTGhostOperative Ghost;

	CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	CharTemplate = CharMgr.FindCharacterTemplate(IteratorGhostTemplate.CharacterTemplateName);
	CharTemplate.bIsPsionic = true;

	UnitState = CharTemplate.CreateInstanceFromTemplate(StartState);
	StartState.AddStateObject(UnitState);

	UnitState.SetCharacterName(IteratorGhostTemplate.FirstName, IteratorGhostTemplate.LastName, IteratorGhostTemplate.NickName);
	UnitState.SetCountry(CharTemplate.DefaultAppearance.nmFlag);
	UnitState.RankUpSoldier(StartState, IteratorGhostTemplate.SoldierClassTemplateName);
	UnitState.ApplyInventoryLoadout(StartState, CharTemplate.DefaultLoadout);
	UnitState.StartingRank = 1;
	UnitState.SetXPForRank(1);
	UnitState.SetBackground(IteratorGhostTemplate.preBackground);

	WeaponState = UnitState.GetPrimaryWeapon();
	foreach IteratorGhostTemplate.WeaponUpgrades(WeaponUpgradeName) {
		UpgradeTemplate = X2WeaponUpgradeTemplate(ItemTemplateMgr.FindItemTemplate(WeaponUpgradeName));
		if (UpgradeTemplate != none) {
			WeaponState.ApplyWeaponUpgradeTemplate(UpgradeTemplate);
		}
	}

	Ghost = IteratorGhostTemplate;
	Ghost.StateObjectRef = UnitState.GetReference();

	Active.AddItem(UnitState.GetReference());
	Master.AddItem(Ghost);
}



function CreateRTSquads(XComGameState StartState) {

	local RTGameState_PersistentGhostSquad one;
	local RTGhostOperative Ghost;

	one = RTGameState_PersistentGhostSquad(StartState.CreateNewStateObject(class'RTGameState_PersistentGhostSquad'));
	one.CreateSquad(1, default.SquadOneName, default.SquadOneBackground, default.SquadOneSitRepName);
	Squads.AddItem(one.GetReference());

	foreach Master(Ghost) {
		// team 1 "SPECTRE"
		if(SquadOneMembers.Find(Ghost.ExternalID) != INDEX_NONE) {
			one.Operatives.AddItem(Ghost.StateObjectRef);
			one.initOperatives.AddItem(Ghost.StateObjectRef);
		}
	}
}

// UpdateNumDeaths(name CharacterTemplateName, StateObjectReference UnitRef)
simulated function UpdateNumDeaths(name CharacterTemplateName, StateObjectReference UnitRef) {
	local RTDeathRecord 	IteratorDeathRecord, NewDeathRecord;
	local RTKillCount		IteratorKillCount, NewKillCount;
	local bool				bFoundDeathRecord, bFoundKillCount;

	foreach DeathRecordData(IteratorDeathRecord) {
		if(IteratorDeathRecord.CharacterTemplateName != CharacterTemplateName) {
			continue;
		}

		bFoundDeathRecord = true;
		IteratorDeathRecord.NumDeaths++;

		foreach IteratorDeathRecord.IndividualKillCounts(IteratorKillCount) {
			if(IteratorKillCount.UnitRef.ObjectID == UnitRef.ObjectID) {
				bFoundKillCount = true;
				IteratorKillCount.KillCount++;
			}
		}

		if(!bFoundKillCount) {
			NewKillCount.UnitRef = UnitRef;
			NewKillCount.KillCount = 1;
			IteratorDeathRecord.IndividualKillCounts.AddItem(NewKillCount);
		}

	}

	// new character. make a new death record and increment the number of deaths.
	// also, create a new kill count and increment the number of kills.
	if(!bFoundDeathRecord) {
		NewDeathRecord.CharacterTemplateName = CharacterTemplateName;
		NewDeathRecord.NumDeaths = 1;

		NewKillCount.UnitRef = UnitRef;
		NewKillCount.KillCount = 1;
		NewDeathRecord.IndividualKillCounts.AddItem(NewKillCount);
		DeathRecordData.AddItem(NewDeathRecord);
	}
}

// UpdateNumCrits(name CharacterTemplateName)
simulated function UpdateNumCrits(name CharacterTemplateName) {
	local RTDeathRecord 	IteratorDeathRecord, NewDeathRecord;
	local bool				bFoundDeathRecord;

	foreach DeathRecordData(IteratorDeathRecord) {
		if(IteratorDeathRecord.CharacterTemplateName != CharacterTemplateName) {
			continue;
		}

		bFoundDeathRecord = true;
		IteratorDeathRecord.NumCrits++;
	}

	// new character. make a new death record and increment the number of crits.
	if(!bFoundDeathRecord) {
		NewDeathRecord.CharacterTemplateName = CharacterTemplateName;
		NewDeathRecord.NumCrits = 1;
		DeathRecordData.AddItem(NewDeathRecord);
	}

}

// Creates the killtracker object if it doesn't exist
// RTGameState_ProgramFaction GetProgramFaction()
static function RTGameState_ProgramFaction GetProgramFaction() {
	local XComGameStateHistory History;
	local RTGameState_ProgramFaction Program;


	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'RTGameState_ProgramFaction', Program)
	{
		break;
	}

	if (Program != none) {
		return Program;
	} else {
		`RedScreen("Program does not exist! Returning null!");
		return none;
	}
}

// RefreshListeners()
static function RefreshListeners() {
	local RTGameState_ProgramFaction Program;

	Program = GetProgramFaction();
	Program.InitListeners();
}

// InitListeners()
function InitListeners() {
	local X2EventManager EventMgr;
	local Object ThisObj;

	ThisObj = self;
	EventMgr = `XEVENTMGR;
	EventMgr.UnregisterFromAllEvents(ThisObj); // clear all old listeners to clear out old stuff before re-registering

	EventMgr.RegisterForEvent(ThisObj, 'KillMail', OnKillMail, ELD_OnStateSubmitted,,,);
	EventMgr.RegisterForEvent(ThisObj, 'UnitAttacked', OnUnitAttacked, ELD_OnStateSubmitted,,,);
}

// EventData = DeadUnitState
// EventSource = KillerUnitState
function EventListenerReturn OnKillMail(Object EventData, Object EventSource, XComGameState GameState, Name InEventID, Object CallbackData) {
	local XComGameState_Unit KillerUnitState, DeadUnitState;
	local RTGameState_ProgramFaction Program;
	local XComGameState NewGameState;

	// `Log("OnKillMail: EventData =" @ EventData);
	// EventData is the unit who died
	// `Log("OnKillMail: EventSource =" @ EventSource);
	// EventSource is the unit that killed
	KillerUnitState = XComGameState_Unit(EventSource);
	if (KillerUnitState == none)
		return ELR_NoInterrupt;

	DeadUnitState = XComGameState_Unit(EventData);
	if (DeadUnitState == none)
		return ELR_NoInterrupt;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: UpdateDeathRecordData");
	Program = RTGameState_ProgramFaction(NewGameState.CreateStateObject(class'RTGameState_ProgramFaction', self.ObjectID));
	NewGameState.AddStateObject(Program);
	Program.UpdateNumDeaths(DeadUnitState.GetMyTemplate().CharacterGroupName, KillerUnitState.GetReference());
	`GAMERULES.SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}
// EventID = AbilityActivated
// EventData = AbilityState
// EventSource = UnitWhoUsedAbilityStateState
// or...
// EventID = UnitAttacked
// EventData = UnitState
// EventSource = UnitState
function EventListenerReturn OnUnitAttacked(Object EventData, Object EventSource, XComGameState GameState, Name InEventID, Object CallbackData) {
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit AttackedUnitState;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if(AbilityContext == none) {
		return ELR_NoInterrupt;
	}

	AttackedUnitState = XComGameState_Unit(EventData);
	if(AttackedUnitState == none) {
		AttackedUnitState = XComGameState_Unit(EventSource);
		if(AttackedUnitState == none) {
			return ELR_NoInterrupt;
		}
	}

	if(AbilityContext.ResultContext.HitResult == eHit_Crit) {
		UpdateNumCrits(AttackedUnitState.GetMyTemplate().CharacterGroupName);
	}

	return ELR_NoInterrupt;
}

function OnEndTacticalPlay(XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local XComGameState_HeadquartersXCom XComHQ, NewXComHQ;
	local XComGameState_MissionSite MissionState;

	super.OnEndTacticalPlay(NewGameState);
	History = class'XComGameStateHistory'.static.GetGameStateHistory();

	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.GetReference().ObjectID));

	MissionState = XComGameState_MissionSite(History.GetGameStateForObjectID(XComHQ.MissionRef.ObjectID));
	if(!IsRelevantMission(MissionState)) {
		return;
	}
	foreach NewGameState.IterateByClassType(class'XComGameState_Unit', UnitState) {
		if(Master.Find('NickName', UnitState.GetNickName()) != INDEX_NONE) {
			if(UnitState.bCaptured) {
				Captured.AddItem(UnitState.GetReference());
			} else {
				Active.AddItem(UnitState.GetReference());
			}
		}
	}
	
	RecalculateActiveOperativesAndSquads(NewGameState);
	PromoteAllOperatives(NewGameState);


}

protected static function bool IsRelevantMission(XComGameState_MissionSite MissionState) {
	// TODO:: this
	return true;
}

protected function RecalculateActiveOperativesAndSquads(XComGameState NewGameState) {
	//TODO:: this
	return;
}

protected function PromoteAllOperatives(XComGameState NewGameState) {
	//TODO:: this
	return;
}

// Faction Stuff

//#############################################################################################
//----------------   FACTION SOLDIERS ---------------------------------------------------------
//#############################################################################################

//---------------------------------------------------------------------------------------
function int GetNumFactionSoldiers(optional XComGameState NewGameState)
{
	local int i;
	local RTGhostOperative g;

	i = 0 ;
	foreach Master(g) {
		i++;
	}

	return i;
}

//---------------------------------------------------------------------------------------
function bool IsFactionSoldierRewardAllowed(XComGameState NewGameState)
{
	// The Program doesn't give out Faction Soldier rewards
	return false;
}

//---------------------------------------------------------------------------------------
function bool IsExtraFactionSoldierRewardAllowed(XComGameState NewGameState)
{
	// The Program doesn't give out Faction Soldier rewards
	return false;
}

private function AddRisingTidesTacticalTags(XComGameState_HeadquartersXCom XComHQ) {// mark missions as being invalid for One Small Favor or Just Passing Through, usually story, (golden path or otherwise) 

}

simulated function bool CashOneSmallFavor(XComGameState NewGameState, XComGameState_MissionSite MissionSite) {
	local StateObjectReference GhostRef, EmptyRef;
	local name GhostTemplateName;

	if(!bOneSmallFavorAvailable)
		return false;
	
	if(Deployed == none) {
		RotateRandomSquadToDeploy();
	}
	
	if(Deployed == none) {
		class'RTHelpers'.static.RTLog("The Program has no squads?", true);
		return false; // we... have no squads?
	}

	MissionSite = XComGameState_MissionSite(NewGameState.ModifyStateObject(MissionSite.class, MissionSite.ObjectID));
	foreach Deployed.Operatives(GhostRef) {
		GhostTemplateName = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(GhostRef.ObjectID)).GetMyTemplateName();
		MissionSite.GeneratedMission.Mission.SpecialSoldiers.AddItem(GhostTemplateName);
	}

	return true;
}

protected function RotateRandomSquadToDeploy() {
	if(Squads.Length == 0)
		return;
	Deployed = RTGameState_PersistentGhostSquad(`XCOMHISTORY.GetGameStateForObjectID(Squads[`SYNC_RAND(Squads.Length)].ObjectID));
}

//#############################################################################################
//-----------------   COVERT ACTIONS  ---------------------------------------------------------
//#############################################################################################

//---------------------------------------------------------------------------------------
// Remove vanilla actions for modded faction where the modded action should override
function ModifyGoldenPathActions(XComGameState NewGameState)
{
	local X2StrategyElementTemplateManager StratMgr;
	local array<X2StrategyElementTemplate> AllActionTemplates;
	local X2StrategyElementTemplate DataTemplate;
	local X2CovertActionTemplate ActionTemplate;
	local XComGameState_CovertAction ActionState;
	local XComGameStateHistory History;
	local StateObjectReference ActionRef;

	//class'RTHelpers'.static.RTLog("Modifying Golden Path actions for The Program...");
	if(GoldenPathActions.Length == 0) {
		//class'RTHelpers'.static.RTLog("ModifyGoldenPathActions failed, no GoldenPathActions available!", true);
	} else {
		History = `XCOMHISTORY;
		foreach GoldenPathActions(ActionRef)
		{
			//class'RTHelpers'.static.RTLOG("Found Covert Action " $ ActionState.GetMyTemplateName $ "...", false);
			ActionState = XComGameState_CovertAction(History.GetGameStateForObjectID(ActionRef.ObjectID));
			if(ActionState.GetMyTemplateName() == 'CovertAction_FindFaction' || ActionState.GetMyTemplateName() == 'CovertAction_FindFarthestFaction') {
				RemoveCovertAction(ActionRef);
			}
		}
	}
}

function PrintGoldenPathActionInformation() {
	local XComGameStateHistory 				History;
	local StateObjectReference 				StateObjRef;
	local XComGameState_CovertAction 		CovertActionState;
	local X2CovertActionTemplate			CovertActionTemplate;

	History = `XCOMHISTORY;

	class'RTHelpers'.static.RTLog("Printing Golden Path covert actions for the Program...");
	foreach GoldenPathActions(StateObjRef) {
		CovertActionState = XComGameState_CovertAction(History.GetGameStateForObjectID(StateObjRef.ObjectID));
		if(CovertActionState == none)
			continue;
		CovertActionTemplate = CovertActionState.GetMyTemplate();
		class'RTHelpers'.static.RTLog("" $ CovertActionTemplate.DataName);
	}
}

function CreateGoldenPathActions(XComGameState NewGameState)
{
	super.CreateGoldenPathActions(NewGameState);
	//PrintGoldenPathActionInformation();
	ModifyGoldenPathActions(NewGameState);
}

//#############################################################################################
//----------------- GENERAL FACTION METHODS ---------------------------------------------------
//#############################################################################################
event OnCreation(optional X2DataTemplate Template)
{
	local int idx;

	super.OnCreation( Template );

}

function MeetXCom(XComGameState NewGameState)
{
	local XComGameState_HeadquartersResistance ResHQ;
	local array<Name> ExclusionList;
	local int idx;

	ResHQ = XComGameState_HeadquartersResistance(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));
	ResHQ = XComGameState_HeadquartersResistance(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersResistance', ResHQ.ObjectID));
 	ExclusionList = ResHQ.CovertActionExclusionList; // Get the current list of covert actions for other factions from Res HQ

	bMetXCom = true;
	bNewFragmentActionAvailable = true;
	MetXComDate = GetCurrentTime();

	CleanUpFactionCovertActions(NewGameState);
	CreateGoldenPathActions(NewGameState);
	GenerateCovertActions(NewGameState, ExclusionList);
	
	// Program-specfic startup
	SetUpProgramFaction(NewGameState);

	for(idx = 0; idx < default.NumCardsOnMeet; idx++)
	{
		GenerateNewPlayableCard(NewGameState);
	}

	// DisplayResistancePlaque(NewGameState);

	ResHQ.CovertActionExclusionList = ExclusionList; // Save the updated Exclusion List to ResHQ

	// Ensure a Rookie Covert Action exists
	if (!ResHQ.IsRookieCovertActionAvailable(NewGameState))
	{
		ResHQ.CreateRookieCovertAction(NewGameState);
	}
}


function PreMissionUpdate(XComGameState NewGameState, XComGameState_MissionSite MissionSiteState) {
	if(bOneSmallFavorActivated && bOneSmallFavorAvailable) {
		bOneSmallFavorAvailable = false;
		bOneSmallFavorActivated = false;
	}
}
