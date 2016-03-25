//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_Meld.uc
//  AUTHOR:  Aleosiss  
//  DATE:    18 March 2016
//  PURPOSE: Meld effect
//           
//---------------------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------------------

class RTEffect_Meld extends X2Effect_Persistent config(RTGhost);


// GetMeldComponent
static function XComGameState_Effect_RTMeld GetMeldComponent(XComGameState_Effect Effect)
{
	if (Effect != none) 
		return XComGameState_Effect_RTMeld(Effect.FindComponentObject(class'XComGameState_Effect_RTMeld'));
	return none;
}


simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Effect_RTMeld		MeldEffectState;
	local XComGameState_Unit				EffectTargetUnit;
	local X2EventManager					EventMgr;
	local Object							ListenerObj;

	EventMgr = `XEVENTMGR;
	EffectTargetUnit = XComGameState_Unit(kNewTargetState);
	if(GetMeldComponent(NewEffectState) == none)
	{
		MeldEffectState = XComGameState_Effect_RTMeld(NewGameState.CreateStateObject(class'XComGameState_Effect_RTMeld'));
		MeldEffectState.InitComponent(EffectTargetUnit);
		NewEffectState.AddComponentObject(MeldEffectState);
		NewGameState.AddStateObject(MeldEffectState);
	

		ListenerObj = MeldEffectState;
		if(ListenerObj == none)
		{
			`Redscreen("RTMeld: Failed to find Meld component when registering listener (WE DUN FUCKED)");
			return;
		}
		EventMgr.RegisterForEvent(ListenerObj, 'RTAddToMeld', MeldEffectState.AddUnitToMeld, ELD_OnStateSubmitted,,,true);
		EventMgr.RegisterForEvent(ListenerObj, 'RTRemoveFromMeld', MeldEffectState.RemoveUnitFromMeld, ELD_OnStateSubmitted,,,true);
		//EventMgr.RegisterForEvent(ListenerObj, 'UnitPanicked', MeldEffectState.PanicMeld,ELD_OnStateSubmitted,,,true); 
	}
	else
	{
		EventMgr.TriggerEvent('RTAddToMeld', EffectTargetUnit, EffectTargetUnit, NewGameState); 
	}

}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_Unit	EffectTargetUnit;
	EffectTargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	`XEVENTMGR.TriggerEvent('RTRemoveFromMeld', EffectTargetUnit, EffectTargetUnit, NewGameState); 
	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);
}