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
	local UnitValue	UnitVal;

	UnitState = XComGameState_Unit(kNewTargetState);
	TimeStopEffectState = RTGameState_TimeStopEffect(NewEffectState);
	TimeStopEffectState.PreventedDamageValues.Length = 0;
	TimeStopEffectState.iShouldRecordCounter = 0;
	bWasPreviouslyImmobilized = false;
	m_aStatChanges.Length = 0;

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
		ExtendCooldownTimers(UnitState, NewGameState);
		ExtendEffectDurations(UnitState, NewGameState);

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

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication, XComGameState_Player Player)
{
	local XComGameState_Unit TimeStoppedUnit;

	TimeStoppedUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if(TimeStoppedUnit != none) {
		TimeStoppedUnit.ActionPoints.Length = 0;
		TimeStoppedUnit.ReserveActionPoints.Length = 0;

		// extend cooldown/effect timers
		ExtendCooldownTimers(TimeStoppedUnit, NewGameState);
		ExtendEffectDurations(TimeStoppedUnit, NewGameState);
	}
	return super.OnEffectTicked(ApplyEffectParameters, kNewEffectState, NewGameState, FirstApplication, Player);
}

simulated function ExtendCooldownTimers(XComGameState_Unit TimeStoppedUnit, XComGameState NewGameState) {
	local XComGameState_Ability AbilityState, NewAbilityState;
	local int i;

	for(i = 0; i < TimeStoppedUnit.Abilities.Length; i++) {
		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(TimeStoppedUnit.Abilities[i].ObjectID));
		if(AbilityState.IsCoolingDown()) {
			NewAbilityState = XComGameState_Ability(NewGameState.CreateStateObject(AbilityState.class, AbilityState.ObjectID));
			NewGameState.AddStateObject(NewAbilityState);
			NewAbilityState.iCooldown += 1; // need to add to config
		}
	}
}

