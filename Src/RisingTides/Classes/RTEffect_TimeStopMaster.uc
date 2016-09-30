class RTEffect_TimeStopMaster extends X2Effect_PersistentStatChange;

var bool bWasPreviouslyTrue;


simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnit;
	local XComGameState_TimerData TimerData, OldTimerData;
	local XComGameStateHistory		History;
	
	TargetUnit = XComGameState_Unit(kNewTargetState);
	
	// Could you, Madoka? Could you see me in my stopped time?
	// Uh, no...
	// Oh.
	AddPersistentStatChange(eStat_DetectionModifier, 1);

	History = `XCOMHISTORY;
	foreach History.IterateByClassType(class'XComGameState_TimerData', OldTimerData) {
		TimerData = new class'XComGameState_TimerData'(OldTimerData);
		if(TimerData.TimerType == EGSTT_TurnCount) {
			TimerData.bStopTime = true;
		} 
	}

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);

}



simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
	local XComGameState_AIReinforcementSpawner OldSpawnerState, NewSpawnerState;
	local XComGameState_UITimer UiTimer;
	local XComTacticalController TacticalController;
	local XComGameState_TimerData TimerData, OldTimerData;
	local XComGameStateHistory		History;
  	
	/*
	OldUiTimer = XComGameState_UITimer(`XCOMHISTORY.GetSingleGameStateObjectForClass(class 'XComGameState_UITimer', true));
	if(OldUiTimer != none) {

		UiTimer = XComGameState_UITimer(NewGameState.CreateStateObject(class 'XComGameState_UITimer', OldUiTimer.ObjectID));

		UiTimer.UiState = OldUiTimer.UIState;
		UiTimer.ShouldShow = OldUiTimer.ShouldShow;
		UiTimer.DisplayMsgTitle = OldUiTimer.DisplayMsgTitle;
		UiTimer.DisplayMsgSubtitle = OldUiTimer.DisplayMsgSubtitle;
		UiTimer.TimerValue = OldUiTimer.TimerValue + 1;
	
		NewGameState.AddStateObject(UiTimer);
	}

	*/
	History = `XCOMHISTORY;
	foreach History.IterateByClassType(class'XComGameState_UITimer', UiTimer)
		break;
	if (UiTimer != none) {
		UiTimer.TimerValue++;
		TacticalController = XComTacticalController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController());
		if (TacticalController != none)
			XComPresentationLayer(TacticalController.Pres).UITimerMessage(UiTimer.DisplayMsgTitle, UiTimer.DisplayMsgSubtitle, string(UiTimer.TimerValue), UiTimer.UiState, UiTimer.ShouldShow);
	}

	
	
	foreach History.IterateByClassType(class'XComGameState_AIReinforcementSpawner', OldSpawnerState) {
		NewSpawnerState = XComGameState_AIReinforcementSpawner(NewGameState.CreateStateObject(class'XComGameState_AIReinforcementSpawner', OldSpawnerState.ObjectID));
		NewSpawnerState.Countdown = OldSpawnerState.Countdown + 1;
		NewGameState.AddStateObject(NewSpawnerState);
	}							
	return false;
}	

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_TimerData TimerData, OldTimerData;
	local XComGameStateHistory		History;
	/*
	History = `XCOMHISTORY;
	foreach History.IterateByClassType(class'XComGameState_TimerData', OldTimerData) {
		TimerData = new class'XComGameState_TimerData'(OldTimerData);
		if(TimerData.TimerType == EGSTT_TurnCount) {
			TimerData.bStopTime = false;
			NewGameState.AddStateObject(TimerData);
		} 
	}  
	*/
}	   