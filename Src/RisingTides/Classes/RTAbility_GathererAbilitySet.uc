//---------------------------------------------------------------------------------------
//  FILE:    RTAbility_GathererAbilitySet.uc
//  AUTHOR:  Aleosiss
//  DATE:    18 December 2016
//  PURPOSE: Defines abilities used by Nova.
//
//---------------------------------------------------------------------------------------
//	Nova's perks.
//---------------------------------------------------------------------------------------

class RTAbility_GathererAbilitySet extends RTAbility_GhostAbilitySet config(RisingTides);


	var config name OverTheShoulderEffectName;

	var config float   OTS_RADIUS;
	var config float OTS_RADIUS_SQ;

//---------------------------------------------------------------------------------------
//---CreateTemplates---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;


	Templates.AddItem(OverTheShoulder());


	return Templates;
}

// TODO:
// OTS needs to update whenever a unit moves
// OTS needs to update its cleanse effect whenever a unit moves


//---------------------------------------------------------------------------------------
//---Over the Shoulder-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate OverTheShoulder()
{
	local X2AbilityTemplate						Template;
	local X2AbilityCost_ActionPoints			ActionPoint;
	local X2AbilityCooldown						Cooldown;
	local X2AbilityMultiTarget_Radius			Radius;
	local X2Condition_UnitProperty				AllyCondition, LivingNonAllyUnitOnlyProperty;
	

	local RTEffect_OverTheShoulder				OTSEffect;      // I'm unsure of how this works... but it appears that
																// this will control the application and removal of aura effects within its range

	// Aura effects
	local RTEffect_MobileSquadViewer			VisionEffect;
	local X2Effect_ScanningProtocol				ScanningEffect;

	local X2Effect_Persistent					SelfEffect, EnemyEffect, AllyEffect;




	`CREATE_X2TEMPLATE(class'RTAbilityTemplate', Template, 'OverTheShoulder');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_swordSlash";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;

	ActionPoint = new class'X2AbilityCost_ActionPoints';
	ActionPoint.iNumPoints = 1;
	ActionPoint.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPoint);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 1;
	Template.AbilityCooldown = Cooldown;

	AllyCondition = new class 'X2Condition_UnitProperty';
	AllyCondition.ExcludeDead = true;
	AllyCondition.ExcludeCivilian = true;
	AllyCondition.ExcludeRobotic = true;
	AllyCondition.ExcludeHostileToSource = true;
	AllyCondition.ExcludeFriendlyToSource = false;
	AllyCondition.FailOnNonUnits = true;

	LivingNonAllyUnitOnlyProperty = new class 'X2Condition_UnitProperty';
	LivingNonAllyUnitOnlyProperty.ExcludeAlive = false;
	LivingNonAllyUnitOnlyProperty.ExcludeDead = true;
	LivingNonAllyUnitOnlyProperty.ExcludeFriendlyToSource = true;
	LivingNonAllyUnitOnlyProperty.ExcludeHostileToSource = false;
	LivingNonAllyUnitOnlyProperty.TreatMindControlledSquadmateAsHostile = true;
	LivingNonAllyUnitOnlyProperty.FailOnNonUnits = true;
	LivingNonAllyUnitOnlyProperty.ExcludeCivilian = false;

	Radius = new class'X2AbilityMultiTarget_Radius';
	Radius.bUseWeaponRadius = false;
	Radius.bIgnoreBlockingCover = true;
	Radius.bExcludeSelfAsTargetIfWithinRadius = true; // for now
	Radius.fTargetRadius = 	default.OTS_RADIUS * class'XComWorldData'.const.WORLD_StepSize * class'XComWorldData'.const.WORLD_UNITS_TO_METERS_MULTIPLIER;
	Template.AbilityMultiTargetStyle = Radius;
	Template.AbilityMultiTargetConditions.Additem(default.LivingTargetUnitOnlyProperty);

	// begin non-ally aura effects	---------------------------------------

	VisionEffect = new class'RTEffect_MobileSquadViewer';
	VisionEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	VisionEffect.SetDisplayInfo(ePerkBuff_Penalty, "Over The Shoulder", "I see you... see me.", Template.IconImage, true,,Template.AbilitySourceName);
	VisionEffect.TargetConditions.AddItem(LivingNonAllyUnitOnlyProperty);
	VisionEffect.DuplicateResponse = eDupe_Ignore;
	VisionEffect.bUseTargetSightRadius = false;
	VisionEffect.iCustomTileRadius = 3;
	Template.AddMultiTargetEffect(VisionEffect);

	ScanningEffect = new class'X2Effect_ScanningProtocol';
	ScanningEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	ScanningEffect.SetDisplayInfo(ePerkBuff_Penalty, "DEBUG", "DEBUG X2EFFECT_SCANNINGPROTOCOL", Template.IconImage, true,,Template.AbilitySourceName);
	ScanningEffect.TargetConditions.AddItem(LivingNonAllyUnitOnlyProperty);
	ScanningEffect.DuplicateResponse = eDupe_Ignore;
	Template.AddMultiTargetEffect(ScanningEffect);

	// end non-ally aura effects  -----------------------------------------

	// begin ally aura effects	  -----------------------------------------

	AllyEffect = new class'X2Effect_Persistent';
	AllyEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);
	AllyEffect.SetDisplayInfo(ePerkBuff_Bonus,"Over the Shoulder", "I'll keep an eye out for you!", Template.IconImage, true,,Template.AbilitySourceName);
	AllyEffect.TargetConditions.AddItem(default.LivingShooterProperty);
	AllyEffect.DuplicateResponse = eDupe_Ignore;
	Template.AddMultiTargetEffect(AllyEffect);

	// end ally aura effects	  ------------------------------------------

	OTSEffect = new class'RTEffect_OverTheShoulder';
	OTSEffect.BuildPersistentEffect(1,,,, eGameRule_PlayerTurnBegin);
	OTSEffect.SetDisplayInfo(ePerkBuff_Bonus, "Over The Shoulder", "I peer back.", Template.IconImage, true,,Template.AbilitySourceName);
	OTSEffect.DuplicateResponse = eDupe_Ignore;
	Template.AddShooterEffect(OTSEffect);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;

	return Template;
}

//---------------------------------------------------------------------------------------
//---Unsettling Voices-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate RTUnsettlingVoices() {
	local X2AbilityTemplate                     Template;
	local X2AbilityTrigger_EventListener        EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTUnsettlingVoices');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_solace";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitMoveFinished';
	EventListener.ListenerData.Filter = eFilter_None;
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.SolaceCleanseListener;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;

}
