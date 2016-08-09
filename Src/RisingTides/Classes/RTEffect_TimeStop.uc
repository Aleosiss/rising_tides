// This is an Unreal Script



class RTEffect_TimeStop extends X2Effect_PersistentStatChange;

var localized string	TimeStopName, TimeStopDesc, RulerTimeStopTickFlyover, TimeStopEffectAddedString, TimeStopEffectPersistsString, TimeStopEffectRemovedString, TimeStopLostFlyover, LargeUnitTimeStopLostFlyover;
var localized string	RTFriendlyNameAim;
var localized string	RTFriendlyNameCrit;

var bool bWasPreviouslyImmobilized;
var bool bAllowReorder;
var int PreviousStunDuration;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit UnitState;
	local RTGameState_TimeStopEffect TimeStopEffectState;
	local X2EventManager EventManager;
	local UnitValue	UnitVal;
	local bool IsOurTurn;

	UnitState = XComGameState_Unit(kNewTargetState);
	TimeStopEffectState = RTGameState_TimeStopEffect(NewEffectState);
	TimeStopEffectState.PreventedDamageValues.Length = 0;
	bWasPreviouslyImmobilized = false;

	if(UnitState != none)
	{
		// remove all action points... ZA WARUDO, TOKI YO, TOMARE! 
		UnitState.ReserveActionPoints.Length = 0;
		UnitState.ActionPoints.Length = 0;

		if( UnitState.IsTurret() ) // Stunned Turret.   Update turret state.
		{
			UnitState.UpdateTurretState(false);
		}

		// Immobilize to prevent scamper or panic from enabling this unit to move again.
		// Instead of just setting it to one, we're going to check and extend any immobilize already present (because TIME IS STOPPED)
		if(UnitState.GetUnitValue(class'X2Ability_DefaultAbilitySet'.default.ImmobilizedValueName, UnitVal)) {
			if(UnitVal.fValue > 0) {
				bWasPreviouslyImmobilized = true;
			}
		}
		else {
			UnitState.SetUnitFloatValue(class'X2Ability_DefaultAbilitySet'.default.ImmobilizedValueName, 1);
		}

		// TODO: Catch and delay the duration/effects of other effects
		PreviousStunDuration = UnitState.StunnedActionPoints;
		ExtendCooldownTimers(UnitState);
		ExtendEffectDurations(UnitState);
		
	}																			
	
	// You can't see any changes to the world while time is stopped, and you can't move either... don't know why the immo tag isn't working
	AddPersistentStatChange(eStat_SightRadius, 0, MODOP_PostMultiplication);
	AddPersistentStatChange(eStat_Mobility, 0, MODOP_PostMultiplication);
	AddPersistentStatChange(eStat_Dodge, 0, MODOP_PostMultiplication);

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfoAim, ModInfoCrit;

	ModInfoAim.ModType = eHit_Success;
	ModInfoAim.Reason = TimeStopName;
	ModInfoAim.Value = 100;
	ShotModifiers.AddItem(ModInfoAim);

	ModInfoCrit.ModType = eHit_Crit;
	ModInfoCrit.Reason = TimeStopName;
	ModInfoCrit.Value = 100;
	ShotModifiers.AddItem(ModInfoCrit);							   					  
}

function ModifyTurnStartActionPoints(XComGameState_Unit UnitState, out array<name> ActionPoints, XComGameState_Effect EffectState)
{
	ActionPoints.Length = 0;
}

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
	local XComGameState_Unit	TimeStopperUnit, TimeStoppedUnit;
	local UnitValue				UnitVal;


	TimeStopperUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	TimeStoppedUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if(TimeStoppedUnit != none) {
	TimeStoppedUnit.ActionPoints.Length = 0;
	TimeStoppedUnit.ReserveActionPoints.Length = 0;
	
	// extend cooldown/effect timers
	ExtendCooldownTimers(TimeStoppedUnit); 
	ExtendEffectDurations(TimeStoppedUnit);
	}
	return super.OnEffectTicked(ApplyEffectParameters, kNewEffectState, NewGameState, FirstApplication);
}

