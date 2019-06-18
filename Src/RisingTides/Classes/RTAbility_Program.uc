class RTAbility_Program extends X2Ability_HackRewards
	config(ProgramFaction);

	var config float		PROFESSIONALS_HAVE_STANDARDS_DETECTION_MODIFIER_INCREASE;
	var config int			PSIONIC_JAMMING_WILL_PENALTY;

	var config int			PROGRAM_ARMOR_HEALTH_BONUS_T1;
	var config int			PROGRAM_ARMOR_HEALTH_BONUS_T2;
	var config int			PROGRAM_ARMOR_HEALTH_BONUS_T3;
	var config int			PROGRAM_ARMOR_MITIGATION_CHANCE;
	var config int			PROGRAM_ARMOR_MITIGATION_AMOUNT;

	var name 				CloakingProtocolEffectName;
	var config float		CLOAKING_PROTOCOL_RADIUS_METERS;
	var localized string	CloakingProtocolTitle;
	var localized string	CloakingProtocolSelfDescription;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(RTProfessionalsHaveStandards());
	Templates.AddItem(RTPsionicJamming());
	Templates.AddItem(RTProgramArmorStats());
	Templates.AddItem(RTProgramDroneCloakingProtocol());
	Templates.AddItem(RTProgramDroneCloakingProtocolOn());
	Templates.AddItem(RTProgramDroneCloakingProtocolOff());

	return Templates;
}

static function X2AbilityTemplate RTProfessionalsHaveStandards() {
	local X2AbilityTemplate Template;

	Template = ForceAbilityTriggerPostBeginPlay(BuildStatModifyingAbility('RTProfessionalsHaveStandards', "img:///UILibrary_PerkIcons.UIPerk_hack_reward_debuff", EETS_Self, , ePerkBuff_Bonus, eStat_DetectionModifier, default.PROFESSIONALS_HAVE_STANDARDS_DETECTION_MODIFIER_INCREASE));

	return Template;
}

static function X2AbilityTemplate RTPsionicJamming() {
	local X2AbilityTemplate Template;

	Template = ForceAbilityTriggerPostBeginPlay(BuildStatModifyingAbility('RTPsionicJamming', "img:///UILibrary_PerkIcons.UIPerk_hack_reward_debuff", EETS_Self, , ePerkBuff_Penalty, eStat_Will, default.PSIONIC_JAMMING_WILL_PENALTY * -1));

	return Template;
}

static function X2AbilityTemplate RTProgramArmorStats()
{
	local X2AbilityTemplate					Template;
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTProgramArmorStats');
	// Template.IconImage  -- no icon needed for armor stats

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	// the armor
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	// PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, default.MediumPlatedHealthBonusName, default.MediumPlatedHealthBonusDesc, Template.IconImage);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_HP, default.PROGRAM_ARMOR_HEALTH_BONUS_T3);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorChance, default.PROGRAM_ARMOR_MITIGATION_CHANCE);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, default.PROGRAM_ARMOR_MITIGATION_AMOUNT);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate ForceAbilityTriggerPostBeginPlay(X2AbilityTemplate Template) {
	Template.AbilityTriggers.Length = 0;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	return Template;
}

static function X2AbilityTemplate RTProgramDroneCloakingProtocol() {
	local X2AbilityTemplate Template;

	// name TemplateName, optional string TemplateIconImage="img:///UILibrary_PerkIcons.UIPerk_standard", optional bool bCrossClassEligible=false, optional Name AbilitySourceName='eAbilitySource_Perk', optional bool bDisplayInUI=true
	Template = PurePassive('RTProgramDroneCloakingProtocol', "img:///UILibrary_PerkIcons.UIPerk_standard", false, 'eAbilitySource_Perk', true);
	Template.RemoveTemplateAvailablility(Template.BITFIELD_GAMEAREA_Multiplayer);

	Template.AdditionalAbilities.AddItem('RTProgramDroneCloakingProtocolOn');
	Template.AdditionalAbilities.AddItem('RTProgramDroneCloakingProtocolOff');

	return Template;
}

