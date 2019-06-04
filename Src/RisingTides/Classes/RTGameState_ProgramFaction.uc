class RTGameState_ProgramFaction extends XComGameState_ResistanceFaction config(ProgramFaction);

// a lot of the DeathRecordData code is from Xyl's Anatomist Perk. Thanks to him.

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

// SPECTRE
var localized string SquadOneName;					// SPECTRE
var localized string SquadOneBackground;
var localized string WhisperWepName;				// 'Heartspan'
var config array<name> SquadOneMembers;
var config name SquadOneSitRepName;
var config array<name> BerserkerWeaponUpgrades;
var config array<name> MarksmanWeaponUpgrades;
var config array<name> GathererWeaponUpgrades;

// HIGHLANDER
var localized string SquadTwoName;					// HIGHLANDER
var localized string SquadTwoBackground;
var config array<name> SquadTwoMembers;


var() array<StateObjectReference>								Master; 			// master list of operatives
var() array<StateObjectReference> 								Active;				// operatives active
var() RTGameState_PersistentGhostSquad							Deployed; 			// operatives that will be on the next mission
var() array<StateObjectReference>								Captured;			// operatives not available
var() array<StateObjectReference>								Squads;				// list of ghost teams (only one for now)
var() int 														iOperativeLevel;	// all operatives get level ups after a mission, even if they weren't on it. lorewise, they're constantly running missions; the player only sees a fraction of them
var bool														bSetupComplete;		// if we should rebuild the operative array from config

/* END OPERATIVE RECORD   */


// FACTION VARIABLES
var bool																bShouldPerformPostMissionCleanup;	// should cleanup the program's roster after a mission-- set during OSF and JPT missions
var bool																bDirectNeuralManipulation;
var bool																bResistanceSabotageActivated;
var config array<name>													InvalidMissionSources;				// list of mission types ineligible for Program support, usually story missions
var config array<name>													UnavailableCovertActions;			// list of covert actions that the program cannot carry out
var config array<name>													ExcludedGoldenPathCovertActions;				// list of golden path covert actions the program cannot carry out (yet)
var config int															iNumberOfFavorsRequiredToIncreaseInfluence;
var array<X2DataTemplate>												OperativeTemplates;

// TEMPLAR QUESTLINE VARIABLES
var private bool																bTemplarsDestroyed;
var private bool																bTemplarQuestFailed;
var private int																	iTemplarQuestlineStage;
var private array<StateObjectReference>											TemplarQuestActions;
var private bool 																bTemplarMissionSucceeded;

// ONE SMALL FAVOR HANDLING VARIABLES
var private int															iPreviousMaxSoldiersForMission;		// cache of the number of soldiers on a mission before OSF modfied it
var private StateObjectReference										SelectedMissionRef;					// cache of the mission one small favor is going to go against
var bool																bShouldResetOSFMonthly;
var private bool														bOneSmallFavorAvailable;			// can send squad on a mission, replacing XCOM
var private bool														bOneSmallFavorActivated;			// actively sending a squad on the next mission
var private int															iNumberOfFavorsAvailable;			// number of Favors banked
var int																	iNumberOfFavorsCalledIn;			// number of Favors remaining towards next influence gain
var bool																bOSF_FirstTimeDisplayed;
var bool																bPIS_FirstTimeDisplayed;
var protected int														iCurrentProgramGearTier;			// Current Tier of Program gear (used to match XCOM gear progression)

// ONE SMALL FAVOR LOCALIZED STRINGS
var localized string OSFCheckboxAvailable;
var localized string OSFCheckboxUnavailable;
var localized string OSFFirstTime_Title;
var localized string OSFFirstTime_Text;
var config string OSFFirstTime_ImagePath;

// PROGRAM INFO SCREEN LOCALIZED STRINGS
var localized string PISFirstTime_Title;
var localized string PISFirstTime_Text;
var config string PISFirstTime_ImagePath;


// not a bool, want to see how many times this is called
var private int iNumTimesProgramSetup;

// the latest version of the mod
var private int Version;

/* *************F********************************************************** */

defaultproperties
{
	iNumTimesProgramSetup = 0
	Version = 0;
}

// SetUpProgramFaction(XComGameState StartState)
function SetUpProgramFaction(XComGameState StartState)
{
	iNumTimesProgramSetup++;
	if(iNumTimesProgramSetup > 1) {
		return;
	}
	`RTLOG("Running Program-specific setup...");
	InitListeners();
	class'RTGameState_StrategyCard'.static.SetUpStrategyCards(StartState);
	OperativeTemplates = class'RTCharacter_DefaultCharacters'.static.CreateTemplates();
	Version = `DLCINFO.GetVersionInt();
}

// CreateRTOperatives(XComGameState NewGameState)
function CreateRTOperatives(XComGameState StartState) {
	AddRTOperativeToProgram('RTGhostBerserker', StartState);
	AddRTOperativeToProgram('RTGhostMarksman', StartState);
	AddRTOperativeToProgram('RTGhostGatherer', StartState);
	AddRTOperativeToProgram('RTGhostOperator', StartState);
}

// Seperated this out of CreateRTOperative in order to allow the creation of duplicate operatives in Just Passing Through
function AddRTOperativeToProgram(name GhostTemplateName, XComGameState StartState) {
	local RTGameState_Unit UnitState;

	UnitState = CreateRTOperative(GhostTemplateName, StartState);
	Active.AddItem(UnitState.GetReference());
	Master.AddItem(UnitState.GetReference());
}

