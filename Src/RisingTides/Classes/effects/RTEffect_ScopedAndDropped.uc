//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_ScopedAndDropped.uc
//  AUTHOR:  Aleosiss
//  DATE:    29 February 2016
//  PURPOSE: Defines the effect of Scoped And Dropped: Restore Action Points on
//           exposed kills, negate squadsight aim penalties, and count number of
//           kills per turn.
//---------------------------------------------------------------------------------------
//	Scoped And Dropped effect
//---------------------------------------------------------------------------------------
class RTEffect_ScopedAndDropped extends RTEffect_GhostPerkBase;

var localized string RTFriendlyName;
var localized string RTNotFriendlyName;
var int iPanicChance;
var int iDamageRequiredToActivate;


// Negate Squadsight distance penalty
function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfoAim, ModInfoCrit;
	local int Tiles, AimMod, CritMod;
	local UnitValue NumTimesScopedAndDropped;

	Tiles = Attacker.TileDistanceBetween(Target);
	//  remove number of tiles within visible range (which is in meters, so convert to units, and divide that by tile size)
	Tiles -= Attacker.GetVisibilityRadius() * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	if (Tiles > 0) {     //  pretty much should be since a squadsight target is by definition beyond sight range. but...
		// AimMod = ((class'X2AbilityToHitCalc_StandardAim'.default.SQUADSIGHT_DISTANCE_MOD * Tiles) * -1);	// this wasn't working? I must have botched a config file or something
		AimMod = ((-2 * Tiles) * -1);
	}

	ModInfoAim.ModType = eHit_Success;
	ModInfoAim.Reason = RTFriendlyName;
	ModInfoAim.Value = AimMod;
	ShotModifiers.AddItem(ModInfoAim);

	Attacker.GetUnitValue('NumTimesScopedAndDropped', NumTimesScopedAndDropped);
	CritMod = int(NumTimesScopedAndDropped.fValue) * 10;

	ModInfoCrit.ModType = eHit_Crit;
	ModInfoCrit.Reason = RTNotFriendlyName;
	ModInfoCrit.Value = -(CritMod);
	ShotModifiers.AddItem(ModInfoCrit);
}

// Shots cannot graze
function bool ShotsCannotGraze()
{
	return true;
}

// Register for events
function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'ScopedAndDropped', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

// PostAbilityCostPaid handles SND, Sovereign, and SNA
function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit Attacker, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Unit				TargetUnit;
	local X2EventManager					EventMgr;
	local XComGameStateHistory				History;
	local bool								bIsStandardFire, bHitTarget;

	if(kAbility.GetMyTemplateName() == 'RTStandardSniperShot' 
		|| kAbility.GetMyTemplateName() == 'DaybreakFlame' 
		|| kAbility.GetMyTemplateName() == 'RTPrecisionShot' 
		|| kAbility.GetMyTemplateName() == 'RTDisablingShot' 
		|| kAbility.GetMyTemplateName() == 'RTKubikuri' 
		|| kAbility.GetMyTemplateName() == 'PistolStandardShot'
	) {
		bIsStandardFire = true;
	}

	if(AbilityContext.ResultContext.HitResult == eHit_Crit
		|| AbilityContext.ResultContext.HitResult == eHit_Graze 
		|| AbilityContext.ResultContext.HitResult == eHit_Success
	) {
		bHitTarget = true;
	}
	
	//  make sure it's a standard shot
	if (bIsStandardFire) {
		History = `XCOMHISTORY;
		EventMgr = `XEVENTMGR;
		//  check for a direct flanking kill shot
		TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
		if (TargetUnit != none) {
			// Check for Shock 'n Awe ability
			if(bHitTarget) {
				CheckShockAndAwe(TargetUnit, Attacker, EventMgr, NewGameState);
			}
			
			// Here. We. Go.
			if(TargetUnit.IsDead() || TargetUnit.IsBleedingOut()) {
				// Check for Sovereign ability
				CheckSovereignAbility(TargetUnit, Attacker, EventMgr, NewGameState);
				// Check for Scoped and Dropped ability
				CheckScopedAndDropped(TargetUnit, kAbility, Attacker, EffectState, PreCostActionPoints, History, EventMgr, NewGameState);
			}
		}
	}
	return false;
}

