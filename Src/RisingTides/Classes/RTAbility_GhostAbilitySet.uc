//---------------------------------------------------------------------------------------
//  FILE:    RTAbility_GhostAbilitySet.uc
//  AUTHOR:  Aleosiss
//  DATE:    8 February 2016
//  PURPOSE: Defines abilities used by all Rising Tides classes.
//           
//---------------------------------------------------------------------------------------
//	General Perks
//---------------------------------------------------------------------------------------

class RTAbility_GhostAbilitySet extends X2Ability
	config(RTGhost);

	var config int BASE_REFLECTION_CHANCE, BASE_DEFENSE_INCREASE;
	var config int TEEK_REFLECTION_INCREASE, TEEK_DEFENSE_INCREASE;
	var config int BURST_DAMAGE, BURST_COOLDOWN;
	var config int OVERLOAD_CHARGES, OVERLOAD_BASE_COOLDOWN;
	var config int OVERLOAD_PANIC_CHECK;

//---------------------------------------------------------------------------------------
//---CreateTemplates---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(GhostPsiSuite());
	

	return Templates;
}
//---------------------------------------------------------------------------------------
//---Ghost Psi Suite---------------------------------------------------------------------
//---------------------------------------------------------------------------------------
static function X2AbilityTemplate GhostPsiSuite()
{
	local X2AbilityTemplate						Template;
	local X2Effect_Persistent					Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'GhostPsiSuite');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventpsiwitch_mindcontrol";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Effect = new class 'X2Effect_Persistent';
	Effect.BuildPersistentEffect(1, true, true, true);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(Effect);

	Template.AdditionalAbilities.AddItem('');


	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!
	
	Template.bCrossClassEligible = false;

	return Template;
}
//---------------------------------------------------------------------------------------
//---Reflection--------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
