//---------------------------------------------------------------------------------------
//  FILE:    XComGameState_Effect_RTMeld.uc
//  AUTHOR:  Aleosiss  
//  DATE:    22 March 2016
//  PURPOSE: Component class for XComGameState_Effect that holds persistent data and 
//			 listeners for the meld effect.
//---------------------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------------------

class XComGameState_Effect_RTMeld extends XComGameState_BaseObject config(RTGhost);

var array<StateObjectReference> Members;
var StateObjectReference		MeldHost;
var int CombinedWill, SharedHack;
var bool bHasYourHandsMyEyes;

function XComGameState_Effect_RTMeld Initialize(XComGameState_Unit MeldMaker)
{
	MeldHost = MeldMaker.GetReference();
	Members.AddItem(MeldMaker.GetReference());

	CombinedWill = 10;

	bHasYourHandsMyEyes = MeldMaker.HasSoldierAbility('YourHandsMyEyes');
	if(bHasYourHandsMyEyes)
	{
		SharedHack = MeldMaker.GetBaseStat(eStat_Hacking);
	}
	else
	{
		SharedHack = 0;
	}

	return self;
}

function XComGameState_Effect GetOwningEffect()
{
	return XComGameState_Effect(`XCOMHISTORY.GetGameStateForObjectID(OwningObjectID));
}

static function int GetCombinedWill(int numOfMembers)
{
	local int FinalWill;

	FinalWill = numOfMembers * 10;

	return FinalWill;

}

// Tactical Game Cleanup
function EventListenerReturn OnTacticalGameEnd(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local X2EventManager EventManager;
	local Object ListenerObj;
    local XComGameState NewGameState;
	
    //`LOG("Rising Tides: 'TacticalGameEnd' event listener delegate invoked.");
	
	EventManager = `XEVENTMGR;

	// Unregister our callbacks
	ListenerObj = self;
	
	EventManager.UnRegisterFromEvent(ListenerObj, 'RTAddUnitToMeld');
	EventManager.UnRegisterFromEvent(ListenerObj, 'RTRemoveUnitFromMeld');
	EventManager.UnRegisterFromEvent(ListenerObj, 'UnitPanicked');
	EventManager.UnRegisterFromEvent(ListenerObj, 'TacticalGameEnd');
	
    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Meld states cleanup");
	NewGameState.RemoveStateObject(ObjectID);
	`GAMERULES.SubmitGameState(NewGameState);

	`LOG("RisingTides: Meld passive effect unregistered from events.");
	
	return ELR_NoInterrupt;
}
// Update Meld Member Stats
static function UpdateMeldMembers(XComGameState_Effect_RTMeld UpdatedMeldEffect, XComGameState_Effect_RTMeld CurrentMeldEffect, XComGameState NewGameState)
{
	local int i;
	local XComGameState_Unit UpdateUnit;
	local XComGameState_Effect ActiveEffectState;
	local RTEffect_Meld ActiveMeldEffect;

	for(i = 0; i < UpdatedMeldEffect.Members.Length; i++)
	{
		UpdateUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UpdatedMeldEffect.Members[i].ObjectID));		
		// Find all targets of Meld effects in the mission
		foreach `XCOMHistory.IterateByClassType(class'XComGameState_Effect', ActiveEffectState)
		{
			if(ActiveEffectState != none)
			{
				ActiveMeldEffect = RTEffect_Meld(ActiveEffectState.GetX2Effect());
				if(ActiveMeldEffect != none)
				{
					if(ActiveEffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID == UpdateUnit.ObjectID)	   
					{
						ActiveMeldEffect.UpdateEffect(UpdateUnit, UpdatedMeldEffect, CurrentMeldEffect, NewGameState, ActiveEffectState);
						NewGameState.AddStateObject(UpdateUnit);
					}
				}
			}

		}   							   
	}
}

// Add Unit To Meld
simulated function EventListenerReturn AddUnitToMeld(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Effect_RTMeld		CurrentMeldEffect, UpdatedMeldEffect;
	local XComGameState_Unit				EnteringMeldUnit;
	local X2EventManager					EventManager;
	local XComGameState						NewGameState;
	local XComGameStateHistory				History;
		
		
	History = `XCOMHISTORY;

	EnteringMeldUnit = XComGameState_Unit(EventSource);

	CurrentMeldEffect = XComGameState_Effect_RTMeld(History.GetGameStateForObjectID(ObjectID));
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));

	UpdatedMeldEffect = XComGameState_Effect_RTMeld(NewGameState.CreateStateObject(class'XComGameState_Effect_RTMeld', ObjectID));
	// Check to see if the old effect has YHME. If it doesn't, check the new unit for it. Otherwise, update the new MeldEffect to the new SharedHack value.
	if(!CurrentMeldEffect.bHasYourHandsMyEyes)
	{
		UpdatedMeldEffect.bHasYourHandsMyEyes = EnteringMeldUnit.HasSoldierAbility('YourHandsMyEyes');
		if(UpdatedMeldEffect.bHasYourHandsMyEyes && EnteringMeldUnit.GetBaseStat(eStat_Hacking) > UpdatedMeldEffect.SharedHack)
		{
			UpdatedMeldEffect.SharedHack = EnteringMeldUnit.GetBaseStat(eStat_Hacking);
		}
	}
	else
	{
		UpdatedMeldEffect.bHasYourHandsMyEyes = true;
		UpdatedMeldEffect.SharedHack = CurrentMeldEffect.SharedHack;
		if(EnteringMeldUnit.GetBaseStat(eStat_Hacking) > UpdatedMeldEffect.SharedHack && EnteringMeldUnit.HasSoldierAbility('YourHandsMyEyes'))
		{
			UpdatedMeldEffect.SharedHack = EnteringMeldUnit.GetBaseStat(eStat_Hacking);
		}
	}
	// Recombine the Meld Will, then add the old members into the new Meld. Then add the new 
	UpdatedMeldEffect.CombinedWill = GetCombinedWill(CurrentMeldEffect.Members.Length + 1);
	UpdatedMeldEffect.Members = CurrentMeldEffect.Members;
	UpdatedMeldEffect.Members.AddItem(EnteringMeldUnit.GetReference());

	UpdateMeldMembers(UpdatedMeldEffect, CurrentMeldEffect, NewGameState);

	NewGameState.AddStateObject(UpdatedMeldEffect);
	`TACTICALRULES.SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}

