class RTCommandManager extends X2DownloadableContentInfo_RisingTides;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---BEGIN COMMANDS----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

exec function RT_PrintResistanceFactionNames() {
	local XComGameStateHistory 					History;
	local XComGameState_ResistanceFaction 		Faction;
	//local object 								obj;

	History = `XCOMHISTORY;

	`RTLOG("printing faction names...", false);
	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', Faction) {
		if(Faction != none) {
			`RTLOG("" $ Faction.GetMyTemplateName());
		}
	}
}

exec function RT_PrintProgramFactionInformation(optional bool bShouldPrintFullInfo = false, optional bool bShouldPrintAllFields = false) {
	local XComGameStateHistory 				History;
	local RTGameState_ProgramFaction 		Faction;

	History = `XCOMHISTORY;

	`RTLOG("Gathering Debug Information for the Program...");
	Faction = class'RTHelpers'.static.GetProgramState();

	if(bShouldPrintFullInfo) {
		`RTLOG(Faction.ToString(bShouldPrintAllFields), , true);
		return;
	}

	`RTLOG("Printing Golden Path covert actions for the Program...");
	class'RTHelpers'.static.PrintGoldenPathActionsForFaction(Faction);

	`RTLOG("Printing Standard covert actions for the Program...");
	class'RTHelpers'.static.PrintCovertActionsForFaction(Faction);

	`RTLOG("Printing Rival Chosen for the Program...");
	`RTLOG("" $ XComGameState_AdventChosen(History.GetGameStateForObjectID(Faction.RivalChosen.ObjectID)).GetChosenClassName());

	`RTLOG("Printing Misc Information for the Program...");
	class'RTHelpers'.static.PrintMiscInfoForFaction(Faction);


}

exec function RT_TriggerEvent(name EventID) {
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: RT_TriggerEvent" $ EventID);

	`XEVENTMGR.TriggerEvent(EventID, none, none, NewGameState);

	if (NewGameState.GetNumGameStateObjects() > 0) {
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	} else
		`XCOMHISTORY.CleanupPendingGameState(NewGameState);
}

exec function RT_DebugModVersion() {
	`RTLOG("Mod Version is: " $ default.MajorVer $ "." $ default.MinorVer $ "." $ default.PatchVer);
}

exec function RT_ToggleCustomDebugOutput() {
    class'UIDebugStateMachines'.static.GetThisScreen().ToggleVisible();
}

exec function RT_PrintPerkContentsForXCom() {
    class'UIDebugStateMachines'.static.PrintOutPerkContentsForXComUnits();
}

exec function RT_PrintLoadedPerkContents() {
    class'UIDebugStateMachines'.static.PrintOutLoadedPerkContents();
}

exec function RT_TryForceAppendAbilityPerks(name AbilityName) {
	class'UIDebugStateMachines'.static.TryForceAppendAbilityPerks(AbilityName);
}

exec function RT_TryForceCachePerkContent(name AbilityName) {
	class'UIDebugStateMachines'.static.TryForceCachePerkContent(AbilityName);
}

exec function RT_TryForceBuildPerkContentCache() {
	class'UIDebugStateMachines'.static.TryForceBuildPerkContentCache();
}

exec function RT_ForceLoadPerkOnToUnit(name AbilityName) {
	class'UIDebugStateMachines'.static.TryForceBuildPerkContentCache();
	class'UIDebugStateMachines'.static.TryForceCachePerkContent(AbilityName);
	class'UIDebugStateMachines'.static.TryForceAppendAbilityPerks(AbilityName);
}

