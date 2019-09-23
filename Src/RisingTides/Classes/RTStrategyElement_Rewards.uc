// This is an Unreal Script
class RTStrategyElement_Rewards extends X2StrategyElement_XpackRewards config(ProgramFaction);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;

	// Find Faction
	Rewards.AddItem(CreateFindProgramFactionRewardTemplate());
	Rewards.AddItem(CreateFindFarthestProgramFactionRewardTemplate());

	// Hunt Templars
	Rewards.AddItem(CreateProgramHuntTemplarsP1Reward());
	Rewards.AddItem(CreateProgramHuntTemplarsP2Reward());
	Rewards.AddItem(CreateProgramHuntTemplarsP3Reward());

	Rewards.AddItem(CreateProgramHuntTemplarsAmbushReward());
	Rewards.AddItem(CreateProgramTemplarCovenAssaultReward());

	// Misc Rewards
	Rewards.AddItem(CreateProgramAddCardSlotTemplate());
	Rewards.AddItem(CreateProgramIncreaseInfluenceTemplate());

	// Empty Reward
	Rewards.AddItem(CreateProgramNullReward());

	return Rewards;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---Reward Templates--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static function X2DataTemplate CreateFindProgramFactionRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_RTProgram_FindFaction');
	Template.IsRewardAvailableFn = IsFindProgramFactionRewardAvailable;
	Template.GenerateRewardFn = GenerateMeetFactionReward;
	Template.GiveRewardFn = GiveMeetProgramFactionReward;
	Template.CleanUpRewardFn = CleanUpUnitReward;

	return Template;
}

static function X2DataTemplate CreateProgramAddCardSlotTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_RTProgram_AddCardSlot');
	Template.IsRewardAvailableFn = IsProgramFactionReward_AddCardSlot_Available;
	Template.GiveRewardFn = GiveProgramCardSlotReward;

	return Template;
}

static function X2DataTemplate CreateFindFarthestProgramFactionRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_RTProgram_FindFarthestFaction');
	Template.IsRewardAvailableFn = IsFindFarthestProgramFactionRewardAvailable;
	Template.GenerateRewardFn = GenerateMeetFactionReward;
	Template.GiveRewardFn = GiveMeetProgramFactionReward;
	Template.CleanUpRewardFn = CleanUpUnitReward;

	return Template;
}

static function X2DataTemplate CreateProgramIncreaseInfluenceTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_RTProgram_IncreaseFactionInfluence');

	Template.IsRewardAvailableFn = IsProgramFactionReward_IncreaseInfluence_Available;
	Template.GenerateRewardFn = GenerateProgramFactionInfluenceReward;
	Template.GiveRewardFn = GiveProgramFactionInfluenceReward;
	//Template.GetRewardImageFn = GetFactionInfluenceRewardImage;
	//Template.GetRewardStringFn = GetFactionInfluenceRewardString;
	Template.CleanUpRewardFn = CleanUpRewardWithoutRemoval;
	Template.RewardPopupFn = ProgramFactionInfluenceRewardPopup;

	return Template;
}

static function X2DataTemplate CreateProgramHuntTemplarsP1Reward() {
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'RTReward_ProgramHuntTemplarsP1');
	
	Template.IsRewardAvailableFn = IsHuntTemplarsP1Available; // allows logical augmentation of reward availability. For example, rescue rewards are only available if there are captured soldiers
	Template.IsRewardNeededFn = none; // allows logical augmentation of reward availability. Used to indicate if the player desperately needs this resource
	Template.GenerateRewardFn = none;
	Template.SetRewardFn = none;
	Template.GiveRewardFn = GiveHuntTemplarAmbushReward;
	Template.GetRewardStringFn = none;
	Template.GetRewardPreviewStringFn = none;
	Template.GetRewardDetailsStringFn = none;
	Template.GetRewardImageFn = none;
	Template.SetRewardByTemplateFn = none;
	Template.GetBlackMarketStringFn = none;
	Template.GetRewardIconFn = none;
	Template.CleanUpRewardFn = none;
	Template.RewardPopupFn = TemplarAmbushPopup;

	return Template;
}

