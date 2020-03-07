class RTCharacter_DefaultTemplars extends X2Character_DefaultCharacters config(RisingTides);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local X2DataTemplate template;
	
	Templates.AddItem(CreateTemplate_TemplarWarrior('RTTemplarWarrior_M1'));
	Templates.AddItem(CreateTemplate_TemplarWarrior('RTTemplarWarrior_M2'));
	Templates.AddItem(CreateTemplate_TemplarWarrior('RTTemplarWarrior_M3'));

	Templates.AddItem(CreateTemplate_TemplarScholar('RTTemplarScholar_M1'));
	Templates.AddItem(CreateTemplate_TemplarScholar('RTTemplarScholar_M2'));
	Templates.AddItem(CreateTemplate_TemplarScholar('RTTemplarScholar_M3'));

	Templates.AddItem(CreateTemplate_TemplarPriest('RTTemplarPriest_M1'));
	Templates.AddItem(CreateTemplate_TemplarPriest('RTTemplarPriest_M2'));
	Templates.AddItem(CreateTemplate_TemplarPriest('RTTemplarPriest_M3'));

	Templates.AddItem(CreateTemplate_TemplarPeon('RTTemplarPeon_M1'));
	Templates.AddItem(CreateTemplate_TemplarPeon('RTTemplarPeon_M2'));
	Templates.AddItem(CreateTemplate_TemplarPeon('RTTemplarPeon_M3'));

	Templates.AddItem(CreateTemplate_HighCovenWarrior());
	Templates.AddItem(CreateTemplate_HighCovenScholar());
	Templates.AddItem(CreateTemplate_HighCovenPriest());
	Templates.AddItem(CreateTemplate_RTGeist());

	`RTLOG("Created Templars:");
	foreach Templates(template) {
		`RTLOG("" $ template.DataName);
	}
	`RTLOG("Done.");

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
	CharTemplate.CharacterGroupName = 'RT_TemplarWarrior';
	CharTemplate.strBehaviorTree = "RTTemplarWarriorRoot";
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
	CharTemplate.Abilities.AddItem('Momentum');
	CharTemplate.Abilities.AddItem('Overcharge');

	switch(TemplateName) {
		case 'RTTemplarWarrior_M2':
			CharTemplate.DefaultLoadout = 'RTTemplarWarrior_M2';
			break;
		case 'RTTemplarWarrior_M3':
		case 'RTTemplar_HighCovenWarrior':
		case 'RTTemplar_Geist':
			CharTemplate.DefaultLoadout = 'RTTemplarWarrior_M3';
			break;
		default:
			break;
	}
	//CharTemplate.RequiredLoadout = 'RequiredSoldier';
	CharTemplate.BehaviorClass=class'XGAIBehavior';

	CharTemplate.Abilities.AddItem('CarryUnit');
	CharTemplate.Abilities.AddItem('PutDownUnit');
	//CharTemplate.Abilities.AddItem('Evac');
	CharTemplate.Abilities.AddItem('Knockout');
	CharTemplate.Abilities.AddItem('KnockoutSelf');
	CharTemplate.Abilities.AddItem('HunkerDown');
	CharTemplate.strTargetIconImage = class'UIUtilities_Image'.const.TargetIcon_XCom;

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

static function X2CharacterTemplate CreateTemplate_TemplarScholar(name TemplateName)
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
	CharTemplate.CharacterGroupName = 'RT_TemplarScholar';
	CharTemplate.BehaviorClass = class'XGAIBehavior';
	CharTemplate.strBehaviorTree = "RTTemplarScholarRoot";
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
	CharTemplate.bSetGenderAlways = true;
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
	CharTemplate.DefaultLoadout = 'RTTemplarScholar_M1';
	CharTemplate.Abilities.AddItem('TemplarFocus');
	CharTemplate.Abilities.AddItem('Momentum');
	CharTemplate.Abilities.AddItem('RTUnwaveringResolve');
	CharTemplate.Abilities.AddItem('Reverberation');

	switch(TemplateName) {
		case 'RTTemplarScholar_M2':
			CharTemplate.DefaultLoadout = 'RTTemplarScholar_M2';
			CharTemplate.Abilities.AddItem('DeepFocus');
			break;
		case 'RTTemplarScholar_M3':
		case 'RTTemplar_HighCovenScholar':
			CharTemplate.DefaultLoadout = 'RTTemplarScholar_M3';
			CharTemplate.Abilities.AddItem('DeepFocus');
			break;
		default:
			break;
	}

	CharTemplate.Abilities.AddItem('CarryUnit');
	CharTemplate.Abilities.AddItem('PutDownUnit');
	CharTemplate.Abilities.AddItem('Knockout');
	CharTemplate.Abilities.AddItem('KnockoutSelf');
	CharTemplate.Abilities.AddItem('HunkerDown');
	CharTemplate.strTargetIconImage = class'UIUtilities_Image'.const.TargetIcon_XCom;

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

static function X2CharacterTemplate CreateTemplate_TemplarPeon(name TemplateName)
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
	CharTemplate.CharacterGroupName = 'RT_TemplarPeon';
	CharTemplate.BehaviorClass = class'XGAIBehavior';
	CharTemplate.strBehaviorTree = "RTTemplarPeonRoot";
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
	CharTemplate.bSetGenderAlways = true;
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
	CharTemplate.DefaultLoadout = 'RTTemplarPeon_M1';

	if(TemplateName == 'RTTemplarPeon_M2')
	{
		CharTemplate.DefaultLoadout = 'RTTemplarPeon_M2';
	}

	if(TemplateName == 'RTTemplarPeon_M3')
	{
		CharTemplate.DefaultLoadout = 'RTTemplarPeon_M3';
		CharTemplate.Abilities.AddItem('RTTemplarExtraOrdnance');
	}

	CharTemplate.Abilities.AddItem('CarryUnit');
	CharTemplate.Abilities.AddItem('PutDownUnit');
	CharTemplate.Abilities.AddItem('Knockout');
	CharTemplate.Abilities.AddItem('KnockoutSelf');
	CharTemplate.Abilities.AddItem('HunkerDown');
	CharTemplate.strTargetIconImage = class'UIUtilities_Image'.const.TargetIcon_XCom;

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

static function X2CharacterTemplate CreateTemplate_TemplarPriest(name TemplateName)
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
	CharTemplate.CharacterGroupName = 'RT_TemplarPriest';
	CharTemplate.BehaviorClass = class'XGAIBehavior';
	CharTemplate.strBehaviorTree = "RTTemplarPriestRoot";
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
	CharTemplate.bSetGenderAlways = true;
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
	CharTemplate.DefaultLoadout = 'RTTemplarPriest_M1';
	CharTemplate.Abilities.AddItem('TemplarFocus');
	CharTemplate.Abilities.AddItem('Momentum');
	CharTemplate.Abilities.AddItem('PriestRemoved');

	switch(TemplateName) {
		case 'RTTemplarPriest_M2':
			CharTemplate.DefaultLoadout = 'RTTemplarPriest_M2';
			CharTemplate.Abilities.AddItem('DeepFocus');
			break;
		case 'RTTemplarPriest_M3':
		case 'RTTemplar_HighCovenPriest':
			CharTemplate.DefaultLoadout = 'RTTemplarPriest_M3';
			CharTemplate.Abilities.AddItem('DeepFocus');
			break;
		default:
			break;
	}

	CharTemplate.Abilities.AddItem('CarryUnit');
	CharTemplate.Abilities.AddItem('PutDownUnit');
	CharTemplate.Abilities.AddItem('Knockout');
	CharTemplate.Abilities.AddItem('KnockoutSelf');
	CharTemplate.Abilities.AddItem('HunkerDown');
	CharTemplate.strTargetIconImage = class'UIUtilities_Image'.const.TargetIcon_XCom;

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

static function X2CharacterTemplate CreateTemplate_HighCovenWarrior() {
	local X2CharacterTemplate CharTemplate;

	CharTemplate = CreateTemplate_TemplarWarrior('RTTemplar_HighCovenWarrior');
	
	return CharTemplate;
};

static function X2CharacterTemplate CreateTemplate_HighCovenScholar() {
	local X2CharacterTemplate CharTemplate;

	CharTemplate = CreateTemplate_TemplarScholar('RTTemplar_HighCovenScholar');
	
	return CharTemplate;
};

static function X2CharacterTemplate CreateTemplate_HighCovenPriest() {
	local X2CharacterTemplate CharTemplate;

	CharTemplate = CreateTemplate_TemplarPriest('RTTemplar_HighCovenPriest');
	
	return CharTemplate;
};

static function X2CharacterTemplate CreateTemplate_RTGeist() {
	local X2CharacterTemplate CharTemplate;

	CharTemplate = CreateTemplate_TemplarWarrior('RTTemplar_Geist');
	CharTemplate.bForceAppearance = true;
	CharTemplate.bAppearanceDefinesPawn = true;

	CharTemplate.ForceAppearance.nmHead =  'LatMale_F';
	CharTemplate.ForceAppearance.iGender = 1;
	CharTemplate.ForceAppearance.iRace = 3;
	CharTemplate.ForceAppearance.nmHaircut =  'MaleHair_Buzzcut_2';
	CharTemplate.ForceAppearance.iHairColor = 13;
	CharTemplate.ForceAppearance.iFacialHair = 0;
	CharTemplate.ForceAppearance.nmBeard =  'MaleBeard_Blank';
	CharTemplate.ForceAppearance.iSkinColor = 0;
	CharTemplate.ForceAppearance.iEyeColor = 0;
	CharTemplate.ForceAppearance.nmFlag =  'Country_Templar';
	CharTemplate.ForceAppearance.iVoice = 0;
	CharTemplate.ForceAppearance.iAttitude = 0;
	CharTemplate.ForceAppearance.iArmorDeco = 0;
	CharTemplate.ForceAppearance.iArmorTint = 21;
	CharTemplate.ForceAppearance.iArmorTintSecondary = 36;
	CharTemplate.ForceAppearance.iWeaponTint = 20;
	CharTemplate.ForceAppearance.iTattooTint = 2;
	CharTemplate.ForceAppearance.nmWeaponPattern =  'Pat_Nothing';
	CharTemplate.ForceAppearance.nmPawn =  'XCom_Soldier_Templar_M';
	CharTemplate.ForceAppearance.nmTorso =  'CnvTemplar_Std_A_M';
	//CharTemplate.ForceAppearance.nmArms = None;
	CharTemplate.ForceAppearance.nmLegs =  'Templar_Legs_C_M';
	CharTemplate.ForceAppearance.nmHelmet =  'Templar_Helmet_B_M';
	CharTemplate.ForceAppearance.nmEye =  'DefaultEyes_2';
	CharTemplate.ForceAppearance.nmTeeth =  'DefaultTeeth';
	CharTemplate.ForceAppearance.nmFacePropLower =  'Prop_FaceLower_Blank';
	CharTemplate.ForceAppearance.nmFacePropUpper =  'Prop_FaceUpper_Blank';
	CharTemplate.ForceAppearance.nmPatterns =  'Pat_Nothing';
	CharTemplate.ForceAppearance.nmVoice =  'TemplarMaleVoice1_Localized';
	//CharTemplate.ForceAppearance.nmLanguage = None;
	CharTemplate.ForceAppearance.nmTattoo_LeftArm =  'Tattoo_Arms_BLANK';
	CharTemplate.ForceAppearance.nmTattoo_RightArm =  'Tattoo_Arms_BLANK';
	//CharTemplate.ForceAppearance.nmScars =  None;
	CharTemplate.ForceAppearance.nmTorso_Underlay =  'CnvUnderlay_Std_Torsos_A_M';
	CharTemplate.ForceAppearance.nmArms_Underlay =  'CnvUnderlay_Std_Arms_A_M';
	CharTemplate.ForceAppearance.nmLegs_Underlay =  'CnvUnderlay_Std_Legs_A_M';
	//CharTemplate.ForceAppearance.nmFacePaint = None;
	CharTemplate.ForceAppearance.nmLeftArm =  'Templar_Arms_Left_A_T1_M';
	CharTemplate.ForceAppearance.nmRightArm =  'Templar_Arms_Right_A_T1_M';
	CharTemplate.ForceAppearance.nmLeftArmDeco =  'Templar_Shoulder_Left_A_M';
	CharTemplate.ForceAppearance.nmRightArmDeco =  'Templar_Shoulder_Right_A_M';
	CharTemplate.ForceAppearance.nmLeftForearm = 'Templar_Invisible_Forearm_Left_M';
	CharTemplate.ForceAppearance.nmRightForearm = 'Templar_Invisible_Forearm_Right_M';
	CharTemplate.ForceAppearance.nmThighs = 'Templar_Thighs_A_M';
	//CharTemplate.ForceAppearance.nmShins =  None;
	CharTemplate.ForceAppearance.nmTorsoDeco =  'Templar_TorsoDeco_A_M';
	//CharTemplate.ForceAppearance.bGhostPawn = False;

	return CharTemplate;
};