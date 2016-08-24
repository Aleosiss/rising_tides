class RTEffect_BumpInTheNight extends X2Effect_Persistent config(RisingTides);

var int iTileDistanceToActivate;
// Register for events
function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
}

// Killing target triggers stealth
function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit Attacker, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Unit				TargetUnit, PanicTargetUnit;
	local X2EventManager					EventMgr;
	local XComGameState_Ability				AbilityState;
	local GameRulesCache_VisibilityInfo		VisInfo;
	local XComGameStateHistory				History;
	local UnitValue							NumTimes;
	local array<StateObjectReference>		VisibleUnits;
	local int								Index, RandRoll;
	local bool	bShouldTriggerMelee, bShouldTriggerStandard;
        
        bShouldTriggerStandard = false;
		bShouldTriggerMelee = false;

        if(kAbility.GetMyTemplateName() == 'OverwatchShot' ||  kAbility.GetMyTemplateName() == 'StandardShot')
            bShouldTriggerStandard = true;
		if(kAbility.GetMyTemplateName() == 'RTBerserkerKnifeAttack')
			bShouldTriggerMelee = true;
        if(bShouldTriggerStandard || bShouldTriggerMelee) {
            History = `XCOMHISTORY;
            TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
            if(TargetUnit != none && TargetUnit.IsDead()) {
                if(Attacker.TileDistanceBetween(TargetUnit) < iTileDistanceToActivate) {
                    `XEVENTMGR.TriggerEvent('RTBloodlust_Proc', kAbility, Attacker, NewGameState);
				}
            }
        }
		// trigger psionic activation for unstable conduit
		if(Attacker.HasSoldierAbility('RTPsionicBlades') && bShouldTriggerMelee) {
			`XEVENTMGR.TriggerEvent('UnitActivatedPsionicAbility', kAbility, Attacker, NewGameState);
		}




        return false;
}