simulated function ExtendCooldownTimers(XComGameState_Unit TimeStoppedUnit) {
	local XComGameState_Ability AbilityState;
	local int i;
	
	for(i = 0; i < TimeStoppedUnit.Abilities.Length; i++) {
		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(TimeStoppedUnit.Abilities[i].ObjectID));
		if(AbilityState.IsCoolingDown()) {
			AbilityState.iCooldown += 1; // need to add to config	
		}
	}
}

simulated function ExtendEffectDurations(XComGameState_Unit TimeStoppedUnit) {
	local XComGameState_Effect EffectState;
	local int i;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Effect', EffectState) {
		if(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID == TimeStoppedUnit.ObjectID) {
			if(!EffectState.GetX2Effect().bInfiniteDuration) {
			EffectState.iTurnsRemaining += 1;			   
			// need to somehow prevent these effects from doing damage/ticking while active... no idea how atm.
			}
		}
	}
}											 						

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local RTGameState_TimeStopEffect TimeStopEffectState;
	local X2Effect_ApplyWeaponDamage	DamageEffect;
	local XComGameState_Unit UnitState;
	local UnitValue UnitVal;

	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if( UnitState != none)
	{
		UnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));

		if(UnitState.IsTurret())
		{
			UnitState.UpdateTurretState(false);
		}

		// Update immobility status
		if(!bWasPreviouslyImmobilized) {
			UnitState.ClearUnitValue(class'X2Ability_DefaultAbilitySet'.default.ImmobilizedValueName);
		} 

		// Reset stun timer, (if you're stunned while/before time is stopped, the duration should be unchanged)
		UnitState.StunnedActionPoints = PreviousStunDuration;
		
		//// And thus, time resumes...
		//TimeStopEffectState = RTGameState_TimeStopEffect(RemovedEffectState);


		//UnitState.TakeDamage(NewGameState, TimeStopEffectState.GetFinalDamageValue().Damage, 0, 0, , TimeStopEffectState, TimeStopEffectState.ApplyEffectParameters.SourceStateObjectRef, TimeStopEffectState.bExplosive);
		
		NewGameState.AddStateObject(UnitState);
	}

	

}

function bool TimeStopTicked(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
	/*
	local XComGameState_Unit UnitState;
	
	UnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if (UnitState == none)
		UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	if (UnitState != none)
	{
		//The unit remains stunned if they still have more action points to spend being stunned.
		//The unit also remains "stunned" through one more turn, if the turn's action points have been consumed entirely by the stun.
		//In the latter case, the effect will be removed at the beginning of the next turn, just before the unit is able to act.
		//(This prevents one-turn stuns from looking like they "did nothing", when in fact they consumed exactly one turn of actions.)
		//-btopp 2015-09-21

		if(IsTickEveryAction(UnitState))
		{
			UnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
			UnitState.StunnedActionPoints--;

			if(UnitState.StunnedActionPoints == 0)
			{
				// give them an action point back so they can move immediately
				UnitState.StunnedThisTurn = 0;
				UnitState.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
			}
			NewGameState.AddStateObject(UnitState);
		}

		if (UnitState.StunnedActionPoints > 0) 
		{
			return false;
		}
		else if (UnitState.StunnedActionPoints == 0 
			&& UnitState.NumAllActionPoints() == 0 
			&& !UnitState.GetMyTemplate().bCanTickEffectsEveryAction) // allow the stun to complete anytime if it is ticking per-action
		{
			return false;
		}
	}

	*/
	return false;

	
}