simulated function ExtendEffectDurations(XComGameState_Unit TimeStoppedUnit, XComGameState NewGameState) {
	local XComGameState_Effect EffectState, NewEffectState;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Effect', EffectState) {
		if(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID == TimeStoppedUnit.ObjectID) {
			if(!EffectState.GetX2Effect().bInfiniteDuration) {
				NewEffectState = XComGameState_Effect(NewGameState.CreateStateObject(EffectState.class, EffectState.ObjectID));
				NewGameState.AddStateObject(NewEffectState);
				NewEffectState.iTurnsRemaining += 1;
				// need to somehow prevent these effects from doing damage/ticking while active... no idea how atm.
			}
		}
	}
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState) {
	local XComGameState_Unit UnitState;

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



function int GetDefendingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, 
							const out EffectAppliedData AppliedData, const int CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect, optional XComGameState NewGameState) {
	local int i;
	local RTGameState_TimeStopEffect TimeStopEffectState;
	local WeaponDamageValue TotalWeaponDamageValue;
	local RTEffect_TimeStopDamage TimeStopDamageEffect;

	if(CurrentDamage < 1)
		return 0;
	class'RTHelpers'.static.RTLog("Current Damage greater than 0, proceeding...");
	// You can't take damage during a time-stop. Negate and store the damage for when it ends.
	// Let the damage from the Time Stop pass through
	if(WeaponDamageEffect.DamageTag == 'TimeStopDamageEffect' || WeaponDamageEffect.IsA('RTEffect_TimeStopDamage')){
		class'RTHelpers'.static.RTLog("allowing TimeStopDamageEffect!");
		return 0;

	}
	// first check wasn't working...?
	TimeStopDamageEffect = RTEffect_TimeStopDamage(WeaponDamageEffect);
	if(TimeStopDamageEffect != none) {
		class'RTHelpers'.static.RTLog("TimeStopDamageEffect found, allowing");
		return 0;
	}


	TimeStopEffectState = RTGameState_TimeStopEffect(EffectState);
	if(TimeStopEffectState == none) {
		class'RTHelpers'.static.RTLog("TimeStopEffectState not found!");
		return 0;
	}


	// damage over time effects are totally negated
	// hack
	if(WeaponDamageEffect.EffectDamageValue.DamageType == 'fire' || WeaponDamageEffect.EffectDamageValue.DamageType == 'poison' || WeaponDamageEffect.EffectDamageValue.DamageType == 'acid' || WeaponDamageEffect.EffectDamageValue.DamageType == class'X2Item_DefaultDamageTypes'.default.ParthenogenicPoisonType)
		return -(CurrentDamage);

	// record WeaponDamageValues
	if(TimeStopEffectState.bShouldRecordDamageValue){
		class'RTHelpers'.static.RTLog("Recording Weapon Damage Value");

		TotalWeaponDamageValue = SetTotalWeaponDamageValue(CurrentDamage, WeaponDamageEffect.EffectDamageValue);
		TimeStopEffectState.PreventedDamageValues.AddItem(TotalWeaponDamageValue);

		class'RTHelpers'.static.RTLog("Logging,");
		`LOG("PreventedDamageValues.Length = " @ TimeStopEffectState.PreventedDamageValues.Length);
		for(i = 0; i < TimeStopEffectState.PreventedDamageValues.Length; i++) {
			`LOG("TimeStopEffectState.PreventedDamageValues["@i@"].DamageType = " @ TimeStopEffectState.PreventedDamageValues[i].DamageType);
		}
		class'RTHelpers'.static.RTLog("Time Stop has negated " @ TimeStopEffectState.GetFinalDamageValue().Damage @ " damage so far! This time, it was of type " @ TimeStopEffectState.PreventedDamageValues[TimeStopEffectState.PreventedDamageValues.length-1].DamageType @"!");

		// record crit //TODO: figure out how to force crit damage popup
		if(AppliedData.AbilityResultContext.HitResult == eHit_Crit)
			TimeStopEffectState.bCrit = true;
		TimeStopEffectState.bShouldRecordDamageValue = false;
	} else {
		class'RTHelpers'.static.RTLog("TimeStopEffectState.GetDefendingDamageModifier was told not to record a damage value.");
		return 0;
	}
	return -(CurrentDamage);
}

