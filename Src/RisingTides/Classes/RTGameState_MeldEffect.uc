// This is an Unreal Script

class RTGameState_MeldEffect extends XComGameState_Effect config(RTGhost);

var array<StateObjectReference> Members;
var StateObjectReference		MeldHost, GameStateHost;
var float CombinedWill, SharedHack;
var bool bHasYourHandsMyEyes;

function RTGameState_MeldEffect Initialize(XComGameState_Unit MeldMaker)
{
	local RTGameState_MeldEffect ParentMeldEffect, IteratorMeldEffect;

	`LOG("Rising Tides: Initializing new MeldEffect GameState.");
	GameStateHost = MeldMaker.GetReference();

	foreach `XCOMHISTORY.IterateByClassType(class'RTGameState_MeldEffect', IteratorMeldEffect)
	if(IteratorMeldEffect != none)
		if(IteratorMeldEffect.ObjectID != ObjectID)
			ParentMeldEffect = IteratorMeldEffect;

	if(ParentMeldEffect == none)
	{
		`LOG("Rising Tides: No parent Meld found, setting this unit as the host.");
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
			SharedHack = 0.00f;
		}
	}
	else
	{
		`LOG("Rising Tides: Meld Parent GameState found.");
		MeldHost = ParentMeldEffect.MeldHost;
		Members = ParentMeldEffect.Members;
		Members.AddItem(MeldMaker.GetReference());

		CombinedWill = GetCombinedWill(Members.Length);

		bHasYourHandsMyEyes = ParentMeldEffect.bHasYourHandsMyEyes;
		if(bHasYourHandsMyEyes)
		{
			SharedHack = ParentMeldEffect.SharedHack;
			if(MeldMaker.HasSoldierAbility('YourHandsMyEyes') && MeldMaker.GetBaseStat(eStat_Hacking) > SharedHack)
				SharedHack = MeldMaker.GetBaseStat(eStat_Hacking);
		}
		else
		{
			if(MeldMaker.HasSoldierAbility('YourHandsMyEyes'))
				SharedHack = MeldMaker.GetBaseStat(eStat_Hacking);
			else
				SharedHack = 0.00f;
		}
	}

   	`LOG("Rising Tides: " @ XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(GameStateHost.ObjectID)).GetName(eNameType_Full) @" has finished initalizing its RTGameState_MeldEffect.");
	return self;
}

// AddPersistentStatChange(out array<StatChange> m_aStatChanges, ECharStatType StatType, float StatAmount, optional EStatModOp InModOp=MODOP_Addition )
simulated function AddPersistentStatChange(out array<StatChange> m_aStatChanges, ECharStatType StatType, float StatAmount, optional EStatModOp InModOp=MODOP_Addition )
{
	local StatChange NewChange;
	
	NewChange.StatType = StatType;
	NewChange.StatAmount = StatAmount;
	NewChange.ModOp = InModOp;

	m_aStatChanges.AddItem(NewChange);
}

// GetCombinedWill(int numOfMembers)
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


// Add Unit To Meld
simulated function EventListenerReturn AddUnitToMeld(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local RTGameState_MeldEffect			CurrentMeldEffect, UpdatedMeldEffect;
	local RTEffect_Meld						MeldEffect;
	local XComGameState_Unit				EnteringMeldUnit, GameStateHost;
	local X2EventManager					EventManager;
	local XComGameState						NewGameState;
	local XComGameStateHistory				History;
		
		
	History = `XCOMHISTORY;

	EnteringMeldUnit = XComGameState_Unit(EventSource);

	CurrentMeldEffect = RTGameState_MeldEffect(History.GetGameStateForObjectID(ObjectID));
	GameStateHost = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	if(GameStateHost == none)
	{
		`LOG("Rising Tides: What the... there's an uninitalized RTGameState_MeldEffect out there!");
		`LOG("Rising Tides: " @ ApplyEffectParameters.SourceStateObjectRef.ObjectID @ " just tried to AddUnitToMeld!");
		return ELR_NoInterrupt;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
	UpdatedMeldEffect = RTGameState_MeldEffect(NewGameState.CreateStateObject(class'RTGameState_MeldEffect', ObjectID));

	`LOG("" @ GameStateHost.GetName(eNameType_Full) @ " is attempting to add " @ EnteringMeldUnit.GetName(eNameType_Full) @ " to its MeldEffect.");
	
	GameStateHost.UnApplyEffectFromStats(CurrentMeldEffect, NewGameState);
	//NewGameState.RemoveStateObject(CurrentMeldEffect.ObjectID);

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

	// Remake member list, then recombine will
	UpdatedMeldEffect.Members = CurrentMeldEffect.Members;
	UpdatedMeldEffect.Members.AddItem(EnteringMeldUnit.GetReference());
	UpdatedMeldEffect.CombinedWill = GetCombinedWill(CurrentMeldEffect.Members.Length);

	
	NewGameState.AddStateObject(UpdatedMeldEffect);
	GameStateHost.ApplyEffectToStats(UpdatedMeldEffect, NewGameState);

	
	`TACTICALRULES.SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}

// Remove Unit From Meld 
simulated function EventListenerReturn RemoveUnitFromMeld(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local RTGameState_MeldEffect			CurrentMeldEffect, UpdatedMeldEffect;
	local XComGameState_Unit				LeavingMeldUnit, MeldIndexUnit, GameStateHostUnit;
	local X2EventManager					EventManager;
	local XComGameState						NewGameState;
	local XComGameStateHistory				History;
	local Object							ListenerObj;
	local int								Index;


		
		
	History = `XCOMHISTORY;

	LeavingMeldUnit = XComGameState_Unit(EventSource);
	GameStateHostUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	CurrentMeldEffect = RTGameState_MeldEffect(History.GetGameStateForObjectID(ObjectID));


	`LOG("" @ GameStateHostUnit.GetName(eNameType_Full) @ " is attempting to remove " @ LeavingMeldUnit.GetName(eNameType_Full) @ " from its MeldEffect.");

	GameStateHostUnit.UnApplyEffectFromStats(CurrentMeldEffect, NewGameState);
	//NewGameState.RemoveStateObject(ObjectID);

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

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
	UpdatedMeldEffect = RTGameState_MeldEffect(NewGameState.CreateStateObject(class'RTGameState_MeldEffect', ObjectID));
	
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
	// YHME check
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

	NewGameState.AddStateObject(UpdatedMeldEffect);
	GameStateHostUnit.ApplyEffectToStats(UpdatedMeldEffect, NewGameState);
	
	
	`TACTICALRULES.SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}


 