function int GetDefendingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect) { 
	local int DamageTaken, i;
	local RTGameState_TimeStopEffect TimeStopEffectState;
	local WeaponDamageValue TotalWeaponDamageValue, IteratorDamageValue;
	local RTEffect_TimeStopDamage TimeStopDamageEffect;

	if(CurrentDamage < 1)
		return 0;
	`LOG("Rising Tides: Current Damage greater than 0, proceeding...");
	// You can't take damage during a time-stop. Negate and store the damage for when it ends. 
	// Let the damage from the Time Stop pass through
	if(WeaponDamageEffect.DamageTag == 'TimeStopDamageEffect' || WeaponDamageEffect.IsA('RTEffect_TimeStopDamage')){
		`LOG("Rising Tides: allowing TimeStopDamageEffect!");
		return 0;
		
	}
	// first check wasn't working...?
	TimeStopDamageEffect = RTEffect_TimeStopDamage(WeaponDamageEffect);
	if(TimeStopDamageEffect != none) {
		`LOG("Rising Tides: TimeStopDamageEffect found, allowing");
		return 0;
	}
	

	TimeStopEffectState = RTGameState_TimeStopEffect(EffectState);
	if(TimeStopEffectState == none) {
		`LOG("Rising Tides: TimeStopEffectState not found?!!?!?!");
		return 0;
	}
	

	// damage over time effects are totally negated
	// hack 
	if(WeaponDamageEffect.EffectDamageValue.DamageType == 'fire' || WeaponDamageEffect.EffectDamageValue.DamageType == 'poison' || WeaponDamageEffect.EffectDamageValue.DamageType == 'acid' || WeaponDamageEffect.EffectDamageValue.DamageType == class'X2Item_DefaultDamageTypes'.default.ParthenogenicPoisonType)
		return -(CurrentDamage);
	
	// record WeaponDamageValues
	`LOG("Recording Weapon Damage Value");

	TotalWeaponDamageValue = SetTotalWeaponDamageValue(CurrentDamage, WeaponDamageValue);
	TimeStopEffectState.PreventedDamageValues.AddItem(TotalWeaponDamageValue);

	`LOG("Logging,"); 
	`LOG("PreventedDamageValues.Length = " @ TimeStopEffectState.PreventedDamageValues.Length);
	for(i = 0; i < TimeStopEffectState.PreventedDamageValues.Length; i++) {
		`LOG("TimeStopEffectState.PreventedDamageValues["@i@"].DamageType = " @ TimeStopEffectState.PreventedDamageValues[i].DamageType);
	}
	`LOG("Rising Tides: Time Stop has negated " @ TimeStopEffectState.GetFinalDamageValue().Damage @ " damage so far! This time, it was of type " @ TimeStopEffectState.PreventedDamageValues[TimeStopEffectState.PreventedDamageValues.length-1].DamageType @"!");
	
	// record crit //TODO: figure out how to force crit damage popup
	if(AppliedData.AbilityResultContext.HitResult == eHit_Crit)
		TimeStopEffectState.bCrit = true;
	
	return -(CurrentDamage); 
}

simulated function SetTotalWeaponDamageValue(int CurrentDamage, WeaponDamageValue WeaponDamageValue) {
	local WeaponDamageValue TotalWeaponDamageValue;

	TotalWeaponDamageValue.Damage = CurrentDamage + WeaponDamageValue.Damage;
	TotalWeaponDamageValue.Spread = 0;
	TotalWeaponDamageValue.PlusOne = 0;
	TotalWeaponDamageValue.Crit = 0;
	TotalWeaponDamageValue.Pierce =  WeaponDamageValue.Pierce;
	TotalWeaponDamageValue.Rupture = WeaponDamageValue.Rupture;
	TotalWeaponDamageValue.Shred = WeaponDamageValue.Shred;
	TotalWeaponDamageValue.Tag = WeaponDamageValue.Tag;
	TotalWeaponDamageValue.DamageType = WeaponDamageValue.DamageType;

	return TotalWeaponDamageValue;

}

static function bool ShouldTimeStopAsLargeUnit(XComGameState_Unit TargetUnit)
{
	return (TargetUnit.GetMyTemplate().UnitSize > 1 || TargetUnit.GetMyTemplateName() == 'Avatar') && !class'RTHelpers'.static.IsUnitAlienRuler(TargetUnit);
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, name EffectApplyResult)
{
	local RTAction_Greyscaled TimeStopAction;

	if (BuildTrack.StateObject_NewState != none)
	{
		TimeStopAction = RTAction_Greyscaled(class'RTAction_Greyscaled'.static.CreateVisualizationAction(VisualizeGameState.GetContext(), BuildTrack.TrackActor));
		TimeStopAction.PlayIdle = true;
		BuildTrack.TrackActions.AddItem(TimeStopAction);
	}
}


simulated function AddX2ActionsForVisualization_Sync( XComGameState VisualizeGameState, out VisualizationTrack BuildTrack )
{
	local RTAction_Greyscaled TimeStopAction;

	super.AddX2ActionsForVisualization_Sync(VisualizeGameState, BuildTrack);
	if (XComGameState_Unit(BuildTrack.StateObject_NewState) != none)
	{
		TimeStopAction = RTAction_Greyscaled(class'RTAction_Greyscaled'.static.CreateVisualizationAction(VisualizeGameState.GetContext(), BuildTrack.TrackActor));
		TimeStopAction.PlayIdle = true;
		BuildTrack.TrackActions.AddItem(TimeStopAction);
	}
}

// rulers show a different flyover from other units, so this function splits that out
static protected function string GetFlyoverTickText(XComGameState_Unit UnitState)
{
	local XComGameState_Effect EffectState;
	local X2AbilityTag AbilityTag;

	EffectState = UnitState.GetUnitAffectedByEffectState(default.EffectName);
	if(class'RTHelpers'.static.IsUnitAlienRuler(UnitState))
	{
		EffectState = UnitState.GetUnitAffectedByEffectState(default.EffectName);
		AbilityTag = X2AbilityTag(XComEngine(class'Engine'.static.GetEngine()).LocalizeContext.FindTag("Ability"));
		AbilityTag.ParseObj = EffectState;
		return class'XComLocalizer'.static.ExpandString(default.RulerTimeStopTickFlyover);
	}
	else
	{
		return default.TimeStopName;
	}
}

simulated function ModifyTracksVisualization(XComGameState VisualizeGameState, out VisualizationTrack ModifyTrack, const name EffectApplyResult)
{
	local int ActionIndex;
	local int PlacementIndex;
	local VisualizationTrack TimeStopTrack;
	local XComGameState_Unit UnitState;

	PlacementIndex = -1;

	UnitState = XComGameState_Unit(ModifyTrack.StateObject_NewState);
	if( UnitState != none && EffectApplyResult == 'AA_Success' )
	{
		//  Make the TimeStop happen immediately after the wait, rather than waiting until after the apply damage action
		class'RTAction_Greyscaled'.static.AddToVisualizationTrack(TimeStopTrack, VisualizeGameState.GetContext());
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(TimeStopTrack, VisualizeGameState.GetContext(), GetFlyoverTickText(UnitState), '', eColor_Bad, default.StatusIcon);
		class'X2StatusEffects'.static.AddEffectMessageToTrack(TimeStopTrack, default.TimeStopEffectAddedString, VisualizeGameState.GetContext());
		class'X2StatusEffects'.static.UpdateUnitFlag(TimeStopTrack, VisualizeGameState.GetContext());
	}

	for( ActionIndex = 0; ActionIndex < ModifyTrack.TrackActions.Length; ++ActionIndex )
	{
		// If we have a persistent effect, make sure we add to the end.
		if( ModifyTrack.TrackActions[ActionIndex].IsA('X2Action_PersistentEffect') )
		{
			PlacementIndex = ModifyTrack.TrackActions.Length;
		}

		// Otherwise if we find a wait for ability effect, immediately follow it.
		if( bAllowReorder && PlacementIndex == -1 && ModifyTrack.TrackActions[ActionIndex].IsA('X2Action_WaitForAbilityEffect') )
		{
			PlacementIndex = ActionIndex + 1;
		}
	}

	if( PlacementIndex == -1 )
	{
		PlacementIndex = ModifyTrack.TrackActions.Length;
	}
	
	// Put the TimeStop visualization in the right spot
	if( TimeStopTrack.TrackActions.Length != 0 )
	{
		ModifyTrack.TrackActions.Insert(PlacementIndex, TimeStopTrack.TrackActions.Length);
		for( ActionIndex = 0; ActionIndex < TimeStopTrack.TrackActions.Length; ++ActionIndex )
		{
			ModifyTrack.TrackActions[PlacementIndex + ActionIndex] = TimeStopTrack.TrackActions[ActionIndex];
		}
	}
}

static function TimeStopVisualizationTicked(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	local XComGameState_Unit UnitState;
	local array<StateObjectReference> OutEnemyViewers;
	local bool bVisible;

	UnitState = XComGameState_Unit(BuildTrack.StateObject_NewState);
	class'X2TacticalVisibilityHelpers'.static.GetEnemyViewersOfTarget(UnitState.ObjectID, OutEnemyViewers);
	if (UnitState != none)
	{
		if(OutEnemyViewers.Length != 0) {
			//class'X2StatusEffects'.static.AddEffectCameraPanToAffectedUnitToTrack(BuildTrack, VisualizeGameState.GetContext());
			//class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(BuildTrack, VisualizeGameState.GetContext(), GetFlyoverTickText(UnitState), '', eColor_Bad, default.StatusIcon);
			class'X2StatusEffects'.static.AddEffectMessageToTrack(BuildTrack, default.TimeStopEffectPersistsString, VisualizeGameState.GetContext());
		}
		class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
	}
}

simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
	local XComGameState_Unit UnitState;
	local X2Action_ApplyWeaponDamageToUnit DamageAction;
	local XComGameStateContext_Ability  Context;
	local GameRulesCache_VisibilityInfo VisInfo;
	local bool bVisible;
	local string FlyoverText;

	super.AddX2ActionsForVisualization_Removed(VisualizeGameState, BuildTrack, EffectApplyResult, RemovedEffect);
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());


	bVisible = true;
	UnitState = XComGameState_Unit(BuildTrack.StateObject_NewState);
	`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(RemovedEffect.ApplyEffectParameters.SourceStateObjectRef.ObjectID, UnitState.ObjectID, VisInfo);
	if (!VisInfo.bVisibleGameplay)
		bVisible = false;


	if (UnitState != none)
	{
		class'RTAction_GreyscaledEnd'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext());
		if (bVisible)
		{
			FlyoverText = ShouldTimeStopAsLargeUnit(UnitState) ? default.LargeUnitTimeStopLostFlyover : default.TimeStopLostFlyover;
			class'X2StatusEffects'.static.AddEffectCameraPanToAffectedUnitToTrack(BuildTrack, VisualizeGameState.GetContext());
			class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(BuildTrack, VisualizeGameState.GetContext(), FlyoverText, '', eColor_Good, default.StatusIcon);
			class'X2StatusEffects'.static.AddEffectMessageToTrack(BuildTrack, default.TimeStopEffectRemovedString, VisualizeGameState.GetContext());
			
			
		}
		class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());

	}
}

defaultproperties
{
	bIsImpairing=false
	EffectName="Freeze"
	EffectTickedFn=TimeStopTicked
	EffectTickedVisualizationFn=TimeStopVisualizationTicked
	ModifyTracksFn=ModifyTracksVisualization
	bAllowReorder=true

	GameStateEffectClass = class'RTGameState_TimeStopEffect'
}
