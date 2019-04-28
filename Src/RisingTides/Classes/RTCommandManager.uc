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
	Faction = `RTS.GetProgramState();

	if(bShouldPrintFullInfo) {
		`RTLOG(Faction.ToString(bShouldPrintAllFields), , true);
		return;
	}

	`RTLOG("Printing Golden Path covert actions for the Program...");
	`RTS.PrintGoldenPathActionsForFaction(Faction);

	`RTLOG("Printing Standard covert actions for the Program...");
	`RTS.PrintCovertActionsForFaction(Faction);

	`RTLOG("Printing Rival Chosen for the Program...");
	`RTLOG("" $ XComGameState_AdventChosen(History.GetGameStateForObjectID(Faction.RivalChosen.ObjectID)).GetChosenClassName());

	`RTLOG("Printing Misc Information for the Program...");
	Faction.PrintDebuggingInfo();


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
		`RTLOG("UnitState was null for PrintAppearance!", false, true);
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
	ProgramState = `RTS.GetNewProgramState(NewGameState);

	ProgramState.MakeOneSmallFavorAvailable();
	
	`GAMERULES.SubmitGameState(NewGameState);
}

exec function RT_GenerateProgramCards() {
	local RTGameState_ProgramFaction	ProgramState;
	local XComGameState					NewGameState;
	local int							idx;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Add Program Faction Cards!");
	ProgramState = `RTS.GetNewProgramState(NewGameState);
	ProgramState.IncreaseInfluenceLevel(NewGameState);
	ProgramState.IncreaseInfluenceLevel(NewGameState);
	ProgramState.IncreaseInfluenceLevel(NewGameState);
	ProgramState.IncreaseInfluenceLevel(NewGameState);
	`GAMERULES.SubmitGameState(NewGameState);

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Add Program Faction Cards!");
	ProgramState = `RTS.GetNewProgramState(NewGameState);
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

	ProgramState = `RTS.GetProgramState();
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
	ProgramState = `RTS.GetNewProgramState(NewGameState);
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
	ProgramState = `RTS.GetNewProgramState(NewGameState);

	ProgramState.CreateRTOperatives(NewGameState);
	ProgramState.CreateRTSquads(NewGameState);

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: CHEAT: Regenerate Program Operatives, Part 3");
	ProgramState = `RTS.GetNewProgramState(NewGameState);

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
exec function RT_TestPanelLocation(int X, int Y, optional int Width = -1, optional int Height = -1, optional name PanelName = 'TestDebugPanel')
{
	local UIScreen Screen;
	local UIBGBox BGPanel;
	local UIPanel Panel;

	Screen = `SCREENSTACK.GetCurrentScreen();

	`RTLOG("Using " $ Screen.MCName $ " as the base for the TestPanel!");

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
		`RTLOG("Couldn't find a " $ PanelName $ ", creating one!");
		BGPanel = Screen.Spawn(class'UIBGBox', Screen);
		BGPanel.InitBG(PanelName, X, Y, Width, Height);
		BGPanel.SetBGColorState(eUIState_Cash);
		BGPanel.AnimateIn(0);
	}
}

exec function DestroyTestPanel(optional name PanelName = 'TestDebugPanel') {
	local UIScreen Screen;
	local UIBGBox BGPanel;

	Screen = `SCREENSTACK.GetCurrentScreen();

	BGPanel = UIBGBox(Screen.GetChildByName(PanelName, false));
	if(BGPanel == none) {
		`RTLOG("Couldn't find a " $ PanelName $ "!");
	}
	BGPanel.Remove();
}

