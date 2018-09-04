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
var localized string SquadOneName;
var localized string SquadOneBackground;
var config array<name> SquadOneMembers;
var config name SquadOneSitRepName;
var config array<name> BerserkerWeaponUpgrades;
var config array<name> MarksmanWeaponUpgrades;
var config array<name> GathererWeaponUpgrades;


var() array<StateObjectReference>								Master; 			// master list of operatives
var() array<StateObjectReference> 								Active;				// operatives active
var() RTGameState_PersistentGhostSquad					Deployed; 			// operatives that will be on the next mission
var() array<StateObjectReference>								Captured;			// operatives not available
var() array<StateObjectReference>								Squads;				// list of ghost teams (only one for now)
var() int 																		iOperativeLevel;	// all operatives get level ups after a mission, even if they weren't on it. lorewise, they're constantly running missions; the player only sees a fraction of them
var bool														bSetupComplete;		// if we should rebuild the operative array from config

/* END OPERATIVE RECORD   */


// FACTION VARIABLES
var bool																bShouldPerformPostMissionCleanup;	// should cleanup the program's roster after a mission-- set during OSF and JPT missions
var bool																bTemplarsDestroyed;
var bool																bDirectNeuralManipulation;
var config array<name>											InvalidMissionSources;				// list of mission types ineligible for Program support, usually story missions
var config array<name>											UnavailableCovertActions;			// list of covert actions that the program cannot carry out
var config int															iNumberOfFavorsRequiredToIncreaseInfluence;
var array<X2DataTemplate>									OperativeTemplates;

// ONE SMALL FAVOR HANDLING VARIABLES
var private int															iPreviousMaxSoldiersForMission;		// cache of the number of soldiers on a mission before OSF modfied it
var private StateObjectReference							SelectedMissionRef;			// cache of the mission one small favor is going to go against
var bool																bShouldResetOSFMonthly;
var bool																bOneSmallFavorAvailable;			// can send squad on a mission, replacing XCOM
var bool																bOneSmallFavorActivated;			// actively sending a squad on the next mission
var int																	iNumberOfFavorsCalledIn;			
var bool																bOSF_FirstTimeDisplayed;

// ONE SMALL FAVOR LOCALIZED STRINGS
var localized string OSFCheckboxAvailable;
var localized string OSFCheckboxUnavailable;
var localized string OSFFirstTime_Title;
var localized string OSFFirstTime_Text;
var localized string OSFFirstTime_ImagePath;

/* *********************************************************************** */

// SetUpProgramFaction(XComGameState StartState)
 function SetUpProgramFaction(XComGameState StartState)
{
	InitListeners();
	class'RTGameState_StrategyCard'.static.SetUpStrategyCards(StartState);
	OperativeTemplates = class'RTCharacter_DefaultCharacters'.static.CreateTemplates();
	iNumberOfFavorsCalledIn = 0;
}

function InitializeHQ(XComGameState NewGameState, int idx) {
	super.InitializeHQ(NewGameState, idx);
	SetUpProgramFaction(NewGameState);
}

// CreateRTOperatives(XComGameState NewGameState)
function CreateRTOperatives(XComGameState StartState) {
	AddRTOperativeToProgram('RTGhostBerserker', StartState);
	AddRTOperativeToProgram('RTGhostMarksman', StartState);
	AddRTOperativeToProgram('RTGhostGatherer', StartState);
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
	local X2DataTemplate IteratorTemplate;
	local XComGameState_Item WeaponState;
	local name WeaponUpgradeName;
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

	WeaponState = UnitState.GetPrimaryWeapon();
	WeaponState = XComGameState_Item(StartState.ModifyStateObject(class'XComGameState_Item', WeaponState.ObjectID));
	ApplyWeaponUpgrades(GhostTemplateName, WeaponState);

	class'RTHelpers'.static.RTLog( "Creating Program Operative " $ UnitState.GetName(eNameType_Nick) $ 
							", with ObjectID " $ UnitState.GetReference().ObjectID $
							", and CharacterTemplateName " $ UnitState.GetMyTemplateName()
						);

	return UnitState;
}

