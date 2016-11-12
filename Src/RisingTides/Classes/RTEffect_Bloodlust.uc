class RTEffect_Bloodlust extends X2Effect_PersistentStatChange config (RisingTides);

var localized string RTFriendlyName;
var float fCritDamageMod;
var int iMobilityMod, iMeleeHitChanceMod;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local RTGameState_BloodlustEffect BloodEffectState;
	local Object EffectObj, FilterObj;

	EventMgr = `XEVENTMGR;

	BloodEffectState = RTGameState_BloodlustEffect(EffectGameState);

	EffectObj = BloodEffectState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(BloodEffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	FilterObj = UnitState;

	EventMgr.RegisterForEvent(EffectObj, 'RTBumpInTheNight_BloodlustProc', BloodEffectState.BumpInTheNightStatCheck, ELD_OnStateSubmitted, ,FilterObj);
	EventMgr.RegisterForEvent(EffectObj, 'RTPurge_Proc', BloodEffectState.BumpInTheNightStatCheck, ELD_OnStateSubmitted, ,FilterObj);
}


simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState) {
	local XComGameState_Unit UnitState;
 
  
	if(UnitState.IsUnitAffectedByEffectName('RTEffect_QueenOfBlades'))
		AddPersistentStatChange(eStat_Mobility, iMobilityMod);
	else
		AddPersistentStatChange(eStat_Mobility, -iMobilityMod);
  

	super.OnEffectAdded(ApplyEffectParameters, UnitState, NewGameState, NewEffectState);
}


function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers) {

	local ShotModifierInfo HitMod, CritMod;
	local RTGameState_BloodlustEffect BumpEffect;

	if(!bMelee && AbilityState.GetMyTemplateName() != 'RTBerserkerKnifeAttack' && AbilityState.GetMyTemplateName() != 'RTPyroclasticSlash' && AbilityState.GetMyTemplateName() != 'RTReprobateWaltz') {
		return;
	}

	BumpEffect = RTGameState_BloodlustEffect(EffectState);
  
	HitMod.ModType = eHit_Crit;
	HitMod.Value = BumpEffect.iStacks * iMeleeHitChanceMod;
	HitMod.Reason = "Bloodlust"; //TODO: FIX
	ShotModifiers.AddItem(HitMod);
  
}

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState) {
	local float ExtraCritDamage;
	local RTGameState_BloodlustEffect BumpEffect;

	if(!AbilityState.IsMeleeAbility() && AbilityState.GetMyTemplateName() != 'RTBerserkerKnifeAttack' && AbilityState.GetMyTemplateName() != 'RTPyroclasticSlash' && AbilityState.GetMyTemplateName() != 'RTReprobateWaltz') {
		return 0;
	}

	BumpEffect = RTGameState_BloodlustEffect(EffectState);
	ExtraCritDamage = CurrentDamage * BumpEffect.iStacks * fCritDamageMod;
	// only on crits...
	if(AppliedData.AbilityResultContext.HitResult == eHit_Crit) {
		return int(ExtraCritDamage);	
	}

	return 0;
}

DefaultProperties
{
	bStackOnRefresh = true;
	DuplicateResponse = eDupe_Refresh
	GameStateEffectClass = class'RTGameState_BloodlustEffect'
	EffectName = "RTEffect_Bloodlust"
}