exec function RT_ReportTestPanelMCLocation(optional name PanelName = 'TestDebugPanel') {
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

exec function RT_ReportTestPanelLocation(optional name PanelName = 'TestDebugPanel') {
	local UIScreen Screen;
	local UIPanel TestPanel;
	local string LogOutput;
	//local StateObjectReference MissionRef;

	Screen = `SCREENSTACK.GetCurrentScreen();
	/*
var float X;
var float Y;
var float Width;
var float Height;
var float Alpha;
var float RotationDegrees;
var int Anchor;
var int Origin;
	*/

	TestPanel = Screen.GetChildByName(PanelName, false);

	
	LogOutput = ("" $ PanelName $ " located at (" $ TestPanel.X $ ", " $ TestPanel.Y $ ")");
	`RTLOG(LogOutput, false, true);

	LogOutput = ("With a size of (" $ TestPanel.Width $ "x" $ TestPanel.Height $ ")");
	`RTLOG(LogOutput, false, true);

	LogOutput = ("With an Alpha of" $ TestPanel.Alpha $ " and a Rotation of " $ TestPanel.RotationDegrees);
	`RTLOG(LogOutput, false, true);

	LogOutput = ("With Anchor set to " $ TestPanel.Anchor $ " and Origin set to " $ TestPanel.Origin);
	`RTLOG(LogOutput, false, true);
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
	local StateObjectReference ActiveUnitRef;
	local XComGameState_Unit ActiveUnitState;
	local XComGameState NewGameState;
	// Pawn is the CURSOR in the Combat game
	TacticalController = XComTacticalController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController());

	if (TacticalController != none) {
		ActiveUnitRef = TacticalController.GetActiveUnitStateRef();
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState( "Cheat: Reduce Unit Will" );
		ActiveUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', ActiveUnitRef.ObjectID));
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
	EmptyName = '';
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

exec function RT_DebugClosestUnitToCursorAvailableAbilties(bool bPrintFullInfo = false) {
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
			`RTLOG("Found a null AbilityState in the Unit's abilties?!!!");
			continue;
		}

		AbilityState.UpdateAbilityAvailability(Action);
		if(!Action.bInputTriggered) {
			`RTLOG(AbilityState.GetMyTemplateName() $ " isn't input-triggered, continuing!");
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
	/*local XComPresentationLayerBase pres;
	local UISCreenStack	ScreenStack;
	local RTUIScreen_AdvanceTemplarQuestlineStage Screen;

	pres = `PRESBASE;
	ScreenStack = `SCREENSTACK;*/
}

exec function RT_ListAbilityLists() {
	`RTS.ListDefaultAbilityLists();
}

exec function RT_CheatProgramInfluence() {
	local RTGameState_ProgramFaction ProgramState;

	ProgramState = `RTS.GetProgramState();
	ProgramState.TryIncreaseInfluence();
}

exec function RT_CheatEliminateTemplarFaction() {
	local XComGameState NewGameState;
	local XComGameState_ResistanceFaction TemplarState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT - ELIMINATE TEMPLAR FACTION");
	TemplarState = `RTS.GetTemplarFactionState();

	class'RTStrategyElement_Rewards'.static.EliminateFaction(NewGameState, TemplarState);

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

exec function RT_GenerateTemplarAmbush() {
	local XComGameState NewGameState;
	local XComGameState_MissionSite MissionState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT - ELIMINATE TEMPLAR FACTION");
	MissionState = CreateFakeTemplarAmbush(NewGameState);
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	
	MissionState = GetMission('RTMissionSource_TemplarAmbush'); // Find the Ambush mission and display its popup
	if (MissionState != none && MissionState.GetMissionSource().MissionPopupFn != none)
	{
		MissionState.GetMissionSource().MissionPopupFn(MissionState);
		`GAME.GetGeoscape().Pause();
	}
}

simulated function XComGameState_MissionSite GetMission(name MissionSource)
{
	local XComGameStateHistory History;
	local XComGameState_MissionSite MissionState;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_MissionSite', MissionState)
	{
		if (MissionState.Source == MissionSource && MissionState.Available)
		{
			return MissionState;
		}
	}
}

function XComGameState_MissionSite CreateFakeTemplarAmbush(XComGameState NewGameState) {
	local RTGameState_MissionSiteTemplarAmbush MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward RewardState;
	local X2StrategyElementTemplateManager StratMgr;
	local X2RewardTemplate RewardTemplate;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local StateObjectReference EmptyRef;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	RegionState = `XCOMHQ.GetContinent().GetRandomRegionInContinent();

	MissionRewards.Length = 0;
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('RTReward_TemplarAmbush')); // rewards are given by the X2MissionSourceTemplate
	RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewards.AddItem(RewardState);

	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('RTMissionSource_TemplarAmbush'));
	MissionState = RTGameState_MissionSiteTemplarAmbush(NewGameState.CreateNewStateObject(class'RTGameState_MissionSiteTemplarAmbush'));
	MissionState.CovertActionRef = EmptyRef;
	MissionState.bGeneratedFromDebugCommand = true;
	
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true);
	MissionState.ResistanceFaction = `RTS.GetProgramState().GetReference();

	return MissionState;
}

exec function RT_RecreateOneSmallFavor() {
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local RTGameState_ProgramFaction ProgramState;
	local XComGameState_StrategyCard CardState;
	local StateObjectReference IteratorRef;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Rising Tides: CHEAT: Regenerate One Small Favor");
	ProgramState = `RTS.GetNewProgramState(NewGameState);

	// try to find One Small Favor
	foreach ProgramState.PlayableCards(IteratorRef) {
		CardState = XComGameState_StrategyCard(History.GetGameStateForObjectID(IteratorRef.ObjectID));
		if(CardState.GetMyTemplateName() == 'ResCard_RTOneSmallFavor') {
			return;
		}
	}

	// didn't find it, bugged campaign
	foreach History.IterateByClassType(class'XComGameState_StrategyCard', CardState)
	{
		if(CardState.GetMyTemplateName() == 'ResCard_RTOneSmallFavor') {
			ProgramState.PlayableCards.AddItem(CardState.GetReference());
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
			return;
		}
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

exec function RT_ToggleAllToolTips(bool bHide, optional bool bAnimateOutTooltip = false) {
	local UITooltipMgr Mgr;
	local XComPresentationLayerBase Pres;
	local UITooltip Tooltip;
	pres = `PRESBASE;

	Mgr = Pres.m_kTooltipMgr;
	foreach Mgr.Tooltips(Tooltip) {
		if(!bHide)
			Mgr.ActivateTooltip(Tooltip);
		else
			Mgr.DeactivateTooltip(Tooltip, bAnimateOutTooltip);
	}
}

exec function RT_DebugParticleSystemComponents() {
	local Actor A;
	local ParticleSystemComponent PSC;
	local int count, total;
	local XComCheatManager CheatManager;

	CheatManager = `CHEATMGR;

	total = 0;
	// what the fuck is an outer
	foreach CheatManager.Outer.AllActors(class'Actor', A)
	{
		count = 0;
		foreach A.AllOwnedComponents(class'ParticleSystemComponent', PSC) {
			total++;
			count++;
		}

		if(count > 0)
			`RTLOG(A @ count $ "", false, true);
	}
	
	`RTLOG("Total: " $ total, false, true);
}

exec function RT_DebugEmitterPool_1() {
	local Actor A;
	local ParticleSystemComponent PSC;
	local XComCheatManager CheatManager;

	CheatManager = `CHEATMGR;

	// what the fuck is an outer
	foreach CheatManager.Outer.AllActors(class'Actor', A)
	{
		if(A.Name == 'EmitterPool_1') {
			break;
		}
	}

	`RTLOG("Name = " $ A.Name, false, true);
	`RTLOG("Class = " $ A.Class, false, true);
	`RTLOG("Printing PSCs...", false, true);
	foreach A.AllOwnedComponents(class'ParticleSystemComponent', PSC)
	{
		`RTLOG("" $ PSC $ 
			", LastRenderTime: " $ PSC.LastRenderTime $  
			", bWasCompleted: " $ PSC.bWasCompleted $
			", bWasDeactivated: " $ PSC.bWasDeactivated $
			"",
			
		
			false, true);
	}

}

exec function RT_ShowTacticalForceLevel() {
	local XComGameState_BattleData BattleData;

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	if(BattleData == none) {
		`RTLOG("Couldn't find BattleData!", false, true);
		return;
	}
	`RTLOG("Current Force Level is: " $ BattleData.GetForceLevel(), false, true);

}

exec function RT_SetTacticalForceLevel(int iNewForceLevel) {
	local XComGameState_BattleData BattleData;
	local XComGameState	NewGameState;

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	if(BattleData == none) {
		`RTLOG("Couldn't find BattleData!", false, true);
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Setting Tactical Force Level to " $ iNewForceLevel);
	BattleData = XComGameState_BattleData(NewGameState.ModifyStateObject(class'XComGameState_BattleData', BattleData.ObjectID));
	BattleData.SetForceLevel(iNewForceLevel);

	`TACTICALRULES.SubmitGameState(NewGameState);
}

exec function RT_DebugAIBehavior() {
	/*local XComGameState_Unit UnitState;
	local StateObjectReference AbilityRef;
	local XComGameState_Ability AbilityState;
	local XComGameStateHistory History;
	local AvailableAction Action;
	
	UnitState = `CHEATMGR.GetClosestUnitToCursor();
	*/
}

exec function RT_ListAllStrategyCards() {
	local XComGameStateHistory History;
	local XComGameState_StrategyCard CardState;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_StrategyCard', CardState)
	{
		`RTLOG("Found Strategy Card with TemplateName " $ CardState.GetMyTemplateName() $ " and StateObjectRef " $ CardState.GetReference().ObjectID, false, true);
	}
}

exec function bool RT_DebugProgramFactionScreen()
{
	local UIScreen TempScreen;
	local XComHQPresentationLayer Pres;
	local UIScreenStack ScreenStack;

	Pres = `HQPres;

	ScreenStack = Pres.ScreenStack;
	TempScreen = ScreenStack.GetFirstInstanceOf(class'RTUIScreen_ProgramFactionInfo');
	if (TempScreen != none && ScreenStack.GetCurrentScreen() == TempScreen)
	{
		TempScreen.CloseScreen();
		return true;
	}
	
	// don't show when paused or showing popups
	if (Pres.IsBusy())
	{
		return false;
	}
	
	TempScreen = GetProgramFactionInfoScreen();
	ScreenStack.Push(TempScreen, Pres.Get2DMovie());
	RTUIScreen_ProgramFactionInfo(TempScreen).PopulateData();

	return true;
}

static function RTUIScreen_ProgramFactionInfo GetProgramFactionInfoScreen()
{
	local RTUIScreen_ProgramFactionInfo TempScreen;
	local XComPresentationLayerBase Pres;

	Pres = `PRESBASE;
	TempScreen = RTUIScreen_ProgramFactionInfo(FindObject(class'X2DownloadableContentInfo_RisingTides'.default.screen_path, class'RTUIScreen_ProgramFactionInfo'));
	if (Pres != none && TempScreen == none)
	{
		TempScreen = Pres.Spawn(class'RTUIScreen_ProgramFactionInfo', Pres);
		TempScreen.InitScreen(XComPlayerController(Pres.Owner), Pres.Get2DMovie());
		TempScreen.Movie.LoadScreen(TempScreen);
		class'X2DownloadableContentInfo_RisingTides'.default.screen_path = PathName(TempScreen);
	}
	return TempScreen;
}

exec function RT_CheatProgramQuestline() {
	local RTGameState_ProgramFaction	ProgramState;
	local XComGameState					NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Force Templar Questline!");
	ProgramState = `RTS.GetNewProgramState(NewGameState);

	ProgramState.ForceIncreaseInfluence();
	ProgramState.IncrementTemplarQuestlineStage();
	ProgramState.IncrementNumFavorsAvailable(3);
	
	`GAMERULES.SubmitGameState(NewGameState);
}

exec function RT_TestProgramInfoScreenTutorial() {
	local RTGameState_ProgramFaction	ProgramState;

	ProgramState = `RTS.GetProgramState();
	ProgramState.HandleProgramScreenTutorial(true);
}

exec function RT_TestOSFTutorial() {
	local RTGameState_ProgramFaction	ProgramState;

	ProgramState = `RTS.GetProgramState();
	ProgramState.HandleOSFTutorial(true);
}

exec function RT_DebugEncounterIDs()
{
	local XComTacticalMissionManager MissionManager;
	local ConfigurableEncounter Encounter;
	local string DebugText;

	MissionManager = `TACTICALMISSIONMGR;
	foreach MissionManager.ConfigurableEncounters(Encounter)
	{
		DebugText = DebugText $ Encounter.EncounterID $ "\n";
	}
	`RTLOG("Valid EncounterIDs:\n"@DebugText);
}

exec function RT_DebugObjectiveParcelsAndPCPs() {
	local XComParcelManager ParcelManager;
	local XComPlotCoverParcelManager PCPManager;

	local PlotDefinition Plot;
	local PCPDefinition PCP;

	ParcelManager = `PARCELMGR;
	PCPManager = new class'XComPlotCoverParcelManager';

	`RTLOG("--------- PLOTS -------------------------------------------------------------------------------------------------------------------------------------");
	foreach ParcelManager.arrPlots(Plot) {
		if(Plot.ObjectiveTags.Length > 0) {
			`RTLOG(Plot.MapName $ " has an objectiveTag: " $ Plot.ObjectiveTags[0], false, true);
		}
	}
	`RTLOG("--------- PCPS -------------------------------------------------------------------------------------------------------------------------------------");
	foreach PCPManager.arrAllPCPDefs(PCP) {
		if(PCP.ObjectiveTags.Length > 0) {
			`RTLOG(PCP.MapName $ " has an objectiveTag: " $ PCP.ObjectiveTags[0], false, true);
		}
	}
}