function ApplyWeaponUpgrades(name GhostTemplateName, XComGameState_Item NewWeaponState) {
	local X2WeaponUpgradeTemplate UpgradeTemplate;
	local X2ItemTemplateManager ItemTemplateMgr;
	local name WeaponUpgradeName;
	local int idx;

	local name DebugIteratorName;
	local array<name> DebuggingNames;

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
			for(idx = 0; idx < default.MarksmanWeaponUpgrades.Length; idx++) {
				UpgradeTemplate = X2WeaponUpgradeTemplate(ItemTemplateMgr.FindItemTemplate(default.MarksmanWeaponUpgrades[idx]));
				if (UpgradeTemplate != none) {
					NewWeaponState.ApplyWeaponUpgradeTemplate(UpgradeTemplate, idx);
				}
			}
			NewWeaponState.Nickname = "Heartspan";
			break;
		case 'RTGhostGatherer':
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

	local RTGameState_PersistentGhostSquad one;
	local StateObjectReference OperativeRef;
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;

	History = `XCOMHISTORY;

	one = RTGameState_PersistentGhostSquad(StartState.CreateNewStateObject(class'RTGameState_PersistentGhostSquad'));
	one.CreateSquad(1, default.SquadOneName, default.SquadOneBackground, default.SquadOneSitRepName);
	Squads.AddItem(one.GetReference());

	foreach Master(OperativeRef) {
		// team 1 "SPECTRE"
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(OperativeRef.ObjectID));
		if(SquadOneMembers.Find(UnitState.GetMyTemplateName()) != INDEX_NONE) {
			one.Operatives.AddItem(OperativeRef);
			one.initOperatives.AddItem(OperativeRef);
		}
	}

	Deployed = one;
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
	local XComGameState_Unit UnitState;
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
		PromoteAllOperatives(NewGameState);
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

function MakeOneSmallFavorAvailable() {
	local DynamicPropertySet PropertySet;
	// add some checks here...
	if(!bOSF_FirstTimeDisplayed) {
		bOSF_FirstTimeDisplayed = true;
		class'X2StrategyGameRulesetDataStructures'.static.BuildDynamicPropertySet(PropertySet, 'UIAlert_OSFFirstTime', 'UITutorialBox', none, false, false, true, false);
		class'XComPresentationLayerBase'.static.QueueDynamicPopup(PropertySet);
	}

	if(Deployed == none) {
		RotateRandomSquadToDeploy();
	}

	bOneSmallFavorAvailable = true;
}

//---------------------------------------------------------------------------------------
//---Blast Operative Loadouts------------------------------------------------------------
//---------------------------------------------------------------------------------------
// need to blast operative loadouts before they hit post-game, because otherwise XCOM
// will scoop up their gear
protected function BlastOperativeLoadouts(XComGameState NewGameState) {
	local XComGameState_Unit UnitState;
	local XComGameStateHistory History;
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
					class'RTHelpers'.static.RTLog("Couldn't find UnitState for ObjectID" $ UnitIteratorObjRef.ObjectID);
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
protected function PromoteAllOperatives(XComGameState NewGameState) {
	local XComGameState_Unit UnitState;
	local StateObjectReference UnitIteratorObjRef;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	foreach Active(UnitIteratorObjRef) {
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitIteratorObjRef.ObjectID));
		UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
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
		class'RTHelpers'.static.RTLog("Didn't find any active XCOM units on the GameState!", true);
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
	local XComGameState_Unit UnitState, NewUnitState;
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
					class'RTHelpers'.static.RTLog("Couldn't find UnitState for ObjectID" $ UnitIteratorObjRef.ObjectID);
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
	local StateObjectReference SquadIteratorObjRef, UnitIteratorObjRef;
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState_Item ItemState, RemoveItemState;
	local X2ItemTemplateManager	ItemTemplateManager;
	local InventoryLoadout Loadout, EmptyLoadout;
	local InventoryLoadoutItem LoadoutItem;
	local X2EquipmentTemplate EquipmentTemplate;
	local int idx;
	local XComGameState_Item WeaponState;
	

	History = `XCOMHISTORY;
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	foreach Active(UnitIteratorObjRef) {
		Loadout = EmptyLoadout;
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitIteratorObjRef.ObjectID));
		class'RTHelpers'.static.RTLog("Reloading Arsenal for " $ UnitState.GetName(eNameType_Nick) $ ".");

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
	local StateObjectReference GhostRef, EmptyRef;
	local name GhostTemplateName;
	
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
		class'RTHelpers'.static.RTLog("Adding a " $ GhostTemplateName $ " to the SpecialSoldiers for Mission " $ MissionSite.GeneratedMission.Mission.MissionName);
		MissionSite.GeneratedMission.Mission.SpecialSoldiers.AddItem(GhostTemplateName);
	}
	
	iPreviousMaxSoldiersForMission = MissionSite.GeneratedMission.Mission.MaxSoldiers;
	MissionSite.GeneratedMission.Mission.MaxSoldiers = Deployed.Operatives.Length;
	SelectedMissionRef = MissionSite.GetReference();

	return true;
}