function RTGameState_Unit CreateRTOperative(name GhostTemplateName, XComGameState StartState) {
	local RTGameState_Unit UnitState;
	local X2CharacterTemplate TempTemplate;
	local RTCharacterTemplate CharTemplate;
	//local X2DataTemplate IteratorTemplate;
	local XComGameState_Item WeaponState;
	//local name WeaponUpgradeName;
	local X2CharacterTemplateManager CharMgr;

	CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	TempTemplate = CharMgr.FindCharacterTemplate(GhostTemplateName);
	CharTemplate = RTCharacterTemplate(TempTemplate);
	UnitState = RTGameState_Unit(CharTemplate.CreateInstanceFromTemplate(StartState));

	UnitState.SetCountry(CharTemplate.DefaultAppearance.nmFlag);
	UnitState.RankUpSoldier(StartState, CharTemplate.DefaultSoldierClass);
	UnitState.ApplyInventoryLoadout(StartState, CharTemplate.DefaultLoadout);
	UnitState.StartingRank = 1;
	UnitState.SetUnitName(CharTemplate.strForcedFirstName, CharTemplate.strForcedLastName, CharTemplate.strForcedNickName);
	UnitState.SetBackground(UnitState.GetMyTemplate().strCharacterBackgroundMale[0]); // the first background is the classified one, the second one is the unclassified one

	WeaponState = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);
	WeaponState = XComGameState_Item(StartState.ModifyStateObject(class'XComGameState_Item', WeaponState.ObjectID));
	ApplyWeaponUpgrades(GhostTemplateName, WeaponState);

	`RTLOG(	"Creating Program Operative " $ UnitState.GetName(eNameType_Nick) $ 
									", with ObjectID " $ UnitState.GetReference().ObjectID $
									", and CharacterTemplateName " $ UnitState.GetMyTemplateName()
						);

	return UnitState;
}

function ApplyWeaponUpgrades(name GhostTemplateName, XComGameState_Item NewWeaponState) {
	local X2WeaponUpgradeTemplate UpgradeTemplate;
	local X2ItemTemplateManager ItemTemplateMgr;
	//local name WeaponUpgradeName;
	local int idx;

	//local name DebugIteratorName;
	//local array<name> DebuggingNames;


	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	NewWeaponState.WipeUpgradeTemplates();
	switch(GhostTemplateName) {
		case 'RTGhostBerserker':
			for(idx = 0; idx < default.BerserkerWeaponUpgrades.Length; idx++) {
				UpgradeTemplate = X2WeaponUpgradeTemplate(ItemTemplateMgr.FindItemTemplate(default.BerserkerWeaponUpgrades[idx]));
				if (UpgradeTemplate != none) {
					NewWeaponState.ApplyWeaponUpgradeTemplate(UpgradeTemplate, idx);
				}
			}
			break;
		case 'RTGhostMarksman':
			NewWeaponState.Nickname = default.WhisperWepName;
			for(idx = 0; idx < default.MarksmanWeaponUpgrades.Length; idx++) {
				UpgradeTemplate = X2WeaponUpgradeTemplate(ItemTemplateMgr.FindItemTemplate(default.MarksmanWeaponUpgrades[idx]));
				if (UpgradeTemplate != none) {
					NewWeaponState.ApplyWeaponUpgradeTemplate(UpgradeTemplate, idx);
				}
			}
			break;
		case 'RTGhostGatherer':
			for(idx = 0; idx < default.GathererWeaponUpgrades.Length; idx++) {
				UpgradeTemplate = X2WeaponUpgradeTemplate(ItemTemplateMgr.FindItemTemplate(default.GathererWeaponUpgrades[idx]));
				if (UpgradeTemplate != none) {
					NewWeaponState.ApplyWeaponUpgradeTemplate(UpgradeTemplate, idx);
				}
			}
			break;
		case 'RTGhostOperator': // operator uses gatherer equipment, although it might be more accurate in reverse...
			for(idx = 0; idx < default.GathererWeaponUpgrades.Length; idx++) {
				UpgradeTemplate = X2WeaponUpgradeTemplate(ItemTemplateMgr.FindItemTemplate(default.GathererWeaponUpgrades[idx]));
				if (UpgradeTemplate != none) {
					NewWeaponState.ApplyWeaponUpgradeTemplate(UpgradeTemplate, idx);
				}
			}
			break;

	}
}
//---------------------------------------------------------------------------------------
//---Create Program Squads---------------------------------------------------------------
//---------------------------------------------------------------------------------------
function CreateRTSquads(XComGameState StartState) {

	local RTGameState_PersistentGhostSquad one, two;
	local StateObjectReference OperativeRef;
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;

	History = `XCOMHISTORY;

	one = RTGameState_PersistentGhostSquad(StartState.CreateNewStateObject(class'RTGameState_PersistentGhostSquad'));
	one.CreateSquad(1, default.SquadOneName, default.SquadOneBackground, default.SquadOneSitRepName, true);
	Squads.AddItem(one.GetReference());

	two = RTGameState_PersistentGhostSquad(StartState.CreateNewStateObject(class'RTGameState_PersistentGhostSquad'));
	two.CreateSquad(2, default.SquadTwoName, default.SquadTwoBackground, '', false);
	Squads.AddItem(two.GetReference());

	foreach Master(OperativeRef) {
		// team 1 "SPECTRE"
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(OperativeRef.ObjectID));
		if(SquadOneMembers.Find(UnitState.GetMyTemplateName()) != INDEX_NONE) {
			one.Operatives.AddItem(OperativeRef);
			one.initOperatives.AddItem(OperativeRef);
		}

		if(SquadTwoMembers.Find(UnitState.GetMyTemplateName()) != INDEX_NONE) {
			two.Operatives.AddItem(OperativeRef);
			two.initOperatives.AddItem(OperativeRef);
		}
	}

	Deployed = one;
	one.bIsDeployed = true;
}

// UpdateNumDeaths(name CharacterTemplateName, StateObjectReference UnitRef)
simulated function UpdateNumDeaths(name CharacterTemplateName, StateObjectReference UnitRef) {
	local RTDeathRecord 	IteratorDeathRecord, NewDeathRecord;
	local RTKillCount		IteratorKillCount, NewKillCount;
	local bool				bFoundDeathRecord, bFoundKillCount;

	foreach DeathRecordData(IteratorDeathRecord) {

		// is this the death record for this unit type?
		if(IteratorDeathRecord.CharacterTemplateName != CharacterTemplateName) {
			continue;
		}

		// yes
		bFoundDeathRecord = true;
		IteratorDeathRecord.NumDeaths++;

		// is the individual death record for the killer?
		foreach IteratorDeathRecord.IndividualKillCounts(IteratorKillCount) {
			// yes
			if(IteratorKillCount.UnitRef.ObjectID == UnitRef.ObjectID) {
				bFoundKillCount = true;
				IteratorKillCount.KillCount++;
			}
		}
		
		// no, create a new one
		if(!bFoundKillCount) {
			NewKillCount.UnitRef = UnitRef;
			NewKillCount.KillCount = 1;
			IteratorDeathRecord.IndividualKillCounts.AddItem(NewKillCount);
		}

	}

	// no
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

//---------------------------------------------------------------------------------------
//---Getter------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
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

//---------------------------------------------------------------------------------------
//---OnEndTacticalPlay-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
function OnEndTacticalPlay(XComGameState NewGameState)
{
	local XComGameStateHistory History;
	//local XComGameState_Unit UnitState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_MissionSite MissionState;

	super.OnEndTacticalPlay(NewGameState);

	History = class'XComGameStateHistory'.static.GetGameStateHistory();
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));	
	MissionState = XComGameState_MissionSite(History.GetGameStateForObjectID(XComHQ.MissionRef.ObjectID));

	if(bDirectNeuralManipulation) {
		AddDNMExperience(NewGamestate);
	}

	if(IsOSFMission(MissionState)) {
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.GetReference().ObjectID));
		//BlastOperativeLoadouts(NewGameState);

		// only want to promote if its a osf mission, so do it here, while we have access to the missionsite, not in PostMissionCleanup
		if(iOperativeLevel <= 8) {
			PromoteAllOperatives(NewGameState);
			iOperativeLevel++;
		}
	}
}

//---------------------------------------------------------------------------------------
//---IsOSFMission------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
protected static function bool IsOSFMission(XComGameState_MissionSite MissionState) {
	if(MissionState.TacticalGameplayTags.Find('RTOneSmallFavor') != INDEX_NONE) {
		return true;
	}
	return false;
}

function bool CanMakeOneSmallFavorAvailable() {
	return iNumberOfFavorsAvailable > 0;
}

function int GetNumFavorsAvailable() {
	return iNumberOfFavorsAvailable;
}

function IncrementNumFavorsAvailable(int NumFavors) {
	if(NumFavors > 0) {
		iNumberOfFavorsAvailable += NumFavors;
	}
}

function bool IsOneSmallFavorAvailable() {
	return bOneSmallFavorAvailable;
}

function bool MakeOneSmallFavorAvailable() {
	if(Deployed == none) {
		RotateRandomSquadToDeploy();
	}

	if(bOneSmallFavorAvailable) {
		return true;
	}

	if(CanMakeOneSmallFavorAvailable()) {
		iNumberOfFavorsAvailable--;
		bOneSmallFavorAvailable = true;
		return true;
	} else {
		return false;
	}
}

function MakeOneSmallFavorUnavailable() {
	bOneSmallFavorAvailable = false;

	if(bOneSmallFavorAvailable) { // we had a favor teed up, refund it
		iNumberOfFavorsAvailable++;
	}
}

function HandleOSFTutorial(optional bool bOverrideFirstTime = false) {
	local DynamicPropertySet PropertySet;
	local XComGameState NewGameState;
	local RTGameState_ProgramFaction ProgramState;

	if(!bOSF_FirstTimeDisplayed || bOverrideFirstTime) {
		// Update the bool, this requires a newgamestate
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RisingTides: setting One Small Favor tutorial flag...");
		ProgramState = RTGameState_ProgramFaction(NewGameState.ModifyStateObject(class'RTGameState_ProgramFaction', self.ObjectID));
		ProgramState.bOSF_FirstTimeDisplayed = true;
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

		// Display the tutorial popup, this also requires a newgamestate
		class'X2StrategyGameRulesetDataStructures'.static.BuildDynamicPropertySet(PropertySet, 'UIAlert_OSFFirstTime', 'UITutorialBox', none, false, false, true, false);
		class'XComPresentationLayerBase'.static.QueueDynamicPopup(PropertySet);
	}
}

