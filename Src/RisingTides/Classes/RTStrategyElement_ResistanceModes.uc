class RTStrategyElement_ResistanceModes extends X2StrategyElement config (ProgramFaction);

var config array<float>					PsiModeTrainingRateScalar;

//---------------------------------------------------------------------------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Modes;

	Modes.AddItem(CreatePsiTrainingModeTemplate());

	return Modes;
}

//---------------------------------------------------------------------------------------
static function X2DataTemplate CreatePsiTrainingModeTemplate()
{
	local X2ResistanceModeTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ResistanceModeTemplate', Template, 'ResistanceMode_PsiTraining');
	Template.Category = "ResistanceMode";
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.ResHQ_Intel";
	Template.OnActivatedFn = ActivatePsiTrainingMode;
	Template.OnDeactivatedFn = DeactivatePsiTrainingMode;
	Template.OnXCOMArrivesFn = OnXCOMArrivesPsiTrainingMode;
	Template.OnXCOMLeavesFn = OnXCOMLeavesPsiTrainingMode;

	return Template;
}

static function ActivatePsiTrainingMode(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	// The Avenger is already at ResHQ, so activate it immediately
	OnXCOMArrivesPsiTrainingMode(NewGameState, InRef);
}
//---------------------------------------------------------------------------------------
static function DeactivatePsiTrainingMode(XComGameState NewGameState, StateObjectReference InRef)
{
	// The Avenger is already at ResHQ, so deactivate it immediately
	OnXCOMLeavesPsiTrainingMode(NewGameState, InRef);
}
//---------------------------------------------------------------------------------------
static function OnXCOMArrivesPsiTrainingMode(XComGameState NewGameState, StateObjectReference InRef)
{
	local XComGameState_HeadquartersXCom XComHQ;

	// this is a hack to get around the "locate faction not completing" issue
	CompleteCurrentCovertAction(NewGameState);

	XComHQ = GetNewXComHQState(NewGameState);
	if (XComHQ.PsiTrainingRate < class'XComGameState_HeadquartersXCom'.default.XComHeadquarters_DefaultPsiTrainingWorkPerHour) // safety check: ensure healing rate is never below default
	{
		XComHQ.PsiTrainingRate = class'XComGameState_HeadquartersXCom'.default.XComHeadquarters_DefaultPsiTrainingWorkPerHour;
	}
	XComHQ.PsiTrainingRate += class'XComGameState_HeadquartersXCom'.default.XComHeadquarters_DefaultPsiTrainingWorkPerHour * `ScaleStrategyArrayFloat(default.PsiModeTrainingRateScalar);
	XComHQ.HandlePowerOrStaffingChange(NewGameState);
}
//---------------------------------------------------------------------------------------
static function OnXCOMLeavesPsiTrainingMode(XComGameState NewGameState, StateObjectReference InRef)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = GetNewXComHQState(NewGameState);
	XComHQ.PsiTrainingRate -= class'XComGameState_HeadquartersXCom'.default.XComHeadquarters_DefaultPsiTrainingWorkPerHour * `ScaleStrategyArrayFloat(default.PsiModeTrainingRateScalar);
	if (XComHQ.PsiTrainingRate < class'XComGameState_HeadquartersXCom'.default.XComHeadquarters_DefaultPsiTrainingWorkPerHour) // safety check: ensure healing rate is never below default
	{
		XComHQ.PsiTrainingRate = class'XComGameState_HeadquartersXCom'.default.XComHeadquarters_DefaultPsiTrainingWorkPerHour;
	}
	XComHQ.HandlePowerOrStaffingChange(NewGameState);
}

static function XComGameState_HeadquartersXCom GetNewXComHQState(XComGameState NewGameState)
{
	local XComGameState_HeadquartersXCom NewXComHQ;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', NewXComHQ)
	{
		break;
	}

	if (NewXComHQ == none)
	{
		NewXComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		NewXComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', NewXComHQ.ObjectID));
	}

	return NewXComHQ;
}

simulated static function CompleteCurrentCovertAction(XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_CovertAction ActionState;

	//class'RTHelpers'.static.RTLog("HACK! Overriding failed Covert Action! Searching through Available Actions...");
	History = `XCOMHISTORY;
	foreach History.IterateByClassType(class'XComGameState_CovertAction', ActionState)
	{
		//class'RTHelpers'.static.RTLog("" $ ActionState.GetMyTemplateName());
		if(ActionState.GetMyTemplateName() == 'CovertAction_FindProgramFaction' || ActionState.GetMyTemplateName() == 'CovertAction_FindProgramFarAwayFaction') {
			//class'RTHelpers'.static.RTLog("Found it!");
			if (ActionState.bStarted)
			{
				ActionState = XComGameState_CovertAction(NewGameState.ModifyStateObject(class'XComGameState_CovertAction', ActionState.ObjectID));
				ActionState.CompleteCovertAction(NewGameState);
			}
		}
	}
}
