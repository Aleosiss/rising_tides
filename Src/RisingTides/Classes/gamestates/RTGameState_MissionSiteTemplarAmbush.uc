class RTGameState_MissionSiteTemplarAmbush extends XComGameState_MissionSite;

var() StateObjectReference CovertActionRef;
var bool bGeneratedFromDebugCommand;

function bool RequiresAvenger()
{
	// Templar Ambush does not require the Avenger at the mission site
	return false;
}

function SelectSquad()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_CovertAction ActionState;
	local XComGameState_StaffSlot SlotState;
	local array<StateObjectReference> MissionSoldiers;
	local int idx, NumSoldiers;
	local RTGameState_ProgramFaction ProgramState;
	local RTGameState_MissionSiteTemplarAmbush MissionSiteState;

	local string ProgramOperativeTemplateName;
	
	/* TODO: Modify SelectSquad with the following parameters:
		1. Add civilians to the squad
		2. Add Kaga to the squad
	*/

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	ActionState = XComGameState_CovertAction(History.GetGameStateForObjectID(CovertActionRef.ObjectID));

	NumSoldiers = class'X2StrategyGameRulesetDataStructures'.static.GetMaxSoldiersAllowedOnMission(self);

	NewGameState = `CreateChangeState("Set up Ambush Squad");
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	
	for (idx = 0; idx < NumSoldiers; idx++)
	{
		if (idx < ActionState.StaffSlots.Length)
		{
			SlotState = ActionState.GetStaffSlot(idx);
			if (SlotState != none && /*SlotState.IsSoldierSlot() &&*/ SlotState.IsSlotFilled()) // we want the civilians too...
			{
				MissionSoldiers.AddItem(SlotState.GetAssignedStaffRef());
			}
		}
	}

	// for testing purposes
	if(bGeneratedFromDebugCommand) {
		MissionSoldiers = GetRandomSoldiers();
	}

	// Get Kaga
	ProgramState = `RTS.GetProgramState(NewGameState);
	ProgramOperativeTemplateName = "Kaga";

	MissionSiteState = RTGameState_MissionSiteTemplarAmbush(NewGameState.ModifyStateObject(class'RTGameState_MissionSiteTemplarAmbush', ObjectID));
	MissionSiteState.GeneratedMission.Mission.SpecialSoldiers.AddItem(ProgramState.GetOperative(ProgramOperativeTemplateName).GetMyTemplateName());
	
	MissionSoldiers.AddItem(AddProgramOperative(NewGameState, ProgramOperativeTemplateName));

	// Adjust gear
	ProgramState = `RTS.GetNewProgramState(NewGameState);
	ProgramState.AdjustProgramGearLevel(NewGameState);
	
	// Replace the squad with the soldiers who were on the Covert Action
	XComHQ.Squad = MissionSoldiers;
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	return;
}

function StartMission()
{
	local XGStrategy StrategyGame;
	
	BeginInteraction();
	
	StrategyGame = `GAME;
	StrategyGame.PrepareTacticalBattle(ObjectID);
	ConfirmMission(); // Transfer directly to the mission, no squad select. Squad is set up based on the covert action soldiers.
}

