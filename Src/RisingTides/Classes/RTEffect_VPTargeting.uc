//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_VPTargeting.uc
//  AUTHOR:  Aleosiss
//  DATE:    3 March 2016
//  PURPOSE: general damage effect for ghosts
//---------------------------------------------------------------------------------------
//	return to this later
//---------------------------------------------------------------------------------------
class RTEffect_VPTargeting extends X2Effect_Persistent;


function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local int FinalDamage;
	//Check for disabling shot
	if (AbilityState.GetMyTemplateName() == 'RTDisablingShot')
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

function int CalculatedBonusTier(XComGameState_Unit SourceUnitState, Damageable TargetDamageable) {

      local RTGameState_VPTargetingData TargetingDataState;
      local XComGameState_Unit TargetUnitState;
      local X2CharacterTemplate TargetTemplate;
      local X2CharacterTemplateManager TemplateManager;
      
      local RTKillCount IteratorKillCount;
      local RTDeathRecord IteratorRecord;

      local int ReturnValue;
  

      TargetingDataState = class'RTHelpers'.static.GetVPTargetingData();
      TargetUnitState = XComGameState_Unit(TargetDamageable);

      TemplateManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
      TargetTemplate = TemplateManager.FindCharacterTemplate(TargetUnitState.GetMyTemplateName());

      foreach TargetingDataState.Record(IteratorRecord) {
                if(IteratorRecord.CharacterTemplateName != TargetTemplate.CharacterGroupName)
                      continue;

                ReturnValue = IteratorRecord.NumDeaths;
                foreach IteratorRecord.IndividualKillCount(IteratorKillCount) {
                      if(IteratorKillCount.UnitRef.ObjectID != SourceUnitState.ObjectID)
                          continue;
                      ReturnValue += IteratorKillCount.KillCount; // each kill the unit made counts as two for tier calculation
                      break;
                }
      }

      return ReturnValue;
      

      


}																	  
