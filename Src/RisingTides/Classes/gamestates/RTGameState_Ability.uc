// This is an Unreal Script

class RTGameState_Ability extends XComGameState_Ability;

// Get Bloodlust Stack Count
public static function int getBloodlustStackCount(XComGameState_Unit WaltzUnit) {
	local int iStackCount;
	local StateObjectReference IteratorObjRef;
	local RTGameState_Effect BloodlustEffectState;

   if (WaltzUnit != none) {
		// get our stacking effect
		foreach WaltzUnit.AffectedByEffects(IteratorObjRef) {
			BloodlustEffectState = RTGameState_Effect(`XCOMHISTORY.GetGameStateForObjectID(IteratorObjRef.ObjectID));
			if(BloodlustEffectState != none && BloodlustEffectState.GetX2Effect().EffectName == class'RTEffect_Bloodlust'.default.EffectName) {
				break;
			}
		}
		if(BloodlustEffectState != none) {
			iStackCount = BloodlustEffectState.iStacks;
		} else {
			iStackCount = 0;
		}
	} else  {
		`RTLOG("No SourceUnit found for getBloodlustStackCount!");
	}
	return iStackCount;
}

// Reprobate Waltz
function EventListenerReturn ReprobateWaltzListener( Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit WaltzUnit;
	local int iStackCount;
	local float fStackModifier, fFinalPercentChance;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	WaltzUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));


	fStackModifier = 1;
	if(AbilityContext != none) {
		iStackCount = getBloodlustStackCount(WaltzUnit);
		fFinalPercentChance = 100 -  ( class'RTAbility_BerserkerAbilitySet'.default.REPROBATE_WALTZ_BASE_CHANCE + ( class'RTAbility_BerserkerAbilitySet'.default.REPROBATE_WALTZ_BLOODLUST_STACK_CHANCE * iStackCount * fStackModifier));

		if(`SYNC_RAND(100) <= int(fFinalPercentChance)) {
			AbilityTriggerAgainstSingleTarget(AbilityContext.InputContext.PrimaryTarget, false);
		}
	}
	return ELR_NoInterrupt;
}

// credits to /u/robojumper
// This function is native for performance reasons, the script code below describes its function
// NO LONGER AM I SHACKLED BY NATIVE CODE
simulated function name GatherAbilityTargets(out array<AvailableTarget> Targets, optional XComGameState_Unit OverrideOwnerState) {
	local int i, j;
	local XComGameState_Unit kOwner;
	local name AvailableCode;
	local XComGameStateHistory History;
	local bool bDebug;

	GetMyTemplate();
	History = `XCOMHISTORY;
	kOwner = XComGameState_Unit(History.GetGameStateForObjectID(OwnerStateObject.ObjectID));
	if (OverrideOwnerState != none)
		kOwner = OverrideOwnerState;

	if (m_Template != None)
	{
		if(m_TemplateName == 'RTShadowStrike')
			bDebug = false;

		AvailableCode = m_Template.AbilityTargetStyle.GetPrimaryTargetOptions(self, Targets);
		if (AvailableCode != 'AA_Success') {
			if(bDebug)
				`RTLOG("ShadowStrike failed, here's why " @ AvailableCode);
			return AvailableCode;
		}
		for (i = Targets.Length - 1; i >= 0; --i)
		{
			AvailableCode = m_Template.CheckTargetConditions(self, kOwner, History.GetGameStateForObjectID(Targets[i].PrimaryTarget.ObjectID));
			if(bDebug) {
				`RTLOG("ShadowStrike checking target " @  XComGameState_Unit(History.GetGameStateForObjectID(Targets[i].PrimaryTarget.ObjectID)).GetFullName());
			}


			if (AvailableCode != 'AA_Success')
			{
				if(bDebug)
					`RTLOG("ShadowStrike failed, here's why " @ AvailableCode);
				Targets.Remove(i, 1);
			}
		}

		if (m_Template.AbilityMultiTargetStyle != none)
		{
			m_Template.AbilityMultiTargetStyle.GetMultiTargetOptions(self, Targets);

			for (i = Targets.Length - 1; i >= 0; --i)
			{
				for (j = Targets[i].AdditionalTargets.Length - 1; j >= 0; --j)
				{
					AvailableCode = m_Template.CheckMultiTargetConditions(self, kOwner, History.GetGameStateForObjectID(Targets[i].AdditionalTargets[j].ObjectID));
					if (AvailableCode != 'AA_Success' || (Targets[i].AdditionalTargets[j].ObjectID == Targets[i].PrimaryTarget.ObjectID) && !m_Template.AbilityMultiTargetStyle.bAllowSameTarget)
					{
						Targets[i].AdditionalTargets.Remove(j, 1);
					}
				}

				AvailableCode = m_Template.AbilityMultiTargetStyle.CheckFilteredMultiTargets(self, Targets[i]);
				if (AvailableCode != 'AA_Success')
					Targets.Remove(i, 1);
			}
		}

		//The Multi-target style may have deemed some primary targets invalid in calls to CheckFilteredMultiTargets - so CheckFilteredPrimaryTargets must come afterwards.
		AvailableCode = m_Template.AbilityTargetStyle.CheckFilteredPrimaryTargets(self, Targets);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;

		Targets.Sort(SortAvailableTargets);
	}
	return 'AA_Success';
}

simulated function int SortAvailableTargets(AvailableTarget TargetA, AvailableTarget TargetB) {
	local XComGameStateHistory History;
	local XComGameState_Destructible DestructibleA, DestructibleB;
	local int HitChanceA, HitChanceB;
	local ShotBreakdown BreakdownA, BreakdownB;

	if (TargetA.PrimaryTarget.ObjectID != 0 && TargetB.PrimaryTarget.ObjectID == 0)
	{
		return -1;
	}
	if (TargetB.PrimaryTarget.ObjectID != 0 && TargetA.PrimaryTarget.ObjectID == 0)
	{
		return 1;
	}
	if (TargetA.PrimaryTarget.ObjectID == 0 && TargetB.PrimaryTarget.ObjectID == 0)
	{
		return 1;
	}
	History = `XCOMHISTORY;
	DestructibleA = XComGameState_Destructible(History.GetGameStateForObjectID(TargetA.PrimaryTarget.ObjectID));
	DestructibleB = XComGameState_Destructible(History.GetGameStateForObjectID(TargetB.PrimaryTarget.ObjectID));
	if (DestructibleA != none && DestructibleB == none)
	{
		return -1;
	}
	if (DestructibleB != none && DestructibleA == none)
	{
		return 1;
	}

	HitChanceA = GetShotBreakdown(TargetA, BreakdownA);
	HitChanceB = GetShotBreakdown(TargetB, BreakdownB);
	if (HitChanceA < HitChanceB)
	{
		return -1;
	}

	return 1;
}

// Unwilling Conduits
// this should be triggered off of a UnitUsedPsionicAbilityEvent:
// EventData = XComGameState_Ability
// EventSource = XComGameState_Unit
function EventListenerReturn UnwillingConduitEvent(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameStateHistory					History;
	local XComGameState_Ability					PreviousAbilityState, NewAbilityState;
	local XComGameState							NewGameState;
	local XComGameState_Unit					PreviousSourceUnitState, NewSourceUnitState, IteratorUnitState;
	local int									iConduits;
	local XComGameStateContext_Ability			AbilityContext;

	`RTLOG("Starting Unwilling Conduit check!");

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext == none) {
		`RTLOG("Unwilling Conduit Event failed, no AbilityContext!");
		`RedScreenOnce("Rising Tides: Unwilling Conduit Event failed, no AbilityContext!");
		return ELR_NoInterrupt;
	}

	History = `XCOMHISTORY;

	// EventData = AbilityState to Channel
	PreviousAbilityState = XComGameState_Ability(EventData);
	// Event Source = UnitState of AbilityState
	PreviousSourceUnitState = XComGameState_Unit(EventSource);

	if(PreviousAbilityState == none || PreviousSourceUnitState == none) {
		`RedScreenOnce("Rising Tides: Unwilling Conduit Event failed, no previous AbilityState or SourceUnitState!");
		return ELR_NoInterrupt;
	}

	if(!PreviousAbilityState.IsCoolingDown()) {
		return ELR_NoInterrupt;
	}


	iConduits = 0;
	foreach History.IterateByClassType(class'XComGameState_Unit', IteratorUnitState) {
		if(IteratorUnitState.AffectedByEffectNames.Find(class'RTAbility_GathererAbilitySet'.default.OverTheShoulderEffectName) != INDEX_NONE) {
			if(IteratorUnitState.IsEnemyUnit(PreviousSourceUnitState)) {
				iConduits++;
			}
		}
	}

	NewGameState = `CreateChangeState(string(GetFuncName()));
	NewSourceUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', PreviousSourceUnitState.ObjectID));
	NewAbilityState = XComGameState_Ability(NewGameState.CreateStateObject(class'XComGameState_Ability', PreviousAbilityState.ObjectID));

	if(PreviousAbilityState.iCooldown <= iConduits) {
		NewAbilityState.iCooldown = 1;
	} else {
		NewAbilityState.iCooldown -= iConduits;
	}

	NewGameState.AddStateObject(NewAbilityState);
	NewGameState.AddStateObject(NewSourceUnitState);

	if(iConduits > 0) {
		XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = ConduitVisualizationFn;
	}

	`RTLOG("Finishing Unwilling Conduit check!");

	`TACTICALRULES.SubmitGameState(NewGameState);

	if(iConduits > 0)
		AbilityTriggerAgainstSingleTarget(OwnerStateObject, false);
	return ELR_NoInterrupt;
}

function ConduitVisualizationFn(XComGameState VisualizeGameState) {
	local XComGameState_Unit UnitState;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local VisualizationActionMetadata ActionMetadata;
	local XComGameStateHistory History;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Ability AbilityState;

	History = `XCOMHISTORY;
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		foreach VisualizeGameState.IterateByClassType(class'XComGameState_Ability', AbilityState)
		{
			break;
		}
		if (AbilityState == none)
		{
			`RedScreenOnce("Ability state missing from" @ GetFuncName() @ "-jbouscher @gameplay");
			return;
		}

		History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState, , VisualizeGameState.HistoryIndex);
		ActionMetadata.StateObject_NewState = UnitState;
		ActionMetadata.VisualizeActor = UnitState.GetVisualizer();

		AbilityTemplate = AbilityState.GetMyTemplate();
		if (AbilityTemplate != none)
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "Unwilling Conduits", '', eColor_Good, "img:///UILibrary_PerkIcons.UIPerk_reload");
		}
		break;
	}
}

