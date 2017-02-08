// This is an Unreal Script

class RTHelpers extends Object config(RisingTides);

// todo...
var config array<name> MeleeAbilities, SniperShots, OverwatchShots, PsionicAbilities;

enum ERTChecklist {
	eChecklist_DefaultAbilities,
	eChecklist_SniperShots,
	eChecklist_OverwatchShots,
	eChecklist_PsionicAbilities,
	eChecklist_MeleeAbilities
};


// copied here from X2Helpers_DLC_Day60.uc 
static function bool IsUnitAlienRuler(XComGameState_Unit UnitState)
{
	return UnitState.IsUnitAffectedByEffectName('AlienRulerPassive');
}



// where the fuck is the array? hello?
static function bool CheckAbilityActivated(name AbilityTemplateName, ERTChecklist Checklist) {

	switch(Checklist) {
		case eChecklist_MeleeAbilities:
					if( AbilityTemplateName != 'RTBerserkerKnifeAttack' &&
						AbilityTemplateName != 'RTPyroclasticSlash' &&
						AbilityTemplateName != 'RTReprobateWaltz')
					{ return false; }
					break;
		case eChecklist_SniperShots: 
					if( AbilityTemplateName != 'RTStandardSniperShot' && 
						AbilityTemplateName != 'DaybreakFlame' && 
						AbilityTemplateName != 'RTOverwatchShot' &&
						AbilityTemplateName != 'RTPrecisionShot' && 
						AbilityTemplateName != 'RTDisablingShot' &&  
						AbilityTemplateName != 'KillZoneShot') 
					{ return false; }
					break;
		case eChecklist_OverwatchShots: 
					if( AbilityTemplateName != 'RTOverwatchShot' && 
						AbilityTemplateName != 'KillZoneShot' && 
						AbilityTemplateName != 'OverwatchShot' && 
						AbilityTemplateName != 'CloseCombatSpecialistAttack')
					{ return false; }
					break;
		case eChecklist_PsionicAbilities:
					if( AbilityTemplateName != 'PsiOverload' &&
						AbilityTemplateName != 'RTBurst' && 
						AbilityTemplateName != 'PsionicSurge' && 
						AbilityTemplateName != 'Harbinger' && 
						AbilityTemplateName != 'RTKillzone' && 
						AbilityTemplateName != 'TimeStandsStill' &&
						AbilityTemplateName != 'RTMentor')
					{ return false; }
					break;
		case eChecklist_DefaultAbilities:
					if( AbilityTemplateName != 'StandardShot' && 
					  	AbilityTemplateName != 'StandardGhostShot'
					   	
					  )

					{ return false; }
					break;
		default:
					return false;
	} 

	return true;
}