exec function RT_PrintAppearence(int ObjectID) {
	local XComGameState_Unit UnitState;
	local TAppearance a;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ObjectID));
	if(UnitState == none) {
		`RTLOG("UnitState was null for PrintAppearance!");
		return;
	}	

	a = UnitState.kAppearance;
	`LOG(a.nmHead);
	`LOG(a.iGender);
	`LOG(a.iRace);
	`LOG(a.nmHaircut);
	`LOG(a.iHairColor);
	`LOG(a.iFacialHair);
	`LOG(a.nmBeard);
	`LOG(a.iSkinColor);
	`LOG(a.iEyeColor);
	`LOG(a.nmFlag);
	`LOG(a.iVoice);
	`LOG(a.iAttitude);
	`LOG(a.iArmorDeco);
	`LOG(a.iArmorTint);
	`LOG(a.iArmorTintSecondary);
	`LOG(a.iWeaponTint);
	`LOG(a.iTattooTint);
	`LOG(a.nmWeaponPattern);
	`LOG(a.nmPawn);
	`LOG(a.nmTorso);
	`LOG(a.nmArms);
	`LOG(a.nmLegs);
	`LOG(a.nmHelmet);
	`LOG(a.nmEye);
	`LOG(a.nmTeeth);
	`LOG(a.nmFacePropLower);
	`LOG(a.nmFacePropUpper);
	`LOG(a.nmPatterns);
	`LOG(a.nmVoice);
	`LOG(a.nmLanguage);
	`LOG(a.nmTattoo_LeftArm);
	`LOG(a.nmTattoo_RightArm);
	`LOG(a.nmScars);
	`LOG(a.nmTorso_Underlay);
	`LOG(a.nmArms_Underlay);
	`LOG(a.nmLegs_Underlay);
	`LOG(a.nmFacePaint);
	`LOG(a.nmLeftArm);
	`LOG(a.nmRightArm);
	`LOG(a.nmLeftArmDeco);
	`LOG(a.nmRightArmDeco);
	`LOG(a.nmLeftForearm);
	`LOG(a.nmRightForearm);
	`LOG(a.nmThighs);
	`LOG(a.nmShins);
	`LOG(a.nmTorsoDeco);
	`LOG(a.bGhostPawn);
}

exec function RT_ActivateOneSmallFavor() {
	local RTGameState_ProgramFaction	ProgramState;
	local XComGameState					NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Force One Small Favor!");
	ProgramState = class'RTHelpers'.static.GetNewProgramState(NewGameState);

	ProgramState.MakeOneSmallFavorAvailable();
	
	`GAMERULES.SubmitGameState(NewGameState);
}

exec function RT_GenerateProgramCards() {
	local RTGameState_ProgramFaction	ProgramState;
	local XComGameState					NewGameState;
	local int							idx;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Add Program Faction Cards!");
	ProgramState = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	ProgramState.Influence = eFactionInfluence_Influential;
	`GAMERULES.SubmitGameState(NewGameState);


	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Add Program Faction Cards!");
	ProgramState = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	`RTLOG("Generating cards...", false, true);
	for(idx = 0; idx < 20; idx++)
	{
		ProgramState.GenerateNewPlayableCard(NewGameState);
	}

	`GAMERULES.SubmitGameState(NewGameState);
}

