class RTEffect_SimpleHeal extends X2Effect;

var int HEAL_AMOUNT;
var bool bUseWeaponDamage;
var string nAbilitySourceName;

protected simulated function OnEffectAdded (const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameStateHistory		History;
	local XComGameState_Ability		Ability;
	local XComGameState_Item		SourceWeapon;
	local XComGameState_Unit		SourceUnit;
	local XComGameState_Unit		TargetUnit;
	local X2WeaponTemplate			WeaponTemplate;

	History = `XCOMHISTORY;
	Ability = XComGameState_Ability(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	if (Ability == none)
		Ability = XComGameState_Ability(History.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	TargetUnit = XComGameState_Unit(kNewTargetState);

	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	SourceWeapon = XComGameState_Item(History.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));
	if(SourceWeapon != none)
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());

	if(WeaponTemplate == none && bUseWeaponDamage)
	{
		`REDSCREEN("RTEffect_SimpleHeal : Invalid WeaponTemplate.");
		return;
	}
	if(SourceUnit == none)
	{
		`REDSCREEN("RTEffect_SimpleHeal : Invalid SourceUnit.");
		return;
	}
	if(Ability == none)
	{
		`REDSCREEN("RTEffect_SimpleHeal : Invalid Ability.");
		return;
	}
	if(TargetUnit == none)
	{
		`REDSCREEN("RTEffect_SimpleHeal : Invalid TargetUnit.");
		return;
	}
	if(bUseWeaponDamage)
		TargetUnit.ModifyCurrentStat(eStat_HP, WeaponTemplate.BaseDamage.Damage);
	else
		TargetUnit.ModifyCurrentStat(eStat_HP, HEAL_AMOUNT);
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	local XComGameState_Unit OldUnit, NewUnit;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local int Healed;

	if (EffectApplyResult != 'AA_Success')
		return;



	// Grab the current and previous gatekeeper unit and check if it has been healed
	OldUnit = XComGameState_Unit(BuildTrack.StateObject_OldState);
	NewUnit = XComGameState_Unit(BuildTrack.StateObject_NewState);

	Healed = NewUnit.GetCurrentStat(eStat_HP) - OldUnit.GetCurrentStat(eStat_HP);

	if( Healed > 0 )
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None,  nAbilitySourceName @ ": +" @ Healed, '', eColor_Good);
	}
}