simulated function bool UncashOneSmallFavor(XComGameState NewGameState, XComGameState_MissionSite MissionSite) {
	local StateObjectReference GhostRef, EmptyRef;
	local name GhostTemplateName;
	
	if(MissionSite.GetReference().ObjectID != SelectedMissionRef.ObjectID) {
		class'RTHelpers'.static.RTLog("MissionSite ObjectID is not the same as the SelectedMissionRef! Removing OSF from the SelectedMissionRef instead of the given one!");
		MissionSite = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(SelectedMissionRef.ObjectID));
	}

	if(Deployed == none) {
		class'RTHelpers'.static.RTLog("The Program has no squads?", true);
		return false; // we... have no squads?
	}

	MissionSite = XComGameState_MissionSite(NewGameState.ModifyStateObject(MissionSite.class, MissionSite.ObjectID));
	foreach Deployed.Operatives(GhostRef) {
		GhostTemplateName = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(GhostRef.ObjectID)).GetMyTemplateName();
		class'RTHelpers'.static.RTLog("Removing a " $ GhostTemplateName $ " from the SpecialSoldiers for Mission " $ MissionSite.GeneratedMission.Mission.MissionName);
		MissionSite.GeneratedMission.Mission.SpecialSoldiers.RemoveItem(GhostTemplateName);
	}
	
	SelectedMissionRef = EmptyRef;
	MissionSite.GeneratedMission.Mission.MaxSoldiers = iPreviousMaxSoldiersForMission;

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

			if(ActionTemplate.DataName == 'CovertAction_FindFaction' || ActionTemplate.DataName == 'CovertAction_FindFarthestFaction')
				continue; //actively skip this one

			if (ActionTemplate != none && ActionTemplate.bGoldenPath) //we do this so we follow the requirements of Spectres' med to high requirement
			{
				GoldenPathActions.AddItem(CreateCovertAction(NewGameState, ActionTemplate, ActionTemplate.RequiredFactionInfluence));
			}
		}
	}
}