exec function RT_DebugActiveOperatives() {
	local RTGameState_ProgramFaction		ProgramState;
	local StateObjectReference				IteratorRef;
	local XComGameStateHistory				History;
	local XComGameState_Unit				UnitState;

	ProgramState = class'RTHelpers'.static.GetProgramState();
	History = `XCOMHISTORY;
	
	`RTLOG("Printing Active Operatives...");
	foreach ProgramState.Active(IteratorRef) {
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(IteratorRef.ObjectID));
		`RTLOG( "Found Ghost Operative " $ UnitState.GetFullName() $ 
								", with ObjectID " $ UnitState.GetReference().ObjectID $
								", and CharacterTemplateName " $ UnitState.GetMyTemplateName()
							);
	}

}

exec function RT_AddProgramOperativeToXCOMCrew() {
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Unit UnitState;
	local bool bFoundAtLeastOne;

	History = `XCOMHISTORY;
	bFoundAtLeastOne = false;
	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if(	UnitState.GetMyTemplateName() == 'RTGhostMarksman' || 
			UnitState.GetMyTemplateName() == 'RTGhostBerserker' || 
			UnitState.GetMyTemplateName() == 'RTGhostGatherer' ||
			UnitState.GetMyTemplateName() == 'RTGhostOperator'
			)
		{
			`RTLOG("Found a " $ UnitState.GetMyTemplateName() $ ", adding them to XCOM!");
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: CHEAT: AddSPECTREToCrew");
			UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
			XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
			XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
			XComHQ.AddToCrew(NewGameState, UnitState);
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
			bFoundAtLeastOne = true;
		}
	}

	if(!bFoundAtLeastOne)
		`RTLOG("Did not find any active operatives!");
}

exec function RT_RegenerateProgramOperatives() {
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local RTGameState_ProgramFaction ProgramState;
	local StateObjectReference SquadRef;
	local RTGameState_PersistentGhostSquad SquadState;
	local int i;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: CHEAT: Regenerate Program Operatives, Part 1");
	ProgramState = class'RTHelpers'.static.GetNewProgramState(NewGameState);
	`RTLOG("CHEAT: Regenerate Program Operatives ####################", false, true);

	`RTLOG("Wiping Squads...", false, true);
	foreach ProgramState.Squads(SquadRef) {
		SquadState = RTGameState_PersistentGhostSquad(History.GetGameStateForObjectID(SquadRef.ObjectID));
		`RTLOG("Found a " $ SquadState.GetName() $ ", wiping them from existance!", false, true);
		NewGameState.RemoveStateObject(SquadRef.ObjectID);
	}

	`RTLOG("Wiping Operatives...", false, true);
	foreach ProgramState.Master(SquadRef) {
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(SquadRef.ObjectID));
		`RTLOG("Found a " $ UnitState.GetMyTemplateName() $ ", wiping them from existance!", false, true);
		NewGameState.RemoveStateObject(SquadRef.ObjectID);
	}

	ProgramState.Squads.Length = 0;
	ProgramState.Master.Length = 0;
	ProgramState.Active.Length = 0;
	ProgramState.Captured.Length = 0;
	ProgramState.Deployed = none;

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	`RTLOG("Recreating Operatives...", false, true);
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: CHEAT: Regenerate Program Operatives, Part 2");
	ProgramState = class'RTHelpers'.static.GetNewProgramState(NewGameState);

	ProgramState.CreateRTOperatives(NewGameState);
	ProgramState.CreateRTSquads(NewGameState);

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: CHEAT: Regenerate Program Operatives, Part 3");
	ProgramState = class'RTHelpers'.static.GetNewProgramState(NewGameState);

	for(i = 0; i < ProgramState.iOperativeLevel; i++) {
		ProgramState.PromoteAllOperatives(NewGameState);
	}

}

exec function RT_PrintCrew()
{
	local XComGameState_HeadquartersXCom XComHQ;
	local int idx;
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local string CrewString;

	History = `XCOMHISTORY;
	
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	`RTLOG("Logging XCOM Crew...");
	CrewString = "\nXCom Crew";

	for(idx = 0; idx < XComHQ.Crew.Length; idx++)
	{
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(XComHQ.Crew[idx].ObjectID));

		if(UnitState != none)
		{
			CrewString $= "\n" $ UnitState.GetName(eNameType_Full) @ "ObjectID:" @ UnitState.ObjectID;
		}
	}

	`RTLOG(CrewString);
}

// Courtesy of bountygiver
exec function TestPanel(int X, int Y, optional int Width = -1, optional int Height = -1, optional name PanelName = 'TestDebugPanel')
{
	local UIScreen Screen;
	local UIBGBox BGPanel;
	local UIPanel Panel;

	Screen = `SCREENSTACK.GetCurrentScreen();

	Panel = Screen.GetChildByName(PanelName, false);
	if(Width == -1 || Height == -1) {
		Width = 32;
		Height = 32;
	}

	if (Panel != none)
	{
		Panel.SetPosition(X, Y);
		Panel.SetSize(Width, Height);
	}
	else
	{
		BGPanel = Screen.Spawn(class'UIBGBox', Screen);
		BGPanel.InitBG(PanelName, X, Y, Width, Height);
		BGPanel.SetBGColor("FF0000");
		BGPanel.AnimateIn(0);
	}
}

exec function DestroyTestPanel(optional name PanelName = 'TestDebugPanel') {
	local UIScreen Screen;
	local UIBGBox BGPanel;

	Screen = `SCREENSTACK.GetCurrentScreen();

	BGPanel = UIBGBox(Screen.GetChildByName(PanelName, false));
	BGPanel.Remove();
}

exec function ReportTestPanelLocation(optional name PanelName = 'TestDebugPanel') {
	local UIScreen Screen;
	local UIPanel TestPanel;
	local string MissionType, LogOutput;
	local float PosX, PosY;
	//local StateObjectReference MissionRef;

	Screen = `SCREENSTACK.GetCurrentScreen();

	TestPanel = Screen.GetChildByName(PanelName, false);
	PosX = TestPanel.MC.GetNum("_x");
	PosY = TestPanel.MC.GetNum("_y");

	if(UIMission(Screen) != none) {
		MissionType = string(UIMission(Screen).GetMission().GetMissionSource().DataName);
		LogOutput = ("" $ PanelName $ " located at (" $ PosX $ ", " $ PosY $ ") for MissionType " $ MissionType);
		`RTLOG(LogOutput);

	} else {
		LogOutput = ("" $ PanelName $ " located at (" $ PosX $ ", " $ PosY $ ")");
		`RTLOG(LogOutput);

	}
}

exec function RT_DebugVisibilityAll() {	
	local XComGameState_Unit ItUnit;
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', ItUnit)
	{
		`RTLOG("" $ ItUnit.GetFullName());
		class'RTCondition_VisibleToPlayer'.static.IsTargetVisibleToLocalPlayer(ItUnit.GetReference(), , true);
	}
}

exec function RT_ForceVisibilityUpdatesAll() {
	local XComGameState_Unit ItUnit;
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState( "Cheat: Refresh Unit visualizers" );
	XComGameStateContext_ChangeContainer( NewGameState.GetContext() ).BuildVisualizationFn = ForceVisibilityUpdatesAll_BuildVisualization;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', ItUnit)
	{
		ItUnit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', ItUnit.ObjectID));
		ItUnit.bRequiresVisibilityUpdate = true;
	}

	`TACTICALRULES.SubmitGameState(NewGameState);

}

static function ForceVisibilityUpdatesAll_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameState_Unit UnitState;
	local VisualizationActionMetadata BuildTrack;
	local X2Action_UpdateFOW FOWAction;
	//local RTAction_ForceVisibility RTForceVisibilityAction_Reset;

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		BuildTrack.StateObject_NewState = UnitState;
		BuildTrack.StateObject_OldState = UnitState;
		
		//RTForceVisibilityAction_Reset = RTAction_ForceVisibility(class'RTAction_ForceVisibility'.static.AddToVisualizationTree(BuildTrack, VisualizeGameState.GetContext()));
		//RTForceVisibilityAction_Reset.bResetVisibility = true;

		class'X2Action_SyncVisualizer'.static.AddToVisualizationTree(BuildTrack, VisualizeGameState.GetContext());

		FOWAction = X2Action_UpdateFOW( class'X2Action_UpdateFOW'.static.AddToVisualizationTree( BuildTrack, VisualizeGameState.GetContext()) );
		FOWAction.ForceUpdate = true;
	}
}

