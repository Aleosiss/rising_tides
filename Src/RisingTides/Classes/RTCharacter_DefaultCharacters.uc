class RTCharacter_DefaultCharacters extends X2Character_DefaultCharacters config(RisingTides);

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
	
	// SPECTRE
    Templates.AddItem(CreateWhisperTemplate());
    Templates.AddItem(CreateQueenTemplate());
    Templates.AddItem(CreateNovaTemplate());

	return Templates;
}


static function X2CharacterTemplate CreateWhisperTemplate()
{
	local RTCharacterTemplate CharTemplate;

	CharTemplate = CreateProgramSoldierTemplate('RTGhostMarksman');
	
	CharTemplate.DefaultSoldierClass = 'RT_Marksman';
	CharTemplate.DefaultLoadout = 'RT_Marksman';
	CharTemplate.bIsPsionic = true;

	CharTemplate.bForceAppearance = true;
	CharTemplate.bAppearanceDefinesPawn = true;

	CharTemplate.ForceAppearance.nmHead = 'ReaperMale_A';
	CharTemplate.ForceAppearance.iGender = 1;
	CharTemplate.ForceAppearance.iRace = 0;
	CharTemplate.ForceAppearance.nmHaircut = 'MaleHairShort_C';
	CharTemplate.ForceAppearance.iHairColor = 11;
	CharTemplate.ForceAppearance.iFacialHair = 0;
	CharTemplate.ForceAppearance.nmBeard = 'MaleBeard_Blank';
	CharTemplate.ForceAppearance.iSkinColor = 0;
	CharTemplate.ForceAppearance.iEyeColor = 0;
	CharTemplate.ForceAppearance.nmFlag = 'Country_USA';;
	CharTemplate.ForceAppearance.iVoice = 0;
	CharTemplate.ForceAppearance.iAttitude = 1;
	CharTemplate.ForceAppearance.iArmorDeco = 0;
	CharTemplate.ForceAppearance.iArmorTint = 92;
	CharTemplate.ForceAppearance.iArmorTintSecondary = 91;
	CharTemplate.ForceAppearance.iWeaponTint = 70;
	CharTemplate.ForceAppearance.iTattooTint = 55;
	CharTemplate.ForceAppearance.nmWeaponPattern = 'Hex';
	CharTemplate.ForceAppearance.nmPawn = 'XCom_Soldier_M';
	CharTemplate.ForceAppearance.nmTorso = 'MPW_WotC_SLD_MamaMEA_Pathfinder_Und_Secondary_Torso_M';
	//CharTemplate.ForceAppearance.nmArms = None;
	CharTemplate.ForceAppearance.nmLegs = 'MPW_WotC_SLD_MamaMEA_Pathfinder_Und_Legs_M';
	CharTemplate.ForceAppearance.nmHelmet = 'ALL_WotC_MamaMEA_Remnant_Heavy_Helmet_M';
	CharTemplate.ForceAppearance.nmEye = 'DefaultEyes_3';
	CharTemplate.ForceAppearance.nmTeeth = 'DefaultTeeth';
	CharTemplate.ForceAppearance.nmFacePropLower = 'Prop_FaceLower_Blank';
	CharTemplate.ForceAppearance.nmFacePropUpper = 'Prop_FaceUpper_Blank';
	CharTemplate.ForceAppearance.nmPatterns = 'Pat_Nothing';
	CharTemplate.ForceAppearance.nmVoice = 'MaleVoice6_English_US';
	//CharTemplate.ForceAppearance.nmLanguage = None;
	CharTemplate.ForceAppearance.nmTattoo_LeftArm = 'Tattoo_Arms_BLANK';
	CharTemplate.ForceAppearance.nmTattoo_RightArm = 'Tattoo_Arms_BLANK';
	CharTemplate.ForceAppearance.nmScars = 'Scars_BLANK';
	CharTemplate.ForceAppearance.nmTorso_Underlay = 'CnvUnderlay_Std_Torsos_A_M';
	CharTemplate.ForceAppearance.nmArms_Underlay = 'CnvUnderlay_Std_Arms_A_M';
	CharTemplate.ForceAppearance.nmLegs_Underlay = 'CnvUnderlay_Std_Legs_A_M';
	//CharTemplate.ForceAppearance.nmFacePaint = None;
	CharTemplate.ForceAppearance.nmLeftArm = 'MPW_WotC_SLD_MamaMEA_Pathfinder_Und_Secondary_Arm_Left_M';
	CharTemplate.ForceAppearance.nmRightArm = 'MPW_WotC_SLD_MamaMEA_Pathfinder_Und_Secondary_Arm_Right_M';
	CharTemplate.ForceAppearance.nmLeftArmDeco = 'MPW_WotC_SLD_MamaMEA_Remnant_Hvy_Arm_Left_M';
	CharTemplate.ForceAppearance.nmRightArmDeco = 'MPW_WotC_SLD_MamaMEA_Remnant_Hvy_Arm_Right_M';
	//CharTemplate.ForceAppearance.nmLeftForearm = None;
	//CharTemplate.ForceAppearance.nmRightForearm = None;
	//CharTemplate.ForceAppearance.nmThighs = None;
	CharTemplate.ForceAppearance.nmShins = 'MPW_WotC_SLD_MamaMEA_Remnant_Hvy_Legs_M';
	CharTemplate.ForceAppearance.nmTorsoDeco = 'MPW_WotC_SLD_MamaMEA_Remnant_Hvy_Torso_M';
	CharTemplate.ForceAppearance.bGhostPawn = False;

	class'RTHelpers'.static.RTLog("Adding Whisper's character template!");
	return CharTemplate;
}

