//---------------------------------------------------------------------------------------
//  FILE:    RTAbility_GathererAbilitySet.uc
//  AUTHOR:  Aleosiss
//  DATE:    18 December 2016
//  PURPOSE: Defines abilities used by Nova.
//           
//---------------------------------------------------------------------------------------
//	Queen's perks.
//---------------------------------------------------------------------------------------

class RTAbility_GathererAbilitySet extends RTAbility_GhostAbilitySet config(RisingTides);

	var config int OTS_RADIUS;

//---------------------------------------------------------------------------------------
//---CreateTemplates---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;


	Templates.AddItem(OverTheShoulder());
	

	return Templates;
}

//---------------------------------------------------------------------------------------
//---Over the Shoulder-------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate OverTheShoulder()
{
	local X2AbilityTemplate						Template;
	local X2AbilityCost_ActionPoints			ActionPoint;
	local X2AbilityCooldown						Cooldown;
	local X2Effect_Persistent					SelfEffect, EnemyEffect, AllyEffect;
	local X2AbilityMultiTarget_Radius			Radius;

	local X2Condition_UnitProperty				AllyCondition, EnemyCondition;


	`CREATE_X2ABILITY_TEMPLATE(Template, 'OverTheShoulder');
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

	EnemyCondition = new class 'X2Condition_UnitProperty';
	EnemyCondition.ExcludeDead = true;
	EnemyCondition.ExcludeRobotic = true;
	EnemyCondition.ExcludeFriendlyToSource = true;

	Radius = new class'X2AbilityMultiTarget_Radius';
	Radius.bUseWeaponRadius = false;
	Radius.bIgnoreBlockingCover = true; 
	Radius.bExcludeSelfAsTargetIfWithinRadius = true; // for now
	Radius.fTargetRadius = 	default.OTS_RADIUS;
	Template.AbilityMultiTargetStyle = Radius;

	EnemyEffect = new class'X2Effect_Persistent';
	EnemyEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);
	EnemyEffect.SetDisplayInfo(ePerkBuff_Penalty, "Over The Shoulder", "Activated!", Template.IconImage, true,,Template.AbilitySourceName);
	EnemyEffect.TargetConditions.AddItem(EnemyCondition);
	Template.AddMultiTargetEffect(EnemyEffect);

	AllyEffect = new class'X2Effect_Persistent';
	AllyEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);
	AllyEffect.SetDisplayInfo(ePerkBuff_Bonus, "Over The Shoulder", "Activated!", Template.IconImage, true,,Template.AbilitySourceName);
	AllyEffect.TargetConditions.AddItem(AllyCondition);
	Template.AddMultiTargetEffect(AllyEffect);

	SelfEffect = new class'X2Effect_Persistent';
	SelfEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);
	SelfEffect.SetDisplayInfo(ePerkBuff_Bonus, "Over The Shoulder", "Activated!", Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddShooterEffect(SelfEffect);
 
	Template.AbilityToHitCalc = default.DeadEye; 
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}