class RTAbility_Program extends X2Ability_HackRewards
    config(ProgramFaction);
    
    var config float ProfessionalsHaveStandards_DetectionModifierIncrease;

    static function array<X2DataTemplate> CreateTemplates()
    {
        local array<X2DataTemplate> Templates;

        Templates.AddItem(BuildStatModifyingAbility('RTProfessionalsHaveStandards', "img:///UILibrary_PerkIcons.UIPerk_hack_reward", EETS_AllAllies, , ePerkBuff_Bonus, eStat_DetectionModifier, default.ProfessionalsHaveStandards_DetectionModifierIncrease));
       
        return Templates;
    }