class RTGameState_ReprobateWaltz extends RTGameState_Effect;

function EventListenerReturn ReprobateWaltzCheck( Object EventData, Object EventSource, XComGameState GameState, Name EventID) {
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit WaltzUnit, TargetUnit;
	local XComGameState_Ability	AbilityState;
	local int iStackCount, iRandom;
	local float fStackModifier, fFinalPercentChance;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	WaltzUnit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
	TargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));

	if(AbilityContext != none) {
		fFinalPercentChance = ( class'RTAbility_BerserkerAbilitySet'.default.REPROBATE_WALTZ_BASE_CHANCE + ( class'RTAbility_BerserkerAbilitySet'.default.REPROBATE_WALTZ_BLOODLUST_STACK_CHANCE * iStacks ));
		iRandom = `SYNC_RAND(100);
		if(iRandom <= int(fFinalPercentChance)) {
			InitializeAbilityForActivation(AbilityState, WaltzUnit, 'RTReprobateWaltz', History);
			ActivateAbility(AbilityState, TargetUnit.GetReference());
		}	
	}	
	return ELR_NoInterrupt;
}