// Echoed Agony Listener
function EventListenerReturn EchoedAgonyListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameState_Ability AbilityState;
	local XComGameState_Unit SourceUnitState;
	local XComGameState NewGameState;
	local XComGameStateHistory History;
	local int PanicStrength;

	local bool bDebug;

	bDebug = false;

	SourceUnitState = XComGameState_Unit(EventSource); // we are always the source
	if(SourceUnitState.ObjectID != OwnerStateObject.ObjectID) {
		`RedScreen("Rising Tides: Echoed Agony event had an invalid source!");
	}

	History = `XCOMHISTORY;

	// determine correct panic value...
	switch(EventID) {
		case 'UnitTakeEffectDamage':
			PanicStrength = class'RTEffectBuilder'.default.AGONY_STRENGTH_TAKE_DAMAGE;
			break;
		case 'RTFeedback':
			PanicStrength = class'RTEffectBuilder'.default.AGONY_STRENGTH_TAKE_FEEDBACK;
			break;
		case 'UnitPanicked':
			PanicStrength = class'RTEffectBuilder'.default.AGONY_STRENGTH_TAKE_ECHO;
			break;
		default:
			`RTLOG("Echoed Agony had an invalid EventID: " @ EventID);
			PanicStrength = class'RTEffectBuilder'.default.AGONY_STRENGTH_TAKE_FEEDBACK;
	}

	// this meaty block updates the panic event value and submits the change state
	NewGameState = `CreateChangeState(string(GetFuncName()));
	// oh boy
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(SourceUnitState.FindAbility(class'RTAbility_GathererAbilitySet'.default.EchoedAgonyEffectAbilityTemplateName).ObjectID));
	AbilityState = XComGameState_Ability(NewGameState.CreateStateObject(class'XComGameState_Ability', AbilityState.ObjectID));
	AbilityState.PanicEventValue = PanicStrength;
	NewGameState.AddStateObject(AbilityState);
	`TACTICALRULES.SubmitGameState(NewGameState);

	AbilityTriggerAgainstSingleTarget(OwnerStateObject, false);

	if(!bDebug) {
		`RTLOG("EchoedAgonyListener did not find Echoed Agony!");
	}
	return ELR_NoInterrupt;
}

