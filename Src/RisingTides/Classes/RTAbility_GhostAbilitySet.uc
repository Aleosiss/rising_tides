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

