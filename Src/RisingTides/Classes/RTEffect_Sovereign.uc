//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_Sovereign.uc
//  AUTHOR:  Aleosiss
//  DATE:    11 March 2016
//  PURPOSE: Tick panic on crit kills      
//---------------------------------------------------------------------------------------
//	Tick Panic
//---------------------------------------------------------------------------------------
class RTEffect_Sovereign extends X2Effect_Persistent;

//function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit Attacker, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
//{
	//local XComGameState_Unit				EffectTargetUnit, PanicTargetUnit;
	//local X2EventManager					EventMgr;
	//local XComGameState_Ability				AbilityState;
	//local GameRulesCache_VisibilityInfo		VisInfo;
	//local UnitValue							NumTimes;
	//local array<StateObjectReference>		VisibleUnits;
	//local int								Index;
//
//
	////  match the weapon associated with ability to the attacking weapon
	////if (kAbility.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef)
	////{
		//`log("USING THE RIGHT FUCKING GUN");
		//// if the target is dead 
		//EffectTargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
		//if (EffectTargetUnit != none && EffectTargetUnit.IsDead())
		//{
			//
			//return true;
		//}
	////}																						
	//return false;
//}

DefaultProperties
{
	EffectName='RTEffect_Sovereign'
}