// Check if the Shock 'n Awe ability should trigger
private function CheckShockAndAwe(XComGameState_Unit TargetUnit, XComGameState_Unit Attacker, X2EventManager EventMgr, XComGameState NewGameState)
{
	local UnitValue DamageDealt, ShockCounter;
	local int iTotalDamageDealt;
	
	// this should be the attack that proced this PostAbilityCostPaid
	TargetUnit.GetUnitValue('LastEffectDamage', DamageDealt);
	// Running total of damage dealt this turn
	Attacker.GetUnitValue('RTShockAndAweCounter', ShockCounter);

	iTotalDamageDealt = int(DamageDealt.fValue) + int(ShockCounter.fValue);

	if(iTotalDamageDealt < iDamageRequiredToActivate) {
		Attacker.SetUnitFloatValue('RTShockAndAweCounter', iTotalDamageDealt, eCleanup_BeginTurn);
	} else {
		EventMgr.TriggerEvent('RTShockAndAweTrigger', TargetUnit, Attacker, NewGameState);
		while(iTotalDamageDealt > iDamageRequiredToActivate) {
			iTotalDamageDealt -= iDamageRequiredToActivate;
		}
		Attacker.SetUnitFloatValue('RTShockAndAweCounter', iTotalDamageDealt, eCleanup_BeginTurn);
	}
}

// Check if the Sovereign ability should trigger
private function CheckSovereignAbility(XComGameState_Unit TargetUnit, XComGameState_Unit Attacker, X2EventManager EventMgr, XComGameState NewGameState)
{
	local UnitValue DamageDealt;
	local int RandRoll;
	
	if(Attacker.HasSoldierAbility('Sovereign')) {
		TargetUnit.GetUnitValue('LastEffectDamage', DamageDealt);
		if((int(DamageDealt.fValue) + 1) >= TargetUnit.GetMaxStat(eStat_HP)) {
			// Panic
			RandRoll = `SYNC_RAND(100);
			if(RandRoll < iPanicChance) {
				EventMgr.TriggerEvent('SovereignTrigger', TargetUnit, Attacker, NewGameState);
			}
		}
	}
}

// Check if the Scoped and Dropped ability should trigger
private function CheckScopedAndDropped(XComGameState_Unit TargetUnit, XComGameState_Ability Ability, XComGameState_Unit Attacker, XComGameState_Effect EffectState, const array<name> PreCostActionPoints, XComGameStateHistory History, X2EventManager EventMgr, XComGameState NewGameState)
{
	local GameRulesCache_VisibilityInfo VisInfo;
	local XComGameState_Ability AbilityState;
	local UnitValue NumTimes;
	local X2TacticalGameRuleset TacRules;
	local bool ShouldTrigger;

	TacRules = `TACTICALRULES;
	//CheckAndLogAlertLevel(TargetUnit);

	if (TacRules.VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, TargetUnit.ObjectID, VisInfo)) {
		// Only care if there is no cover between this unit and the target unless they were concealed/aware or have Daybreak Flame
		ShouldTrigger = VisInfo.TargetCover == CT_None
		|| Ability.GetMyTemplateName() == 'DaybreakFlame'
		|| TargetUnit.GetCurrentStat(eStat_AlertLevel) != `ALERT_LEVEL_RED;
		if (ShouldTrigger) {
			// Negate changes to the number of action points
			if (Attacker.ActionPoints.Length != PreCostActionPoints.Length) {
				// this is old and probably redundant
				AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
				if (AbilityState != none && AbilityState.GetMyTemplateName() != 'RTOverwatchShot') {
					Attacker.ActionPoints = PreCostActionPoints;
					
					// If the UnitValue doesn't exist, make it, and start it at one since we just shot something
					if(!Attacker.GetUnitValue('NumTimesScopedAndDropped', NumTimes)) {
						Attacker.SetUnitFloatValue('NumTimesScopedAndDropped', 1, eCleanup_BeginTurn);
					}
					// Else, get the value and increment it by one
					else {
						Attacker.GetUnitValue('NumTimesScopedAndDropped', NumTimes);
						NumTimes.fValue = NumTimes.fValue + 1;
						Attacker.SetUnitFloatValue('NumTimesScopedAndDropped', NumTimes.fValue, eCleanup_BeginTurn);
					}

					EventMgr.TriggerEvent('ScopedAndDropped', AbilityState, Attacker, NewGameState);
				}
			}
		}
	}
} 

function CheckAndLogAlertLevel(XComGameState_Unit UnitState)
{
    local int AlertLevel;
    local string UnitName;
    local string AlertString;
    
    AlertLevel = UnitState.GetCurrentStat(eStat_AlertLevel);
    
    UnitName = UnitState.GetFullName();
    if (UnitName == "")
    {
        UnitName = string(UnitState.ObjectID);
    }
    
    switch (AlertLevel)
    {
        case `ALERT_LEVEL_GREEN:
            AlertString = "Green (Unaware)";
            break;
        case `ALERT_LEVEL_YELLOW:
            AlertString = "Yellow (Suspicious)";
            break;
        case `ALERT_LEVEL_RED:
            AlertString = "Red (Combat)";
            break;
        default:
            AlertString = "Unknown (" $ AlertLevel $ ")";
            break;
    }
    
    // Log the alert level
    `RTLOG("Unit [" $ UnitName $ "] Alert Level: " $ AlertString);
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "RTEffect_ScopedAndDropped"
	iPanicChance=20
	iDamageRequiredToActivate=25
}
