class RTCharacter_DefaultTemplars extends X2Character_DefaultCharacters config(RisingTides);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(CreateTemplate_TemplarWarrior('RTTemplarWarrior_M1'));
	Templates.AddItem(CreateTemplate_TemplarWarrior('RTTemplarWarrior_M2'));
	Templates.AddItem(CreateTemplate_TemplarWarrior('RTTemplarWarrior_M3'));

	return Templates;
}

static function X2CharacterTemplate CreateTemplate_TemplarWarrior(name TemplateName)
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	`CREATE_X2CHARACTER_TEMPLATE(CharTemplate, TemplateName);

	// Auto-Loot
	Loot.ForceLevel = 0;
	Loot.LootTableName = 'RTTemplar_BaseLoot';
	CharTemplate.Loot.LootReferences.AddItem(Loot);

	// Timed Loot
	Loot.ForceLevel = 0;
	Loot.LootTableName = 'AdvTrooperM1_TimedLoot';
	CharTemplate.TimedLoot.LootReferences.AddItem(Loot);
	Loot.LootTableName = 'AdvTrooperM1_VultureLoot';
	CharTemplate.VultureLoot.LootReferences.AddItem(Loot);

	CharTemplate.UnitSize = 1;
	CharTemplate.CharacterGroupName = 'RT_Templar';
	CharTemplate.BehaviorClass = class'XGAIBehavior';
	CharTemplate.strBehaviorTree = "RTTemplarRoot";
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = true;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = true;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = true;
	CharTemplate.bCanUse_eTraversal_DropDown = true;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = false;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bCanBeCriticallyWounded = false;
	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bDiesWhenCaptured = true;
	CharTemplate.bAppearanceDefinesPawn = true;
	CharTemplate.bIsAfraidOfFire = true;
	CharTemplate.bIsAlien = false;
	CharTemplate.bIsAdvent = false;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = false;
	CharTemplate.bIsSoldier = false;
	CharTemplate.bCanTakeCover = true;
	CharTemplate.bCanBeCarried = false;
	CharTemplate.bCanBeRevived = true;
	//CharTemplate.AcquiredPhobiaTemplate = 'FearOfMOCX';

	//CharTemplate.bUsePoolSoldiers = true;
	//CharTemplate.bUsePoolDarkVIPs = true; //these two variables let us use character pool chars

	CharTemplate.bIsTooBigForArmory = false;
	CharTemplate.bStaffingAllowed = false;
	CharTemplate.bAppearInBase = false; // Do not appear as filler crew or in any regular staff slots throughout the base
	CharTemplate.bWearArmorInBase = false;
	
	CharTemplate.bAllowRushCam = true;
	CharTemplate.strMatineePackages.AddItem("CIN_Soldier");
	//CharTemplate.strIntroMatineeSlotPrefix = "Char";
	//CharTemplate.strLoadingMatineeSlotPrefix = "Soldier";
	CharTemplate.strMatineePackages.AddItem("CIN_Advent");
	//CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper";
	//CharTemplate.GetRevealMatineePrefixFn = GetAdventMatineePrefix;
	
	//CharTemplate.DefaultSoldierClass = 'Rookie';
	CharTemplate.DefaultLoadout = 'RTTemplarWarrior_M1';
	CharTemplate.Abilities.AddItem('TemplarFocus');
	CharTemplate.Abilities.AddItem('Momentum');

	if(TemplateName == 'RTTemplarWarrior_M2')
	{
		CharTemplate.DefaultLoadout = 'RTTemplarWarrior_M2';

	}

	if(TemplateName == 'RTTemplarWarrior_M3')
	{
		CharTemplate.DefaultLoadout = 'RTTemplarWarrior_M3';
	}
	//CharTemplate.RequiredLoadout = 'RequiredSoldier';
	CharTemplate.BehaviorClass=class'XGAIBehavior';

	CharTemplate.Abilities.AddItem('CarryUnit');
	CharTemplate.Abilities.AddItem('PutDownUnit');
	//CharTemplate.Abilities.AddItem('Evac');
	CharTemplate.Abilities.AddItem('Knockout');
	CharTemplate.Abilities.AddItem('KnockoutSelf');
	CharTemplate.Abilities.AddItem('HunkerDown');
	//CharTemplate.strTargetIconImage = "CultistTargetIcon.target_chaos";

	//CharTemplate.CustomizationManagerClass = class'XComCharacterCustomization_Hybrid';
	//CharTemplate.UICustomizationMenuClass = class'UICustomize_HybridMenu';
	//CharTemplate.UICustomizationInfoClass = class'UICustomize_HybridInfo';
	//CharTemplate.UICustomizationPropsClass = class'UICustomize_HybridProps';
	CharTemplate.CharacterGeneratorClass = class'RTCharacterGenerator_Templar';
	
	CharTemplate.PhotoboothPersonality = 'Personality_Normal';

	//CharTemplate.OnEndTacticalPlayFn = SparkEndTacticalPlay;
	//CharTemplate.GetPhotographerPawnNameFn = GetSparkPawnName;

	return CharTemplate;
}