class RTEventListener extends X2EventListener config(ProgramFaction);

// Stolen from RealityMachina
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(RTContinueFactionHQReveal());
	Templates.AddItem(EnableHostileTemplarFocusUI());
	Templates.AddItem(RTBlockCovertActions());
	Templates.AddItem(RTNegateEnvironmentalDamage());

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

static function X2EventListenerTemplate RTNegateEnvironmentalDamage()
{
	local X2EventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'RT_ModifyEnvironmentDamage');
	Template.RegisterInTactical = true;
	Template.AddEvent('ModifyEnvironmentDamage', NegateEnvironmentalDamage);

	return Template;
}
/*
	ModifyEnvironmentDamageTuple = new class'XComLWTuple';
	ModifyEnvironmentDamageTuple.Id = 'ModifyEnvironmentDamage';
	ModifyEnvironmentDamageTuple.Data.Add(3);
	ModifyEnvironmentDamageTuple.Data[0].kind = XComLWTVBool;
	ModifyEnvironmentDamageTuple.Data[0].b = false;  // override? (true) or add? (false)
	ModifyEnvironmentDamageTuple.Data[1].kind = XComLWTVInt;
	ModifyEnvironmentDamageTuple.Data[1].i = 0;  // override/bonus environment damage
	ModifyEnvironmentDamageTuple.Data[2].kind = XComLWTVObject;
	ModifyEnvironmentDamageTuple.Data[2].o = AbilityStateObject;  // ability being used
	`XEVENTMGR.TriggerEvent('ModifyEnvironmentDamage', ModifyEnvironmentDamageTuple, self, NewGameState);

	EventData = LWTuple
	EventSource = X2Effect_ApplyWeaponDamage
*/
static function EventListenerReturn NegateEnvironmentalDamage(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData) {
	local XComLWTuple Tuple;
	local X2Effect_ApplyWeaponDamage Effect;
	local XComGameState_Ability AbilityState;

	AbilityState = XComGameState_Ability(Tuple.Data[2].o);

	if(`GLOBAL.NEGATED_ENV_DAMAGE_ABILITIES.Find(AbilityState.GetMyTemplateName()) != INDEX_NONE) {

		`RTLOG("Negating environmental damage for " $ AbilityState.GetMyTemplateName());
		Tuple.Data[0].b = true;
		Tuple.Data[1].i = 0;
	}

	return ELR_NoInterrupt;
}