// Remove Unit From Meld 
simulated function EventListenerReturn RemoveUnitFromMeld(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Effect_RTMeld		CurrentMeldEffect, UpdatedMeldEffect;
	local XComGameState_Unit				LeavingMeldUnit, MeldIndexUnit;
	local X2EventManager					EventManager;
	local XComGameState						NewGameState;
	local XComGameStateHistory				History;
	local Object							ListenerObj;
	local int								Index;
		
		
	History = `XCOMHISTORY;

	LeavingMeldUnit = XComGameState_Unit(EventSource);

	CurrentMeldEffect = XComGameState_Effect_RTMeld(History.GetGameStateForObjectID(ObjectID));
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));

	if(CurrentMeldEffect.Members.Length == 1)
	{
		//remove the CurrentMeldEffect
		EventManager = `XEVENTMGR;

		// Unregister our callbacks
		ListenerObj = self;
	
		EventManager.UnRegisterFromEvent(ListenerObj, 'RTAddUnitToMeld');
		EventManager.UnRegisterFromEvent(ListenerObj, 'RTRemoveUnitFromMeld');
		EventManager.UnRegisterFromEvent(ListenerObj, 'UnitPanicked');
		EventManager.UnRegisterFromEvent(ListenerObj, 'TacticalGameEnd');
		
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Meld states cleanup");
		NewGameState.RemoveStateObject(ObjectID);
		`TACTICALRULES.SubmitGameState(NewGameState);

		`LOG("RisingTides: Meld passive effect unregistered from events.");
	
		return ELR_NoInterrupt;
	}

	UpdatedMeldEffect = XComGameState_Effect_RTMeld(NewGameState.CreateStateObject(class'XComGameState_Effect_RTMeld', ObjectID));
	if(LeavingMeldUnit.ObjectID == CurrentMeldEffect.MeldHost.ObjectID)
	{
		//meld host is the first member, so just make the host the second member and call it a day
		UpdatedMeldEffect.MeldHost.ObjectID = CurrentMeldEffect.Members[1].ObjectID;
	}
	else
	{
		UpdatedMeldEffect.MeldHost.ObjectID = CurrentMeldEffect.MeldHost.ObjectID;
	}
	
	for( Index = CurrentMeldEffect.Members.Length - 1; Index > -1; --Index )
	{
		//Remove the leaving unit from the list
		if(CurrentMeldEffect.Members[Index].ObjectID == LeavingMeldUnit.ObjectID)
		{
			CurrentMeldEffect.Members.Remove(Index, 1);
		}
	}
	// YEMH check
	UpdatedMeldEffect.bHasYourHandsMyEyes = false;
	UpdatedMeldEffect.SharedHack = 0;
	if(CurrentMeldEffect.bHasYourHandsMyEyes)
	{	
		for( Index = CurrentMeldEffect.Members.Length - 1; Index > -1; --Index )
		{
			// Check if the new meld effect still has a unit with YEMH
			MeldIndexUnit = XComGameState_Unit(History.GetGameStateForObjectID(CurrentMeldEffect.Members[Index].ObjectID));
			if(MeldIndexUnit.HasSoldierAbility('YourHandsMyEyes'))
			{
				UpdatedMeldEffect.bHasYourHandsMyEyes = true;
				// obviously if the unit has the ability and no one else does, the baseHacking will be higher than 0, this just updates it to the highest value
				// if by some ungodly (i.e. never) chance that there are two YHME effects in play		
				if(MeldIndexUnit.GetBaseStat(eStat_Hacking) > UpdatedMeldEffect.SharedHack)
				{
					UpdatedMeldEffect.SharedHack = MeldIndexUnit.GetBaseStat(eStat_Hacking);
				}
			}
		}
	}
	
	 
	UpdatedMeldEffect.Members = CurrentMeldEffect.Members;
	UpdatedMeldEffect.CombinedWill = GetCombinedWill(UpdatedMeldEffect.Members.Length);

	UpdateMeldMembers(UpdatedMeldEffect,  CurrentMeldEffect, NewGameState);
	
	NewGameState.AddStateObject(UpdatedMeldEffect);
	`TACTICALRULES.SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}


 