function HandleProgramScreenTutorial(optional bool bOverrideFirstTime = false) {
	local DynamicPropertySet PropertySet;
	local XComGameState NewGameState;
	local RTGameState_ProgramFaction ProgramState;

	if(!bPIS_FirstTimeDisplayed || bOverrideFirstTime) {
		// Update the bool, this requires a newgamestate
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RisingTides: setting One Small Favor tutorial flag...");
		ProgramState = RTGameState_ProgramFaction(NewGameState.ModifyStateObject(class'RTGameState_ProgramFaction', self.ObjectID));
		ProgramState.bPIS_FirstTimeDisplayed = true;
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

		// Display the tutorial popup, this also requires a newgamestate
		class'X2StrategyGameRulesetDataStructures'.static.BuildDynamicPropertySet(PropertySet, 'UIAlert_PISFirstTime', 'UITutorialBox', none, false, false, true, false);
		class'XComPresentationLayerBase'.static.QueueDynamicPopup(PropertySet);
	}
}

//---------------------------------------------------------------------------------------
//---Blast Operative Loadouts------------------------------------------------------------
//---------------------------------------------------------------------------------------
// need to blast operative loadouts before they hit post-game, because otherwise XCOM
// will scoop up their gear
protected function BlastOperativeLoadouts(XComGameState NewGameState) {
	local XComGameState_Unit UnitState;
	//local XComGameStateHistory History;
	local XComGameState_Item ItemState;

	foreach NewGameState.IterateByClassType(class'XComGameState_Unit', UnitState) {
		UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
		if(Master.Find('ObjectID', UnitState.ObjectID) != INDEX_NONE) {
			ItemState = UnitState.GetPrimaryWeapon();
			UnitState.BlastLoadout(NewGameState);
			UnitState.AddItemToInventory(ItemState, eInvSlot_PrimaryWeapon, NewGameState); // add the primary back, since it's an infinite copy, it won't make it back to strategy anyways
		}
	}
}
//---------------------------------------------------------------------------------------
//---Recalculate Active Operatives and Squads--------------------------------------------
//---------------------------------------------------------------------------------------
protected function RecalculateActiveOperativesAndSquads(XComGameState NewGameState) {
	// Have to tell all of the RTGameState_PersistentSquads about what members of theirs were captured/rescued
	local RTGameState_PersistentGhostSquad pgs;
	local StateObjectReference SquadIteratorObjRef, UnitIteratorObjRef;
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState_AdventChosen ChosenState;
	local StateObjectReference EmptyRef;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersAlien AlienHeadquarters;

	History = `XCOMHISTORY;

	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

	foreach Squads(SquadIteratorObjRef) {
		pgs = RTGameState_PersistentGhostSquad(History.GetGameStateForObjectID(SquadIteratorObjRef.ObjectID));
		pgs = RTGameState_PersistentGhostSquad(NewGameState.ModifyStateObject(class'RTGameState_PersistentGhostSquad', pgs.ObjectID));
		if(pgs != none) {
			foreach pgs.InitOperatives(UnitIteratorObjRef) {
				UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitIteratorObjRef.ObjectID));
				if(UnitState == none) {
					`RTLOG("Couldn't find UnitState for ObjectID" $ UnitIteratorObjRef.ObjectID);
					continue;
				}

				NewUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
				// TODO: Capture/Rescue of Program Operatives
				// for now, we'll assume the program rescues them on their own time
				// it also doesn't make any sense that a program operative would be able to give any information about the Avenger to ADVENT anyway
				if(UnitState.IsDead() || UnitState.bCaptured) {
					// LEGENDS NEVER DIE
					// WHEN THE WORLD IS CALLING YOU
					// CAN YOU HEAR THEM SCREAMING OUT YOUR NAME?
					// LEGENDS NEVER DIE
					// EVERY TIME YOU BLEED FOR REACHING GREATNESS
					// RELENTLESS YOU SURVIVE
					if(XComHQ.DeadCrew.Find('ObjectID', UnitIteratorObjRef.ObjectID) != INDEX_NONE) {
						XComHQ.DeadCrew.RemoveItem(UnitIteratorObjRef);
					}

					Active.RemoveItem(UnitIteratorObjRef);
					Active.AddItem(UnitIteratorObjRef);
					pgs.Operatives.RemoveItem(UnitIteratorObjRef);
					pgs.Operatives.AddItem(UnitIteratorObjRef);

					NewUnitState.SetStatus(eStatus_Active);
					NewUnitState.SetCurrentStat(eStat_HP, UnitState.GetBaseStat(eStat_HP));
					NewUnitState.SetCurrentStat(eStat_Will, UnitState.GetBaseStat(eStat_Will));
					NewUnitState.bCaptured = false;

					if(NewUnitState.ChosenCaptorRef != EmptyRef) {
						ChosenState = XComGameState_AdventChosen(History.GetGameStateForObjectID(NewUnitState.ChosenCaptorRef.ObjectID));
						ChosenState = XComGameState_AdventChosen(NewGameState.ModifyStateObject(class'XComGameState_AdventChosen', ChosenState.ObjectID));
						ChosenState.ReleaseSoldier(NewGameState, NewUnitState.GetReference());
					} else {
						AlienHeadquarters = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
						AlienHeadquarters = XComGameState_HeadquartersAlien(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersAlien', AlienHeadquarters.ObjectID));
						AlienHeadquarters.CapturedSoldiers.RemoveItem(NewUnitState.GetReference());
					}

					UnitState.ChosenCaptorRef = EmptyRef;

				} else {
					// good job cmdr
					NewUnitState.SetCurrentStat(eStat_HP, UnitState.GetBaseStat(eStat_HP));
					NewUnitState.SetCurrentStat(eStat_Will, UnitState.GetBaseStat(eStat_Will));
					
					pgs.Operatives.RemoveItem(UnitIteratorObjRef);
					pgs.Operatives.AddItem(UnitIteratorObjRef);
					Active.RemoveItem(UnitIteratorObjRef);
					Active.AddItem(UnitIteratorObjRef);
					NewUnitState.bCaptured = false;
				}
			}
		}
	}
	
	return;
}

//---------------------------------------------------------------------------------------
//---Promote All Operatives--------------------------------------------------------------
//---------------------------------------------------------------------------------------
function PromoteAllOperatives(XComGameState NewGameState) {
	local XComGameState_Unit UnitState;
	local StateObjectReference UnitIteratorObjRef;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	foreach Active(UnitIteratorObjRef) {
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitIteratorObjRef.ObjectID));
		UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
		if(UnitState.GetMyTemplateName() == 'RTGhostOperator') { // don't have Kaga level up normally
			continue;
		}

		if(UnitState.GetRank() <= 8) {
			UnitState.RankUpSoldier(NewGameState, ''); // they already have a class
		}
	}

	return;
}