exec function RT_TestUIPopup() {
	local string Title; 
	local string alertText;

	Title = "ALERT: One Small Favor";
	alertText = "The Program fields small squads of elite operatives. As a result of their alliance with XCOM, you may ask them to run a mission for you.\n NOTE: that this favor can only be called in once per month. \n \nCall in One Small Favor by toggling the white checkbox now shown on Mission Launch screens.";

	`PRESBASE.UITutorialBox(Title, alertText, "img:///RisingTidesContentPackage.UIImages.osf_tutorial");
}

exec function RT_ReduceSoldierCurrentWill(int MinusWill) {
	local XComTacticalController TacticalController;
	local XGUnit ActiveUnit;
	local XComGameState_Unit ActiveUnitState;
	local XComGameState NewGameState;
	// Pawn is the CURSOR in the Combat game
	TacticalController = XComTacticalController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController());

	if (TacticalController != none) {
		ActiveUnit = TacticalController.GetActiveUnit();
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState( "Cheat: Reduce Unit Will" );
		ActiveUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', ActiveUnit.ObjectID));
		ActiveUnitState.ModifyCurrentStat(eStat_Will, float(MinusWill));
		`TACTICALRULES.SubmitGameState(NewGameState);
	}
}

exec function RT_GetVisibilityStatusOfClosestUnitToCursor() {
	local XComGameState_Unit UnitState;
	local EForceVisibilitySetting ForceVisibleSetting;
	local XComTacticalCheatManager CheatsManager;

	CheatsManager = `CHEATMGR;

	UnitState = CheatsManager.GetClosestUnitToCursor();
	ForceVisibleSetting = UnitState.ForceModelVisible();
	`RTLOG(UnitState.GetFullName());
	`RTLOG("" $ ForceVisibleSetting);
}

exec function RT_ListAllSquadViewers(optional bool bDetailedInfo = false) {
	local XComGameState_SquadViewer XComSquadViewerState;
	//local RTGameState_SquadViewer RTSquadViewerState;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_SquadViewer', XComSquadViewerState) {
		`RTLOG("" $ "Found a SquadViewer: " $ XComSquadViewerState.ToString(bDetailedInfo), , true);
	}
}

