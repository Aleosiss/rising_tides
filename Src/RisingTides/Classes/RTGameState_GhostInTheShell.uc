// This is an Unreal Script
class RTGameState_GhostInTheShell extends RTGameState_Effect;

function EventListenerReturn OnTacticalGameEnd(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local X2EventManager EventManager;
	local Object ListenerObj;
    local XComGameState NewGameState;

	EventManager = class'X2EventManager'.static.GetEventManager();

	// Unregister our callbacks
	ListenerObj = self;
	
	EventManager.UnRegisterFromEvent(ListenerObj, 'AbilityActivated');
	
    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("GITS cleanup");
	NewGameState.RemoveStateObject(ObjectID);
	`GAMERULES.SubmitGameState(NewGameState);
	
	return ELR_NoInterrupt;
}

function EventListenerReturn GhostInTheShellCheck(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability AbilityContext;
	local StateObjectReference AbilityRef;
	local XComGameState_Ability GhostAbilityState;
	local XComGameState_Ability AbilityState;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Unit NewAttacker, Attacker;
	local XComGameState NewGameState;
	local bool	bShouldTrigger;
	
	History = `XCOMHISTORY;
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext == none)
		return ELR_NoInterrupt;
	
	// Check if the source object was the source unit for this effect, and make sure the target was not
	if (AbilityContext.InputContext.SourceObject.ObjectID != ApplyEffectParameters.SourceStateObjectRef.ObjectID ||
		AbilityContext.InputContext.SourceObject.ObjectID == AbilityContext.InputContext.PrimaryTarget.ObjectID)
		return ELR_NoInterrupt;
	
	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
	if (AbilityState == none || AbilityState.ObjectID == 0)
		return ELR_NoInterrupt;
	
	if(AbilityState.GetMyTemplateName() == 'Interact_OpenChest' ||  AbilityState.GetMyTemplateName() == 'Interact_TakeVial' || AbilityState.GetMyTemplateName() == 'Interact_StasisTube')
            bShouldTrigger = true;
	if(AbilityState.GetMyTemplateName() == 'Interact' ||  AbilityState.GetMyTemplateName() == 'Interact_PlantBomb' || AbilityState.GetMyTemplateName() == 'Interact_OpenDoor')
            bShouldTrigger = true;
	if(AbilityState.GetMyTemplateName() == 'FinalizeHack' ||  AbilityState.GetMyTemplateName() == 'GatherEvidence' || AbilityState.GetMyTemplateName() == 'PlantExplosiveMissionDevice')
            bShouldTrigger = true;

	// We only want to trigger GITS when the source is actually using the right ability
	if(!bShouldTrigger) {
		return ELR_NoInterrupt;
	}

	Attacker = XComGameState_Unit(EventSource);	 

	if (Attacker != none) {
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
		NewAttacker = XComGameState_Unit(NewGameState.CreateStateObject(Attacker.Class, Attacker.ObjectID));
		//XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = TriggerBumpInTheNightFlyoverVisualizationFn;
		NewGameState.AddStateObject(NewAttacker);

		NewAttacker.ModifyCurrentStat(eStat_DetectionModifier, 0);
		`TACTICALRULES.SubmitGameState(NewGameState);

		InitializeAbilityForActivation(GhostAbilityState, NewAttacker, 'RTGhostInTheShellEffect', History);
		ActivateAbility(GhostAbilityState, NewAttacker.GetReference());
		NewAttacker = XComGameState_Unit(History.GetGameStateForObjectID(NewAttacker.ObjectID));

	}

	return ELR_NoInterrupt;
}


function TriggerGhostInTheShellFlyoverVisualizationFn(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{
	local XComGameState_Unit UnitState;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local VisualizationTrack BuildTrack;
	local XComGameStateHistory History;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Ability AbilityState;

	History = `XCOMHISTORY;
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		foreach VisualizeGameState.IterateByClassType(class'XComGameState_Ability', AbilityState)
		{
			break;
		}
		if (AbilityState == none)
		{
			`RedScreenOnce("Ability state missing from" @ GetFuncName() @ "-jbouscher @gameplay");
			`LOG("Rising Tides: ITS BROKEN");
			return;
		}

		History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, BuildTrack.StateObject_OldState, BuildTrack.StateObject_NewState, , VisualizeGameState.HistoryIndex);
		BuildTrack.StateObject_NewState = UnitState;
		BuildTrack.TrackActor = UnitState.GetVisualizer();

		AbilityTemplate = AbilityState.GetMyTemplate();
		if (AbilityTemplate != none)
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None,"Ghost in the Shell", '', eColor_Good, AbilityTemplate.IconImage);

			OutVisualizationTracks.AddItem(BuildTrack);
		}
		break;
	}
}