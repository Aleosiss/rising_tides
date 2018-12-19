class RTAbility_Program extends X2Ability_HackRewards
	config(ProgramFaction);

	var config float	ProfessionalsHaveStandards_DetectionModifierIncrease;
	var config int		PsionicJamming_WillPenalty;

	static function array<X2DataTemplate> CreateTemplates()
	{
		local array<X2DataTemplate> Templates;

		Templates.AddItem(RTProfessionalsHaveStandards());
		Templates.AddItem(RTPsionicJamming());

		return Templates;
	}

	static function X2AbilityTemplate RTProfessionalsHaveStandards() {
		local X2AbilityTemplate Template;

		Template = ForceAbilityTriggerPostBeginPlay(BuildStatModifyingAbility('RTProfessionalsHaveStandards', "img:///UILibrary_PerkIcons.UIPerk_hack_reward_debuff", EETS_Self, , ePerkBuff_Bonus, eStat_DetectionModifier, default.ProfessionalsHaveStandards_DetectionModifierIncrease));

		return Template;
	}

	
	static function X2AbilityTemplate RTPsionicJamming() {
		local X2AbilityTemplate Template;

		Template = ForceAbilityTriggerPostBeginPlay(BuildStatModifyingAbility('RTPsionicJamming', "img:///UILibrary_PerkIcons.UIPerk_hack_reward_debuff", EETS_Self, , ePerkBuff_Penalty, eStat_Will, default.PsionicJamming_WillPenalty * -1));

		return Template;
	}


	static function X2AbilityTemplate ForceAbilityTriggerPostBeginPlay(X2AbilityTemplate Template) {
		Template.AbilityTriggers.Length = 0;
		Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

		return Template;
	}