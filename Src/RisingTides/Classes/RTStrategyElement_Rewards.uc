// This is an Unreal Script
class RTStrategyElement_Rewards extends X2StrategyElement_XpackRewards config(ProgramFaction);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;

	// Find Faction
	Rewards.AddItem(CreateFindProgramFactionRewardTemplate());
	Rewards.AddItem(CreateFindFarthestProgramFactionRewardTemplate());

	// Hunt Templars

	// Misc Rewards
	Rewards.AddItem(CreateProgramAddCardSlotTemplate());
	Rewards.AddItem(CreateProgramIncreaseInfluenceTemplate());

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

	`CREATE_X2Reward_TEMPLATE(Template, '');
	
	Template.IsRewardAvailableFn = none; // allows logical augmentation of reward availability. For example, rescue rewards are only available if there are captured soldiers
	Template.IsRewardNeededFn = none; // allows logical augmentation of reward availability. Used to indicate if the player desperately needs this resource
	Template.GenerateRewardFn = none;
	Template.SetRewardFn = none;
	Template.GiveRewardFn = none;
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

static function X2DataTemplate CreateProgramHuntTemplarsP2Reward() {
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, '');
	
	Template.IsRewardAvailableFn = none; // allows logical augmentation of reward availability. For example, rescue rewards are only available if there are captured soldiers
	Template.IsRewardNeededFn = none; // allows logical augmentation of reward availability. Used to indicate if the player desperately needs this resource
	Template.GenerateRewardFn = none;
	Template.SetRewardFn = none;
	Template.GiveRewardFn = none;
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

	`CREATE_X2Reward_TEMPLATE(Template, '');
	
	Template.IsRewardAvailableFn = none; // allows logical augmentation of reward availability. For example, rescue rewards are only available if there are captured soldiers
	Template.IsRewardNeededFn = none; // allows logical augmentation of reward availability. Used to indicate if the player desperately needs this resource
	Template.GenerateRewardFn = none;
	Template.SetRewardFn = none;
	Template.GiveRewardFn = none;
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

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---Is Available Delegates--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// copied from RealityMachina
static function bool IsProgramFactionReward_AddCardSlot_Available(optional XComGameState NewGameState, optional StateObjectReference AuxRef) {
	local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;

	History = `XCOMHISTORY;
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
	local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;

	History = `XCOMHISTORY;
	FactionState = GetFactionState(NewGameState, AuxRef);

	if(FactionState.GetMyTemplateName() == class'RTHelpers'.default.ProgramFactionName)
		return IsFindFactionRewardAvailable(NewGameState, AuxRef);
	else return false;
}

static function bool IsFindFarthestProgramFactionRewardAvailable(optional XComGameState NewGameState, optional StateObjectReference AuxRef) {
	local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;

	History = `XCOMHISTORY;
	FactionState = GetFactionState(NewGameState, AuxRef);

	if(FactionState.GetMyTemplateName() == class'RTHelpers'.default.ProgramFactionName)
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

	return true;
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
	local XComGameState_ResistanceFaction FactionState, RandomFactionState;
	local array<XComGameState_ResistanceFaction> ArrayOfStates;
	local XComGameStateHistory History;
	local XComGameState_CovertAction ActionState;

	History = `XCOMHISTORY;
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
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---Misc Delegates--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static function ProgramFactionInfluenceRewardPopup(XComGameState_Reward RewardState)
{
	local DynamicPropertySet PropertySet; //need to delay it when the player can see it
	
	class'X2StrategyGameRulesetDataStructures'.static.BuildDynamicPropertySet(PropertySet, 'UIAlert_ProgramLevelup', 'UIFactionPopup', none, false, false, true, false);
	class'XComPresentationLayerBase'.static.QueueDynamicPopup(PropertySet);
}