//---------------------------------------------------------------------------------------
//---Add Direct Neural Manpulation Experience--------------------------------------------
//---------------------------------------------------------------------------------------
protected function AddDNMExperience(XComGameState NewGameState) {
	local XComGameState_Unit UnitState, BondMateState;
	local array<XComGameState_Unit> ActiveSquadUnitStates;
	local StateObjectReference BondMateRef, EmptyRef;

	foreach NewGameState.IterateByClassType(class'XComGameState_Unit', UnitState) {
		if(UnitState.GetTeam() == eTeam_XCom && !UnitState.isDead() && !UnitState.bCaptured) {
			ActiveSquadUnitStates.AddItem(UnitState);
		}
	}

	if(ActiveSquadUnitStates.Length == 0) {
		`RTLOG("Didn't find any active XCOM units on the GameState!", true);
		return;
	}

	foreach ActiveSquadUnitStates(UnitState) {
		foreach ActiveSquadUnitStates(BondMateState) {
			BondMateRef = EmptyRef;
			UnitState.HasSoldierBond(BondMateRef);
			if(BondMateRef == EmptyRef) {
				// this soldier has no bond
				continue;
			}

			if(BondMateRef.ObjectID == BondMateState.ObjectID) {
				// don't want to double dip on the sweet gainz bro
				ActiveSquadUnitStates.RemoveItem(BondMateState);
				
				UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
				BondMateState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', BondMateState.ObjectID));
				UnitState.AddXP(GetDNMXPForRank(UnitState));
				BondMateState.AddXP(GetDNMXPForRank(BondMateState));

				// don't need to keep iterating since bonds are 1-to-1
				break;
			}
		}
	}
}


//---------------------------------------------------------------------------------------
//---Retrieve Rescued Program Operatives-------------------------------------------------
//---------------------------------------------------------------------------------------
// If a Program Operative is rescued, they won't be considered a 'special soldier' and will be added to XCOM's Barracks
simulated function RetrieveRescuedProgramOperatives(XComGameState NewGameState) {
	local RTGameState_PersistentGhostSquad pgs;
	local StateObjectReference SquadIteratorObjRef, UnitIteratorObjRef;
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local XComGameState_HeadquartersXCom XComHQ;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));	
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.GetReference().ObjectID));
	foreach Squads(SquadIteratorObjRef) {
		pgs = RTGameState_PersistentGhostSquad(History.GetGameStateForObjectID(SquadIteratorObjRef.ObjectID));
		pgs = RTGameState_PersistentGhostSquad(NewGameState.ModifyStateObject(class'RTGameState_PersistentGhostSquad', pgs.ObjectID));
		if(pgs != none) {
			foreach pgs.InitOperatives(UnitIteratorObjRef) {
				UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitIteratorObjRef.ObjectID));
				if(UnitState == none) {
					`RTLOG("Couldn't find UnitState for ObjectID" $ UnitIteratorObjRef.ObjectID);
					continue;
				}

				// time to clean up
				if(XComHQ.Crew.Find('ObjectID', UnitIteratorObjRef.ObjectID) != INDEX_NONE) {
					XComHQ.RemoveFromCrew(UnitIteratorObjRef);
					pgs.Operatives.RemoveItem(UnitIteratorObjRef);
					pgs.Operatives.AddItem(UnitIteratorObjRef);
					pgs.CapturedOperatives.RemoveItem(UnitIteratorObjRef);
				}
			}
		}
	}
}

//---------------------------------------------------------------------------------------
//---Reload Operative Armaments----------------------------------------------------------
//---------------------------------------------------------------------------------------
// Reset Consumables
simulated function ReloadOperativeArmaments(XComGameState NewGameState) {
	local XComGameStateHistory History;
	local StateObjectReference UnitIteratorObjRef;
	local XComGameState_Unit UnitState, NewUnitState;
	//local XComGameState_Item ItemState, RemoveItemState;
	//local X2ItemTemplateManager	ItemTemplateManager;
	//local InventoryLoadout Loadout, EmptyLoadout;
	//local InventoryLoadoutItem LoadoutItem;
	//local X2EquipmentTemplate EquipmentTemplate;
	//local int idx;
	local XComGameState_Item WeaponState;
	

	History = `XCOMHISTORY;
	//ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	foreach Active(UnitIteratorObjRef) {
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitIteratorObjRef.ObjectID));
		`RTLOG("Reloading Arsenal for " $ UnitState.GetName(eNameType_Nick) $ ".");

		NewUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
		NewUnitState.BlastLoadout(NewGameState);
		NewUnitState.ApplyInventoryLoadout(NewGameState, UnitState.GetMyTemplate().DefaultLoadout);
		
		WeaponState = NewUnitState.GetPrimaryWeapon();
		WeaponState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', WeaponState.ObjectID));
		ApplyWeaponUpgrades(UnitState.GetMyTemplateName(), WeaponState);

	}
}

simulated function int GetDNMXPForRank(XComGameState_Unit UnitState) {
	local int xp;

	if(UnitState.GetSoldierClassTemplate().GetMaxConfiguredRank() >= UnitState.GetRank()) {
		// we're at max rank, no need to grant xp
		return 0;
	}

	xp = max(UnitState.GetRank() - 2, 1);
	return xp;
}

// Faction Stuff

//#############################################################################################
//----------------   FACTION SOLDIERS ---------------------------------------------------------
//#############################################################################################

//---------------------------------------------------------------------------------------
function int GetNumFactionSoldiers(optional XComGameState NewGameState)
{
	local int i;
	local StateObjectReference Ref;

	i = 0;
	foreach Master(Ref) {
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
	local StateObjectReference GhostRef;
	local name GhostTemplateName;

	bOneSmallFavorActivated = true;
	
	if(Deployed == none) {
		RotateRandomSquadToDeploy();
	}

	if(Deployed == none) {
		`RTLOG("The Program has no squads?", true);
		return false; // we... have no squads?
	}

	MissionSite = XComGameState_MissionSite(NewGameState.ModifyStateObject(MissionSite.class, MissionSite.ObjectID));
	foreach Deployed.Operatives(GhostRef) {
		GhostTemplateName = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(GhostRef.ObjectID)).GetMyTemplateName();
		HandleOperativeHelmets(NewGameState);
		`RTLOG("Adding a " $ GhostTemplateName $ " to the SpecialSoldiers for Mission " $ MissionSite.GeneratedMission.Mission.MissionName);
		MissionSite.GeneratedMission.Mission.SpecialSoldiers.AddItem(GhostTemplateName);
	}

	AdjustProgramGearLevel(NewGameState);
	
	iPreviousMaxSoldiersForMission = MissionSite.GeneratedMission.Mission.MaxSoldiers;
	MissionSite.GeneratedMission.Mission.MaxSoldiers = Deployed.Operatives.Length;
	SelectedMissionRef = MissionSite.GetReference();

	return true;
}

simulated function bool UncashOneSmallFavor(XComGameState NewGameState, XComGameState_MissionSite MissionSite) {
	local StateObjectReference GhostRef, EmptyRef;
	local name GhostTemplateName;

	bOneSmallFavorActivated = false;
	
	if(MissionSite.GetReference().ObjectID != SelectedMissionRef.ObjectID) {
		`RTLOG("MissionSite ObjectID is not the same as the SelectedMissionRef! Removing OSF from the SelectedMissionRef instead of the given one!");
		MissionSite = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(SelectedMissionRef.ObjectID));
	}

	if(Deployed == none) {
		`RTLOG("The Program has no squads?", true);
		return false; // we... have no squads?
	}

	MissionSite = XComGameState_MissionSite(NewGameState.ModifyStateObject(MissionSite.class, MissionSite.ObjectID));
	foreach Deployed.Operatives(GhostRef) {
		GhostTemplateName = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(GhostRef.ObjectID)).GetMyTemplateName();
		`RTLOG("Removing a " $ GhostTemplateName $ " from the SpecialSoldiers for Mission " $ MissionSite.GeneratedMission.Mission.MissionName);
		MissionSite.GeneratedMission.Mission.SpecialSoldiers.RemoveItem(GhostTemplateName);
	}
	
	SelectedMissionRef = EmptyRef;
	MissionSite.GeneratedMission.Mission.MaxSoldiers = iPreviousMaxSoldiersForMission;

	return true;
}
	
protected function RotateRandomSquadToDeploy() {
	local bool bFoundSquad;
	local int i;
	if(Squads.Length == 0)
		return;
	
	if(Deployed != none) {
		Deployed.bIsDeployed = false;
		Deployed = none;
	}
	
	while(!bFoundSquad) {
		Deployed = RTGameState_PersistentGhostSquad(`XCOMHISTORY.GetGameStateForObjectID(Squads[`SYNC_RAND(Squads.Length)].ObjectID));
		bFoundSquad = Deployed.CanBeDeployed();
		i++;
		if(i > 20) {
			`RTLOG("Can't find a deployable squad?!", true, false);
			return;
		}
	}

	Deployed.bIsDeployed = true;
	return;
}

function HandleOperativeHelmets(XComGameState NewGameState) {
	local XComGameState_Unit OperativeState;
	local StateObjectReference IteratorRef;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	foreach Master(IteratorRef) {
		OperativeState = XComGameState_Unit(History.GetGameStateForObjectID(IteratorRef.ObjectID));
		OperativeState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', OperativeState.ObjectID));
		if(class'X2DownloadableContentInfo_RisingTides'.default.bShouldRemoveHelmets) {
			OperativeState.kAppearance.nmHelmet = '';
		} else {
			if(OperativeState.kAppearance.iGender == eGender_Female) {
				OperativeState.kAppearance.nmHelmet = 'ALL_WotC_MamaMEA_Remnant_Heavy_Helmet_F';
			} else {
				OperativeState.kAppearance.nmHelmet = 'ALL_WotC_MamaMEA_Remnant_Heavy_Helmet_M';
			}
		}
	}
}

function XComGameState_Unit GetOperative(string Nickname) {
	local XComGameState_Unit UnitState;
	local StateObjectReference IteratorRef;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	foreach Active(IteratorRef) {
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(IteratorRef.ObjectID));
		if(UnitState.GetNickName(true) == Nickname) {
			return UnitState;
		}
	}
}

