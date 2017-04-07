class RTGameState_RisingTidesCommand extends XComGameState_BaseObject config(RisingTides);


/* *********************************************************************** */

/* BEGIN KILL RECORD */

// each type of unit has an RTDeathRecord
// in this DeathRecord, there is an individual killcount array that lists all the units
// that have ever killed this one, and how many they'd defeated.
// the NumDeaths variable in the DeathRecord is the sum of all of the IndividualKillCounts.KillCount values.
// Additionally, whenever a critical hit is landed, it increments the NumCrits value.

// required methods:
// void AddDeathRecord(name CharacterTemplateName, StateObjectReference UnitState, bool bWasCrit)
// void IncrementDeathRecord(name CharacterTemplateName, StateObjectReference UnitState, bool bWasCrit)
// bool GetDeathRecord(name CharacterTemplateName, out RTDeathRecord DeathRecord)

struct RTKillCount
{
	var StateObjectReference      UnitRef;				// The owner of this kill count
	var name                      UnitName;				// The name of the owner of this kill count
	var int                       KillCount;			// the number of kills

};

struct RTDeathRecord
{
	var name                      CharacterTemplateName;	// the type of unit that died
	var int                       NumDeaths;              	// number of times the unit has been killed by a friendly unit
	var int                       NumCrits;               	// number of times the unit has been critically hit
	var array<RTKillCount>        IndividualKillCounts;   	// per-unit kill counts ( worth more to VitalPointTargeting than other kills ); the sum of these should always equal NumDeaths
};

	var() array<RTDeathRecord> DeathRecordData;				// GHOST Datavault contianing information on every kill made by deployed actor

/* END KILL RECORD   */

/* *********************************************************************** */

/* *********************************************************************** */

/* BEGIN OPERATIVE RECORD */

struct RTGhostOperative
{
	var name 						SoldierClassTemplateName;
	var name						CharacterTemplateName;

	var StateObjectReference 		ObjectID

	var localized string			FirstName;
	var localized string			NickName;
	var localized string			LastName;
}

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
	RTCom.CreateRTDeathRecord(StartState);
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
		UnitState.SetCountry(CharTemplate.DefaultAppearence.nmFlag);
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
		Ghost.ObjectID = UnitState.ObjectID;
		Ghosts.AddItem(Ghost);
	}
}