static function X2CharacterTemplate CreateQueenTemplate()
{
	local RTCharacterTemplate CharTemplate;

	CharTemplate = CreateProgramSoldierTemplate('RTGhostBerserker');
	
	CharTemplate.DefaultSoldierClass = 'RT_Berserker';
	CharTemplate.DefaultLoadout = 'RT_Berserker';
    CharTemplate.bIsPsionic = true;
    
	CharTemplate.bForceAppearance = true;
	CharTemplate.bAppearanceDefinesPawn = true;

	CharTemplate.ForceAppearance.nmHead = 'CaucFem_D';
	CharTemplate.ForceAppearance.iGender = 2;
	CharTemplate.ForceAppearance.iRace = 0;
	CharTemplate.ForceAppearance.nmHaircut = 'FemHair_F';
	CharTemplate.ForceAppearance.iHairColor = 17;
	CharTemplate.ForceAppearance.iFacialHair = 0;
	CharTemplate.ForceAppearance.nmBeard = 'MaleBeard_Blank';
	CharTemplate.ForceAppearance.iSkinColor = 0;
	CharTemplate.ForceAppearance.iEyeColor = 6;
	CharTemplate.ForceAppearance.nmFlag = 'Country_USA';;
	CharTemplate.ForceAppearance.iVoice = 0;
	CharTemplate.ForceAppearance.iAttitude = 6;
	CharTemplate.ForceAppearance.iArmorDeco = 0;
	CharTemplate.ForceAppearance.iArmorTint = 92;
	CharTemplate.ForceAppearance.iArmorTintSecondary = 91;
	CharTemplate.ForceAppearance.iWeaponTint = 7;
	CharTemplate.ForceAppearance.iTattooTint = 10;
	CharTemplate.ForceAppearance.nmWeaponPattern = 'Hex';
	CharTemplate.ForceAppearance.nmPawn = 'XCom_Soldier_F';
	CharTemplate.ForceAppearance.nmTorso = 'LPW_WotC_SLD_MamaMEA_Pathfinder_Und_Secondary_Torso_F';
	CharTemplate.ForceAppearance.nmArms = 'PwrLgt_Std_A_F';
	CharTemplate.ForceAppearance.nmLegs = 'LPW_WotC_SLD_MamaMEA_Pathfinder_Und_Legs_F';
	CharTemplate.ForceAppearance.nmHelmet = 'ALL_WotC_MamaMEA_Remnant_Heavy_Helmet_F';
	CharTemplate.ForceAppearance.nmEye = 'DefaultEyes_3';
	CharTemplate.ForceAppearance.nmTeeth = 'DefaultTeeth';
	CharTemplate.ForceAppearance.nmFacePropLower = 'Prop_FaceLower_Blank';
	CharTemplate.ForceAppearance.nmFacePropUpper = 'Prop_FaceUpper_Blank';
	CharTemplate.ForceAppearance.nmPatterns = 'Pat_Nothing';
	CharTemplate.ForceAppearance.nmVoice = 'FemaleVoice2_English_US';
	//CharTemplate.ForceAppearance.nmLanguage = None;
	CharTemplate.ForceAppearance.nmTattoo_LeftArm = 'Tattoo_Arms_BLANK';
	CharTemplate.ForceAppearance.nmTattoo_RightArm = 'Tattoo_Arms_BLANK';
	CharTemplate.ForceAppearance.nmScars = 'Scars_BLANK';
	CharTemplate.ForceAppearance.nmTorso_Underlay = 'CnvUnderlay_Std_A_F';
	CharTemplate.ForceAppearance.nmArms_Underlay = 'CnvMed_Underlay_A_F';
	CharTemplate.ForceAppearance.nmLegs_Underlay = 'CnvUnderlay_Std_A_F';
	//CharTemplate.ForceAppearance.nmFacePaint = None;
	CharTemplate.ForceAppearance.nmLeftArm = 'LPW_WotC_SLD_MamaMEA_Pathfinder_Und_Secondary_Arm_Left_F';
	CharTemplate.ForceAppearance.nmRightArm = 'LPW_WotC_SLD_MamaMEA_Pathfinder_Und_Secondary_Arm_Right_F';
	CharTemplate.ForceAppearance.nmLeftArmDeco = 'LPW_WotC_SLD_MamaMEA_Remnant_Hvy_Arm_Left_F';
	CharTemplate.ForceAppearance.nmRightArmDeco = 'LPW_WotC_SLD_MamaMEA_Remnant_Hvy_Arm_Right_F';
	//CharTemplate.ForceAppearance.nmLeftForearm = None;
	//CharTemplate.ForceAppearance.nmRightForearm = None;
	//CharTemplate.ForceAppearance.nmThighs = None;
	CharTemplate.ForceAppearance.nmShins = 'LPW_WotC_SLD_MamaMEA_Remnant_Hvy_Legs_F';
	CharTemplate.ForceAppearance.nmTorsoDeco = 'LPW_WotC_SLD_MamaMEA_Remnant_Hvy_Torso_F';
	CharTemplate.ForceAppearance.bGhostPawn = False;

	class'RTHelpers'.static.RTLog("Adding Queen's character template!");
	return CharTemplate;
}

