//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_VPTargeting.uc
//  AUTHOR:  Aleosiss
//  DATE:    3 March 2016
//  PURPOSE: general damage effect
//---------------------------------------------------------------------------------------
//	return to this later
//---------------------------------------------------------------------------------------
class RTEffect_VPTargeting extends X2Effect_Persistent;

var int BonusDamage;
var array<Name> ResearchedTemplates;


simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local array<StateObjectReference> ResearchedTechs;
	local XComGameStateHistory History;
	local StateObjectReference TechRef;

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);

	//History = `XCOMHISTORY;
	//XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
//
	//ResearchedTechs = XComHQ.GetCompletedResearchTechs();

	
}

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local int FinalDamage;
	//Check for disabling shot
	if (AbilityState.GetMyTemplateName() == 'DisablingShot')
	{
		return FinalDamage;
	}

	//if(XComGameState_Unit(TargetDamagable) != none) {
		//if(ResearchedTemplates.Find(XComGameState_Unit(TargetDamagable).GetMyTemplateName()) != INDEX_NONE) {
			//FinalDamage += BonusDamage; 
		//}
	//}

	if(AppliedData.AbilityResultContext.HitResult == eHit_Crit || AppliedData.AbilityResultContext.HitResult == eHit_Success)
		return FinalDamage;
}																			  