//#############################################################################################
//-----------------   COVERT ACTIONS  ---------------------------------------------------------
//#############################################################################################

//---------------------------------------------------------------------------------------
// Remove vanilla actions for modded faction where the modded action should override
function AddNewCovertActions(XComGameState NewGameState, int NumActionsToCreate, out array<Name> ExclusionList)
{
	local X2StrategyElementTemplateManager StratMgr;
	local X2CovertActionTemplate ActionTemplate;
	local int idx, iRand;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	// First iterate through the available actions list and check for any that are forced to be created
	for (idx = AvailableCovertActions.Length - 1; idx >= 0; idx--)
	{
		ActionTemplate = X2CovertActionTemplate(StratMgr.FindStrategyElementTemplate(AvailableCovertActions[idx]));
		if (ActionTemplate != none && ActionTemplate.bForceCreation && ExclusionList.Find(ActionTemplate.DataName) == INDEX_NONE)
		{
			if(default.UnavailableCovertActions.Find(ActionTemplate.DataName) == INDEX_NONE)
			{
				AddCovertAction(NewGameState, ActionTemplate, ExclusionList);
				NumActionsToCreate--;
				
				AvailableCovertActions.Remove(idx, 1); // Remove the name from the available actions list
			}
		}
	}

	// Randomly choose available actions from the deck
	while (AvailableCovertActions.Length > 0 && NumActionsToCreate > 0)
	{
		iRand = `SYNC_RAND(AvailableCovertActions.Length);
		ActionTemplate = X2CovertActionTemplate(StratMgr.FindStrategyElementTemplate(AvailableCovertActions[iRand]));
		if (ActionTemplate != none && ExclusionList.Find(ActionTemplate.DataName) == INDEX_NONE)
		{
			if(default.UnavailableCovertActions.Find(ActionTemplate.DataName) == INDEX_NONE)
			{
				AddCovertAction(NewGameState, ActionTemplate, ExclusionList);
				NumActionsToCreate--;			
			}
		}
		
		AvailableCovertActions.Remove(iRand, 1); // Remove the name from the available actions list
	}
}

function PrintGoldenPathActionInformation() {
	local XComGameStateHistory 				History;
	local StateObjectReference 				StateObjRef;
	local XComGameState_CovertAction 		CovertActionState;
	local X2CovertActionTemplate			CovertActionTemplate;

	History = `XCOMHISTORY;

	`RTLOG("Printing Golden Path covert actions for the Program...");
	foreach GoldenPathActions(StateObjRef) {
		CovertActionState = XComGameState_CovertAction(History.GetGameStateForObjectID(StateObjRef.ObjectID));
		if(CovertActionState == none)
			continue;
		CovertActionTemplate = CovertActionState.GetMyTemplate();
		`RTLOG("" $ CovertActionTemplate.DataName);
	}
}

function CreateGoldenPathActions(XComGameState NewGameState)
{
	local X2StrategyElementTemplateManager StratMgr;
	local array<X2StrategyElementTemplate> AllActionTemplates;
	local X2StrategyElementTemplate DataTemplate;
	local X2CovertActionTemplate ActionTemplate;

	// Only perform this setup if there's no more GP actions remaining
	if (GoldenPathActions.Length == 0)
	{
		StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
		AllActionTemplates = StratMgr.GetAllTemplatesOfClass(class'X2CovertActionTemplate');

		foreach AllActionTemplates(DataTemplate)
		{
			ActionTemplate = X2CovertActionTemplate(DataTemplate);

			if(default.ExcludedGoldenPathCovertActions.Find(ActionTemplate.DataName) != INDEX_NONE)
				continue;

			if (ActionTemplate != none && ActionTemplate.bGoldenPath) //we do this so we follow the requirements of Spectres' med to high requirement
			{
				GoldenPathActions.AddItem(CreateCovertAction(NewGameState, ActionTemplate, ActionTemplate.RequiredFactionInfluence));
			}
		}
	}
}

