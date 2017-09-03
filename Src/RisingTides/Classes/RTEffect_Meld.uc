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

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local RTGameState_MeldEffect			MeldEffectState;
	local XComGameState_Unit				EffectTargetUnit;
	local X2EventManager					EventMgr;
	local Object							ListenerObj;
	local float								MeldWill, MeldHacking, MeldPsiOff;

	EventMgr = `XEVENTMGR;
	EffectTargetUnit = XComGameState_Unit(kNewTargetState);
	MeldEffectState = RTGameState_MeldEffect(NewEffectState);



	EventMgr.TriggerEvent('RTAddToMeld', EffectTargetUnit, EffectTargetUnit, NewGameState);

	ListenerObj = MeldEffectState;
	if(ListenerObj == none)
	{
		`Redscreen("RTMeld: Failed to find Meld component when registering listener... what?");
		return;
	}

	EventMgr.RegisterForEvent(ListenerObj, 'RTAddToMeld', MeldEffectState.AddUnitToMeld, ELD_OnStateSubmitted,,,true,);
	EventMgr.RegisterForEvent(ListenerObj, 'RTRemoveFromMeld', MeldEffectState.RemoveUnitFromMeld, ELD_OnStateSubmitted,,,true,);
	EventMgr.RegisterForEvent(ListenerObj, 'RTFeedback', MeldEffectState.RemoveUnitFromMeld,ELD_OnStateSubmitted,,,true,);
	EventMgr.RegisterForEvent(ListenerObj, 'TacticalGameEnd', MeldEffectState.OnTacticalGameEnd, ELD_OnStateSubmitted);


	MeldEffectState.Initialize(EffectTargetUnit);

	m_aStatChanges.length = 0;

	MeldWill = MeldEffectState.GetMeldStrength() - EffectTargetUnit.GetBaseStat(eStat_Will);
	MeldPsiOff = MeldEffectState.GetMeldStrength() - EffectTargetUnit.GetBaseStat(eStat_PsiOffense);
	MeldHacking = MeldEffectState.SharedHack - EffectTargetUnit.GetBaseStat(eStat_Hacking);

	AddPersistentStatChange(eStat_Will, MeldWill);
	AddPersistentStatChange(eStat_Hacking, MeldHacking);
	AddPersistentStatChange(eStat_PsiOffense, MeldPsiOff);

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
