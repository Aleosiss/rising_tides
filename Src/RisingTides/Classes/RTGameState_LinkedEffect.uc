class RTGameState_LinkedEffect extends RTGameState_Effect;

var bool bCanTrigger;

function EventListenerReturn LinkedFireCheck (Object EventData, Object EventSource, XComGameState GameState, Name EventID) {
    local XComGameState_Unit TargetUnit, LinkedSourceUnit, LinkedUnit;
	local XComGameStateHistory History;
	local RTEffect_LinkedIntelligence LinkedEffect;
    local RTGameState_MeldEffect  MeldEffectState;
	local StateObjectReference AbilityRef;
	local GameRulesCache_VisibilityInfo	VisInfo;
	local XComGameState_Ability AbilityState, OriginalShot;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState NewGameState;
	local RTGameState_LinkedEffect NewLinkedEffectState;
	local StateObjectReference	EmptyRef;
	
	if(!bCanTrigger) {
		`LOG("Rising Tides: this should never happen");
		return ELR_NoInterrupt;
	}

	EmptyRef.ObjectID = 0;
	//`LOG("Rising Tides: Linked Fire Check Setup!");
	History = `XCOMHISTORY;
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext == none) {
		return ELR_NoInterrupt;	
	}
	//`LOG("Rising Tides: Linked Fire Check Stage 1");
	// We only want to link fire when the source is actually shooting a reaction shot
	if(AbilityContext.InputContext.AbilityTemplateName != 'RTOverwatchShot' && AbilityContext.InputContext.AbilityTemplateName != 'KillZoneShot' && AbilityContext.InputContext.AbilityTemplateName != 'OverwatchShot') {
		return ELR_NoInterrupt;
	}
	//`LOG("Rising Tides: Linked Fire Check Stage 2");
	// The LinkedSourceUnit should be  the unit that is currently attacking
	LinkedSourceUnit = class'X2TacticalGameRulesetDataStructures'.static.GetAttackingUnitState(GameState);

	// The Linked Unit is the one responding to the call to arms
	LinkedUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	
	// Only other units can shoot
	if(LinkedUnit.ObjectID == LinkedSourceUnit.ObjectID) {
		return ELR_NoInterrupt; 
	}
	// make sure we're on the same team 
	if(LinkedSourceUnit.IsEnemyUnit(LinkedUnit)) {
		return ELR_NoInterrupt;
	}
	// meld check
	if(!LinkedUnit.IsUnitAffectedByEffectName('RTEffect_Meld')|| !LinkedSourceUnit.IsUnitAffectedByEffectName('RTEffect_Meld')) {
		return ELR_NoInterrupt;
	}
	// Don't reveal ourselves
	if(LinkedUnit.IsConcealed()) {
		return ELR_NoInterrupt;
	}
	// The TargetUnit is the unit targeted by the source unit
	TargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));

	// The parent template of this RTGameState_LinkedEffect
	LinkedEffect = RTEffect_LinkedIntelligence(GetX2Effect()); 

	// We only shoot Linked shots to not make infinite overwatch chains
	AbilityRef = LinkedUnit.FindAbility(LinkedEffect.AbilityToActivate);
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));

	if(AbilityState == none) {
		`RedScreenOnce("Couldn't find an ability to shoot!");
		`LOG("Rising Tides: AbilityContext.InputContext.AbilityTemplateName = " @ AbilityContext.InputContext.AbilityTemplateName);
	}

	//  for non-pre emptive fire, don't process during the interrupt step
	if (AbilityContext.InterruptionStatus == eInterruptionStatus_Interrupt)	{
		return ELR_NoInterrupt;
	}

    // only shoot enemy units
	if (TargetUnit != none && TargetUnit.IsEnemyUnit(LinkedUnit)) {
		// for some reason, standard target visibility conditions weren't preventing units from shooting
		// leading to annoying siuations involving shooting through walls
		`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(LinkedUnit.ObjectID, TargetUnit.ObjectID, VisInfo);
		if(!VisInfo.bClearLOS && !LinkedUnit.HasSoldierAbility('DaybreakFlame')) {
			// only whisper can shoot through walls...
			return ELR_NoInterrupt;
		}

		// break out if we can't shoot
		if (AbilityState != none) {
				// break out if we can't grant an action point to shoot with
				// this is to tell the difference between stuff like normal Covering Fire, which uses ReserveActionPoints that have already been allocated,
				// and stuff like Return Fire, which are free and should be allocated a point to shoot with.
				// Linked Fire is free; this should always be valid
				if (LinkedEffect.GrantActionPoint != '') {
					// create an new gamestate and increment the number of grants
					NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
					NewLinkedEffectState = RTGameState_LinkedEffect(NewGameState.CreateStateObject(Class, ObjectID));
					//NewLinkedEffectState.GrantsThisTurn++;
					NewGameState.AddStateObject(NewLinkedEffectState);
					
					// add a action point to shoot with
					LinkedUnit = XComGameState_Unit(NewGameState.CreateStateObject(LinkedUnit.Class, LinkedUnit.ObjectID));
					if(LinkedUnit.ReserveActionPoints.Length < 1) {
						LinkedUnit.ReserveActionPoints.AddItem(class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint);
					}
					NewGameState.AddStateObject(LinkedUnit);
					// check if we can shoot. if we can't, clean up the gamestate from history
					if (AbilityState.CanActivateAbilityForObserverEvent(TargetUnit, LinkedUnit) != 'AA_Success')
					{
						History.CleanupPendingGameState(NewGameState);
					}
					else
					{
						bCanTrigger = false;

						AbilityState = XComGameState_Ability(NewGameState.CreateStateObject(AbilityState.Class, AbilityState.ObjectID));
						NewGameState.AddStateObject(AbilityState);
						XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = TriggerLinkedEffectFlyoverVisualizationFn;
						`TACTICALRULES.SubmitGameState(NewGameState);

						if (LinkedEffect.bUseMultiTargets)
						{
							AbilityState.AbilityTriggerAgainstSingleTarget(LinkedUnit.GetReference(), true);
						}
						else
						{
							AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(AbilityState, TargetUnit.ObjectID);
							if( AbilityContext.Validate() )
							{
								`TACTICALRULES.SubmitGameStateContext(AbilityContext);
							}
						}

						
					}
				}
				else if (AbilityState.CanActivateAbilityForObserverEvent(TargetUnit) == 'AA_Success')
				{
					if (LinkedEffect.bUseMultiTargets)
					{
						AbilityState.AbilityTriggerAgainstSingleTarget(LinkedUnit.GetReference(), true);
					}
					else
					{
						AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(AbilityState, TargetUnit.ObjectID);
						if( AbilityContext.Validate() )
						{
							`TACTICALRULES.SubmitGameStateContext(AbilityContext);
						}
					}
				}
		}
	}
	bCanTrigger = true;
	return ELR_NoInterrupt;



}

function TriggerLinkedEffectFlyoverVisualizationFn(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
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
			return;
		}

		History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, BuildTrack.StateObject_OldState, BuildTrack.StateObject_NewState, , VisualizeGameState.HistoryIndex);
		BuildTrack.StateObject_NewState = UnitState;
		BuildTrack.TrackActor = UnitState.GetVisualizer();

		AbilityTemplate = AbilityState.GetMyTemplate();
		if (AbilityTemplate != none)
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "Networked OI", '', eColor_Good, "img:///UILibrary_PerkIcons.UIPerk_insanity");

			OutVisualizationTracks.AddItem(BuildTrack);
		}
		break;
	}
}


defaultproperties
{
bCanTrigger=true
}
