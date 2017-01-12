//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_EveryMomentMatters.uc
//  AUTHOR:  Aleosiss
//  DATE:    26 December 2016  
//---------------------------------------------------------------------------------------
class RTEffect_EveryMomentMatters extends X2Effect_Persistent config(RisingTides);

var float BONUS_DAMAGE_PERCENT;

// Add damage reduction for disabling shot
function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local float ExtraDamage;
	local XComGameState_Item WeaponState;
	local XComGameState_Unit TargetState;
	local bool bLastShot;
	local int iMissingHealth;

	// Check for hit
	if (AppliedData.AbilityResultContext.HitResult == eHit_Success) {
		// Check for last bullet in the magazine
		WeaponState = AbilityState.GetSourceWeapon();
		if(WeaponState != none) {
			if(WeaponState.Ammo == 1) {
				bLastShot = true;	
			}
		}
	}

	if(!bLastShot) {
		return int(ExtraDamage);
	}

	TargetState = XComGameState_Unit(TargetDamageable);
	if(TargetState == none) {
		return int(ExtraDamage);
	}

	iMissingHealth = TargetState.GetMaxStat(eStat_HP) - TargetState.GetCurrentStat(eStat_HP);
	if(iMissingHealth > 0) {
		ExtraDamage = iMissingHealth * BONUS_DAMAGE_PERCENT;
	}	
	
	return int(ExtraDamage);
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;
	local XComGameState_Item SourceWeapon;
	
	SourceWeapon = AbilityState.GetSourceWeapon();
	if (SourceWeapon != none)
	{
		if(SourceWeapon.Ammo == 1) {
			ModInfo.ModType = eHit_Crit;
			ModInfo.Reason = "Death In" @SourceWeapon.GetClipSize()@"Acts";
			ModInfo.Value = 100;
			ShotModifiers.AddItem(ModInfo);
		}
	}
}

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local RTGameState_EveryMomentMatters EMMGameState;
	local Object EffectObj, FilterObj;

	EventMgr = `XEVENTMGR;

	EMMGameState = RTGameState_EveryMomentMatters(EffectGameState);
	EffectObj = EMMGameState;

	FilterObj = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EMMGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	`LOG("Rising Tides - Every Moment Matters: Registered for event, FilterObj = " @ XComGameState_Unit(FilterObj).GetFullName() @"-------------------------------------");
	EventMgr.RegisterForEvent(EffectObj, 'AbilityActivated', EMMGameState.EveryMomentMattersCheck, ELD_OnStateSubmitted,,FilterObj);
}												  

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	BONUS_DAMAGE_PERCENT = 0.25
	GameStateEffectClass = class'RTGameState_EveryMomentMatters'
}