// the 'golden path' for the Program
function InitTemplarQuestActions(XComGameState NewGameState) {
	local X2StrategyElementTemplateManager StratMgr;
	local array<X2StrategyElementTemplate> AllActionTemplates;
	local X2StrategyElementTemplate DataTemplate;
	local X2CovertActionTemplate ActionTemplate;
	local array<name>	TemplarQuestCovertActionTemplateNames;

	if(TemplarQuestActions.Length != 0) {
		`RTLOG("Not creating more Templar Quest Covert Actions...");
		return;
	}

	// oof
	TemplarQuestCovertActionTemplateNames.AddItem('CovertAction_HuntTemplarsP1Template');
	TemplarQuestCovertActionTemplateNames.AddItem('CovertAction_HuntTemplarsP2Template');
	TemplarQuestCovertActionTemplateNames.AddItem('CovertAction_HuntTemplarsP3Template');

	TemplarQuestCovertActionTemplateNames.AddItem('CovertAction_CallInFavorTemplate');

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	AllActionTemplates = StratMgr.GetAllTemplatesOfClass(class'X2CovertActionTemplate');

	foreach AllActionTemplates(DataTemplate)
	{
		ActionTemplate = X2CovertActionTemplate(DataTemplate);
		if (ActionTemplate != none && 
			TemplarQuestCovertActionTemplateNames.Find(ActionTemplate.DataName) != INDEX_NONE)
		{
			TemplarQuestActions.AddItem(CreateTemplarCovertAction(NewGameState, ActionTemplate, ActionTemplate.RequiredFactionInfluence));
		}
	}
}

function StateObjectReference CreateTemplarCovertAction(XComGameState NewGameState, X2CovertActionTemplate ActionTemplate, optional EFactionInfluence UnlockLevel)
{
	local XComGameState_CovertAction ActionState;

	ActionState = ActionTemplate.CreateInstanceFromTemplate(NewGameState, GetReference());
	ActionState.Spawn(NewGameState);
	ActionState.AmbushMissionSource = 'RTMissionSource_TemplarAmbush';
	ActionState.RequiredFactionInfluence = UnlockLevel; // Set the Influence level required to unlock this Action
	ActionState.bNewAction = true;

	return ActionState.GetReference();
}

// if NOT set, the next templar mission (ambush or coven assault) will be considered as failed
function SetTemplarMissionSucceededFlag(bool _bTemplarAmbushMissionSucceed) {
	bTemplarMissionSucceeded = _bTemplarAmbushMissionSucceed;
}

function bool didTemplarMissionSucceed() {
	return bTemplarMissionSucceeded;
}

function bool TemplarQuestlineSucceeded() {
	return iTemplarQuestlineStage == 4;
}

function HandleTemplarQuestActions(XComGameState NewGameState) {
	local XComGameState_CovertAction ActionState;
	local StateObjectReference QuestRef;
	local name QuestTemplateName;
	local XComGameStateHistory History;

	if(hasFailedTemplarQuestline()) {
		`RTLOG("Templar questline failed. Not adding a Covert Action!");
		return;
	}

	switch(iTemplarQuestlineStage) {
		case 0:
			if(!IsTemplarFactionMet()) { return; } // don't print the action if we haven't met the Templars yet
			QuestTemplateName = 'CovertAction_HuntTemplarsP1Template';
			`RTLOG("Adding CovertAction_HuntTemplarsP1Template");
			break;
		case 1:
			QuestTemplateName = 'CovertAction_HuntTemplarsP2Template';
			`RTLOG("Adding CovertAction_HuntTemplarsP2Template");
			break;
		case 2:
			QuestTemplateName = 'CovertAction_HuntTemplarsP3Template';
			`RTLOG("Adding CovertAction_HuntTemplarsP3Template");
			break;
		case 3:
			`RTLOG("Adding Templar Coven Assault Mission!");
		case 4:
			`RTLOG("Templar Questline Completed!");
			QuestTemplateName = 'CovertAction_CallInFavorTemplate';
			`RTLOG("Adding CovertAction_CallInFavorTemplate");
		default:
			`RTLOG("iTemplarQuestStage is out-of-bounds! Ending early...");
			return;
	}

	History = `XCOMHISTORY;
	foreach TemplarQuestActions(QuestRef) {
		ActionState = XComGameState_CovertAction(History.GetGameStateForObjectID(QuestRef.ObjectID));
		if(ActionState.GetMyTemplateName() == QuestTemplateName) {
			CovertActions.AddItem(QuestRef);
		}
	}
}



// clean up the Templar Quest Actions too
function CleanUpFactionCovertActions(XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_CovertAction ActionState;
	local int idx;

	History = `XCOMHISTORY;

	super.CleanUpFactionCovertActions(NewGameState);

	for(idx = 0; idx < TemplarQuestActions.Length; idx++)
	{
		// Clean up any non-started actions created for the facility.
		ActionState = XComGameState_CovertAction(History.GetGameStateForObjectID(TemplarQuestActions[idx].ObjectID));
		if (ActionState != none && !ActionState.bStarted)
		{
			ActionState = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', ActionState.ObjectID));
			ActionState.RemoveEntity(NewGameState);
		}
	}

	TemplarQuestActions.Length = 0;
}

function IncrementTemplarQuestlineStage() {
	iTemplarQuestlineStage++;
}

function int getTemplarQuestlineStage() {
	return iTemplarQuestlineStage;
}

function bool IsTemplarQuestlineComplete() {
	return getTemplarQuestlineStage() == 4;
}

function bool IsTemplarFactionMet() {
	local XComGameState_ResistanceFaction FactionState;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState) {
		if(FactionState.GetMyTemplateName() == 'Faction_Templars') {
			return FactionState.bMetXCom;
		}
	}

	return false;
}

function OnEndOfMonth(XComGameState NewGameState, out array<Name> ActionExclusionList)
{
	super.OnEndOfMonth(NewGamestate, ActionExclusionList);
	InitTemplarQuestActions(NewGameState);
	HandleTemplarQuestActions(NewGameState);

	if(bShouldResetOSFMonthly) {
		MakeOneSmallFavorAvailable();
	}
}

//#############################################################################################
//----------------- GENERAL FACTION METHODS ---------------------------------------------------
//#############################################################################################
simulated function X2ResistanceFactionTemplate GetMyTemplate()
{ 
	if(m_Template == none)
	{
		m_Template = RTProgramFactionTemplate(GetMyTemplateManager().FindStrategyElementTemplate(m_TemplateName));
	}
	return m_Template;
}

//---------------------------------------------------------------------------------------
event OnCreation(optional X2DataTemplate Template)
{
	super.OnCreation( Template );

	m_Template = X2ResistanceFactionTemplate(Template);
	m_TemplateName = Template.DataName;

}

function MeetXCom(XComGameState NewGameState)
{
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameState_ResistanceFaction TemplarFaction;
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
	InitTemplarQuestActions(NewGameState);
	HandleTemplarQuestActions(NewGameState);
	
	CreateRTOperatives(NewGameState);
	CreateRTSquads(NewGameState);
	//CreateRTDeathRecord(StartState);
	bSetupComplete = true;	
	

	// adopt the templar's rival
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', TemplarFaction) {
		if(TemplarFaction.GetMyTemplateName() == 'Faction_Templars') {
			RivalChosen = TemplarFaction.GetRivalChosen().GetReference();
			break;
		}
	}

	// Need one for One Small Favor
	AddOneSmallFavorCard(NewGameState); // this also adds a card slot

	// Normal cards on meet
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

function AddOneSmallFavorCard(XComGameState NewGameState) {
	local XComGameStateHistory History;
	local XComGameState_StrategyCard CardState;
	local StateObjectReference	EmptyCardRef;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_StrategyCard', CardState)
	{
		if(CardState.GetMyTemplateName() != 'ResCard_RTOneSmallFavor') {
			continue;
		}
		
		if(!IsCardAvailable(CardState, 5)) { // card strength is greater than possible, can never draw by accident
			`RTLOG("OSF isn't available?", true, false);
			return;
		}

		if(GetNumCardSlots() < 1) {
			CardSlots.AddItem(EmptyCardRef);
		}

		if(CardSlots[0] != EmptyCardRef) {
			return;
		}
		
		CardState = XComGameState_StrategyCard(NewGameState.ModifyStateObject(class'XComGameState_StrategyCard', CardState.ObjectID));
		CardState.bDrawn = true;
		CardState.bNewCard = true;

		NewPlayableCards.AddItem(CardState.GetReference());
		PlayableCards.AddItem(CardState.GetReference());
		PlaceCardInSlot(CardState.GetReference(), 0);
		CardState.ActivateCard(NewGameState);
	}
}

function PreMissionUpdate(XComGameState NewGameState, XComGameState_MissionSite MissionSiteState) {
	if(bOneSmallFavorActivated) {
		bShouldPerformPostMissionCleanup = true;
	}

	if(MissionSiteState.Source == 'RTMissionSource_TemplarAmbush') {
		bShouldPerformPostMissionCleanup = true;
	}
}

function bool isOneSmallFavorActivated() {
	return bOneSmallFavorActivated;
}