static function X2DataTemplate CreateProgramHuntTemplarsP2Reward() {
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'RTReward_ProgramHuntTemplarsP2');
	
	Template.IsRewardAvailableFn = IsHuntTemplarsP2Available; // allows logical augmentation of reward availability. For example, rescue rewards are only available if there are captured soldiers
	Template.IsRewardNeededFn = none; // allows logical augmentation of reward availability. Used to indicate if the player desperately needs this resource
	Template.GenerateRewardFn = none;
	Template.SetRewardFn = none;
	Template.GiveRewardFn = GiveHuntTemplarAmbushReward;
	Template.GetRewardStringFn = none;
	Template.GetRewardPreviewStringFn = none;
	Template.GetRewardDetailsStringFn = none;
	Template.GetRewardImageFn = none;
	Template.SetRewardByTemplateFn = none;
	Template.GetBlackMarketStringFn = none;
	Template.GetRewardIconFn = none;
	Template.CleanUpRewardFn = none;
	Template.RewardPopupFn = none;

	return Template;
}

static function X2DataTemplate CreateProgramHuntTemplarsP3Reward() {
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'RTReward_ProgramHuntTemplarsP3');
	
	Template.IsRewardAvailableFn = IsHuntTemplarsP3Available;
	Template.IsRewardNeededFn = none; 
	Template.GenerateRewardFn = none;
	Template.SetRewardFn = none;
	Template.GiveRewardFn = GiveHuntTemplarAmbushReward; // TODO
	Template.GetRewardStringFn = none; // TODO
	Template.GetRewardPreviewStringFn = none; // TODO
	Template.GetRewardDetailsStringFn = none; // TODO
	Template.GetRewardImageFn = none; // TODO
	Template.SetRewardByTemplateFn = none;
	Template.GetBlackMarketStringFn = none;
	Template.GetRewardIconFn = none;
	Template.CleanUpRewardFn = none;
	Template.RewardPopupFn = HuntTemplarsP3RewardPopup; // TODO

	return Template;
}

static function X2DataTemplate CreateProgramNullReward() {
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'RTReward_None');

	return Template;
}

static function X2DataTemplate CreateProgramHuntTemplarsAmbushReward() {
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'RTReward_TemplarAmbush');
	
	Template.IsRewardAvailableFn = none;
	Template.IsRewardNeededFn = none; 
	Template.GenerateRewardFn = none;
	Template.SetRewardFn = none;
	Template.GiveRewardFn = GiveHuntTemplarAmbushReward; // TODO
	Template.GetRewardStringFn = none; // TODO
	Template.GetRewardPreviewStringFn = none; // TODO
	Template.GetRewardDetailsStringFn = none; // TODO
	Template.GetRewardImageFn = none; // TODO
	Template.SetRewardByTemplateFn = none;
	Template.GetBlackMarketStringFn = none;
	Template.GetRewardIconFn = none;
	Template.CleanUpRewardFn = none;
	Template.RewardPopupFn = none; // TODO

	return Template;
}

static function X2DataTemplate CreateProgramTemplarCovenAssaultReward() {
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'RTReward_TemplarHighCovenAssault');
	
	Template.IsRewardAvailableFn = none;
	Template.IsRewardNeededFn = none; 
	Template.GenerateRewardFn = none;
	Template.SetRewardFn = none;
	Template.GiveRewardFn = GiveTemplarCovenAssaultReward; // TODO
	Template.GetRewardStringFn = none; // TODO
	Template.GetRewardPreviewStringFn = none; // TODO
	Template.GetRewardDetailsStringFn = none; // TODO
	Template.GetRewardImageFn = none; // TODO
	Template.SetRewardByTemplateFn = none;
	Template.GetBlackMarketStringFn = none;
	Template.GetRewardIconFn = none;
	Template.CleanUpRewardFn = none;
	Template.RewardPopupFn = none; // TODO

	return Template;
}

static function X2DataTemplate CreateProgramGrantFavorReward() {
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'RTReward_ProgramGrantFavor');
	
	Template.IsRewardAvailableFn = IsProgramFactionRewardAvailable;
	Template.IsRewardNeededFn = none; 
	Template.GenerateRewardFn = none;
	Template.SetRewardFn = none;
	Template.GiveRewardFn = GiveProgramGrantFavorReward; // TODO
	Template.GetRewardStringFn = none; // TODO
	Template.GetRewardPreviewStringFn = none; // TODO
	Template.GetRewardDetailsStringFn = none; // TODO
	Template.GetRewardImageFn = none; // TODO
	Template.SetRewardByTemplateFn = none;
	Template.GetBlackMarketStringFn = none;
	Template.GetRewardIconFn = none;
	Template.CleanUpRewardFn = none;
	Template.RewardPopupFn = none; // TODO

	return Template;
}

