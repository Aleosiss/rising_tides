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
var() array<StateObjectReference> 								Active;				// ghosts active
var() RTGameState_PersistentGhostSquad							Deployed; 			// ghosts that will be on the next mission
var() array<StateObjectReference>								Captured;			// ghosts not available
var() array<StateObjectReference>								Squads;				// list of ghost teams (only one for now)
var() int 														iOperativeLevel;	// all ghosts get level ups after a mission, even if they weren't on it. lorewise, they're constantly running missions; the player only sees a fraction of them
var bool														bSetupComplete;		// if we should rebuild the ghost array from config

/* END OPERATIVE RECORD   */


// FACTION VARIABLES
var bool																bOneSmallFavorAvailable;		// can send squad on a mission, replacing XCOM
var bool																bTemplarsDestroyed;
var bool																bDirectNeuralManipulation;
var config array<name>													InvalidMissionSources; 			// list of mission types ineligible for Program support, usually story missions

// ONE SMALL FAVOR HANDLING VARIABLES
var private int															iPreviousMaxSoldiersForMission; // cache of the number of soldiers on a mission before OSF modfied it
var private StateObjectReference										SelectedMissionRef;				// cache of the mission one small favor is going to go against

/* *********************************************************************** */

// SetUpProgramFaction(XComGameState StartState)
 function SetUpProgramFaction(XComGameState StartState)
{
	InitListeners();
	class'RTGameState_StrategyCard'.static.SetUpStrategyCards(StartState);
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
	local XComGameState_Unit UnitState;

	UnitState = CreateRTOperative(GhostTemplateName, StartState);
	Active.AddItem(UnitState.GetReference());
	Master.AddItem(UnitState.GetReference());
}

function XComGameState_Unit CreateRTOperative(name GhostTemplateName, XComGameState StartState) {
	local XComGameState_Unit UnitState;
	
	local X2CharacterTemplateManager CharMgr;
	local X2CharacterTemplate CharTemplate;
	local XComGameState_Item WeaponState;

	local name WeaponUpgradeName;

	CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	CharTemplate = CharMgr.FindCharacterTemplate(GhostTemplateName);

	UnitState = CharTemplate.CreateInstanceFromTemplate(StartState);

	UnitState.SetCountry(CharTemplate.DefaultAppearance.nmFlag);
	UnitState.RankUpSoldier(StartState, CharTemplate.DefaultSoldierClass);
	UnitState.ApplyInventoryLoadout(StartState, CharTemplate.DefaultLoadout);
	UnitState.StartingRank = 1;
	UnitState.SetUnitName(CharTemplate.strForcedFirstName, CharTemplate.strForcedLastName, CharTemplate.strForcedNickName);
	UnitState.SetBackground(UnitState.GetMyTemplate().strCharacterBackgroundMale[0]); // the first background is the classified one, the second one is the unclassified one

	WeaponState = UnitState.GetPrimaryWeapon();
	ApplyWeaponUpgrades(GhostTemplateName, WeaponState);

	class'RTHelpers'.static.RTLog( "Creating Program Operative " $ UnitState.GetFullName() $ 
							", with ObjectID " $ UnitState.GetReference().ObjectID $
							", and CharacterTemplateName " $ UnitState.GetMyTemplateName()
						);

	return UnitState;
}