function EventListenerReturn TriangulationListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameState_Unit SourceUnitState, IteratorUnitState, OwnerUnitState;
	local XComGameStateHistory History;

	//`LOG("Triangulation Triggered via EventID " @ EventID);
	History = `XCOMHISTORY;

	SourceUnitState = XComGameState_Unit(EventSource);
	OwnerUnitState = XComGameState_Unit(History.GetGameStateForObjectID(OwnerStateObject.ObjectID));

	if(!SourceUnitState.IsUnitAffectedByEffectName('RTEffect_Meld') || !OwnerUnitState.IsUnitAffectedByEffectName('RTEffect_Meld')) {
		//`LOG("!SourceUnitState.IsUnitAffectedByEffectName('RTEffect_Meld')");
		return ELR_NoInterrupt;
	}

	if(!OwnerUnitState.IsUnitAffectedByEffectName(class'RTAbility_GathererAbilitySet'.default.OverTheShoulderSourceEffectName)){
		//`LOG("!SourceUnitState.IsUnitAffectedByEffectName(class'RTAbility_GathererAbilitySet'.default.OverTheShoulderSourceEffectName)");
		return ELR_NoInterrupt;
	}

	foreach History.IterateByClassType(class'XComGameState_Unit', IteratorUnitState) {
		// don't target ourselves
		if(IteratorUnitState.ObjectID == OwnerUnitState.ObjectID) {
			//`LOG("IteratorUnitState.ObjectID == SourceUnitState.ObjectID");
			continue;
		}
		// only target melded units
		if(!IteratorUnitState.IsUnitAffectedByEffectName('RTEffect_Meld')) {
			//`LOG("!IteratorUnitState.IsUnitAffectedByEffectName('RTEffect_Meld')");
			continue;
		}
		// don't duplicate the effect
		//if(IteratorUnitState.IsUnitAffectedByEffectName(class'RTAbility_GathererAbilitySet'.default.OverTheShoulderSourceEffectName)) {
			//`LOG("IteratorUnitState.IsUnitAffectedByEffectName(class'RTAbility_GathererAbilitySet'.default.OverTheShoulderSourceEffectName)");
			//continue;
		//}
		// hit it
		//`LOG("Triangulation triggering against " @ IteratorUnitState.GetFullName());
		AbilityTriggerAgainstSingleTarget(IteratorUnitState.GetReference(), false);
	}

	return ELR_NoInterrupt;
}

