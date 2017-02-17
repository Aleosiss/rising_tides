//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_TimeStopTag.uc
//  AUTHOR:  Aleosiss
//  DATE:    8 August 2016
//  PURPOSE: Tracks damage preview/calcualtion for TimeStop
//  NOTES: There is absolutely no reason this shouldn't just be a part of TimeStopMaster... except for no discernable reason, the effect will not work when attached there.  
//			EDIT: Took me 8 months, but I figured out why it wouldn't work; unfortunately, i'm lazy as fuck and am not going to refactor.
//---------------------------------------------------------------------------------------
//	Time Stop tag effect
//---------------------------------------------------------------------------------------
class RTEffect_TimeStopTag extends X2Effect_Persistent config(RTMarksman);

//Add damage for precision shot crits
function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local RTGameState_TimeStopEffect	TimeStopEffectState;
	local XComGameState_Effect			TempEffectState;
	local StateObjectReference			EffectRef;
	local XComGameState_Unit			TargetUnit;

	`LOG("Rising Tides: RTEffect_TimeStopMaster.GetAttackingDamageModifier called...");
	TargetUnit = XComGameState_Unit(TargetDamageable);
		if(TargetUnit != none) {
			foreach TargetUnit.AffectedByEffects(EffectRef)
			{
				TempEffectState = XComGameState_Effect(`XCOMHISTORY.GetGameStateForObjectID(EffectRef.ObjectID));
				if(TempEffectState != none){
					TimeStopEffectState	= RTGameState_TimeStopEffect(TempEffectState);
					if(TimeStopEffectState != none && TimeStopEffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID == TargetUnit.ObjectID) {
						`LOG("Rising Tides: TimeStopEffectState Found, proceeding...");
						break;
					}
				}	
			}
	}
	// This is truly the darkest timeline...
	// Exploiting the behavior of X2Effect_ApplyWeaponDamage here, as it calls GetAttackingDamageModifier twice
	// for the damage preview and only once for the actual attack
	if(TimeStopEffectState != none) {
		TimeStopEffectState.iShouldRecordCounter = TimeStopEffectState.iShouldRecordCounter + 1; // 1 after the first pass, 2 after the second
	}

	return 0; 
}

function int GetExtraArmorPiercing(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData) { 
	local RTGameState_TimeStopEffect	TimeStopEffectState;
	local XComGameState_Effect			TempEffectState;
	local StateObjectReference			EffectRef;
	local XComGameState_Unit			TargetUnit;

	`LOG("Rising Tides: RTEffect_TimeStopMaster.GetExtraArmorPiercing called...");
	TargetUnit = XComGameState_Unit(TargetDamageable);
	if(TargetUnit != none) {
		foreach TargetUnit.AffectedByEffects(EffectRef) 
		{
			TempEffectState = XComGameState_Effect(`XCOMHISTORY.GetGameStateForObjectID(EffectRef.ObjectID));
			if(TempEffectState != none){
				TimeStopEffectState	= RTGameState_TimeStopEffect(TempEffectState);
				if(TimeStopEffectState != none && TimeStopEffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID == TargetUnit.ObjectID) {
					`LOG("Rising Tides: TimeStopEffectState Found, proceeding...");
					break;
				}
			}
		}
	}
	if(TimeStopEffectState != none) {
		if(TimeStopEffectState.iShouldRecordCounter == 1) {
			TimeStopEffectState.bShouldRecordDamageValue = true;
			`LOG("Rising Tides: TimeStopEffectState should record the damage value!");	
		} 
		else {
			if(TimeStopEffectState.iShouldRecordCounter == 2)
				`LOG("Rising Tides: TimeStopEffectState detected a damage preview attempt and will not record a damage value.");
			TimeStopEffectState.bShouldRecordDamageValue = false;
			`LOG("Rising Tides: TimeStopEffectState.bShouldRecordDamageValue is incorrect: " @ TimeStopEffectState.iShouldRecordCounter);	
		}
		TimeStopEffectState.iShouldRecordCounter = 0;
	}
	
	return 0; 
}

DefaultProperties
{
	EffectName="TimeStopTagEffect";
}