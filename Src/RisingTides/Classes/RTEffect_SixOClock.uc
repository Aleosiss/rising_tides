///---------------------------------------------------------------------------------------
//  FILE:    RTEffect_SixOClock.uc
//  AUTHOR:  Aleosiss
//  DATE:    5 March 2016
//  PURPOSE: Six O'Clock overwatch counter
//---------------------------------------------------------------------------------------
//	Six O'Clock effect
//---------------------------------------------------------------------------------------


class RTEffect_SixOClock extends X2Effect_Persistent;

var array<name> AllowedAbilities;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'SixOClockTriggered', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local X2EventManager EventMgr;
	local XComGameState_Ability AbilityState;       //  used for looking up our source ability (Guardian), not the incoming one that was activated
	local UnitValue Count;

	if (SourceUnit.ReserveActionPoints.Length != PreCostReservePoints.Length && AbilityContext.IsResultContextHit() && AllowedAbilities.Find(kAbility.GetMyTemplate().DataName) != INDEX_NONE)
	{
		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
		if (AbilityState != none)
		{
			if(!SourceUnit.GetUnitValue('SOCCounter', Count))
			{
				SourceUnit.SetUnitFloatValue('SOCCounter', 0, eCleanup_BeginTurn);
			}
			SourceUnit.GetUnitValue('SOCCounter', Count);
			if (int(Count.fValue) < 1)
			{
				SourceUnit.ReserveActionPoints = PreCostReservePoints;

				Count.fValue = Count.fValue + 1;
				SourceUnit.SetUnitFloatValue('SOCCounter', Count.fValue, eCleanup_BeginTurn);
				 
				EventMgr = `XEVENTMGR;
				EventMgr.TriggerEvent('SixOClockTriggered', AbilityState, SourceUnit, NewGameState);

				return false;
			}
		}
	}
	return false;
}

DefaultProperties
{
	AllowedAbilities(0) = "RTOverwatchShot"
	AllowedAbilities(1) = "PistolOverwatchShot"
}