//---------------------------------------------------------------------------------------
//  FILE:    RTGameState_MeldEffect.uc
//  AUTHOR:  Aleosiss
//  DATE:    22 May 2016
//  PURPOSE: Extended GameState_Effect that holds custom listeners for per-unit MeldEffects.
//---------------------------------------------------------------------------------------

class RTGameState_MeldEffect extends RTGameState_Effect config(RTGhost);

var array<StateObjectReference> Members;
var StateObjectReference		MeldHost, GameStateHost;
var float CombinedWill, SharedHack, MeldStrength;
var bool bHasYourHandsMyEyes;
var ECharStatType MeldStrengthStatType;

// Initialize(XComGameState_Unit MeldMaker)
function RTGameState_MeldEffect Initialize(XComGameState_Unit MeldMaker)
{
	local array<StateObjectReference> IteratorArray;
	local RTGameState_MeldEffect ParentMeldEffect, IteratorMeldEffect;
	local int i;

	`LOG("Rising Tides: Initializing new MeldEffect GameState.");
	GameStateHost = MeldMaker.GetReference();

	foreach `XCOMHISTORY.IterateByClassType(class'RTGameState_MeldEffect', IteratorMeldEffect){
		if(IteratorMeldEffect != none){
			if(IteratorMeldEffect.ObjectID != ObjectID){
				IteratorArray.AddItem(IteratorMeldEffect.GetReference());
				break;

			}
		}
	}



	//ParentMeldEffect = RTGameState_MeldEffect(`XCOMHISTORY.GetSingleGameStateObjectForClass(class, true));
	ParentMeldEffect = RTGameState_MeldEffect(`XCOMHISTORY.GetGameStateForObjectID(IteratorArray[0].ObjectID));

	// if there is no prexisting Meld, we're going to have to make it ourselves
	if(ParentMeldEffect == none || ParentMeldEffect.ObjectID == ObjectID)
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
		`LOG("Rising Tides: Meld Parent GameState found:");
		`LOG(IteratorArray[0].ObjectID @ " is the parent StateObjectReference.");
		MeldHost = ParentMeldEffect.MeldHost;
		Members = ParentMeldEffect.Members;
		Members.AddItem(MeldMaker.GetReference());

		//CombinedWill = GetCombinedWill(Members.Length);
		MeldStrength = GetMeldStrength();

		bHasYourHandsMyEyes = ParentMeldEffect.bHasYourHandsMyEyes;
		if(bHasYourHandsMyEyes)
		{
			SharedHack = ParentMeldEffect.SharedHack;
			if(MeldMaker.HasSoldierAbility('YourHandsMyEyes') && MeldMaker.GetBaseStat(eStat_Hacking) > SharedHack)
				SharedHack = MeldMaker.GetBaseStat(eStat_Hacking);
		}
		else
		{
			if(MeldMaker.HasSoldierAbility('YourHandsMyEyes')) {
				SharedHack = MeldMaker.GetBaseStat(eStat_Hacking);
				bHasYourHandsMyEyes = true;
			}
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

// GetMeldStrength()
simulated function int GetMeldStrength() {
	local float LocalMeldStrength;
	local XComGameStateHistory History;
	local StateObjectReference UnitRef;

	local ECharStatType StatType;

	StatType = default.MeldStrengthStatType;

	History = `XCOMHISTORY;

	foreach Members (UnitRef) {
		LocalMeldStrength = max(XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID)).GetBaseStat(StatType), LocalMeldStrength);
	}
	foreach Members (UnitRef) {
		if(UnitRef.ObjectID == GameStateHost.ObjectID)
			continue;
		LocalMeldStrength += int(XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID)).GetBaseStat(StatType) / 10);
	}
	MeldStrength = LocalMeldStrength;
	return LocalMeldStrength;

}


