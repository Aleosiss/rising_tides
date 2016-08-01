//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_Meld.uc
//  AUTHOR:  Aleosiss  
//  DATE:    18 March 2016
//  PURPOSE: Meld effect
//           
//---------------------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------------------

class RTEffect_Meld extends X2Effect_PersistentStatChange config(RTGhost);

var float MeldWill, MeldHacking;
var bool bIsUpdate;



function bool IsThisEffectBetterThanExistingEffect(const out XComGameState_Effect ExistingEffect)
{
	return true;
}

simulated function UnApplyEffectFromStats(RTGameState_MeldEffect MeldEffectState, XComGameState_Unit UnitState, XComGameState GameState)
{
	UnitState.UnApplyEffectFromStats(MeldEffectState, GameState);
}

simulated function ApplyEffectToStats(RTGameState_MeldEffect MeldEffectState, XComGameState_Unit UnitState, XComGameState GameState)
{
	UnitState.ApplyEffectToStats(MeldEffectState, GameState);
}

// Attempt to OnEffectAdded using extended GameState_Effect
simulated function ExtendedMeldAttempt(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local RTGameState_MeldEffect			MeldEffectState;
	local XComGameState_Unit				EffectTargetUnit;
	local X2EventManager					EventMgr;
	local XComGameStateHistory				History;
	local Object							ListenerObj;

	EventMgr = `XEVENTMGR;
	History = `XCOMHISTORY;
	EffectTargetUnit = XComGameState_Unit(kNewTargetState);
	MeldEffectState = RTGameState_MeldEffect(NewEffectState);

	
		
	EventMgr.TriggerEvent('RTAddToMeld', EffectTargetUnit, EffectTargetUnit, NewGameState); 

	ListenerObj = NewEffectState;
	if(ListenerObj == none)
	{
		`Redscreen("RTMeld: Failed to find Meld component when registering listener (WE DUN FUCKED)");
		return;
	}
	EventMgr.RegisterForEvent(ListenerObj, 'RTAddToMeld', MeldEffectState.AddUnitToMeld, ELD_OnStateSubmitted,,,true);
	EventMgr.RegisterForEvent(ListenerObj, 'RTRemoveFromMeld', MeldEffectState.RemoveUnitFromMeld, ELD_OnStateSubmitted,,,true);
	EventMgr.RegisterForEvent(ListenerObj, 'UnitPanicked', MeldEffectState.RemoveUnitFromMeld,ELD_OnStateSubmitted,,,true); 
	EventMgr.RegisterForEvent(ListenerObj, 'TacticalGameEnd', MeldEffectState.OnTacticalGameEnd, ELD_OnStateSubmitted);

	`LOG("Rising Tides: The Meld has finished registering for events.");

	MeldEffectState.Initialize(EffectTargetUnit);

	
	MeldWill = MeldEffectState.CombinedWill;
	MeldHacking = MeldEffectState.SharedHack;


	AddPersistentStatChange(eStat_Will, MeldWill);
	AddPersistentStatChange(eStat_Hacking, MeldHacking);
	AddPersistentStatChange(eStat_PsiOffense, MeldWill);
	
	MeldEffectState.StatChanges = m_aStatChanges;

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, MeldEffectState);
	

}


simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local RTGameState_MeldEffect			MeldEffectState;
	local XComGameState_Unit				EffectTargetUnit;
	local X2EventManager					EventMgr;
	local XComGameStateHistory				History;
	local Object							ListenerObj;
	local float								i;

	EventMgr = `XEVENTMGR;
	History = `XCOMHISTORY;
	EffectTargetUnit = XComGameState_Unit(kNewTargetState);
	MeldEffectState = RTGameState_MeldEffect(NewEffectState);

	
		
	EventMgr.TriggerEvent('RTAddToMeld', EffectTargetUnit, EffectTargetUnit, NewGameState); 

	ListenerObj = MeldEffectState;
	if(ListenerObj == none)
	{
		`Redscreen("RTMeld: Failed to find Meld component when registering listener (WE DUN FUCKED)");
		return;
	}
	EventMgr.RegisterForEvent(ListenerObj, 'RTAddToMeld', MeldEffectState.AddUnitToMeld, ELD_OnStateSubmitted,,,true);
	EventMgr.RegisterForEvent(ListenerObj, 'RTRemoveFromMeld', MeldEffectState.RemoveUnitFromMeld, ELD_OnStateSubmitted,,,true);
	EventMgr.RegisterForEvent(ListenerObj, 'UnitPanicked', MeldEffectState.RemoveUnitFromMeld,ELD_OnStateSubmitted,,,true); 
	EventMgr.RegisterForEvent(ListenerObj, 'TacticalGameEnd', MeldEffectState.OnTacticalGameEnd, ELD_OnStateSubmitted);

	`LOG("Rising Tides: The Meld has finished registering for events, initalizing...");

	MeldEffectState.Initialize(EffectTargetUnit);
	
	m_aStatChanges.length = 0;
	//MeldEffectState.StatChanges.Length = 0;

	MeldWill = MeldEffectState.CombinedWill;
	MeldHacking = MeldEffectState.SharedHack - EffectTargetUnit.GetBaseStat(eStat_Hacking);;
	`LOG("Rising Tides: YHME: Adding the following value to Hacking Stat: " @ MeldHacking);

	AddPersistentStatChange(eStat_Will, MeldWill);
	AddPersistentStatChange(eStat_Hacking, MeldHacking);
	AddPersistentStatChange(eStat_PsiOffense, MeldWill);
	
	MeldEffectState.StatChanges = m_aStatChanges;


	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, MeldEffectState);
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_Unit EffectTargetUnit;

	EffectTargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	`XEVENTMGR.TriggerEvent('RTRemoveFromMeld', EffectTargetUnit, EffectTargetUnit, NewGameState); 
	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);
	
}

DefaultProperties
{
	EffectName="RTEffect_Meld"
	DuplicateResponse = eDupe_Refresh
	GameStateEffectClass = class'RTGameState_MeldEffect'
}