function EventListenerReturn RTAbilityTriggerEventListener_ValidAbilityLocations(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComWorldData World;
	local XComGameStateHistory History;
	local AvailableAction CurrentAvailableAction;
	local AvailableTarget Targets;
	local XComGameState_Unit SourceUnit;
	local TTile ValidTile;
	local vector ValidActiviationLocation;
	local array<vector> TargetLocations;
	local AvailableTarget EmptyTarget;
	local int i;

	History = `XCOMHISTORY;

	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(OwnerStateObject.ObjectID));

	CurrentAvailableAction.AvailableCode = CanActivateAbility(SourceUnit);

	if (CurrentAvailableAction.AvailableCode == 'AA_Success' && ValidActivationTiles.Length > 0)
	{
		World = `XWORLD;
		CurrentAvailableAction.AbilityObjectRef = GetReference();
		i = 0;
		//`LOG("Listing X Coords of ValidTiles");
		foreach ValidActivationTiles(ValidTile) {
			`LOG("" @ ValidTile.X);
			// reset targets each loop
			Targets = EmptyTarget;

			ValidActiviationLocation = World.GetPositionFromTileCoordinates(ValidTile);
			GatherAdditionalAbilityTargetsForLocation(ValidActiviationLocation, Targets);

			// Set up the available action
			CurrentAvailableAction.AvailableTargets.AddItem(Targets);


			// The ValidTile is also the Target location which needs to be passed when activating the ability
			TargetLocations.AddItem(ValidActiviationLocation);
			class'XComGameStateContext_Ability'.static.ActivateAbility(CurrentAvailableAction, i, TargetLocations);
			i++;
		}

	}

	return ELR_NoInterrupt;
}

function EventListenerReturn AbilityTriggerEventListener_Self_CloakingProtocolConcealmentHandler(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData) {
	local XComGameStateHistory History;
	local XComGameState_Unit AbilityOwnerUnit, TargetUnit;
	local int RangeDiff;

	History = `XCOMHISTORY;

	AbilityOwnerUnit = XComGameState_Unit(History.GetGameStateForObjectID(OwnerStateObject.ObjectID));
	TargetUnit = XComGameState_Unit(EventData);

	if(AbilityOwnerUnit.ObjectID == TargetUnit.ObjectID) {
		return ELR_NoInterrupt;
	}

	if(!AbilityOwnerUnit.IsConcealed()) {
		return ELR_NoInterrupt;
	}

	if(!AbilityOwnerUnit.IsUnitAffectedByEffectName(class'RTAbility_ProgramDroneAbilitySet'.default.CloakingProtocolEffectName)) {
		return ELR_NoInterrupt;
	}

	RangeDiff = `TILESTOMETERS(AbilityOwnerUnit.TileDistanceBetween(TargetUnit));

	if(RangeDiff > class'RTAbility_ProgramDroneAbilitySet'.default.CLOAKING_PROTOCOL_RADIUS_METERS) {
		return ELR_NoInterrupt;
	}

	ActivateAbility(OwnerStateObject);

	return ELR_NoInterrupt;
}

// mostly used for debugging
function EventListenerReturn RTAbilityTriggerEventListener_Self(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	`RTLOG("RTAbilityTriggerEventListener_Self");
	`RTLOG(XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(OwnerStateObject.ObjectID)).GetFullName());
	//RTAbilityTriggerAgainstSingleTarget(OwnerStateObject, false);
	ActivateAbility(OwnerStateObject);

	return ELR_NoInterrupt;
}

// ActivateAbility
protected function bool ActivateAbility(StateObjectReference TargetRef) {
	local XComGameStateContext_Ability	AbilityContext;
	local XComGameState					NewGameState;
	local name							AvailableCode;

	AvailableCode = CanActivateAbilityForObserverEvent(XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(TargetRef.ObjectID)));
	if(AvailableCode != 'AA_Success') {
		`RTLOG("Couldn't Activate "@ self.GetMyTemplateName() @ " for observer event, Code = "$ AvailableCode);
		return false;
	} else {
		NewGameState = `CreateChangeState("Activating Ability " $ GetMyTemplateName());
		NewGameState.ModifyStateObject(self.Class, ObjectID);
		`TACTICALRULES.SubmitGameState(NewGameState);
	}

	AbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(self, TargetRef.ObjectID);

	if( AbilityContext.Validate() ) {
		`RTLOG("The AbilityContext was validated, submitting it!");
		if(!`TACTICALRULES.SubmitGameStateContext(AbilityContext)) {
			`RTLOG("The Context failed to be submitted!");
			return false;
		} else {
			`RTLOG("The Context was submitted successfully!");
			return true;
		}
	} else {
		`RTLOG("Rising Tides: Couldn't validate AbilityContext, " @ self.GetMyTemplateName() @ " not activated.");
		return false;
	}
}

function bool RTAbilityTriggerAgainstSingleTarget(StateObjectReference TargetRef, bool bMustHaveAdditionalTargets, optional int VisualizeIndex = -1, optional array<vector> TargetLocations) {
	return RTAbilityTriggerAgainstSingleTarget_Static(ObjectID, OwnerStateObject, TargetRef, bMustHaveAdditionalTargets, VisualizeIndex, TargetLocations);
}

static function bool RTAbilityTriggerAgainstSingleTarget_Static(int AbilityID, StateObjectReference SourceRef, StateObjectReference TargetRef, bool bMustHaveAdditionalTargets, optional int VisualizeIndex = -1, optional array<vector> TargetLocations) {
	local GameRulesCache_Unit UnitCache;
	local int i, j;
	local X2TacticalGameRuleset TacticalRules;
	local AvailableTarget AvailTarget;

	TacticalRules = `TACTICALRULES;
	`log("0");
	if (TacticalRules.GetGameRulesCache_Unit(SourceRef, UnitCache))
	{
		`log("1");
		for (i = 0; i < UnitCache.AvailableActions.Length; ++i)
		{
			`log("2");
			if (UnitCache.AvailableActions[i].AbilityObjectRef.ObjectID == AbilityID)
			{
				`log("3");
				for (j = 0; j < UnitCache.AvailableActions[i].AvailableTargets.Length; ++j)
				{
					`log("4");
					AvailTarget = UnitCache.AvailableActions[i].AvailableTargets[j];
					if (AvailTarget.PrimaryTarget.ObjectID == TargetRef.ObjectID)
					{
						`log("5");
						if (UnitCache.AvailableActions[i].AvailableCode == 'AA_Success')
						{
							`log("6");
							if (bMustHaveAdditionalTargets ? AvailTarget.AdditionalTargets.Length > 0 : true)
							{
								if(class'XComGameStateContext_Ability'.static.ActivateAbility(UnitCache.AvailableActions[i], j, TargetLocations,,,, VisualizeIndex)) {
									`log("7");
								} else `log("8");
								return true;
							}
						}
						break;
					}
				}
				break;
			}
		}
	}
	return false;
}

defaultproperties
{

}