function ApplyWeaponUpgrades(name GhostTemplateName, XComGameState_Item WeaponState) {
	local X2WeaponUpgradeTemplate UpgradeTemplate;
	local X2ItemTemplateManager ItemTemplateMgr;
	local name WeaponUpgradeName;

	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	switch(GhostTemplateName) {
		case 'RTGhostBerserker':
			foreach default.BerserkerWeaponUpgrades(WeaponUpgradeName) {
				UpgradeTemplate = X2WeaponUpgradeTemplate(ItemTemplateMgr.FindItemTemplate(WeaponUpgradeName));
				if (UpgradeTemplate != none) {
					WeaponState.ApplyWeaponUpgradeTemplate(UpgradeTemplate);
				}
			}
		case 'RTGhostMarksman':
			foreach default.MarksmanWeaponUpgrades(WeaponUpgradeName) {
				UpgradeTemplate = X2WeaponUpgradeTemplate(ItemTemplateMgr.FindItemTemplate(WeaponUpgradeName));
				if (UpgradeTemplate != none) {
					WeaponState.ApplyWeaponUpgradeTemplate(UpgradeTemplate);
				}
			}
		case 'RTGhostGatherer':
			foreach default.GathererWeaponUpgrades(WeaponUpgradeName) {
				UpgradeTemplate = X2WeaponUpgradeTemplate(ItemTemplateMgr.FindItemTemplate(WeaponUpgradeName));
				if (UpgradeTemplate != none) {
					WeaponState.ApplyWeaponUpgradeTemplate(UpgradeTemplate);
				}
			}
	}
}

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
	MissionState = XComGameState_MissionSite(History.GetGameStateForObjectID(XComHQ.MissionRef.ObjectID));

	if(bDirectNeuralManipulation) {
		AddDNMExperience(NewGamestate);
	}

	if(IsOSFMission(MissionState)) {
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.GetReference().ObjectID));
		RecalculateActiveOperativesAndSquads(NewGameState);
		PromoteAllOperatives(NewGameState);
	}
}

protected static function bool IsOSFMission(XComGameState_MissionSite MissionState) {
	if(MissionState.TacticalGameplayTags.Find('RTOneSmallFavor') != INDEX_NONE) {
		return true;
	}
	return false;
}

protected function RecalculateActiveOperativesAndSquads(XComGameState NewGameState) {
	// Have to tell all of the RTGameState_PersistentSquads about what members of theirs were captured/rescued
	local RTGameState_PersistentGhostSquad pgs;
	local StateObjectReference SquadIteratorObjRef, UnitIteratorObjRef;
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState, NewUnitState;

	History = `XCOMHISTORY;
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

				if(UnitState.bCaptured) {
					// unfort
					pgs.Operatives.RemoveItem(UnitIteratorObjRef);
					pgs.CapturedOperatives.RemoveItem(UnitIteratorObjRef);	// maybe paranoid, remove duplicates
					pgs.CapturedOperatives.AddItem(UnitIteratorObjRef);
				} else if(UnitState.IsDead()) {
					// LEGENDS NEVER DIE
					// WHEN THE WORLD IS CALLING YOU
					// CAN YOU HEAR THEM SCREAMING OUT YOUR NAME?
					// LEGENDS NEVER DIE
					// EVERY TIME YOU BLEED FOR REACHING GREATNESS
					// RELENTLESS YOU SURVIVE
					NewUnitState.SetStatus(eStatus_Active);
					NewUnitState.SetCurrentStat(eStat_HP, UnitState.GetMaxStat(eStat_HP));
					NewUnitState.SetCurrentStat(eStat_Will, UnitState.GetMaxStat(eStat_Will));
				} else {
					// good job cmdr
					pgs.Operatives.RemoveItem(UnitIteratorObjRef);
					pgs.Operatives.AddItem(UnitIteratorObjRef);
					pgs.CapturedOperatives.RemoveItem(UnitIteratorObjRef);
				}

			}
		}
	}
	
	return;
}

protected function PromoteAllOperatives(XComGameState NewGameState) {
	//TODO:: this
	// Promote all operatives after a OSF mission.
	local XComGameState_Unit UnitState;
	local StateObjectReference UnitIteratorObjRef;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	foreach Active(UnitIteratorObjRef) {
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitIteratorObjRef.ObjectID));
		if(UnitState.GetRank() <= 8) {
			UnitState.RankUpSoldier(NewGameState, ''); // they already have a class
		}
	}

	return;
}

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
	local int idx;

	super.OnCreation( Template );

	m_Template = X2ResistanceFactionTemplate(Template);
	m_TemplateName = Template.DataName;

	for(idx = 0; idx < default.StartingCardSlots; idx++)
	{
		// Add Slots with empty entries
		AddCardSlot();
	}
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
	if(bOneSmallFavorAvailable) {
		bOneSmallFavorAvailable = false;
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