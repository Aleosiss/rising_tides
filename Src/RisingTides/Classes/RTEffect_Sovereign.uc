//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_Sovereign.uc
//  AUTHOR:  Aleosiss
//  DATE:    11 March 2016
//  PURPOSE: Tick panic on crit kills      
//---------------------------------------------------------------------------------------
//	Tick Panic
//---------------------------------------------------------------------------------------
class RTEffect_Sovereign extends X2Effect_Persistent config(RTMarksman);

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit Attacker, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Unit				EffectTargetUnit, PanicTargetUnit;
	local X2EventManager					EventMgr;
	local XComGameState_Ability				AbilityState;
	local GameRulesCache_VisibilityInfo		VisInfo;
	local UnitValue							NumTimes;
	local array<StateObjectReference>		VisibleUnits;
	local int								Index;


	//  match the weapon associated with ability to the attacking weapon
	//if (kAbility.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef)
	//{
		`log("USING THE RIGHT FUCKING GUN");
		// if the target is dead 
		EffectTargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
		if (EffectTargetUnit != none && EffectTargetUnit.IsDead())
		{
			`log("ITS DEAD, LOOKING FOR UNITS TO FUCK UP");
			class'RTTacticalVisibilityHelpers'.static.GetAllVisibleAlliesForPlayer(EffectTargetUnit.ControllingPlayer.ObjectID, VisibleUnits, -1, false);
			for(Index = 0; Index < VisibleUnits.Length; Index++)
			{
				
				// Units within 5 tiles of the source that aren't psionic or robotic
				PanicTargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(VisibleUnits[Index].ObjectID));
				if(!PanicTargetUnit.IsRobotic() && !PanicTargetUnit.IsPsionic() && EffectTargetUnit.TileDistanceBetween(PanicTargetUnit) < 5)
				{
					`log("T-T-TRIGGERED");
					`log(PanicTargetUnit.ToString());
					`XEVENTMGR.TriggerEvent('SovereignTrigger', Attacker, PanicTargetUnit, NewGameState);
				}
			}
			return true;
		}
	//}																						
	return false;
}

DefaultProperties
{
	WatchRule = eGameRule_PlayerTurnEnd
}