protected function int GetXComGearTier() {
	local array<Name> CompletedTechs;
	return 1;
	CompletedTechs = `RTS.GetCompletedXCOMTechNames();
	if(CompletedTechs.Find('PlasmaRifle') != INDEX_NONE) {
		return 3;
	}
	if(CompletedTechs.Find('MagnetizedWeapons') != INDEX_NONE) {
		return 2;
	}
	
	return 1;
}

protected function int GetAlienForceTier() {
	local XComGameState_HeadquartersAlien AlienHQ;
	local int iAlienForceLevel;

	AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	iAlienForceLevel = AlienHQ.GetForceLevel();

	if(iAlienForceLevel > 13)
		return 3;
	if(iAlienForceLevel > 7)
		return 2;

	return 1;
}

protected function ModifyProgramGearTier(XComGameState NewGameState, int newGearTier) {
	// method assumes that there needs to be a swap
	`RTLOG("Modifying gear tier, old tier was " $ iCurrentProgramGearTier $ ", new tier is " $ newGearTier);
	if(newGearTier < 1 || newGearTier > 3) {
		`RTLOG("new gear tier is out of bounds. Reseting to T3.");
		newGearTier = 3;
	}
	iCurrentProgramGearTier = newGearTier;
	ModifyArmorStats(newGearTier);
	ModifyWeaponStats(newGearTier);
	ReloadOperativeArmaments(NewGameState);
}

function bool hasFailedTemplarQuestline() {
	return bTemplarQuestFailed;
}

function FailTemplarQuestline() {
	bTemplarQuestFailed = true;
}

protected function ModifyArmorStats(int newGearTier) {
	local array<name> AbilityTemplateNames;
	local name AbilityTemplateName;
	local X2AbilityTemplate AbilityTemplate;
	local array<X2AbilityTemplate> AbilityTemplates;
	local X2AbilityTemplateManager AbilityTemplateMgr;

	local X2Effect IteratorEffect;
	local X2Effect_PersistentStatChange ArmorEffect;
	local StatChange IteratorStatChange;
	local X2ItemTemplateManager ItemTemplateMgr;
	local X2ArmorTemplate ArmorTemplate;

	// BEGIN ABILITY TEMPLATE MODIFICATION ****************************************************************************************************
	AbilityTemplateMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityTemplateMgr.GetTemplateNames(AbilityTemplateNames);
	foreach AbilityTemplateNames(AbilityTemplateName) {
		AbilityTemplates.Length = 0;
		AbilityTemplateMgr.FindAbilityTemplateAllDifficulties(AbilityTemplateName, AbilityTemplates);

		foreach AbilityTemplates(AbilityTemplate) {

			if(AbilityTemplate.DataName != 'RTProgramArmorStats')
				continue;

			foreach AbilityTemplate.AbilityTargetEffects(IteratorEffect) {
				ArmorEffect = X2Effect_PersistentStatChange(IteratorEffect);
				if (ArmorEffect == None) {
					continue;
				}
				
				foreach ArmorEffect.m_aStatChanges(IteratorStatChange) {
					if(IteratorStatChange.StatType == eStat_HP) {
						switch(newGearTier) {
							case 1:
								IteratorStatChange.StatAmount = class'RTAbility_Program'.default.PROGRAM_ARMOR_HEALTH_BONUS_T1;
								break;
							case 2:
								IteratorStatChange.StatAmount = class'RTAbility_Program'.default.PROGRAM_ARMOR_HEALTH_BONUS_T2;
								break;
							case 3:
								IteratorStatChange.StatAmount = class'RTAbility_Program'.default.PROGRAM_ARMOR_HEALTH_BONUS_T3;
								break;
							default:
								`RTLOG("Invalid Gear Tier, defaulting to T3.");
								IteratorStatChange.StatAmount = class'RTAbility_Program'.default.PROGRAM_ARMOR_HEALTH_BONUS_T3;
						}
					}
				}
			}
		}
	}
	// END ABILITY TEMPLATE MODIFICATION ******************************************************************************************************

	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ArmorTemplate = X2ArmorTemplate(ItemTemplateMgr.FindItemTemplate('ProgramArmor'));
	switch(newGearTier) {
		case 1:
			ArmorTemplate.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'RTAbility_Program'.default.PROGRAM_ARMOR_HEALTH_BONUS_T1, true);
			break;
		case 2:
			ArmorTemplate.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'RTAbility_Program'.default.PROGRAM_ARMOR_HEALTH_BONUS_T2, true);
			break;
		case 3:
			ArmorTemplate.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'RTAbility_Program'.default.PROGRAM_ARMOR_HEALTH_BONUS_T3, true);
			break;
		default:
			ArmorTemplate.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'RTAbility_Program'.default.PROGRAM_ARMOR_HEALTH_BONUS_T3, true);
	} 
}

protected function ModifyWeaponStats(int newGearTier) {
	local X2ItemTemplateManager ItemTemplateManager;
	local array<Name> ProgramWeaponTemplateNames;
	local name IteratorName;
	local X2WeaponTemplate WeaponTemplate;
	local WeaponDamageValue ModifiedDamageValue;
	local int iDamageMalus;
	
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ProgramWeaponTemplateNames = class'RTItem'.static.GetProgramWeaponTemplateNames();
	foreach ProgramWeaponTemplateNames(IteratorName) {
		WeaponTemplate = X2WeaponTemplate(ItemTemplateManager.FindItemTemplate(IteratorName));
		iDamageMalus = (3 - newGearTier) * 2;	// -> tier 1 = 2 tiers of reduction, tier 2 = 1 tier of reduction, tier 3 = 0 tiers of reduction
												// -> 2 damage per tier
		switch(WeaponTemplate.WeaponCat) {
			case 'pistol':
				iDamageMalus = iDamageMalus / 2;
				ModifiedDamageValue = class'RTItem'.default.PISTOL_PROGRAM_BASEDAMAGE;
				ModifiedDamageValue.Damage -= iDamageMalus;
				WeaponTemplate.BaseDamage = ModifiedDamageValue;
				break;
			case 'sniper_rifle':
				ModifiedDamageValue = class'RTItem'.default.SNIPERRIFLE_PROGRAM_BASEDAMAGE;
				ModifiedDamageValue.Damage -= iDamageMalus;
				WeaponTemplate.BaseDamage = ModifiedDamageValue;
				break;
			case 'shotgun':
				ModifiedDamageValue = class'RTItem'.default.SHOTGUN_PROGRAM_BASEDAMAGE;
				ModifiedDamageValue.Damage -= iDamageMalus;
				WeaponTemplate.BaseDamage = ModifiedDamageValue;
				break;
			case 'rifle':
				ModifiedDamageValue = class'RTItem'.default.ASSAULTRIFLE_PROGRAM_BASEDAMAGE;
				ModifiedDamageValue.Damage -= iDamageMalus;
				WeaponTemplate.BaseDamage = ModifiedDamageValue;
				break;
			case 'sword':
				ModifiedDamageValue = class'RTItem'.default.SWORD_PROGRAM_BASEDAMAGE;
				ModifiedDamageValue.Damage -= iDamageMalus;
				WeaponTemplate.BaseDamage = ModifiedDamageValue;
				break;
			default:
				//continue;
		}
	}
}

