class RTAbility_Program extends X2Ability_HackRewards
	config(ProgramFaction);

	var config float	PROFESSIONALS_HAVE_STANDARDS_DETECTION_MODIFIER_INCREASE;
	var config int		PSIONIC_JAMMING_WILL_PENALTY;

	var config int		PROGRAM_ARMOR_HEALTH_BONUS_T1;
	var config int		PROGRAM_ARMOR_HEALTH_BONUS_T2;
	var config int		PROGRAM_ARMOR_HEALTH_BONUS_T3;
	var config int		PROGRAM_ARMOR_MITIGATION_CHANCE;
	var config int		PROGRAM_ARMOR_MITIGATION_AMOUNT;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(RTProfessionalsHaveStandards());
	Templates.AddItem(RTPsionicJamming());
	Templates.AddItem(RTProgramArmorStats());

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