static function X2DataTemplate CreateProgramCallInFavorReward() {
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'RTReward_ProgramCallInFavor');
	
	Template.IsRewardAvailableFn = none;
	Template.IsRewardNeededFn = none; 
	Template.GenerateRewardFn = none;
	Template.SetRewardFn = none;
	Template.GiveRewardFn = GiveProgramCallInFavorReward; // TODO
	Template.GetRewardStringFn = none; // TODO
	Template.GetRewardPreviewStringFn = none; // TODO
	Template.GetRewardDetailsStringFn = none; // TODO
	Template.GetRewardImageFn = none; // TODO
	Template.SetRewardByTemplateFn = none;
	Template.GetBlackMarketStringFn = none;
	Template.GetRewardIconFn = none;
	Template.CleanUpRewardFn = none;
	Template.RewardPopupFn = none; // TODO

	return Template;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---Is Available Delegates--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// copied from RealityMachina
static function bool IsProgramFactionReward_AddCardSlot_Available(optional XComGameState NewGameState, optional StateObjectReference AuxRef) {
	//local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;

	//History = `XCOMHISTORY;
	FactionState = GetFactionState(NewGameState, AuxRef);
	if (FactionState != none) {
		if ( FactionState.GetMyTemplateName() != 'Faction_Program') {
			return false; // only for the Program
		}
	}

	if(class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('T1_M6_KillAvatar') || class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('T2_M3_CompleteForgeMission')  || class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('T4_M1_CompleteStargateMission')) {
		return true;
	}
	return false;
}

static function bool IsProgramFactionReward_IncreaseInfluence_Available(optional XComGameState NewGameState, optional StateObjectReference AuxRef) {
	// since the program will increase influence via OSF missions, this won't be used by the system
	return false;
}