static function X2AbilityTemplate RTProgramDroneCloakingProtocolOn() {
	local X2AbilityTemplate Template;
	local X2AbilityCost_Charges Charges;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityMultiTarget_Radius Radius;
	local RTEffect_AuraSource AuraEffect;
	local X2Condition_UnitEffects UnitEffectCondition;
	local X2Effect_PersistentStatChange MobilityDebuffEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTProgramDroneCloakingProtocolOn');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = class'RTEffectBuilder'.default.StealthIconPath;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	UnitEffectCondition = new class'X2Condition_UnitEffects';
	UnitEffectCondition.AddExcludeEffect(default.CloakingProtocolEffectName, 'AA_UnitIsConcealed');
	Template.AbilityShooterConditions.AddItem(UnitEffectCondition);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	Radius = new class'X2AbilityMultiTarget_Radius';
	Radius.bUseWeaponRadius = false;
	Radius.bIgnoreBlockingCover = true;
	Radius.bExcludeSelfAsTargetIfWithinRadius = true;
	Radius.fTargetRadius =	default.CLOAKING_PROTOCOL_RADIUS_METERS * class'XComWorldData'.const.WORLD_StepSize * class'XComWorldData'.const.WORLD_UNITS_TO_METERS_MULTIPLIER;
	Template.AbilityMultiTargetStyle = Radius;

	Template.AddMultiTargetEffect(`RTEB.CreateStealthEffect(1, false));
	Template.AddMultiTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	// aura controller effect	------------------------------------------
	AuraEffect = new class'RTEffect_AuraSource';
	AuraEffect.BuildPersistentEffect(1, true,,, eGameRule_PlayerTurnBegin);
	AuraEffect.SetDisplayInfo(ePerkBuff_Bonus, default.CloakingProtocolTitle, default.CloakingProtocolSelfDescription, Template.IconImage, true,,Template.AbilitySourceName);
	AuraEffect.DuplicateResponse = eDupe_Refresh;
	AuraEffect.EffectName = default.CloakingProtocolEffectName;
//	AuraEffect.VFXTemplateName = "RisingTidesContentPackage.fX.P_Drone_CloakingProtocolAura";
//	AuraEffect.VFXSocket = 'FX_Base';
//	AuraEffect.VFXSocketsArrayName = 'None';
//	AuraEffect.fVFXScale = 0.5;
	AuraEffect.fRadius = default.CLOAKING_PROTOCOL_RADIUS_METERS;
	AuraEffect.bReapplyOnTick = true;
	Template.AddTargetEffect(AuraEffect);

	MobilityDebuffEffect = new class'X2Effect_PersistentStatChange';
	MobilityDebuffEffect.BuildPersistentEffect(1, true, true, false);
	MobilityDebuffEffect.AddPersistentStatChange(eStat_Mobility, 0.5, MODOP_PostMultiplication);
	MobilityDebuffEffect.EffectName = 'CloakingProtocolMobilityMalus';

	Template.AddTargetEffect(MobilityDebuffEffect);
	Template.AddTargetEffect(`RTEB.CreateConcealmentEffect());
	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Template.CustomFireAnim = 'NO_CloakingProtocol';

	return Template;
}

static function X2AbilityTemplate RTProgramDroneCloakingProtocolOff() {
	local X2AbilityTemplate Template;
	local X2Effect_RemoveEffects RemoveEffect;
	local X2AbilityMultiTarget_Radius Radius;
	local X2Condition_UnitEffects UnitEffectCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RTProgramDroneCloakingProtocolOff');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_defend_panic";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityCosts.AddItem(default.FreeActionCost);

	UnitEffectCondition = new class'X2Condition_UnitEffects';
	UnitEffectCondition.AddRequireEffect(default.CloakingProtocolEffectName, 'AA_UnitIsFlanked');
	Template.AbilityShooterConditions.AddItem(UnitEffectCondition);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	RemoveEffect = new class'X2Effect_RemoveEffects';
	RemoveEffect.EffectNamesToRemove.AddItem(default.CloakingProtocolEffectName);
	RemoveEffect.EffectNamesToRemove.AddItem('CloakingProtocolMobilityMalus');
	Template.AddTargetEffect(RemoveEffect);

	Radius = new class'X2AbilityMultiTarget_Radius';
	Radius.bUseWeaponRadius = false;
	Radius.bIgnoreBlockingCover = true;
	Radius.bExcludeSelfAsTargetIfWithinRadius = true; // for now
	Radius.fTargetRadius = 	default.CLOAKING_PROTOCOL_RADIUS_METERS * class'XComWorldData'.const.WORLD_StepSize * class'XComWorldData'.const.WORLD_UNITS_TO_METERS_MULTIPLIER;
	Template.AbilityMultiTargetStyle = Radius;

	RemoveEffect = new class'X2Effect_RemoveEffects';
	RemoveEffect.EffectNamesToRemove.AddItem(class'RTEffectBuilder'.default.StealthEffectName);
	Template.AddMultiTargetEffect(RemoveEffect);

	//Template.CustomFireAnim = 'NO_CloakingProtocolOff';

	return Template;
}

defaultproperties
{
	CloakingProtocolEffectName = "RTProgramDroneCloakingProtocolAura"
}