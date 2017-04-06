class RTGameState_RisingTidesCommand extends XComGameState_BaseObject;


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
	var StateObjectReference      UnitRef;
	var name                      UnitName;
	var int                       KillCount;

};

struct RTDeathRecord
{
	var name                      CharacterTemplateName; // the type of unit that died
	var int                       NumDeaths;              // number of times the unit has been killed by a friendly unit
	var int                       NumCrits;               // number of times the unit has been critically hit
	var array<RTKillCount>        IndividualKillCounts;   // per-unit kill counts ( worth more to VitalPointTargeting than other kills )
};

var() array<RTDeathRecord> DeathRecordData;                  // GHOST Datavault contianing information on every kill made by deployed actor

/* END KILL RECORD   */

/* *********************************************************************** */

/* *********************************************************************** */

/* BEGIN OPERATIVE RECORD */

var() array<StateObjectReference> Ghosts;	// ghosts active
var() array<StateObjectReference> Squad;	// ghosts that will be on the next mission
var() int iOperativeLevel;					// all ghosts get level ups after a mission, even if they weren't on it. lorewise, they're constantly running missions; the player only sees a fraction of them


/* END OPERATIVE RECORD   */


/* *********************************************************************** */
