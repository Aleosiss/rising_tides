class RTGameState_TwitchEffect extends XComGameState_Effect;

function EventListenerReturn TwitchFireCheck (Object EventData, Object EventSource, XComGameState GameState, Name EventID) {
    local XComGameState_Unit AttackingUnit, TwitchAttackingUnit, TwitchLinkedUnit;
	local XComGameStateHistory History;
	local RTEffect_TwitchReaction TwitchEffect;
    local RTGameState_MeldEffect  MeldEffectState;
	local StateObjectReference AbilityRef;
	local XComGameState_Ability AbilityState, OriginalShot;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState NewGameState;
	local RTGameState_TwitchEffect NewTwitchEffectState;

	History = `XCOMHISTORY;
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext == none) {
		return ELR_NoInterrupt;	
	}

	// The AttackingUnit should be the unit that is currently attacking
	AttackingUnit = class'X2TacticalGameRulesetDataStructures'.static.GetAttackingUnitState(GameState);

	// The TwitchAttackingUnit is the one responding to the call to arms
	TwitchAttackingUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	// The TwitchLinkedUnit is the unit targeted by the source unit
	TwitchLinkedUnit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	
	// meld check
	if(!TwitchLinkedUnit.IsUnitAffectedByEffectName('RTEffect_Meld')|| !TwitchAttackingUnit.IsUnitAffectedByEffectName('RTEffect_Meld')) {
		return ELR_NoInterrupt;
	}

	// Don't reveal ourselves
	if(TwitchAttackingUnit.IsConcealed()) {
		return ELR_NoInterrupt;
	}



	// The parent template of this RTGameState_TwitchEffect
	TwitchEffect = RTEffect_TwitchReaction(GetX2Effect()); 
	
	// do standard checks here
	//STUFF
	//STUFF
	//STUFF

	// Get the AbilityToActivate (TwitchReactionShot)
	AbilityRef = TwitchAttackingUnit.FindAbility(TwitchEffect.AbilityToActivate);
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));



    // only shoot enemy units
	if (AttackingUnit != none && AttackingUnit.IsEnemyUnit(TwitchAttackingUnit)) {
		// break out if we can't shoot
		if (AbilityState != none) {
				// break out if we can't grant an action point to shoot with
				if (TwitchEffect.GrantActionPoint != '') {
					
					// create an new gamestate and increment the number of grants
					NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
					NewTwitchEffectState = RTGameState_LinkedEffect(NewGameState.CreateStateObject(Class, ObjectID));
					NewTwitchEffectState.GrantsThisTurn++;
					NewGameState.AddStateObject(NewTwitchEffectState);
					
					// add a action point to shoot with
					TwitchAttackingUnit = XComGameState_Unit(NewGameState.CreateStateObject(TwitchAttackingUnit.Class, TwitchAttackingUnit.ObjectID));
					TwitchAttackingUnit.ReserveActionPoints.AddItem(TwitchEffect.GrantActionPoint);
					NewGameState.AddStateObject(TwitchAttackingUnit);

					// check if we can shoot. if we can't, clean up the gamestate from history
					if (AbilityState.CanActivateAbilityForObserverEvent(AttackingUnit, TwitchAttackingUnit) != 'AA_Success')
					{
						History.CleanupPendingGameState(NewGameState);
					}
					else
					{
						`TACTICALRULES.SubmitGameState(NewGameState);

						if (LinkedEffect.bUseMultiTargets)
						{
							AbilityState.AbilityTriggerAgainstSingleTarget(TwitchAttackingUnit.GetReference(), true);
						}
						else
						{
							AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(AbilityState, AttackingUnit.ObjectID);
							if( AbilityContext.Validate() )
							{
								`TACTICALRULES.SubmitGameStateContext(AbilityContext);
							}
						}
					}
				}
				else if (AbilityState.CanActivateAbilityForObserverEvent(AttackingUnit) == 'AA_Success')
				{
					if (LinkedEffect.bUseMultiTargets)
					{
						AbilityState.AbilityTriggerAgainstSingleTarget(TwitchAttackingUnit.GetReference(), true);
					}
					else
					{
						AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(AbilityState, AttackingUnit.ObjectID);
						if( AbilityContext.Validate() )
						{
							`TACTICALRULES.SubmitGameStateContext(AbilityContext);
						}
					}
				}
		}
	}

	return ELR_NoInterrupt;



}
