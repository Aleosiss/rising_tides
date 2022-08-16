class RTEventListener extends X2EventListener config(ProgramFaction);

// Stolen from RealityMachina
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(RTContinueFactionHQReveal());
	Templates.AddItem(EnableHostileTemplarFocusUI());
	Templates.AddItem(RTBlockCovertActions());

	return Templates;
}

static function X2EventListenerTemplate RTContinueFactionHQReveal()
{
	local X2EventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'RT_FactionHQReveal');
	Template.RegisterInStrategy = true;
	Template.AddEvent('RevealHQ_Program', ResumeFactionHQReveal);

	return Template;
}

static protected function EventListenerReturn ResumeFactionHQReveal(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	`HQPRES.FactionRevealPlayClassIntroMovie();

	return ELR_NoInterrupt;
}

static function X2EventListenerTemplate EnableHostileTemplarFocusUI()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RT_EnableHostileTemplarFocusUI');

	Template.RegisterInTactical = true;
	Template.AddCHEvent('OverrideUnitFocusUI', OnOverrideFocus, ELD_Immediate);

	return Template;
}

/**
 * Tuple Data:
 * Index 0 = IsVisible
 * Index 1 = CurrentValue
 * Index 2 = MaximumValue
 * Index 3 = BarColor
 * Index 4 = Icon
 * Index 5 = TooltipLong
 * Index 6 = TooltipShort
 */

static function EventListenerReturn OnOverrideFocus(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit UnitState;
	local XComLWTuple Tuple;
	local XComGamestate_Effect_TemplarFocus FocusState;

	Tuple = XComLWTuple(EventData);
	UnitState = XComGameState_Unit(EventSource);
	FocusState = UnitState.GetTemplarFocusEffectState();

	if(!`CONFIG.HostileTemplarFocusUIEnabled) {
		return ELR_NoInterrupt;
	}

	if (UnitState.HasSoldierAbility('TemplarFocus') && FocusState != none)
	{
		Tuple.Data[0].b = true;
		Tuple.Data[1].i = FocusState.FocusLevel;
		Tuple.Data[2].i = FocusState.GetMaxFocus(UnitState);
		Tuple.Data[3].s = "0x" $ class'UIUtilities_Colors'.const.PSIONIC_HTML_COLOR;
		Tuple.Data[4].s = "";
		Tuple.Data[5].s = `XEXPAND.ExpandString(class'UITacticalHUD_SoldierInfo'.default.FocusLevelDescriptions[FocusState.FocusLevel]);
		Tuple.Data[6].s = class'UITacticalHUD_SoldierInfo'.default.FocusLevelLabel;
	}

	return ELR_NoInterrupt;
}

static function X2EventListenerTemplate RTBlockCovertActions()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RT_BlockCovertActions');

	Template.RegisterInStrategy = true;
	Template.AddCHEvent('CovertAction_PreventGiveRewards', OnPreventGiveRewards, ELD_Immediate);

	return Template;
}

/**
 * Tuple Data:
 * Index 0 = false
 */
static function EventListenerReturn OnPreventGiveRewards(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_CovertAction ActionState;
	local XComLWTuple Tuple;
	local StateObjectReference ActionRef;
	local RTGameState_ProgramFaction ProgramState;

	Tuple = XComLWTuple(EventData);
	ActionState = XComGameState_CovertAction(EventSource);
	ActionRef = ActionState.GetReference();
	
	ProgramState = `RTS.GetProgramState();
	if(ProgramState == none) {
		return ELR_NoInterrupt;
	}

	if(ProgramState.BlockedCovertActions.Length == 0) {
		return ELR_NoInterrupt;
	}

	if(ProgramState.BlockedCovertActions.Find('ObjectID', ActionState.ObjectID) != INDEX_NONE) {
		ProgramState.BlockedCovertActions.RemoveItem(ActionRef);
		Tuple.Data[0].b = true;
	}

	return ELR_NoInterrupt;
}