// For some reason I cannot get my mission to set normally, probably because I don't understand the systems.
// Instead of learning, I'm just going to brute force it.
function SetMissionData(X2RewardTemplate MissionReward, bool bUseSpecifiedLevelSeed, int LevelSeedOverride, optional array<string> ExcludeFamilies)
{
	local XComHeadquartersCheatManager CheatManager;
	local GeneratedMissionData EmptyData;
	local XComTacticalMissionManager MissionMgr;
	local XComParcelManager ParcelMgr;
	local string Biome;
	local X2MissionSourceTemplate MissionSource;
	local array<name> SourceSitReps;
	local name SitRepName;
	local array<name> SitRepNames;
	local PlotTypeDefinition PlotTypeDef;
	local PlotDefinition SelectedDef;
	local String AdditionalTag;
	// Variables for Issue #157
	local array<X2DownloadableContentInfo> DLCInfos; 
	local int i; 
	// Variables for Issue #157

	local MissionDefinition _MissionDef;

	MissionMgr = `TACTICALMISSIONMGR;
	ParcelMgr = `PARCELMGR;

	MissionMgr.GetMissionDefinitionForType("RT_TemplarAmbush", _MissionDef);

	GeneratedMission = EmptyData;
	GeneratedMission.MissionID = ObjectID;
	GeneratedMission.Mission = _MissionDef;
	GeneratedMission.LevelSeed = (bUseSpecifiedLevelSeed) ? LevelSeedOverride : class'Engine'.static.GetEngine().GetSyncSeed();
	GeneratedMission.BattleDesc = "";
	GeneratedMission.SitReps.Length = 0;
	SitRepNames.Length = 0;

	// Grab potential Chosen gameplay tags
	AddChosenTacticalTags();

	// Add additional required plot objective tags
	foreach AdditionalRequiredPlotObjectiveTags(AdditionalTag)
	{
		GeneratedMission.Mission.RequiredPlotObjectiveTags.AddItem(AdditionalTag);
	}

	GeneratedMission.SitReps = GeneratedMission.Mission.ForcedSitreps;
	SitRepNames = GeneratedMission.Mission.ForcedSitreps;

	// Add Forced SitReps from Cheats
	CheatManager = XComHeadquartersCheatManager(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().CheatManager);
	if(CheatManager != none && CheatManager.ForceSitRepTemplate != '')
	{
		GeneratedMission.SitReps.AddItem(CheatManager.ForceSitRepTemplate);
		SitRepNames.AddItem(CheatManager.ForceSitRepTemplate);
		CheatManager.ForceSitRepTemplate = '';
	}
	else if(!bForceNoSitRep)
	{
		// No cheats, add SitReps from the Mission Source
		MissionSource = GetMissionSource();

		if(MissionSource.GetSitrepsFn != none)
		{
			SourceSitReps = MissionSource.GetSitrepsFn(self);

			foreach SourceSitReps(SitRepName)
			{
				if(GeneratedMission.SitReps.Find(SitRepName) == INDEX_NONE)
				{
					GeneratedMission.SitReps.AddItem(SitRepName);
					SitRepNames.AddItem(SitRepName);
				}
			}
		}
	}

	GeneratedMission.MissionQuestItemTemplate = MissionMgr.ChooseQuestItemTemplate(Source, MissionReward, GeneratedMission.Mission, (DarkEvent.ObjectID > 0));

	if(GeneratedMission.Mission.sType == "")
	{
		`Redscreen("GetMissionDataForSourceReward() failed to generate a mission with: \n"
						$ " Source: " $ Source $ "\n RewardType: " $ MissionReward.DisplayName);
	}

	// find a plot that supports the biome and the mission
	SelectBiomeAndPlotDefinition(GeneratedMission.Mission, Biome, SelectedDef, SitRepNames);

	// do a weighted selection of our plot
	GeneratedMission.Plot = SelectedDef;

	// Add SitReps forced by Plot Type
	PlotTypeDef = ParcelMgr.GetPlotTypeDefinition(GeneratedMission.Plot.strType);

	foreach PlotTypeDef.ForcedSitReps(SitRepName)
	{
		if(GeneratedMission.SitReps.Find(SitRepName) == INDEX_NONE && 
			(SitRepName != 'TheLost' || GeneratedMission.SitReps.Find('TheHorde') == INDEX_NONE))
		{
			GeneratedMission.SitReps.AddItem(SitRepName);
		}
	}

	// Start Issue #157
	DLCInfos = `ONLINEEVENTMGR.GetDLCInfos(false);
	for(i = 0; i < DLCInfos.Length; ++i)
	{
		DLCInfos[i].PostSitRepCreation(GeneratedMission, self);
	}
	// End Issue #157

	// Now that all sitreps have been chosen, add any sitrep tactical tags to the mission list
	UpdateSitrepTags();

	// the plot we find should either have no defined biomes, or the requested biome type
	//`assert( (GeneratedMission.Plot.ValidBiomes.Length == 0) || (GeneratedMission.Plot.ValidBiomes.Find( Biome ) != -1) );
	if (GeneratedMission.Plot.ValidBiomes.Length > 0)
	{
		GeneratedMission.Biome = ParcelMgr.GetBiomeDefinition(Biome);
	}

	if(GetMissionSource().BattleOpName != "")
	{
		GeneratedMission.BattleOpName = GetMissionSource().BattleOpName;
	}
	else
	{
		GeneratedMission.BattleOpName = class'XGMission'.static.GenerateOpName(false);
	}

	GenerateMissionFlavorText();
}

private function StateObjectReference AddProgramOperative(XComGameState NewGameState, string ProgramOperativeTemplateName) {
	local XComGameState_Unit UnitState;
	local XComGameStateHistory History;
	local RTGameState_ProgramFaction ProgramState;
	local name TemplateName;
	local StateObjectReference EmptyRef;

	History = `XCOMHISTORY;

	ProgramState = `RTS.GetProgramState(NewGameState);
	TemplateName = ProgramState.GetOperative(ProgramOperativeTemplateName).GetMyTemplateName();

	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		// If this unit is one of the required special soldiers, add them to the squad
		if (TemplateName == UnitState.GetMyTemplateName())
		{
			UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
			
			return UnitState.GetReference();
		}
	}

	if(UnitState == none) {
		`RTLOG("Something broke, couldn't find Program Operative for ambush!");
		return EmptyRef;
	}
}

private function array<StateObjectReference> GetRandomSoldiers() {
	local XComGameState_HeadquartersXCom XComHQ;
	local int i;
	local array<StateObjectReference> list;
	local array<int> id_list;
	local XComGameState_Unit UnitState;
	local XComGameStateHistory History;

	XComHQ = `XCOMHQ;
	History = `XCOMHISTORY;

	while(i < 3) {
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(XComHQ.Crew[`SYNC_RAND(XComHQ.Crew.Length) - 1].ObjectID));
		if(!UnitState.IsSoldier()) {
			continue;
		}
		
		if(id_list.Find(UnitState.ObjectID) == INDEX_NONE) {
			list.AddItem(UnitState.GetReference());
			id_list.AddItem(UnitState.ObjectID);
			i++;
		}
	}

	return list;
}