exec function RT_ClearLog() {
	local int i;
	for(i = 0; i<100; i++) {
		`RTLOG(" ", false, true);
	}
}

exec function RT_GetTeamStatusOfClosestUnitToCursor() {
	local XComGameState_Unit UnitState;
	local ETeam TeamFlag;
	local XComTacticalCheatManager CheatsManager;
	local XComGameState_Player PlayerState;

	CheatsManager = `CHEATMGR;

	UnitState = CheatsManager.GetClosestUnitToCursor();
	PlayerState = XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(UnitState.GetAssociatedPlayerID()));
	TeamFlag = PlayerState.TeamFlag;
	if( UnitState.IsMindControlled() ) {
		`RTLOG("Unit is mind controlled!",,true);
		TeamFlag = UnitState.GetPreviousTeam();
	}

	`RTLOG(UnitState.GetFullName(),,true);
	`RTLOG("TeamFlag: " $ TeamFlag,,true);
}

// Based on code from "Configurable Mission Timers" by wghost
exec function RT_DebugKismetVariables() {
	//local XComGameState_Unit UnitState;
	//local ETeam TeamFlag;
	//local XComTacticalCheatManager CheatsManager;
	//local XComGameState_Player PlayerState;
	local WorldInfo WorldInfo;
	local Sequence MainSequence;
	local array<SequenceObject> SeqObjs;
	local int i, j;
	//local SeqVar_Int TimerVariable;
	//local SeqVar_Bool TimerEngagedVariable;
	local GeneratedMissionData GeneratedMission;
	local XComGameState_BattleData BattleData;
	local string objectiveName;
	local name EmptyName;
	local array<StateObjectReference> GameStates;

	//CheatsManager = `CHEATMGR;

	WorldInfo = `XWORLDINFO;
	WorldInfo.MyKismetVariableMgr.RebuildVariableMap();
	MainSequence = WorldInfo.GetGameSequence();
	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	GeneratedMission = class'UIUtilities_Strategy'.static.GetXComHQ().GetGeneratedMissionData(BattleData.m_iMissionID);

	if(GeneratedMission.Mission.MapNames.Length == 0)
	{
		`RTLOG("No objective map defined, skipping",,true);
		return;
	}

	for(i = 0; i < GeneratedMission.Mission.MapNames.Length; i++)
	{
		if(InStr(GeneratedMission.Mission.MapNames[i], "Obj_") != -1)
		{
			objectiveName = GeneratedMission.Mission.MapNames[i];
			break;
		}
	}

	`RTLOG("objectiveName = " $ objectiveName);

	if(objectiveName == "")
	{
		`RTLOG("No objective defined for this map, skipping",,true);
		return;
	}

	if (mainSequence != None)
	{
		mainSequence.FindSeqObjectsByClass( class'SequenceVariable', true, SeqObjs);
		if(SeqObjs.Length != 0)
		{
			`RTLOG("Kismet variables found",,true);
			for(i = 0; i < SeqObjs.Length; i++)
			{
				if(SequenceVariable(SeqObjs[i]).VarName != EmptyName) {
					if(SeqVar_GameStateObject(SeqObjs[i]) != none) {
						`RTLOG("Found " $ SequenceVariable(SeqObjs[i]).VarName $ " , ClassType: " $ SeqObjs[i].class $ " GameStateObj: " $ SeqVar_GameStateObject(SeqObjs[i]).GetObject().ObjectID ,, true);
					} else if(SeqVar_GameStateList(SeqObjs[i]) != none) {
						`RTLOG("Found " $ SequenceVariable(SeqObjs[i]).VarName $ " , ClassType: " $ SeqObjs[i].class,, true);
						GameStates = SeqVar_GameStateList(SeqObjs[i]).GameStates;
						for(j = 0; j < GameStates.Length; j++) {
							`RTLOG("" $ GameStates[j].ObjectID,,true);
						}
					} else if(SeqVar_Bool(SeqObjs[i]) != none) {
						`RTLOG("Found " $ SequenceVariable(SeqObjs[i]).VarName $ " , ClassType: " $ SeqObjs[i].class $ " Bool: " $ SeqVar_Bool(SeqObjs[i]).bValue,, true);
					} else if(SeqVar_Int(SeqObjs[i]) != none) {
						`RTLOG("Found " $ SequenceVariable(SeqObjs[i]).VarName $ " , ClassType: " $ SeqObjs[i].class $ " Int: " $ SeqVar_Int(SeqObjs[i]).IntValue,, true);
					} else {
						`RTLOG("Found " $ SequenceVariable(SeqObjs[i]).VarName $ " , ClassType: " $ SeqObjs[i].class,, true);
						//`RTLOG("" $ SeqObjs[i].ObjName,, true);
					}
				}
			}
		}
	}
}