static function bool IsFindProgramFactionRewardAvailable(optional XComGameState NewGameState, optional StateObjectReference AuxRef) {
	//local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;

	//History = `XCOMHISTORY;
	FactionState = GetFactionState(NewGameState, AuxRef);

	if(FactionState.GetMyTemplateName() == `RTD.ProgramFactionName)
		return IsFindFactionRewardAvailable(NewGameState, AuxRef);
	else return false;
}

static function bool IsFindFarthestProgramFactionRewardAvailable(optional XComGameState NewGameState, optional StateObjectReference AuxRef) {
	//local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;

	//History = `XCOMHISTORY;
	FactionState = GetFactionState(NewGameState, AuxRef);

	if(FactionState.GetMyTemplateName() == `RTD.ProgramFactionName)
		return IsFindFarthestFactionRewardAvailable(NewGameState, AuxRef);
	else return false;
}

static function bool IsProgramFactionRewardAvailable(optional XComGameState NewGameState, optional StateObjectReference AuxRef) {
	local XComGameState_ResistanceFaction FactionState;

	FactionState = GetFactionState(NewGameState, AuxRef);
	if (FactionState != none) {
		if ( FactionState.GetMyTemplateName() != 'Faction_Program') {
			return false;
		}

		return FactionState.bMetXCom;
	}

	return false;
}

static function bool IsHuntTemplarsP1Available(optional XComGameState NewGameState, optional StateObjectReference AuxRef) {
	local RTGameState_ProgramFaction ProgramState;
	local XComGameState_ResistanceFaction FactionState;
	//local XComGameStateHistory History;

	FactionState = GetFactionState(NewGameState, AuxRef);
	if (FactionState != none) {
		if ( FactionState.GetMyTemplateName() != 'Faction_Program') {
			`RTLOG("FactionState.GetMyTemplateName() == " $ FactionState.GetMyTemplateName() $ ", returning FALSE!");
			return false;
		}
	}

	ProgramState = RTGameState_ProgramFaction(FactionState);
	if(ProgramState == none) {
		`RTLOG("wut", true);
	}

	if(ProgramState.hasFailedTemplarQuestline()) {
		return false;
	}

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState) {
		if(FactionState.GetMyTemplateName() == 'Faction_Templars') {
			if(FactionState.bMetXCom) {
				`RTLOG("The Templars have been met, returning TRUE!");
				return true;
			}
		}
	}
	`RTLOG("The Templars haven't been met, returning FALSE!");
	return false;
}

static function bool IsHuntTemplarsP2Available(optional XComGameState NewGameState, optional StateObjectReference AuxRef) {
	local RTGameState_ProgramFaction ProgramState;
	local XComGameState_ResistanceFaction FactionState;
	//local XComGameStateHistory History;

	FactionState = GetFactionState(NewGameState, AuxRef);
	if (FactionState != none) {
		if ( FactionState.GetMyTemplateName() != 'Faction_Program') {
			`RTLOG("FactionState.GetMyTemplateName() == " $ FactionState.GetMyTemplateName() $ ", returning FALSE!");
			return false;
		}
	}

	ProgramState = RTGameState_ProgramFaction(FactionState);
	if(ProgramState == none) {
		`RTLOG("wut", true);
	}

	if(ProgramState.hasFailedTemplarQuestline()) {
		return false;
	}

	if(ProgramState.getTemplarQuestlineStage() == 1) {
		`RTLOG("The questline stage has been met, returning TRUE!");
		return true;
	}

	`RTLOG("The questline stage hasn't been met, returning FALSE!");
	return false;
}

static function bool IsHuntTemplarsP3Available(optional XComGameState NewGameState, optional StateObjectReference AuxRef) {
	local RTGameState_ProgramFaction ProgramState;
	local XComGameState_ResistanceFaction FactionState;
	//local XComGameStateHistory History;

	FactionState = GetFactionState(NewGameState, AuxRef);
	if (FactionState != none) {
		if ( FactionState.GetMyTemplateName() != 'Faction_Program') {
			`RTLOG("FactionState.GetMyTemplateName() == " $ FactionState.GetMyTemplateName() $ ", returning FALSE!");
			return false;
		}
	}

	ProgramState = RTGameState_ProgramFaction(FactionState);
	if(ProgramState == none) {
		`RTLOG("wut", true);
	}

	if(ProgramState.hasFailedTemplarQuestline()) {
		return false;
	}

	if(ProgramState.getTemplarQuestlineStage() == 2) {
		`RTLOG("The questline stage has been met, returning TRUE!");
		return true;
	}

	`RTLOG("The questline stage hasn't been met, returning FALSE!");
	return false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---Generate Reward Delegates--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static function GenerateMeetFactionReward(XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference AuxRef)
{
	// there is no reward
	return;
}

static function GenerateProgramFactionInfluenceReward(XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference AuxRef) {
	RewardState.RewardObjectReference = AuxRef; //hold the faction state here
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---Give Reward Delegates--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static function GiveProgramCardSlotReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_ResistanceFaction FactionState;
	//local array<XComGameState_ResistanceFaction> ArrayOfStates;
	//local XComGameStateHistory History;
	local XComGameState_CovertAction ActionState;

	ActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(AuxRef.ObjectID));

	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', ActionState.Faction.ObjectID));
	FactionState.AddCardSlot();
}

static function GiveMeetProgramFactionReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_ResistanceFaction FactionState;

	FactionState = XComGameState_ResistanceFaction(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'RTGameState_ProgramFaction'));

	// If the player is rewarded a soldier for an non-met faction, meet them. This is the code path for the "Find Faction" covert action
	// Late game Covert Actions which reward faction soldiers will only be for previously met factions
	if (FactionState != none && !FactionState.bMetXCom)
	{
		FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FactionState.ObjectID));
		FactionState.MeetXCom(NewGameState); // Don't give a Faction soldier since we were just rewarded one
	}
}

static function GiveProgramFactionInfluenceReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_ResistanceFaction FactionState;
	
	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', RewardState.RewardObjectReference.ObjectID));
	FactionState.IncreaseInfluenceLevel(NewGameState);
	if(FactionState.GetInfluence() < eFactionInfluence_Influential) {
		if(RTGameState_ProgramFaction(FactionState) != none) {
			RTGameState_ProgramFaction(FactionState).ForceIncreaseInfluence();
		}
	}
}

static function GiveHuntTemplarsP1Reward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local RTGameState_ProgramFaction ProgramFaction;
	
	ProgramFaction = `RTS.GetNewProgramState(NewGameState);
	if(ProgramFaction.getTemplarQuestlineStage() == 0) {
		`RTLOG("Granting GiveHuntTemplarsP1Reward!");
		GiveProgramAdvanceQuestlineReward(NewGameState, RewardState, AuxRef, bOrder, OrderHours);
	} else {
		`RTLOG("Not granting GiveHuntTemplarsP1Reward, incorrect questline stage. Expecting 0 but received " $ ProgramFaction.getTemplarQuestlineStage());
	}
}

