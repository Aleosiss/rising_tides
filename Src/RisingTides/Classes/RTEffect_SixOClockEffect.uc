///---------------------------------------------------------------------------------------
//  FILE:    RTEffect_SixOClockEffect.uc
//  AUTHOR:  Aleosiss
//  DATE:    5 March 2016
//  PURPOSE: Six O'Clock will calculation, 
//           also has GetAllVisibleAllies functions (player, unit, squadsight)
//---------------------------------------------------------------------------------------
//	Six O'Clock effect
//---------------------------------------------------------------------------------------
class RTEffect_SixOClockEffect extends X2Effect_PersistentStatChange config(RTMarksman);

var config int DEFENSE_BONUS, PSI_BONUS, WILL_BONUS;
var localized string RTFriendlyName;
//var array<StatChange> m_aStatChanges;
	

//function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
//{
	//
	//local ShotModifierInfo ModInfo;
//
	//`RedScreenOnce("Sweet Jesus!");
	//ModInfo.ModType = eHit_Success;
	//ModInfo.Reason = FriendlyName;
	//ModInfo.Value = -(DEFENSE_BONUS);
//
	//ShotModifiers.AddItem(ModInfo);
//}
//
//simulated function AddPersistentStatChange(ECharStatType StatType, float StatAmount, optional EStatModOp InModOp=MODOP_Addition )
//{
	/*
	local StatChange NewChange;

	`log("------------------------------------------------------------------------------------------------------------------------------------------------");
	`log("ADDING THE STATS!");
	`log("------------------------------------------------------------------------------------------------------------------------------------------------");
	
	
	NewChange.StatType = StatType;
	NewChange.StatAmount = StatAmount;
	NewChange.ModOp = InModOp;

	m_aStatChanges.AddItem(NewChange);
	*/

	//super.AddPersistentStatChange(StatType, StatAmount, InModOp);
//}


//simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
//{
//
	//`log("------------------------------------------------------------------------------------------------------------------------------------------------");
	//`log("EFFECT ADDED!");
	//`log("------------------------------------------------------------------------------------------------------------------------------------------------");
//
	//NewEffectState.StatChanges = m_aStatChanges;
	//super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
//
//}

//simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
//{
	//`log("------------------------------------------------------------------------------------------------------------------------------------------------");
	//`log("EFFECT REMOVED!");
	//`log("------------------------------------------------------------------------------------------------------------------------------------------------");
//
	//RemovedEffectState.StatChanges = m_aStatChanges;
	//super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);
//}


DefaultProperties
{
	EffectName="SixOClock"
	DuplicateResponse = eDupe_Refresh
}


/*
function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
																			   
	EventMgr.RegisterForEvent(EffectObj, 'SixOClock', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit Attacker, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Unit				TargetUnit;
	local X2EventManager					EventMgr;
	local XComGameState_Ability				AbilityState;
	local GameRulesCache_VisibilityInfo		VisInfo;
	local array<StateObjectReference>		VisibleUnits, SSVisibleUnits;
	local RTEffect_SixOClockP2				P2Effect; 

	local XComGameStateHistory				History;
	local int								Index, HistoryIndex;

	History = `XCOMHISTORY;
	HistoryIndex = -1;



	
	if(kAbility.m_TemplateName == 'RTOverwatch')
	{
		class'RTTacticalVisibilityHelpers'.static.GetAllVisibleAlliesForUnit(Attacker.ObjectID, VisibleUnits);
		class'RTTacticalVisibilityHelpers'.static.GetAllSquadsightAlliesForUnit(Attacker.ObjectID, SSVisibleUnits);
		for( Index = VisibleUnits.Length - 1; Index > -1; --Index )
		{
			//if(Attacker.TargetIsAlly(VisibleUnits[Index].ObjectID, HistoryIndex))
			//{
				//Add P2Effect to TargetUnit here
				
			//}
		}
		for( Index = SSVisibleUnits.Length - 1; Index > -1; --Index )
		{
			//if(Attacker.TargetIsAlly(SSVisibleUnits[Index].ObjectID, HistoryIndex))
			//{
				//Add P2Effect to TargetUnit here
			//}
		}
		return true;	
	}	
		
		
											  
	return false;
}
*/