static function X2CharacterTemplate CreateNovaTemplate()
{
	local RTCharacterTemplate CharTemplate;

	CharTemplate = CreateProgramSoldierTemplate('RTGhostGatherer');
	
	CharTemplate.DefaultSoldierClass = 'RT_Gatherer';
	CharTemplate.DefaultLoadout = 'RT_Gatherer';
    CharTemplate.bIsPsionic = true;
    
	CharTemplate.bForceAppearance = true;
	CharTemplate.bAppearanceDefinesPawn = true;

	CharTemplate.ForceAppearance.nmHead = 'CaucFem_B';
	CharTemplate.ForceAppearance.iGender = 2;
	CharTemplate.ForceAppearance.iRace = 0;
	CharTemplate.ForceAppearance.nmHaircut = 'FemHair_G';
	CharTemplate.ForceAppearance.iHairColor = 7;
	CharTemplate.ForceAppearance.iFacialHair = 0;
	CharTemplate.ForceAppearance.nmBeard = 'MaleBeard_Blank';
	CharTemplate.ForceAppearance.iSkinColor = 0;
	CharTemplate.ForceAppearance.iEyeColor = 3;
	CharTemplate.ForceAppearance.nmFlag = 'Country_USA';;
	CharTemplate.ForceAppearance.iVoice = 0;
	CharTemplate.ForceAppearance.iAttitude = 2;
	CharTemplate.ForceAppearance.iArmorDeco = 0;
	CharTemplate.ForceAppearance.iArmorTint = 92;
	CharTemplate.ForceAppearance.iArmorTintSecondary = 91;
	CharTemplate.ForceAppearance.iWeaponTint = 7;
	CharTemplate.ForceAppearance.iTattooTint = 16;
	CharTemplate.ForceAppearance.nmWeaponPattern = 'Hex';
	CharTemplate.ForceAppearance.nmPawn = 'XCom_Soldier_F';
	CharTemplate.ForceAppearance.nmTorso = 'LPW_WotC_SLD_MamaMEA_Pathfinder_Und_Torso_F';
	CharTemplate.ForceAppearance.nmArms = 'PwrLgt_Std_A_F';
	CharTemplate.ForceAppearance.nmLegs = 'LPW_WotC_SLD_MamaMEA_Pathfinder_Und_Legs_F';
	CharTemplate.ForceAppearance.nmHelmet = 'ALL_WotC_MamaMEA_Remnant_Heavy_Helmet_F';
	CharTemplate.ForceAppearance.nmEye = 'DefaultEyes_3';
	CharTemplate.ForceAppearance.nmTeeth = 'DefaultTeeth';
	CharTemplate.ForceAppearance.nmFacePropLower = 'Prop_FaceLower_Blank';
	CharTemplate.ForceAppearance.nmFacePropUpper = 'Prop_FaceUpper_Blank';
	CharTemplate.ForceAppearance.nmPatterns = 'Pat_Nothing';
	CharTemplate.ForceAppearance.nmVoice = 'FemaleVoice10_English_US';
	//CharTemplate.ForceAppearance.nmLanguage = None;
	CharTemplate.ForceAppearance.nmTattoo_LeftArm = 'Tattoo_Arms_BLANK';
	CharTemplate.ForceAppearance.nmTattoo_RightArm = 'Tattoo_Arms_BLANK';
	CharTemplate.ForceAppearance.nmScars = 'Scars_BLANK';
	CharTemplate.ForceAppearance.nmTorso_Underlay = 'CnvUnderlay_Std_A_F';
	CharTemplate.ForceAppearance.nmArms_Underlay = 'CnvMed_Underlay_A_F';
	CharTemplate.ForceAppearance.nmLegs_Underlay = 'CnvUnderlay_Std_A_F';
	//CharTemplate.ForceAppearance.nmFacePaint = None;
	CharTemplate.ForceAppearance.nmLeftArm = 'LPW_WotC_SLD_MamaMEA_Pathfinder_Und_Secondary_Arm_Left_F';
	CharTemplate.ForceAppearance.nmRightArm = 'LPW_WotC_SLD_MamaMEA_Pathfinder_Und_Secondary_Arm_Right_F';
	CharTemplate.ForceAppearance.nmLeftArmDeco = 'LPW_WotC_SLD_MamaMEA_Remnant_Hvy_Arm_Left_F';
	CharTemplate.ForceAppearance.nmRightArmDeco = 'LPW_WotC_SLD_MamaMEA_Remnant_Hvy_Arm_Right_F';
	//CharTemplate.ForceAppearance.nmLeftForearm = None;
	//CharTemplate.ForceAppearance.nmRightForearm = None;
	//CharTemplate.ForceAppearance.nmThighs = None;
	CharTemplate.ForceAppearance.nmShins = 'LPW_WotC_SLD_MamaMEA_Remnant_Hvy_Legs_F';
	CharTemplate.ForceAppearance.nmTorsoDeco = 'LPW_WotC_SLD_MamaMEA_Remnant_Hvy_Torso_F';
	CharTemplate.ForceAppearance.bGhostPawn = False;

	class'RTHelpers'.static.RTLog("Adding Nova's character template!");
	return CharTemplate;
}