static function GiveHuntTemplarsP2Reward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local RTGameState_ProgramFaction ProgramFaction;
	
	ProgramFaction = `RTS.GetNewProgramState(NewGameState);
	if(ProgramFaction.getTemplarQuestlineStage() == 1) {
		`RTLOG("Granting GiveHuntTemplarsP2Reward!");
		GiveProgramAdvanceQuestlineReward(NewGameState, RewardState, AuxRef, bOrder, OrderHours);
	} else {
		`RTLOG("Not granting GiveHuntTemplarsP2Reward, incorrect questline stage. Expecting 1 but received " $ ProgramFaction.getTemplarQuestlineStage());
	}
}

static function GiveHuntTemplarsP3Reward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local RTGameState_ProgramFaction ProgramFaction;
	
	ProgramFaction = `RTS.GetNewProgramState(NewGameState);
	if(ProgramFaction.getTemplarQuestlineStage() == 2) {
		`RTLOG("Granting GiveHuntTemplarsP3Reward!");
		GiveHighCovenAssaultMission(NewGameState, RewardState, AuxRef, bOrder, OrderHours);
	} else {
		`RTLOG("Not granting GiveHuntTemplarsP3Reward, incorrect questline stage. Expecting 2 but received " $ ProgramFaction.getTemplarQuestlineStage());
	}
}

static function GiveHighCovenAssaultMission(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local RTGameState_ProgramFaction ProgramState;
	local RTGameState_MissionSiteTemplarHighCoven MissionState;
	local DynamicPropertySet PropertySet;

	ProgramState = `RTS.GetNewProgramState(NewGameState);
	ProgramState.IncrementTemplarQuestlineStage();
	ProgramState.IncrementNumFavorsAvailable(3);

	MissionState = CreateTemplarHighCovenAssaultMission(NewGameState);

	RewardState.RewardObjectReference = MissionState.GetReference();
}

static function HuntTemplarsP3RewardPopup(XComGameState_Reward RewardState)
{
	local XComGameState_MissionSite MissionSite;
	local StateObjectReference EmptyRef;
	local RTGameState_ProgramFaction ProgramFaction;
	
	ProgramFaction = `RTS.GetProgramState();
	if(ProgramFaction.getTemplarQuestlineStage() >= 2) {
		`RTLOG("HuntTemplarsP3RewardPopup: correct stage, continuing...");
	} else {
		`RTLOG("HuntTemplarsP3RewardPopup: wrong stage, failing!");
		return;
	}

	if(RewardState.RewardObjectReference == EmptyRef) {
		`RTLOG("HuntTemplarsP3RewardPopup: Failed the mission, not sending the mission popup!");
		return;
	}

	MissionSite = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
	if (MissionSite != none && MissionSite.GetMissionSource().MissionPopupFn != none)
	{
		MissionSite.GetMissionSource().MissionPopupFn(MissionSite);
	}
}

static function TemplarAmbushPopup(XComGameState_Reward RewardState) {
	HuntTemplarsP3RewardPopup(RewardState);
}

static function RTGameState_MissionSiteTemplarHighCoven CreateTemplarHighCovenAssaultMission(XComGameState NewGameState) {
	local RTGameState_MissionSiteTemplarHighCoven MissionState;
	local XComGameState_Reward RewardState;
	local X2StrategyElementTemplateManager StratMgr;
	local X2RewardTemplate RewardTemplate;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local XComGameState_WorldRegion RegionState;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	MissionRewards.Length = 0;
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('RTReward_TemplarHighCovenAssault')); // rewards are given by the X2MissionSourceTemplate
	RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewards.AddItem(RewardState);

	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('RTMissionSource_TemplarHighCovenAssault'));
	MissionState = RTGameState_MissionSiteTemplarHighCoven(NewGameState.CreateNewStateObject(class'RTGameState_MissionSiteTemplarHighCoven'));
	MissionState.bGeneratedFromDebugCommand = false;

	//RegionState = GetRegionForHavenState(TemplarHavenState);
	RegionState = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(`RTS.GetTemplarFactionState().Region.ObjectID));
	
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true);
	MissionState.ResistanceFaction = `RTS.GetProgramState().GetReference();

	return MissionState;
}

private static function XComGameState_WorldRegion GetRegionForHavenState(XComGameState_Haven HavenState) {
	local XComGameState_Continent ContinentState;
	local XComGameState_WorldRegion RegionState;
	local Vector2D HavenLocation;
	local StateObjectReference RegionRef;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	ContinentState = XComGameState_Continent(History.GetGameStateForObjectID(HavenState.GetContinent().ObjectID));
	HavenLocation = HavenState.Get2DLocation();

	foreach ContinentState.Regions(RegionRef)
	{
		RegionState = XComGameState_WorldRegion(History.GetGameStateForObjectID(RegionRef.ObjectID));		
		if (RegionState.InRegion(HavenLocation))
		{
			return RegionState;
		}
	}

	`RTLOG("GetRegionForHavenState() failed! Returning none!", true);
	return none;

} 