//---------------------------------------------------------------------------------------
protected function SelectBiomeAndPlotDefinition(MissionDefinition MissionDef, out string Biome, out PlotDefinition SelectedDef, optional array<name> SitRepNames)
{
	local XComParcelManager ParcelMgr;
	local string PrevBiome;
	local array<string> ExcludeBiomes;

	ParcelMgr = `PARCELMGR;
	ExcludeBiomes.Length = 0;
	
	Biome = SelectBiome(MissionDef, ExcludeBiomes);
	PrevBiome = Biome;

	while(!SelectPlotDefinition(MissionDef, Biome, SelectedDef, ExcludeBiomes, SitRepNames))
	{
		Biome = SelectBiome(MissionDef, ExcludeBiomes);

		if(Biome == PrevBiome)
		{
			`Redscreen("Could not find valid plot for mission!\n" $ " MissionType: " $ MissionDef.MissionName);
			SelectedDef = ParcelMgr.arrPlots[0];
			return;
		}
	}
}

//---------------------------------------------------------------------------------------
protected function string SelectBiome(MissionDefinition MissionDef, out array<string> ExcludeBiomes)
{
	local string Biome;
	local int TotalValue, RollValue, CurrentValue, idx, BiomeIndex;
	local array<BiomeChance> BiomeChances;
	local string TestBiome;

	if(MissionDef.ForcedBiome != "")
	{
		return MissionDef.ForcedBiome;
	}

	// Grab Biome from location
	Biome = class'X2StrategyGameRulesetDataStructures'.static.GetBiome(Get2DLocation());

	if(ExcludeBiomes.Find(Biome) != INDEX_NONE)
	{
		Biome = "";
	}

	// Grab "extra" biomes which we could potentially swap too (used for Xenoform)
	BiomeChances = class'X2StrategyGameRulesetDataStructures'.default.m_arrBiomeChances;

	// Not all plots support these "extra" biomes, check if excluded
	foreach ExcludeBiomes(TestBiome)
	{
		BiomeIndex = BiomeChances.Find('BiomeName', TestBiome);

		if(BiomeIndex != INDEX_NONE)
		{
			BiomeChances.Remove(BiomeIndex, 1);
		}
	}

	// If no "extra" biomes just return the world map biome
	if(BiomeChances.Length == 0)
	{
		return Biome;
	}

	// Calculate total value of roll to see if we want to swap to another biome
	TotalValue = 0;

	for(idx = 0; idx < BiomeChances.Length; idx++)
	{
		TotalValue += BiomeChances[idx].Chance;
	}

	// Chance to use location biome is remainder of 100
	if(TotalValue < 100)
	{
		TotalValue = 100;
	}

	// Do the roll
	RollValue = `SYNC_RAND(TotalValue);
	CurrentValue = 0;

	for(idx = 0; idx < BiomeChances.Length; idx++)
	{
		CurrentValue += BiomeChances[idx].Chance;

		if(RollValue < CurrentValue)
		{
			Biome = BiomeChances[idx].BiomeName;
			break;
		}
	}

	return Biome;
}

//---------------------------------------------------------------------------------------
protected function bool SelectPlotDefinition(MissionDefinition MissionDef, string Biome, out PlotDefinition SelectedDef, out array<string> ExcludeBiomes, optional array<name> SitRepNames)
{
	local XComParcelManager ParcelMgr;
	local array<PlotDefinition> ValidPlots;
	local X2SitRepTemplateManager SitRepMgr;
	local name SitRepName;
	local X2SitRepTemplate SitRep;

	ParcelMgr = `PARCELMGR;
	ParcelMgr.GetValidPlotsForMission(ValidPlots, MissionDef, Biome);
	SitRepMgr = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();

	// pull the first one that isn't excluded from strategy, they are already in order by weight
	foreach ValidPlots(SelectedDef)
	{
		foreach SitRepNames(SitRepName)
		{
			SitRep = SitRepMgr.FindSitRepTemplate(SitRepName);

			if(SitRep != none && SitRep.ExcludePlotTypes.Find(SelectedDef.strType) != INDEX_NONE)
			{
				continue;
			}
		}

		if(!SelectedDef.ExcludeFromStrategy)
		{
			return true;
		}
	}

	ExcludeBiomes.AddItem(Biome);
	return false;
}
