//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_Stealth.uc
//  AUTHOR:  Aleosiss
//	DATE:	 7/14/16
//  PURPOSE: True stealth ability, which is simply normal Ranger Stealth + 
//			 a DetectionModifier bump.
//           
//---------------------------------------------------------------------------------------
//  
//---------------------------------------------------------------------------------------
class RTEffect_Stealth extends X2Effect_PersistentStatChange;
	
var float fStealthModifier;


simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit UnitState;

	
	
	UnitState = XComGameState_Unit(kNewTargetState);
	if (UnitState != none)
		`XEVENTMGR.TriggerEvent('EffectEnterUnitConcealment', UnitState, UnitState, NewGameState);
	
	AddPersistentStatChange(eStat_DetectionModifier, fStealthModifier);
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}																							 

DefaultProperties
{
	EffectName = "RTStealth"
	fStealthModifier=0.9f
}