private static function Vector2D GetNearbyLocation(Vector2D initial2DPos, float fMin, float fMax) {
	local Vector2D new2DPos;
	local float x, y;

	x = `SYNC_FRAND_STATIC(fMax) + fMin;
	y = `SYNC_FRAND_STATIC(fMax) + fMin;

	if(`SYNC_RAND_STATIC(2) >= 1) {
		x *= -1;
	}

	if(`SYNC_RAND_STATIC(2) >= 1) {
		y *= -1;
	}

	new2DPos = initial2DPos;
	new2DPos.x += x;
	new2DPos.y += y;

	return new2DPos;
}

static function GiveTemplarCovenAssaultReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local RTGameState_ProgramFaction ProgramFaction;

	ProgramFaction = `RTS.GetProgramState(NewGameState);
	if(!ProgramFaction.didTemplarMissionSucceed()) {
		GiveTemplarQuestlineFailedReward(NewGameState, RewardState, AuxRef, bOrder, OrderHours);
	} else {
		`RTLOG("Templar Questline Succeeded!");
		GiveTemplarQuestlineCompleteReward(NewGameState, RewardState, AuxRef, bOrder, OrderHours);
		// TODO: Success notification
	}
	
	// reset the flag
	ProgramFaction.SetTemplarMissionSucceededFlag(false);
}

static function GiveTemplarQuestlineFailedReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local RTGameState_ProgramFaction ProgramState;
	local XComGameState_ResistanceFaction TemplarState;
	local DynamicPropertySet PropertySet;

	ProgramState = `RTS.GetNewProgramState(NewGameState);
	TemplarState = `RTS.GetTemplarFactionState();

	ProgramState.IncrementTemplarQuestlineStage(); // we still need to increment this
	ProgramState.FailTemplarQuestline();
	
	
	`RTLOG("Templar Questline FAILED!");

	EliminateFaction(NewGameState, TemplarState);

	// Notify
	class'X2StrategyGameRulesetDataStructures'.static.BuildDynamicPropertySet(PropertySet, 'RTUIAlert', 'RTAlert_TemplarQuestlineFailed', none, true, true, true, false);
	class'XComPresentationLayerBase'.static.QueueDynamicPopup(PropertySet, NewGameState);
}

static function GiveTemplarQuestlineCompleteReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1) {
	local XComGameState_ResistanceFaction TemplarState;
	local RTGameState_ProgramFaction ProgramState;

	ProgramState = `RTS.GetNewProgramState(NewGameState);
	ProgramState.IncrementNumFavorsAvailable(30);
	ProgramState.IncrementTemplarQuestlineStage(); // should be 4 now
	
	TemplarState = `RTS.GetTemplarFactionState();
	EliminateFaction(NewGameState, TemplarState);

	CreateTemplarQuestlineCompletePopups(NewGameState);
}

static function CreateTemplarQuestlineCompletePopups(XComGameState NewGameState) {
	local DynamicPropertySet PropertySet;
	local DynamicPropertySet EmptySet;
	local XComGameState_Tech TechState;
	local StateObjectReference TechRef;
	local XComGameStateHistory History;

	/*
	static function BuildDynamicPropertySet(
	out DynamicPropertySet PropertySet, 
	Name PrimaryKey, 
	Name SecondaryKey, 
	delegate<AlertCallback> CallbackFunction, 
	bool bDisplayImmediate,
	bool bDisplayOnAvengerSideViewIdle,
	bool bDisplayOnGeoscapeIdle,
	bool bDisplayInTacticalIdle )
	*/

	// You won
	class'X2StrategyGameRulesetDataStructures'.static.BuildDynamicPropertySet(PropertySet,'RTUIAlert','RTAlert_TemplarQuestlineComplete', none, false, true, false, false);
	class'XComPresentationLayerBase'.static.QueueDynamicPopup(PropertySet, NewGameState);
	PropertySet = EmptySet;

	History = `XCOMHISTORY;
	foreach History.IterateByClassType(class'XComGameState_Tech', TechState) {
		if(TechState.GetMyTemplateName() == 'RTBuildProgramDrone') {
			break;
		}
	}

	// Program Drone Blueprints | eAlert_ProvingGroundProjectAvailable
	class'X2StrategyGameRulesetDataStructures'.static.BuildDynamicPropertySet(PropertySet, 'UIAlert', 'eAlert_ProvingGroundProjectAvailable', none, false, true, false, false);
	class'X2StrategyGameRulesetDataStructures'.static.AddDynamicStringProperty(PropertySet, 'SoundToPlay', "Geoscape_CrewMemberLevelledUp");
	class'X2StrategyGameRulesetDataStructures'.static.AddDynamicIntProperty(PropertySet, 'TechRef', TechState.ObjectID);
	class'XComPresentationLayerBase'.static.QueueDynamicPopup(PropertySet, NewGameState);
	PropertySet = EmptySet;

	// Warp Grenade Blueprints |  eAlert_ItemAvailable
	class'X2StrategyGameRulesetDataStructures'.static.BuildDynamicPropertySet(PropertySet, 'UIAlert', 'eAlert_ItemAvailable', none, false, true, false, false);
	class'X2StrategyGameRulesetDataStructures'.static.AddDynamicStringProperty(PropertySet, 'SoundToPlay', "Geoscape_CrewMemberLevelledUp");
	class'X2StrategyGameRulesetDataStructures'.static.AddDynamicNameProperty(PropertySet, 'ItemTemplate', 'RTWarpGrenade');
	class'XComPresentationLayerBase'.static.QueueDynamicPopup(PropertySet, NewGameState);
	PropertySet = EmptySet;
}

static function GiveHuntTemplarAmbushReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local RTGameState_ProgramFaction ProgramFaction;

	ProgramFaction = `RTS.GetNewProgramState(NewGameState);
	if(!ProgramFaction.didTemplarMissionSucceed()) {
		GiveTemplarQuestlineFailedReward(NewGameState, RewardState, AuxRef, bOrder, OrderHours);
	} else {
		switch(ProgramFaction.getTemplarQuestlineStage()) {
			case 0:
				GiveHuntTemplarsP1Reward(NewGameState, RewardState, AuxRef, bOrder, OrderHours);
				break;
			case 1:
				GiveHuntTemplarsP2Reward(NewGameState, RewardState, AuxRef, bOrder, OrderHours);
				break;
			case 2:
				GiveHuntTemplarsP3Reward(NewGameState, RewardState, AuxRef, bOrder, OrderHours);
				break;
			default:
				`RTLOG("Something broke, GiveHuntTemplarAmbushReward is out of bounds!", true, false);
				break;
		}
	}

	// reset the flag
	ProgramFaction.SetTemplarMissionSucceededFlag(false);
}

static function EliminateFaction(XComGameState NewGameState, XComGameState_ResistanceFaction FactionState, optional bool bShouldFactionSoldiersDesert = true) {
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistHQ;
	local XComGameState_Haven FactionHavenState;
	local StateObjectReference IteratorRef;
	local XComGameState_Unit UnitState;
	local XComGameState_StrategyCard CardState;
	local name FactionTemplateName;
	//local XComGameState_WorldRegion RegionState;
	//local StateObjectReference EmptyRef;
	//local int i;
	local RTGameState_DestroyedHaven HavenRuinState;

	History = `XCOMHISTORY;
	XComHQ = `RTS.GetXComHQState();
	ResistHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));
	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FactionState.GetReference().ObjectID));
	FactionTemplateName = FactionState.GetMyTemplateName();
	`RTLOG("Eliminating Faction: " $ FactionTemplateName);
	
	/** What, exactly, goes into removing a faction?
		-> Remove FactionState.GetReference() from XCGS_HeadquartersResistance.Factions
		-> Call DeactivateCard on all activated faction cards
		-> Check Covert Actions, if there are any from the faction they need to be canceled
		-> Need to clean up faction soldiers? It would be more realistic for them to stick around then leave randomly, perhaps even sabotage the avenger but fuck that
		-> Clean up the Resistance Haven
		-> Find soldiers in the XCOM barracks that are faction heroes, and remove them
		-> Generate a popup displaying all of what has transpired
		-> Transfer Chosen missions to Program(?)
	*/

	// remove from resistance hq
	ResistHQ = XComGameState_HeadquartersResistance(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersResistance', ResistHQ.GetReference().ObjectID));
	ResistHQ.Factions.RemoveItem(FactionState.GetReference());

	// remove covert actions
	FactionState.CleanUpFactionCovertActions(NewGameState);
	FactionState.CovertActions.Length = 0;

	// remove resistance orders
	foreach FactionState.CardSlots(IteratorRef) 
	{
		CardState = XComGameState_StrategyCard(History.GetGameStateForObjectID(IteratorRef.ObjectID));
		if(CardState != none) {
			CardState.DeactivateCard(NewGameState);
			FactionState.PlayableCards.AddItem(IteratorRef);
		}
		//i++;
	}

	// remove haven
	FactionHavenState = XComGameState_Haven(`XCOMHISTORY.GetGameStateForObjectID(FactionState.FactionHQ.ObjectID));
	FactionHavenState = XComGameState_Haven(NewGameState.ModifyStateObject(class'XComGameState_Haven', FactionState.FactionHQ.ObjectID));
	
	// Required to fill the Faction wheel in UIStrategyMap
	if(FactionTemplateName == 'Faction_Templars' ||
		FactionTemplateName == 'Faction_Reapers' ||
		FactionTemplateName == 'Faction_Skirmishers'
	) {
		HavenRuinState = RTGameState_DestroyedHaven(NewGameState.CreateNewStateObject(class'RTGameState_DestroyedHaven'));
		HavenRuinState.FactionRef = FactionState.GetReference();
		HavenRuinState.ChampionClassName = FactionState.GetChampionClassName();
		HavenRuinState.InitializeRuins(NewGameState);
	}

	if (`HQPRES != none && `HQPRES.StrategyMap2D != none)
	{
		FactionHavenState.RemoveMapPin(NewGameState);
	}
	NewGameState.RemoveStateObject(FactionHavenState.ObjectID);

	// remove faction solders
	if(bShouldFactionSoldiersDesert) {
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.GetReference().ObjectID));
		foreach XComHQ.Crew(IteratorRef)
		{
			UnitState = XComGameState_Unit(History.GetGameStateForObjectID(IteratorRef.ObjectID));
			if(UnitState != none && UnitState.FactionRef == FactionState.GetReference())
			{
				FireUnit(NewGameState, IteratorRef);
			}
		}
	}

	// rip
	NewGameState.RemoveStateObject(FactionState.ObjectID);
}

static function GiveProgramGrantFavorReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1) {
	local RTGameState_ProgramFaction ProgramState;

	ProgramState = `RTS.GetNewProgramState(NewGameState);
	ProgramState.IncrementNumFavorsAvailable(1);
}

static function GiveProgramCallInFavorReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1) {
	local RTGameState_ProgramFaction ProgramState;

	ProgramState = `RTS.GetNewProgramState(NewGameState);
	ProgramState.MakeOneSmallFavorAvailable();
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---Misc Delegates/Helpers--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static function ProgramFactionInfluenceRewardPopup(XComGameState_Reward RewardState)
{
	local DynamicPropertySet PropertySet; //need to delay it when the player can see it
	
	class'X2StrategyGameRulesetDataStructures'.static.BuildDynamicPropertySet(PropertySet, 'UIAlert_ProgramLevelup', 'UIFactionPopup', none, false, false, true, false);
	class'XComPresentationLayerBase'.static.QueueDynamicPopup(PropertySet);
}

static function GiveProgramAdvanceQuestlineReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1) {
	local RTGameState_ProgramFaction ProgramState;
	local DynamicPropertySet PropertySet;

	ProgramState = `RTS.GetNewProgramState(NewGameState);

	if(ProgramState.hasFailedTemplarQuestline()) {
		`RTLOG("Questline FAILED, not giving questline reward!");
	}

	ProgramState.IncrementTemplarQuestlineStage();
	ProgramState.IncrementNumFavorsAvailable(3);

	// notification
	class'X2StrategyGameRulesetDataStructures'.static.BuildDynamicPropertySet(PropertySet, 'RTUIAlert', 'RTAlert_TemplarQuestlineAdvanced', none, true, true, true, false);
	class'XComPresentationLayerBase'.static.QueueDynamicPopup(PropertySet, NewGameState);
}

// why wasn't this static in the first place...
static function FireUnit(XComGameState NewGameState, StateObjectReference UnitReference)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local StateObjectReference EmptyRef;
	local int idx;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	XComHQ.RemoveFromCrew(UnitReference);

	for(idx = 0; idx < XComHQ.Squad.Length; idx++)
	{
		if(XComHQ.Squad[idx] == UnitReference)
		{
			XComHQ.Squad[idx] = EmptyRef;
			break;
		}
	}

	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitReference.ObjectID));
	class'X2StrategyGameRulesetDataStructures'.static.ResetAllBonds(NewGameState, UnitState);

	// REMOVE FIRED UNIT?
	//NewGameState.RemoveStateObject(UnitReference.ObjectID);
}