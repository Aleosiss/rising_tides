class RTGameState_TwitchEffect extends XComGameState_Effect;

var bool bCanTrigger;

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
	local StateObjectReference	EmptyRef;

	if(!bCanTrigger) {
		`LOG("Rising Tides: TwitchEffect is probably being called before it finishes resolving!");
		return ELR_NoInterrupt;
	}
	
	EmptyRef.ObjectID = 0;

	`LOG("Rising Tides: Twitch Fire Check startup.");
	History = `XCOMHISTORY;
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext == none) {
		return ELR_NoInterrupt;	
	}
	`LOG("Rising Tides: Twitch Fire Check Stage 1");
	// The AttackingUnit should be the unit that is currently attacking
	AttackingUnit = class'X2TacticalGameRulesetDataStructures'.static.GetAttackingUnitState(GameState);

	// The TwitchAttackingUnit is the one responding to the call to arms
	TwitchAttackingUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	// The TwitchLinkedUnit is the unit targeted by the source unit
	TwitchLinkedUnit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	if(TwitchLinkedUnit == none) {
		return ELR_NoInterrupt;
	}
	
	// meld check
	if(!TwitchLinkedUnit.IsUnitAffectedByEffectName('RTEffect_Meld')|| !TwitchAttackingUnit.IsUnitAffectedByEffectName('RTEffect_Meld')) {
		return ELR_NoInterrupt;
	}
	`LOG("Rising Tides: Twitch Fire Check Stage 2");
	// Don't reveal ourselves
	if(TwitchAttackingUnit.IsConcealed()) {
		return ELR_NoInterrupt;
	}
	`LOG("Rising Tides: Twitch Fire Check Stage 3");


	// The parent template of this RTGameState_TwitchEffect
	TwitchEffect = RTEffect_TwitchReaction(GetX2Effect()); 
	
	// do standard checks here
	//STUFF
	//STUFF
	//STUFF

	// Get the AbilityToActivate (TwitchReactionShot)
	AbilityRef = TwitchAttackingUnit.FindAbility(TwitchEffect.AbilityToActivate, EmptyRef);
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));

	if(AbilityState == none) {
		`RedScreenOnce("Couldn't find an ability to shoot!");
		`LOG("Rising Tides: TwitchEffect.AbilityToActivate = " @ TwitchEffect.AbilityToActivate);
	}

	`LOG("Rising Tides: Twitch Fire Check Stage 4");
    // only shoot enemy units
	if (AttackingUnit != none && AttackingUnit.IsEnemyUnit(TwitchAttackingUnit)) {
		`LOG("Rising Tides: Twitch Fire Check Stage 5");
		// break out if we can't shoot
		if (AbilityState != none) {
				`LOG("Rising Tides: Twitch Fire Check Stage 6");
				// break out if we can't grant an action point to shoot with
				if (TwitchEffect.GrantActionPoint != '') {
					`LOG("Rising Tides: Twitch Fire Check Stage 7");
					// create an new gamestate and increment the number of grants
					NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
					NewTwitchEffectState = RTGameState_TwitchEffect(NewGameState.CreateStateObject(Class, ObjectID));
					//NewTwitchEffectState.GrantsThisTurn++;
					NewGameState.AddStateObject(NewTwitchEffectState);
					
					// add a action point to shoot with
					TwitchAttackingUnit = XComGameState_Unit(NewGameState.CreateStateObject(TwitchAttackingUnit.Class, TwitchAttackingUnit.ObjectID));
					TwitchAttackingUnit.ReserveActionPoints.AddItem(TwitchEffect.GrantActionPoint);
					NewGameState.AddStateObject(TwitchAttackingUnit);
					`LOG("Rising Tides: Twitch Fire Check Stage 8");
					// check if we can shoot. if we can't, clean up the gamestate from history
					if (AbilityState.CanActivateAbilityForObserverEvent(AttackingUnit, TwitchAttackingUnit) != 'AA_Success')
					{
						`LOG(AbilityState.CanActivateAbilityForObserverEvent(AttackingUnit, TwitchAttackingUnit));
						History.CleanupPendingGameState(NewGameState);
					}
					else
					{
						`LOG("Rising Tides: Twitch Fire Check Stage 9");
						bCanTrigger = false;
						AbilityState = XComGameState_Ability(NewGameState.CreateStateObject(AbilityState.Class, AbilityState.ObjectID));
						NewGameState.AddStateObject(AbilityState);
						XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = TriggerAbilityFlyoverVisualizationFn;
						`TACTICALRULES.SubmitGameState(NewGameState);

						if (TwitchEffect.bUseMultiTargets)
						{
							AbilityState.AbilityTriggerAgainstSingleTarget(TwitchAttackingUnit.GetReference(), true);
						}
						else
						{
							AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(AbilityState, AttackingUnit.ObjectID);
							if( AbilityContext.Validate() )
							{
								`LOG("Rising Tides: Twitch Fire Check Stage 11");
								`TACTICALRULES.SubmitGameStateContext(AbilityContext);
								`LOG("Rising Tides: Twitch Fire Check Stage 12");
							}
						}
						bCanTrigger = true;
					}
				}
				else if (AbilityState.CanActivateAbilityForObserverEvent(AttackingUnit) == 'AA_Success')
				{
					if (TwitchEffect.bUseMultiTargets)
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

defaultproperties
{
bCanTrigger=true
}