// RemakeSelf(RTGameState_MeldEffect OtherMeldEffect)
simulated function RemakeSelf(RTGameState_MeldEffect OtherMeldEffect)
{
	StatChanges.Length = 0;
	Members.Length = 0;

	Members = OtherMeldEffect.Members;
	MeldHost = OtherMeldEffect.MeldHost;
	SharedHack = OtherMeldEffect.SharedHack;
	StatChanges = OtherMeldEffect.StatChanges;
	CombinedWill = OtherMeldEffect.CombinedWill;
	MeldStrength = OtherMeldEffect.MeldStrength;
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
	local XComGameState_Unit				EnteringMeldUnit, GameStateHostUnit, newGameStateHostUnit;
	local X2EventManager					EventManager;
	local XComGameState						NewGameState;
	local XComGameStateHistory				History;
	local float								HackModifier, MeldWillModifier, MeldPsiOffModifier;


	History = `XCOMHISTORY;

	`LOG("Rising Tides: AddUnitToMeld called by " @ EventID);

	EnteringMeldUnit = XComGameState_Unit(EventSource);
	MeldEffect = RTEffect_Meld(GetX2Effect());
	CurrentMeldEffect = RTGameState_MeldEffect(History.GetGameStateForObjectID(ObjectID));
	GameStateHostUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	if(GameStateHostUnit == none)
		return ELR_NoInterrupt;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
	UpdatedMeldEffect = RTGameState_MeldEffect(NewGameState.CreateStateObject(class'RTGameState_MeldEffect', ObjectID));

	`LOG("" @ GameStateHostUnit.GetName(eNameType_Full) @ " is attempting to add " @ EnteringMeldUnit.GetName(eNameType_Full) @ " to its MeldEffect.");

	//GameStateHostUnit.UnApplyEffectFromStats(self, NewGameState);
	//NewGameState.RemoveStateObject(CurrentMeldEffect.ObjectID);
	//`LOG("" @ GameStateHostUnit.GetName(eNameType_Full) @ " is attempting to remove " @ CurrentMeldEffect.CombinedWill @ " from itself.");
	MeldEffect.UnApplyEffectFromStats(self, GameStateHostUnit, NewGameState);

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
	UpdatedMeldEffect.CombinedWill = GetCombinedWill(UpdatedMeldEffect.Members.Length);
	UpdatedMeldEffect.MeldStrength = UpdatedMeldEffect.GetMeldStrength();

	HackModifier = UpdatedMeldEffect.SharedHack - GameStateHostUnit.GetBaseStat(eStat_Hacking);
	MeldWillModifier = UpdatedMeldEffect.MeldStrength - GameStateHostUnit.GetBaseStat(eStat_Will);
	MeldPsiOffModifier = UpdatedMeldEffect.MeldStrength - GameStateHostUnit.GetBaseStat(eStat_PsiOffense);

	UpdatedMeldEffect.StatChanges.Length = 0;
	AddPersistentStatChange(UpdatedMeldEffect.StatChanges, eStat_Will, MeldWillModifier);
	AddPersistentStatChange(UpdatedMeldEffect.StatChanges, eStat_Hacking, HackModifier);
	AddPersistentStatChange(UpdatedMeldEffect.StatChanges, eStat_PsiOffense, MeldPsiOffModifier);


	RemakeSelf(UpdatedMeldEffect);
	//`LOG("Rising Tides: " @ GameStateHostUnit.GetName(eNameType_Full) @ "'s meld has " @ UpdatedMeldEffect.Members.Length @ " people in it.");
	newGameStateHostUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', GameStateHostUnit.ObjectID));
	//newGameStateHostUnit.ApplyEffectToStats(self, NewGameState);
	//`LOG("" @ GameStateHostUnit.GetName(eNameType_Full) @ " is attempting to add " @ UpdatedMeldEffect.CombinedWill @ " to itself.");
	MeldEffect.ApplyEffectToStats(self, newGameStateHostUnit, NewGameState);

	NewGameState.AddStateObject(UpdatedMeldEffect);
	NewGameState.AddStateObject(newGameStateHostUnit);


	`TACTICALRULES.SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}

// Remove Unit From Meld
simulated function EventListenerReturn RemoveUnitFromMeld(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local RTGameState_MeldEffect			CurrentMeldEffect, UpdatedMeldEffect;
	local XComGameState_Unit				LeavingMeldUnit, MeldIndexUnit, GameStateHostUnit, newGameStateHostUnit;
	local RTEffect_Meld						MeldEffect;
	local X2EventManager					EventManager;
	local XComGameState						NewGameState;
	local XComGameStateHistory				History;
	local Object							ListenerObj;
	local int								Index;
	local float								HackModifier, MeldWillModifier, MeldPsiOffModifier;

	`LOG("Rising Tides: RemoveUnitToMeld called by " @ EventID);
	History = `XCOMHISTORY;
	LeavingMeldUnit = XComGameState_Unit(EventSource);
	GameStateHostUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	CurrentMeldEffect = RTGameState_MeldEffect(History.GetGameStateForObjectID(ObjectID));
	MeldEffect = RTEffect_Meld(GetX2Effect());


	`LOG("" @ GameStateHostUnit.GetName(eNameType_Full) @ " is attempting to remove " @ LeavingMeldUnit.GetName(eNameType_Full) @ " from its MeldEffect.");
	if(GameStateHostUnit == none)
		return ELR_NoInterrupt;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
	UpdatedMeldEffect = RTGameState_MeldEffect(NewGameState.CreateStateObject(class'RTGameState_MeldEffect', ObjectID));
	MeldEffect.UnApplyEffectFromStats(self, GameStateHostUnit, NewGameState);

	//NewGameState.RemoveStateObject(ObjectID);

	if(GameStateHostUnit.ObjectID == LeavingMeldUnit.ObjectID)
	{
		//remove the CurrentMeldEffect
		EventManager = `XEVENTMGR;

		// Unregister our callbacks
		ListenerObj = self;

		EventManager.UnRegisterFromEvent(ListenerObj, 'RTAddUnitToMeld');
		EventManager.UnRegisterFromEvent(ListenerObj, 'RTRemoveUnitFromMeld');
		//EventManager.UnRegisterFromEvent(ListenerObj, 'UnitPanicked');
		EventManager.UnRegisterFromEvent(ListenerObj, 'TacticalGameEnd');

		RemoveEffect(NewGameState, NewGameState);
		XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = TriggerLeaveMeldFlyoverVisualizationFn;

		`TACTICALRULES.SubmitGameState(NewGameState);

		`LOG("RisingTides: Meld passive effect unregistered from events.");

		return ELR_NoInterrupt;
	}

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
		// reset hack modifier
		if(UpdatedMeldEffect.bHasYourHandsMyEyes) {
			HackModifier = UpdatedMeldEffect.SharedHack - GameStateHostUnit.GetBaseStat(eStat_Hacking);
		} else {
			HackModifier = 0;
		}

	} else {
			HackModifier = 0;
	}
	// Remake member list, then recombine will
	UpdatedMeldEffect.Members = CurrentMeldEffect.Members;
	UpdatedMeldEffect.CombinedWill = GetCombinedWill(UpdatedMeldEffect.Members.Length);
	UpdatedMeldEffect.MeldStrength = UpdatedMeldEffect.GetMeldStrength();

	MeldWillModifier = UpdatedMeldEffect.MeldStrength - GameStateHostUnit.GetBaseStat(eStat_Will);
	MeldPsiOffModifier = UpdatedMeldEffect.MeldStrength - GameStateHostUnit.GetBaseStat(eStat_PsiOffense);

	UpdatedMeldEffect.StatChanges.Length = 0;
	AddPersistentStatChange(UpdatedMeldEffect.StatChanges, eStat_Will, MeldWillModifier);
	AddPersistentStatChange(UpdatedMeldEffect.StatChanges, eStat_Hacking, HackModifier);
	AddPersistentStatChange(UpdatedMeldEffect.StatChanges, eStat_PsiOffense, MeldPsiOffModifier);


	RemakeSelf(UpdatedMeldEffect);
	//`LOG("Rising Tides: " @ GameStateHostUnit.GetName(eNameType_Full) @ "'s meld has " @ UpdatedMeldEffect.Members.Length @ " people in it.");
	newGameStateHostUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', GameStateHostUnit.ObjectID));
	//newGameStateHostUnit.ApplyEffectToStats(self, NewGameState);
	//`LOG("" @ GameStateHostUnit.GetName(eNameType_Full) @ " is attempting to add " @ UpdatedMeldEffect.CombinedWill @ " to itself.");
	MeldEffect.ApplyEffectToStats(self, newGameStateHostUnit, NewGameState);

	NewGameState.AddStateObject(UpdatedMeldEffect);
	NewGameState.AddStateObject(newGameStateHostUnit);


	`TACTICALRULES.SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}

// Join Visualization
function TriggerJoinMeldFlyoverVisualizationFn(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{
	local XComGameState_Unit UnitState;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local VisualizationTrack BuildTrack;
	local XComGameStateHistory History;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Ability AbilityState;

	History = `XCOMHISTORY;

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(GameStateHost.ObjectID));


	History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, BuildTrack.StateObject_OldState, BuildTrack.StateObject_NewState, , VisualizeGameState.HistoryIndex);
	BuildTrack.StateObject_NewState = UnitState;
	BuildTrack.TrackActor = UnitState.GetVisualizer();

	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "Joined the meld!", '', eColor_Attention, "img:///UILibrary_PerkIcons.UIPerk_reload");
	OutVisualizationTracks.AddItem(BuildTrack);
}

// Leave Visualization
function TriggerLeaveMeldFlyoverVisualizationFn(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{
	local XComGameState_Unit UnitState;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local VisualizationTrack BuildTrack;
	local XComGameStateHistory History;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Ability AbilityState;

	History = `XCOMHISTORY;

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(GameStateHost.ObjectID));


	History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, BuildTrack.StateObject_OldState, BuildTrack.StateObject_NewState, , VisualizeGameState.HistoryIndex);
	BuildTrack.StateObject_NewState = UnitState;
	BuildTrack.TrackActor = UnitState.GetVisualizer();

	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "Left the meld!", '', eColor_Attention, "img:///UILibrary_PerkIcons.UIPerk_reload");
	OutVisualizationTracks.AddItem(BuildTrack);


}

defaultproperties
{
	MeldStrengthStatType = eStat_Will
}