function OnEndOfMonth(XComGameState NewGameState, out array<Name> ActionExclusionList)
{
	super.OnEndOfMonth(NewGamestate, ActionExclusionList);

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

function GenerateNewPlayableCard(XComGameState NewGameState)
{
	local XComGameState_StrategyCard NewCardState, IteratorCardState;
	local StateObjectReference IteratorRef;
	local XComGameStateHistory History;

	NewCardState = GetRandomCardToMakePlayable(NewGameState);
	if(NewCardState == none) {
		//class'RTHelpers'.static.RTLog("Couldn't make a random card playable!");
		return;
	}

	// No duplicates please
	History = `XCOMHISTORY;
	foreach PlayableCards(IteratorRef) {
		IteratorCardState = XComGameState_StrategyCard(History.GetGameStateForObjectID(IteratorRef.ObjectID));
		if(IteratorCardState == none) {
			continue;
		}

		if(NewCardState.GetMyTemplateName() == IteratorCardState.GetMyTemplateName()) {
			class'RTHelpers'.static.RTLog("Created a duplicate card, returning none!");
			return;
		}
	}

	foreach NewPlayableCards(IteratorRef) {
		IteratorCardState = XComGameState_StrategyCard(History.GetGameStateForObjectID(IteratorRef.ObjectID));
		if(IteratorCardState == none) {
			continue;
		}

		if(NewCardState.GetMyTemplateName() == IteratorCardState.GetMyTemplateName()) {
			class'RTHelpers'.static.RTLog("Created a duplicate card, returning none!");
			return;
		}
	}

	AddPlayableCard(NewGameState, NewCardState.GetReference());
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
	AddCardSlot();
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
	if(bOneSmallFavorActivated) {
		bShouldPerformPostMissionCleanup = true;
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

	iNumberOfFavorsCalledIn++;

	if(iNumberOfFavorsCalledIn >= default.iNumberOfFavorsRequiredToIncreaseInfluence) {
		// Award influence increase
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
	}
}

// Listen for AvengerLandedScanRegion, recieves a NewGameState
// can pull an XComGameState_ScanningSite from XComHQ.CurrentLocation attached to the NewGameState
// check to see if the resistance is building an outpost
// set ScanHoursRemaining, and TotalScanHours to 1
static function EventListenerReturn FortyYearsOfWarEventListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameState NewGameState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_HeadquartersXCom XComHQ;

	class'RTHelpers'.static.RTLog("Forty Years of War Triggered!");
	foreach GameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ) {
		if(XComHQ != none) {
			break;
		}
	}

	RegionState = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(XComHQ.CurrentLocation.ObjectID));
	if(RegionState == none) {
		class'RTHelpers'.static.RTLog("FortyYearsOfWarEventListener did not recieve a region!", true);
		return ELR_NoInterrupt;
	}

	if(!RegionState.bCanScanForOutpost) {
		class'RTHelpers'.static.RTLog("Can't modify outpost build time, since we aren't scanning for one!");
		return ELR_NoInterrupt;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("FortyYearsOfWar modifying outpost build time!");
	RegionState = XComGameState_WorldRegion(NewGameState.ModifyStateObject(class'XComGameState_WorldRegion', RegionState.ObjectID));
	RegionState.ModifyRemainingScanTime(0.0001);
	`GAMERULES.SubmitGameState(NewGameState);
	class'RTHelpers'.static.RTLog("Forty Years of War successfully executed!");
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
	local XComGameState_Haven HavenState;
	local XComGameState_HeadquartersResistance ResHQ;

	History = class'XComGameStateHistory'.static.GetGameStateHistory();
	ResHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	if(StartState == none) {
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding the Program Faction Object...");
	} else  {
		NewGameState = StartState;
	}

	if(ResHQ.GetFactionByTemplateName('Faction_Program') == none) {  //no faction, add it ourselves 
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

		foreach History.IterateByClassType(class'XComGameState_Haven', HavenState)
		{
			if(!HavenState.IsFactionHQ())
				AllHavens.AddItem(HavenState.GetReference());
		}

		if(AllHavens.Length == 0) {
			class'RTHelpers'.static.RTLog("Couldn't find a Haven to attach the Faction to!");
		}

		HavenState = XComGameState_Haven(NewGameState.ModifyStateObject(class'XComGameState_Haven', AllHavens[`SYNC_RAND_STATIC(AllHavens.Length)].ObjectID));

		FactionState.HomeRegion = HavenState.Region;
		FactionState.Region = FactionState.HomeRegion;
		FactionState.Continent = FactionState.GetWorldRegion().Continent;
		HavenState.FactionRef = FactionState.GetReference();
		HavenState.SetScanHoursRemaining(`ScaleStrategyArrayInt(HavenState.MinScanDays), `ScaleStrategyArrayInt(HavenState.MaxScanDays));
		HavenState.MakeScanRepeatable();
	
		FactionState.FactionHQ = HavenState.GetReference();
		FactionState.SetUpProgramFaction(NewGameState);
		FactionState.CreateGoldenPathActions(NewGameState);
	}

	if(NewGameState.GetNumGameStateObjects() > 0) {
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else {
		History.CleanupPendingGameState(NewGameState);
	}
}

static function DisplayFirstTimePopup() {
	`PRESBASE.UITutorialBox(default.OSFFirstTime_Title, default.OSFFirstTime_Text, default.OSFFirstTime_ImagePath);
}