simulated function WeaponDamageValue SetTotalWeaponDamageValue(int CurrentDamage, WeaponDamageValue WeaponDamageValue) {
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

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, name EffectApplyResult)
{
	local RTAction_Greyscaled TimeStopAction;

	if (ActionMetadata.StateObject_NewState != none)
	{
		TimeStopAction = RTAction_Greyscaled(class'RTAction_Greyscaled'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		TimeStopAction.PlayIdle = true;
	}
}

simulated function AddX2ActionsForVisualization_Sync( XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata )
{
	local RTAction_Greyscaled TimeStopAction;

	super.AddX2ActionsForVisualization_Sync(VisualizeGameState, ActionMetadata);
	if (XComGameState_Unit(ActionMetadata.StateObject_NewState) != none)
	{
		TimeStopAction = RTAction_Greyscaled(class'RTAction_Greyscaled'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		TimeStopAction.PlayIdle = true;
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

simulated function ModifyTracksVisualization(XComGameState VisualizeGameState, out out VisualizationActionMetadata ModifyActionMetadata, const name EffectApplyResult)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(ModifyActionMetadata.StateObject_NewState);
	if( UnitState != none && EffectApplyResult == 'AA_Success' )
	{
		//  Make the TimeStop happen immediately after the wait, rather than waiting until after the apply damage action
		class'RTAction_Greyscaled'.static.AddToVisualizationTree(ModifyActionMetadata, VisualizeGameState.GetContext(), false, ModifyActionMetadata.LastActionAdded);
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ModifyActionMetadata, VisualizeGameState.GetContext(), GetFlyoverTickText(UnitState), '', eColor_Bad, default.StatusIcon);
		class'X2StatusEffects'.static.AddEffectMessageToTrack(ModifyActionMetadata,
															  default.TimeStopEffectAddedString,
															  VisualizeGameState.GetContext(),
															  class'UIEventNoticesTactical'.default.FrozenTitle,
															  default.StatusIcon,
															  eUIState_Bad);
		class'X2StatusEffects'.static.UpdateUnitFlag(ModifyActionMetadata, VisualizeGameState.GetContext());
	}
}

static function TimeStopVisualizationTicked(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local XComGameState_Unit UnitState;
	local array<StateObjectReference> OutEnemyViewers;

	UnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);
	class'X2TacticalVisibilityHelpers'.static.GetEnemyViewersOfTarget(UnitState.ObjectID, OutEnemyViewers);
	if (UnitState != none)
	{
		if(OutEnemyViewers.Length != 0) {
			//class'X2StatusEffects'.static.AddEffectCameraPanToAffectedUnitToTrack(BuildTrack, VisualizeGameState.GetContext());
			//class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(BuildTrack, VisualizeGameState.GetContext(), GetFlyoverTickText(UnitState), '', eColor_Bad, default.StatusIcon);
			class'X2StatusEffects'.static.AddEffectMessageToTrack(ActionMetadata,
															  default.TimeStopEffectPersistsString,
															  VisualizeGameState.GetContext(),
															  class'UIEventNoticesTactical'.default.FrozenTitle,
															  default.StatusIcon,
															  eUIState_Warning);

		}
		class'X2StatusEffects'.static.UpdateUnitFlag(ActionMetadata, VisualizeGameState.GetContext());
	}
}

simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
	local XComGameState_Unit UnitState;
	local GameRulesCache_VisibilityInfo VisInfo;
	local bool bVisible;
	local string FlyoverText;
	local XComGameStateVisualizationMgr VisMgr;
	local X2Action_SKULLJACK FromSkullJack;

	super.AddX2ActionsForVisualization_Removed(VisualizeGameState, ActionMetadata, EffectApplyResult, RemovedEffect);
	VisMgr = `XCOMVISUALIZATIONMGR;

	bVisible = true;
	UnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);
	`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(RemovedEffect.ApplyEffectParameters.SourceStateObjectRef.ObjectID, UnitState.ObjectID, VisInfo);
	if (!VisInfo.bVisibleGameplay)
		bVisible = false;
	
	if (UnitState != none)
	{
		FromSkullJack = X2Action_SKULLJACK(VisMgr.GetNodeOfType(VisMgr.BuildVisTree, class'X2Action_SkullJack'));
		if( FromSkullJack != None )
		{
			class'RTAction_GreyscaledEnd'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), true, , FromSkullJack.ParentActions);
		}
		else
		{
			class'RTAction_GreyscaledEnd'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded);
		}

		if (bVisible)
		{
			FlyoverText = ShouldTimeStopAsLargeUnit(UnitState) ? default.LargeUnitTimeStopLostFlyover : default.TimeStopLostFlyover;
			//class'X2StatusEffects'.static.AddEffectCameraPanToAffectedUnitToTrack(BuildTrack, VisualizeGameState.GetContext());
			class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ActionMetadata, VisualizeGameState.GetContext(), FlyoverText, '', eColor_Good, default.StatusIcon);
			//class'X2StatusEffects'.static.AddEffectMessageToTrack(BuildTrack, default.TimeStopEffectRemovedString, VisualizeGameState.GetContext());
			class'X2StatusEffects'.static.AddEffectMessageToTrack(ActionMetadata,
																  FlyoverText,
																  VisualizeGameState.GetContext(),
																  class'UIEventNoticesTactical'.default.FrozenTitle,
																  default.StatusIcon,
																  eUIState_Good);

		}
		class'X2StatusEffects'.static.UpdateUnitFlag(ActionMetadata, VisualizeGameState.GetContext());

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