static function RTCharacterTemplate CreateProgramSoldierTemplate(optional name TemplateName = 'Soldier')
{
	local RTCharacterTemplate CharTemplate;

	`CREATE_X2TEMPLATE(class'RTCharacterTemplate', CharTemplate, TemplateName);
	CharTemplate.UnitSize = 1;
	CharTemplate.BehaviorClass = class'XGAIBehavior';
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
	CharTemplate.bCanBeCriticallyWounded = true;
	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bAppearanceDefinesPawn = true;
	CharTemplate.bIsAfraidOfFire = true;
	CharTemplate.bIsAlien = false;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = false;
	CharTemplate.bIsSoldier = true;
	CharTemplate.bCanTakeCover = true;
	CharTemplate.bCanBeCarried = true;	
	CharTemplate.bCanBeRevived = true;
	CharTemplate.bUsePoolSoldiers = true;
	CharTemplate.bStaffingAllowed = true;
	CharTemplate.bAppearInBase = true;
	CharTemplate.strMatineePackages.AddItem("CIN_Soldier");
	CharTemplate.strIntroMatineeSlotPrefix = "Char";
	CharTemplate.strLoadingMatineeSlotPrefix = "Soldier";
	CharTemplate.bUsesWillSystem = true;

	CharTemplate.DefaultSoldierClass = 'Rookie';
	CharTemplate.DefaultLoadout = 'RookieSoldier';
	CharTemplate.RequiredLoadout = 'RequiredSoldier';
	CharTemplate.Abilities.AddItem('Loot');
	CharTemplate.Abilities.AddItem('Interact_PlantBomb');
	CharTemplate.Abilities.AddItem('Interact_TakeVial');
	CharTemplate.Abilities.AddItem('Interact_StasisTube');
	CharTemplate.Abilities.AddItem('Interact_MarkSupplyCrate');
	CharTemplate.Abilities.AddItem('Interact_ActivateAscensionGate');
	CharTemplate.Abilities.AddItem('CarryUnit');
	CharTemplate.Abilities.AddItem('PutDownUnit');
	CharTemplate.Abilities.AddItem('Evac');
	CharTemplate.Abilities.AddItem('PlaceEvacZone');
	CharTemplate.Abilities.AddItem('LiftOffAvenger');
	CharTemplate.Abilities.AddItem('Knockout');
	CharTemplate.Abilities.AddItem('KnockoutSelf');
	CharTemplate.Abilities.AddItem('Panicked');
	CharTemplate.Abilities.AddItem('Berserk');
	CharTemplate.Abilities.AddItem('Obsessed');
	CharTemplate.Abilities.AddItem('Shattered');
	CharTemplate.Abilities.AddItem('HunkerDown');
	CharTemplate.Abilities.AddItem('DisableConsumeAllPoints');
	CharTemplate.Abilities.AddItem('Revive');

	// bondmate abilities
	//CharTemplate.Abilities.AddItem('BondmateResistantWill');
	CharTemplate.Abilities.AddItem('BondmateSolaceCleanse');
	CharTemplate.Abilities.AddItem('BondmateSolacePassive');
	CharTemplate.Abilities.AddItem('BondmateTeamwork');
	CharTemplate.Abilities.AddItem('BondmateTeamwork_Improved');
	CharTemplate.Abilities.AddItem('BondmateSpotter_Aim');
	CharTemplate.Abilities.AddItem('BondmateSpotter_Aim_Adjacency');
	//CharTemplate.Abilities.AddItem('BondmateSpotter_Crit');
	//CharTemplate.Abilities.AddItem('BondmateSpotter_Crit_Adjacency');
	//CharTemplate.Abilities.AddItem('BondmateReturnFire_Passive');
	//CharTemplate.Abilities.AddItem('BondmateReturnFire');
	//CharTemplate.Abilities.AddItem('BondmateReturnFire_Adjacency');
	//CharTemplate.Abilities.AddItem('BondmateReturnFire_Improved_Passive');
	//CharTemplate.Abilities.AddItem('BondmateReturnFire_Improved');
	//CharTemplate.Abilities.AddItem('BondmateReturnFire_Improved_Adjacency');
	CharTemplate.Abilities.AddItem('BondmateDualStrike');

	CharTemplate.AddTemplateAvailablility(CharTemplate.BITFIELD_GAMEAREA_Multiplayer); // Allow in MP!
	CharTemplate.MPPointValue = CharTemplate.XpKillscore * 10;
	
	CharTemplate.strTargetIconImage = class'UIUtilities_Image'.const.TargetIcon_XCom;
	CharTemplate.strAutoRunNonAIBT = "SoldierAutoRunTree";
	CharTemplate.CharacterGeneratorClass = class'XGCharacterGenerator';

	return CharTemplate;
}