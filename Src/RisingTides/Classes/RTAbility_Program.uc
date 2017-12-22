class RTAbility_Program extends X2Ability_HackRewards
    config(ProgramFaction);
    
    var config float    ProfessionalsHaveStandards_DetectionModifierIncrease;
    var config int      PsionicJamming_WillPenalty;
    
    static function array<X2DataTemplate> CreateTemplates()
    {
        local array<X2DataTemplate> Templates;

        Templates.AddItem(BuildStatModifyingAbility('RTProfessionalsHaveStandards', "img:///UILibrary_PerkIcons.UIPerk_hack_reward_debuff", EETS_AllAllies, , ePerkBuff_Bonus, eStat_DetectionModifier, default.ProfessionalsHaveStandards_DetectionModifierIncrease));
        Templates.AddItem(BuildStatModifyingAbility('RTPsionicJamming', "img:///UILibrary_PerkIcons.UIPerk_hack_reward_debuff", EETS_AllEnemies, , ePerkBuff_Penalty, eStat_Will, default.PsionicJamming_WillPenalty));

        return Templates;
    }