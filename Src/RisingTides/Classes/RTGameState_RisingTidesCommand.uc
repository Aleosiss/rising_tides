class RTGameState_RisingTidesCommand extends XComGameState_BaseObject config(RisingTides);

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

var() array<RTDeathRecord> DeathRecordData;					// GHOST Datavault contianing information on every kill made by deployed actor

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

	var localized string			FirstName;
	var localized string			NickName;
	var localized string			LastName;
};

var const config array<RTGhostOperative>	GhostTemplates;

var() array<RTGhostOperative> 	Ghosts;					// ghosts active
var() array<RTGhostOperative> 	Squad;					// ghosts that will be on the next mission
var() int 						iOperativeLevel;		// all ghosts get level ups after a mission, even if they weren't on it. lorewise, they're constantly running missions; the player only sees a fraction of them


/* END OPERATIVE RECORD   */


/* *********************************************************************** */

// SetUpRisingTidesCommand(XComGameState StartState)
static function SetUpRisingTidesCommand(XComGameState StartState)
{
	local RTGameState_RisingTidesCommand RTCom;

	foreach StartState.IterateByClassType(class'RTGameState_RisingTidesCommand', RTCom)
	{
		break;
	}

	if (RTCom == none)
	{
		RTCom = RTGameState_RisingTidesCommand(StartState.CreateStateObject(class'RTGameState_RisingTidesCommand'));
	}

	StartState.AddStateObject(RTCom);
	RTCom.CreateRTOperatives(StartState);
	//RTCom.CreateRTDeathRecord(StartState);
}

function CreateRTOperatives(XComGameState NewGameState) {
	local XComGameState_Unit UnitState;
	local X2ItemTemplateManager ItemTemplateMgr;
	local X2CharacterTemplateManager CharMgr;
	local X2CharacterTemplate CharTemplate;
	local XComGameState_Item WeaponState;
	local X2WeaponUpgradeTemplate UpgradeTemplate;
	local name WeaponUpgradeName;

	local RTGhostOperative IteratorGhost;
	local RTGhostOperative Ghost;

	CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	foreach default.GhostTemplates(IteratorGhost) {
		CharTemplate = CharMgr.FindCharacterTemplate(IteratorGhost.CharacterTemplateName);
		CharTemplate.bIsPsionic = true;

		UnitState = CharTemplate.CreateInstanceFromTemplate(NewGameState);
		NewGameState.AddStateObject(UnitState);

		UnitState.SetCharacterName(IteratorGhost.FirstName, IteratorGhost.LastName, IteratorGhost.NickName);
		UnitState.SetCountry(CharTemplate.DefaultAppearance.nmFlag);
		UnitState.RankUpSoldier(NewGameState, IteratorGhost.SoldierClassTemplateName);
		UnitState.ApplyInventoryLoadout(NewGameState, CharTemplate.DefaultLoadout);
		UnitState.StartingRank = 1;
		UnitState.SetXPForRank(1);

		WeaponState = UnitState.GetPrimaryWeapon();
		foreach IteratorGhost.WeaponUpgrades(WeaponUpgradeName) {
			UpgradeTemplate = X2WeaponUpgradeTemplate(ItemTemplateMgr.FindItemTemplate(WeaponUpgradeName));
			if (UpgradeTemplate != none) {
				WeaponState.ApplyWeaponUpgradeTemplate(UpgradeTemplate);
			}
		}

		Ghost = IteratorGhost;
		Ghost.StateObjectRef = UnitState.GetReference();
		Ghosts.AddItem(Ghost);
	}
}

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
static function RTGameState_RisingTidesCommand GetRTCommand() {
	local XComGameStateHistory History;
	local RTGameState_RisingTidesCommand RTCom;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'RTGameState_RisingTidesCommand', RTCom)
	{
		break;
	}

	if (RTCom != none) {
		return RTCom;
	} else {
		`RedScreen("RTCom does not exist! Returning null!");
		return none;
	}
}

static function RefreshListeners() {
	local RTGameState_RisingTidesCommand RTCom;

	RTCom = GetRTCommand();
	RTCom.InitListeners();
}

function InitListeners() {
	local X2EventManager EventMgr;
	local Object ThisObj;

	ThisObj = self;
	EventMgr = `XEVENTMGR;
	EventMgr.UnregisterFromAllEvents(ThisObj); // clear all old listeners to clear out old stuff before re-registering

	EventMgr.RegisterForEvent(ThisObj, 'KillMail', OnKillMail, ELD_OnStateSubmitted,,, true);
	EventMgr.RegisterForEvent(ThisObj, 'UnitAttacked', OnUnitAttacked, ELD_OnStateSubmitted,,, true);
}

// EventData = DeadUnitState
// EventSource = KillerUnitState
function EventListenerReturn OnKillMail(Object EventData, Object EventSource, XComGameState GameState, Name InEventID) {
	local XComGameState_Unit KillerUnitState, DeadUnitState;
	local RTGameState_RisingTidesCommand RTCom;
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
	RTCom = RTGameState_RisingTidesCommand(NewGameState.CreateStateObject(class'RTGameState_RisingTidesCommand', self.ObjectID));
	NewGameState.AddStateObject(RTCom);
	RTCom.UpdateNumDeaths(DeadUnitState.GetMyTemplate().CharacterGroupName, KillerUnitState.GetReference());
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
function EventListenerReturn OnUnitAttacked(Object EventData, Object EventSource, XComGameState GameState, Name InEventID) {
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit AttackedUnitState;
	local bool bWasCrit;

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