exec function RT_DebugClosestUnitToCursorAvailableAbilties() {
	local XComGameState_Unit UnitState;
	local StateObjectReference AbilityRef;
	local XComGameState_Ability AbilityState;
	local XComGameStateHistory History;
	local AvailableAction Action;

	UnitState = `CHEATMGR.GetClosestUnitToCursor();
	if(UnitState == none) {
		`RTLOG("Couldn't find unit to debug!", false, true);
		return;
	}

	History = `XCOMHISTORY;
	if(History == none) {
		`RTLOG("NO HISTORY??????", false, true);
		return;
	}

	`RTLOG("Gathering and displaying ability availability for " $ UnitState.GetFullName(), false, true);
	foreach UnitState.Abilities(AbilityRef) {
		AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));
		if(AbilityState == none) {
			continue;
		}

		AbilityState.UpdateAbilityAvailability(Action);
		if(!Action.bInputTriggered) {
			continue;
		}
		
		if(Action.AvailableCode == 'AA_Success') {
			`RTLOG("" $ AbilityState.GetMyTemplateName() $ " is available.", false, true);
		} else { `RTLOG("" $ AbilityState.GetMyTemplateName() $ " is not available due to " $ Action.AvailableCode, false, true); }
	}
	`RTLOG("Finished gathering and displaying ability availablity for " $ UnitState.GetFullName(), false, true);
}

exec function RT_CheatLadderPoints(int Points) {
	local XComGameState NewGameState;
	local XComGameState_LadderProgress LadderData;
	local XComGameState_ChallengeScore ChallengeScore;

	// CMPT_KilledEnemy
	NewGameState = class'XComGameStateContext_ChallengeScore'.static.CreateChangeState( );

	ChallengeScore = XComGameState_ChallengeScore( NewGameState.CreateStateObject( class'XComGameState_ChallengeScore' ) );
	ChallengeScore.ScoringType = CMPT_KilledEnemy;
	ChallengeScore.AddedPoints = Points;

	LadderData = XComGameState_LadderProgress( `XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_LadderProgress', true));
	LadderData = XComGameState_LadderProgress( NewGameState.ModifyStateObject( class'XComGameState_LadderProgress', LadderData.ObjectID ) );
	LadderData.CumulativeScore += Points;

	`XCOMGAME.GameRuleset.SubmitGameState( NewGameState );

	return;
}

exec function TestScreen() {
	local XComPresentationLayerBase pres;
	local UISCreenStack	ScreenStack;

	local RTUIScreen_AdvanceTemplarQuestlineStage Screen;

	pres = `PRESBASE;
	ScreenStack = `SCREENSTACK;
}

exec function RT_ListAbilityLists() {
	class'RTHelpers'.static.ListDefaultAbilityLists();
}

exec function RT_CheatProgramInfluence() {
    local RTGameState_ProgramFaction ProgramState;

    ProgramState = class'RTHelpers'.static.GetProgramState();
    ProgramState.TryIncreaseInfluence();
}

exec function RT_CheatEliminateTemplarFaction() {
	local XComGameState NewGameState;
	local XComGameState_ResistanceFaction TemplarState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT - ELIMINATE TEMPLAR FACTION");
	TemplarState = class'RTHelpers'.static.GetTemplarFactionState();

	class'RTStrategyElement_Rewards'.static.EliminateFaction(NewGameState, TemplarState);

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

