class RTAbility_Program extends X2Ability_HackRewards
	config(ProgramFaction);

	var config float		PROFESSIONALS_HAVE_STANDARDS_DETECTION_MODIFIER_INCREASE;
	var config int			PSIONIC_JAMMING_WILL_PENALTY;

	var config int			PROGRAM_ARMOR_HEALTH_BONUS_M1;
	var config int			PROGRAM_ARMOR_HEALTH_BONUS_M2;
	var config int			PROGRAM_ARMOR_HEALTH_BONUS_M3;
	var config int			PROGRAM_ARMOR_MITIGATION_CHANCE;
	var config int			PROGRAM_ARMOR_MITIGATION_AMOUNT_M1;
	var config int			PROGRAM_ARMOR_MITIGATION_AMOUNT_M2;
	var config int			PROGRAM_ARMOR_MITIGATION_AMOUNT_M3;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(RTProfessionalsHaveStandards());
	Templates.AddItem(RTPsionicJamming());

	Templates.AddItem(RTProgramArmorStats(1));
	Templates.AddItem(RTProgramArmorStats(2));
	Templates.AddItem(RTProgramArmorStats(3));

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

static function X2AbilityTemplate RTProgramArmorStats(int iTier)
{
	local X2AbilityTemplate					Template;
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;
	local name								tierSuffix;

	tierSuffix = `RTS.getSuffixForTier(iTier);

	`CREATE_X2ABILITY_TEMPLATE(Template, `RTS.concatName(class'RTItem'.default.ARMOR_PROGRAM_STATS_NAME, tierSuffix));
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
	switch(iTier) {
		case 1:
			PersistentStatChangeEffect.AddPersistentStatChange(eStat_HP, default.PROGRAM_ARMOR_HEALTH_BONUS_M1);
			PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, default.PROGRAM_ARMOR_MITIGATION_AMOUNT_M1);
			break;
		case 2:
			PersistentStatChangeEffect.AddPersistentStatChange(eStat_HP, default.PROGRAM_ARMOR_HEALTH_BONUS_M2);
			PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, default.PROGRAM_ARMOR_MITIGATION_AMOUNT_M2);
			break;
		case 3:
			PersistentStatChangeEffect.AddPersistentStatChange(eStat_HP, default.PROGRAM_ARMOR_HEALTH_BONUS_M3);
			PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, default.PROGRAM_ARMOR_MITIGATION_AMOUNT_M3);
			break;
		default:
			`RTLOG("Warning, " $ GetFuncName() $ " was provided invalid tier, returning tier 3!", true, false);
			PersistentStatChangeEffect.AddPersistentStatChange(eStat_HP, default.PROGRAM_ARMOR_HEALTH_BONUS_M3);
			PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, default.PROGRAM_ARMOR_MITIGATION_AMOUNT_M3);
	}
	
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorChance, default.PROGRAM_ARMOR_MITIGATION_CHANCE);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate ForceAbilityTriggerPostBeginPlay(X2AbilityTemplate Template) {
	Template.AbilityTriggers.Length = 0;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	return Template;
}