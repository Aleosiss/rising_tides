// This is an Unreal Script
class RTStrategyElement_Rewards extends X2StrategyElement_XpackRewards config(ProgramFaction);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;

	// Factions
	Rewards.AddItem(CreateFindProgramFactionRewardTemplate());
	Rewards.AddItem(CreateFindFarthestProgramFactionRewardTemplate());

	// Hunt Templars

	return Rewards;
}

static function X2DataTemplate CreateFindProgramFactionRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_RTProgram_FindFaction');
	Template.IsRewardAvailableFn = IsFindFactionRewardAvailable;
	Template.GenerateRewardFn = GenerateMeetFactionReward;
	Template.GiveRewardFn = MeetProgramFaction;
	Template.CleanUpRewardFn = CleanUpUnitReward;

	return Template;
}

static function X2DataTemplate CreateFindFarthestProgramFactionRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_RTProgram_FindFarthestFaction');
	Template.IsRewardAvailableFn = IsFindFarthestProgramFactionRewardAvailable;
	Template.GenerateRewardFn = GenerateMeetFactionReward;
	Template.GiveRewardFn = MeetProgramFaction;
	Template.CleanUpRewardFn = CleanUpUnitReward;

	return Template;
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


static function GenerateMeetFactionReward(XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference AuxRef)
{
	// there is no reward
	return;
}

static function MeetProgramFaction(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
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