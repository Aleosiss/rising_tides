class RTEffect_BumpInTheNight extends X2Effect_Persistent config(RisingTides);

var int iTileDistanceToActivate;
// Register for events
function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj, FilterObj;
	local RTGameState_BumpInTheNightEffect BITNEffectState;

	EventMgr = `XEVENTMGR;
	BITNEffectState = RTGameState_BumpInTheNightEffect(EffectGameState);


	EffectObj = BITNEffectState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	FilterObj = UnitState;
	
	EventMgr.RegisterForEvent(EffectObj, 'AbilityActivated', BITNEffectState.RTBumpInTheNight, ELD_OnStateSubmitted, 1, FilterObj);


}

// Killing target triggers stealth and potentially adds a bloodlust stack
function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit Attacker, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	return super.PostAbilityCostPaid(EffectState, AbilityContext, kAbility, Attacker, AffectWeapon, NewGameState, PreCostActionPoints, PreCostReservePoints);
	/*local XComGameState_Unit				TargetUnit, PanicTargetUnit;
	local X2EventManager					EventMgr;
	local XComGameState_Ability				AbilityState;
	local GameRulesCache_VisibilityInfo		VisInfo;
	local XComGameStateHistory				History;
	local array<StateObjectReference>		VisibleUnits;
	local int								Index, RandRoll;
	local bool								bShouldTriggerMelee, bShouldTriggerStandard;
        
	bShouldTriggerStandard = false;
	bShouldTriggerMelee = false;

	// melee kills give bloodlust and extra AP w/ QoB, but standard kills still give stealth
	if(kAbility.GetMyTemplateName() == 'OverwatchShot' ||  kAbility.GetMyTemplateName() == 'StandardShot' || kAbility.GetMyTemplateName() == 'StandardGhostShot')
            bShouldTriggerStandard = true;
	if(kAbility.GetMyTemplateName() == 'RTBerserkerKnifeAttack' || kAbility.GetMyTemplateName() == 'RTPyroclasticSlash' || kAbility.GetMyTemplateName() == 'RTReprobateWaltz')
			bShouldTriggerMelee = true;

	if(bShouldTriggerMelee || bShouldTriggerStandard) {
		History = `XCOMHISTORY;
		TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID)); 
		if(TargetUnit != none && TargetUnit.IsDead()) {
			if(Attacker.TileDistanceBetween(TargetUnit) < iTileDistanceToActivate) {
						// melee kills additionally give bloodlust stacks and proc queen of blades
						if(bShouldTriggerMelee) {
							// t-t-t-t-triggered
							`XEVENTMGR.TriggerEvent('RTBumpInTheNight_BloodlustProc', kAbility, Attacker, NewGameState);

							// since we've added a bloodlust stack, we need to check if we should leave the meld
							if(!Attacker.HasSoldierAbility('RTContainedFury', false) && Attacker.IsUnitAffectedByEffectName('RTEffect_Meld')) {
								if(class'RTGameState_Ability'.static.getBloodlustStackCount(Attacker) > class'RTAbility_BerserkerAbilitySet'.default.MAX_BLOODLUST_MELDJOIN) {
									`XEVENTMGR.TriggerEvent('RTRemoveFromMeld', Attacker, Attacker, NewGameState);	
								}
							}
					
							if(Attacker.HasSoldierAbility('RTQueenOfBlades', true) && Attacker.ActionPoints.Length != PreCostActionPoints.Length) {
								Attacker.ActionPoints = PreCostActionPoints;
							}
						} else {
							// all of the kills give stealth...
							`XEVENTMGR.TriggerEvent('RTBumpInTheNight_StealthProc', kAbility, Attacker, NewGameState);
						}
					}
				}
        
		// trigger psionic activation for unstable conduit if psionic blades were present and used
		if(Attacker.HasSoldierAbility('RTPsionicBlades') && bShouldTriggerMelee) {
			`XEVENTMGR.TriggerEvent('UnitActivatedPsionicAbility', kAbility, Attacker, NewGameState);
		}
	}
    
	return false;
	*/
}

defaultproperties
{
	GameStateEffectClass = class'RTGameState_BumpInTheNightEffect'
}