public function AdjustProgramGearLevel(XComGameState NewGameState) {
	local int iXComGearTier;
	local int iAlienForceTier;

	iXComGearTier = GetXComGearTier();
	iAlienForceTier = GetAlienForceTier();
	`RTLOG("XComGearTier = " $ iXComGearTier);
	`RTLOG("AlienForceTier = " $ iAlienForceTier);
	`RTLOG("CurrentProgramGearTier = " $ iCurrentProgramGearTier);
	if(iCurrentProgramGearTier != iAlienForceTier) {
		ModifyProgramGearTier(NewGameState, iAlienForceTier);
	}
}

function PerformPostMissionCleanup(XComGameState NewGameState) {
	bShouldPerformPostMissionCleanup = false;

	RecalculateActiveOperativesAndSquads(NewGameState);
	RetrieveRescuedProgramOperatives(NewGameState);
	ReloadOperativeArmaments(NewGameState);

	if(bOneSmallFavorActivated) {
		bOneSmallFavorAvailable = false;
		bOneSmallFavorActivated = false;
	}
}

function TryIncreaseInfluence() {
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local XComGameState_Reward RewardState;
	local XComGameState NewGameState;
	local RTGameState_ProgramFaction Program;
	local int iGuarenteedCorrectValue; // too lazy to see what the correct value should be XDDD

	iNumberOfFavorsCalledIn++;
	iGuarenteedCorrectValue = iNumberOfFavorsCalledIn;

	if(iNumberOfFavorsCalledIn >= default.iNumberOfFavorsRequiredToIncreaseInfluence) {
		// Award influence increase
		`RTLOG("Enough Favors have been called in. Increasing influence.", false, true);
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RisingTides: Increasing Influence");
		Program = RTGameState_ProgramFaction(NewGameState.ModifyStateObject(class'RTGameState_ProgramFaction', self.ObjectID));
		StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
		
		RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_RTProgram_IncreaseFactionInfluence'));
		
		RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
		RewardState.GetMyTemplate().GenerateRewardFn(RewardState, NewGameState,,GetReference()); 
		RewardState.GiveReward(NewGameState, GetReference());
		
		// Reset number of favors
		Program.iNumberOfFavorsCalledIn = 0;
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

		// This method creates and submits another new game state
		RewardState.DisplayRewardPopup();
	} else {
		`RTLOG("Not enough Favors have been called in. Not increasing influence.", false, true);
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RisingTides: Increasing Influence");
		Program = RTGameState_ProgramFaction(NewGameState.ModifyStateObject(class'RTGameState_ProgramFaction', self.ObjectID));
		Program.iNumberOfFavorsCalledIn = iGuarenteedCorrectValue;
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
}

function ForceIncreaseInfluence() {
	local int iInfluence;

	iInfluence = Influence;
	iInfluence++;

	if(iInfluence > 4) {
		return;
	}

	Influence = EFactionInfluence(iInfluence);
}

// Listen for AvengerLandedScanRegion, recieves a NewGameState
// can pull an XComGameState_ScanningSite from XComHQ.CurrentLocation attached to the NewGameState
// check to see if the resistance is building an outpost
// set ScanHoursRemaining, and TotalScanHours to 1

// List for Override Event, recieves a LWTuple
// Event Data is the Tuple, the Event Source is the RegionState
// Tuple should have one bool, set it to true
static function EventListenerReturn FortyYearsOfWarEventListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	//local XComGameState NewGameState;
	//local XComGameState_WorldRegion RegionState;
	//local XComGameState_HeadquartersXCom XComHQ;
	local XComLWTuple Tuple;

	`RTLOG("Forty Years of War Triggered!");
	Tuple = XComLWTuple(EventData);
	if(Tuple == none) {
		`RTLOG("FYOW did not recieve a LWTuple, ending...", true);
		`RTLOG("" $ EventData.class);
		return ELR_NoInterrupt;
	}

	if(Tuple.Id != 'RegionOutpostBuildStart') {
		`RTLOG("FYOW did not receive the correct Tuple, ending...", true);
		return ELR_NoInterrupt;
	}

	Tuple.Data[0].b = true;

	`RTLOG("Forty Years of War successfully executed!");
	return ELR_NoInterrupt;
}

// RealityMachina's code
static function InitFaction(optional XComGameState StartState) {
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local RTProgramFactionTemplate FactionTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local X2StrategyElementTemplate DataTemplate;
	local RTGameState_ProgramFaction FactionState;
	local array<StateObjectReference> AllHavens;
	local RTGameState_Haven HavenState;
	local XComGameState_Haven IteratorHavenState;
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameState_WorldRegion RegionState;
	local StateObjectReference RegionRef;

	`RTLOG("Trying to add the Program as a Faction...");

	History = class'XComGameStateHistory'.static.GetGameStateHistory();
	ResHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	if(StartState == none) {
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding the Program Faction Object...");
	} else {
		NewGameState = StartState;
	}

	if(ResHQ.GetFactionByTemplateName('Faction_Program') == none) { // no faction, add it ourselves 
		`RTLOG("Didn't find it, adding the Program to the campaign!");
		ResHQ = XComGameState_HeadquartersResistance(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersResistance', ResHQ.ObjectID)); 
		DataTemplate = StratMgr.FindStrategyElementTemplate('Faction_Program');
		if(DataTemplate != none)
		{
			FactionTemplate = RTProgramFactionTemplate(DataTemplate);
			FactionState = RTGameState_ProgramFaction(FactionTemplate.CreateInstanceFromTemplate(NewGameState));
			ResHQ.Factions.AddItem(FactionState.GetReference());

			FactionState.FactionName = FactionTemplate.GenerateFactionName();
			FactionState.FactionIconData = FactionTemplate.GenerateFactionIcon();
		}

		foreach History.IterateByClassType(class'XComGameState_Haven', IteratorHavenState)
		{
			if(!IteratorHavenState.IsFactionHQ())
				AllHavens.AddItem(IteratorHavenState.GetReference());
		}
		IteratorHavenState = XComGameState_Haven(History.GetGameStateForObjectID(AllHavens[`SYNC_RAND_STATIC(AllHavens.Length)].ObjectID));
		RegionRef = IteratorHavenState.Region;

		RegionState = XComGameState_WorldRegion(History.GetGameStateForObjectID(RegionRef.ObjectID));
		RegionState = XComGameState_WorldRegion(NewGameState.ModifyStateObject(class'XComGameState_WorldRegion', RegionRef.ObjectID));

		FactionState.HomeRegion = RegionRef;
		FactionState.Region = RegionRef;
		FactionState.Continent = RegionState.Continent;

		HavenState = RTGameState_Haven(NewGameState.CreateNewStateObject(class'RTGameState_Haven'));
		HavenState.Region = RegionRef;
		HavenState.Continent = IteratorHavenState.Continent;
		HavenState.FactionRef = FactionState.GetReference();
		HavenState.SetScanHoursRemaining(`ScaleStrategyArrayInt(HavenState.MinScanDays), `ScaleStrategyArrayInt(HavenState.MaxScanDays));
		HavenState.MakeScanRepeatable();
		HavenState.Location = IteratorHavenState.Location;
		HavenState.Rotation = IteratorHavenState.Rotation;
		HavenState.bNeedsLocationUpdate = true;

		RegionState.RemoveHaven(NewGameState);
		RegionState.Haven = HavenState.GetReference();
	
		FactionState.FactionHQ = HavenState.GetReference();
		FactionState.SetUpProgramFaction(NewGameState);
		FactionState.CreateGoldenPathActions(NewGameState);
		FactionState.InitTemplarQuestActions(NewGameState);
	}
	else {
		`RTLOG("The Program was already present.");
	}

	if(NewGameState.GetNumGameStateObjects() > 0) {
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else {
		History.CleanupPendingGameState(NewGameState);
	}
}

static function DisplayOSFFirstTimePopup() {
	`PRESBASE.UITutorialBox(default.OSFFirstTime_Title, default.OSFFirstTime_Text, default.OSFFirstTime_ImagePath);
}

static function DisplayPISFirstTimePopup() {
	`PRESBASE.UITutorialBox(default.PISFirstTime_Title, default.PISFirstTime_Text, default.PISFirstTime_ImagePath);
}

function PrintDebuggingInfo() {
	`RTLOG("Is Favor Available");
	`RTLOG("" $ bOneSmallFavorAvailable);
	`RTLOG("Number of Favors remaining");
	`RTLOG("" $ iNumberOfFavorsAvailable);
}

public function int GetCurrentVersion() {
	return Version;
}

public function bool CompareVersion(int newVersion, // the version to compare against
									optional bool bShouldNotUpdateVersion = false // if this is set, do not update the version to the newerVersion
) {
	if(newVersion > GetCurrentVersion()) {
		// the new version is newer
		if(!bShouldNotUpdateVersion) {
			Version = newVersion;
		}
		return true;
	} else {
		// the new version is either equal or older
		return false;
	}
}