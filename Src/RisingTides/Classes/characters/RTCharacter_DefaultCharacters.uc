class RTCharacter_DefaultCharacters extends X2Character_DefaultCharacters config(RisingTides);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	// SPECTRE
	Templates.AddItem(CreateWhisperTemplate());
	Templates.AddItem(CreateQueenTemplate());
	Templates.AddItem(CreateNovaTemplate());
	
	// HIGHLANDER
	Templates.AddItem(CreateKagaTemplate());


	// Drone
	Templates.AddItem(CreateProgramDroneTemplate('ProgramDrone'));

	// Talking Heads
	Templates.AddItem(CreateSpeakerTemplate('ProgramNovaStrategy', "'Nova'", "img:///RisingTidesContentPackage.UIImages.vhs_program_icon_filled_256x256"));
	Templates.AddItem(CreateSpeakerTemplate('ProgramHadleyStrategy', "Dr. Hadley", "img:///RisingTidesContentPackage.UIImages.program_portrait_hadley_talkinghead"));

	return Templates;
}


static function X2CharacterTemplate CreateWhisperTemplate()
{
	local RTCharacterTemplate CharTemplate;

	CharTemplate = CreateProgramSoldierTemplate('RTGhostMarksman');
	
	CharTemplate.DefaultSoldierClass = 'RT_Marksman';
	CharTemplate.DefaultLoadout = 'RT_Marksman';
	CharTemplate.bIsPsionic = true;

	CharTemplate.bHasFullDefaultAppearance = true;
	CharTemplate.bAppearanceDefinesPawn = true;

	CharTemplate.DefaultAppearance.nmPawn = 'XCom_Soldier_M';
	CharTemplate.DefaultAppearance.nmHead = 'ReaperMale_A';
	CharTemplate.DefaultAppearance.iGender = 1;
	CharTemplate.DefaultAppearance.iRace = 0;
	CharTemplate.DefaultAppearance.nmHaircut = 'MaleHairShort_C';
	CharTemplate.DefaultAppearance.iHairColor = 11;
	CharTemplate.DefaultAppearance.iFacialHair = 0;
	CharTemplate.DefaultAppearance.nmBeard = 'MaleBeard_Blank';
	CharTemplate.DefaultAppearance.iSkinColor = 0;
	CharTemplate.DefaultAppearance.iEyeColor = 0;
	CharTemplate.DefaultAppearance.nmFlag = 'Country_USA';;
	CharTemplate.DefaultAppearance.iVoice = 0;
	CharTemplate.DefaultAppearance.iAttitude = 1;
	CharTemplate.DefaultAppearance.iArmorDeco = 0;
	CharTemplate.DefaultAppearance.iArmorTint = 92;
	CharTemplate.DefaultAppearance.iArmorTintSecondary = 91;
	CharTemplate.DefaultAppearance.iWeaponTint = 70;
	CharTemplate.DefaultAppearance.iTattooTint = 55;
	CharTemplate.DefaultAppearance.nmWeaponPattern = 'Hex';
	CharTemplate.DefaultAppearance.nmTorso = 'RT_MamaMEA_Pathfinder_Und_Secondary_Torso_M';
	//CharTemplate.DefaultAppearance.nmArms = None;
	CharTemplate.DefaultAppearance.nmLegs = 'RT_MamaMEA_Pathfinder_Und_Legs_M';
	CharTemplate.DefaultAppearance.nmHelmet = 'RT_MamaMEA_Remnant_Heavy_Helmet_M';
	CharTemplate.DefaultAppearance.nmEye = 'DefaultEyes_3';
	CharTemplate.DefaultAppearance.nmTeeth = 'DefaultTeeth';
	CharTemplate.DefaultAppearance.nmFacePropLower = 'Prop_FaceLower_Blank';
	CharTemplate.DefaultAppearance.nmFacePropUpper = 'Prop_FaceUpper_Blank';
	CharTemplate.DefaultAppearance.nmPatterns = 'Pat_Nothing';
	CharTemplate.DefaultAppearance.nmVoice = 'MaleVoice6_English_US';
	//CharTemplate.DefaultAppearance.nmLanguage = None;
	CharTemplate.DefaultAppearance.nmTattoo_LeftArm = 'Tattoo_Arms_BLANK';
	CharTemplate.DefaultAppearance.nmTattoo_RightArm = 'Tattoo_Arms_BLANK';
	CharTemplate.DefaultAppearance.nmScars = 'Scars_BLANK';
	CharTemplate.DefaultAppearance.nmTorso_Underlay = 'CnvUnderlay_Std_Torsos_A_M';
	CharTemplate.DefaultAppearance.nmArms_Underlay = 'CnvUnderlay_Std_Arms_A_M';
	CharTemplate.DefaultAppearance.nmLegs_Underlay = 'CnvUnderlay_Std_Legs_A_M';
	//CharTemplate.DefaultAppearance.nmFacePaint = None;
	CharTemplate.DefaultAppearance.nmLeftArm = 'RT_MamaMEA_Pathfinder_Und_Secondary_Arm_Left_M';
	CharTemplate.DefaultAppearance.nmRightArm = 'RT_MamaMEA_Pathfinder_Und_Secondary_Arm_Right_M';
	CharTemplate.DefaultAppearance.nmLeftArmDeco = 'RT_MamaMEA_Remnant_Hvy_Arm_Left_M';
	CharTemplate.DefaultAppearance.nmRightArmDeco = 'RT_MamaMEA_Remnant_Hvy_Arm_Right_M';
	//CharTemplate.DefaultAppearance.nmLeftForearm = None;
	//CharTemplate.DefaultAppearance.nmRightForearm = None;
	//CharTemplate.DefaultAppearance.nmThighs = None;
	CharTemplate.DefaultAppearance.nmShins = 'RT_MamaMEA_Remnant_Hvy_Legs_M';
	CharTemplate.DefaultAppearance.nmTorsoDeco = 'RT_MamaMEA_Remnant_Hvy_Torso_M';
	CharTemplate.DefaultAppearance.bGhostPawn = False;

	CharTemplate.ReceivesProgramRankups = true;

	`RTLOG("Adding Whisper's character template!");
	return CharTemplate;
}

static function X2CharacterTemplate CreateQueenTemplate()
{
	local RTCharacterTemplate CharTemplate;

	CharTemplate = CreateProgramSoldierTemplate('RTGhostBerserker');
	
	CharTemplate.DefaultSoldierClass = 'RT_Berserker';
	CharTemplate.DefaultLoadout = 'RT_Berserker';
	CharTemplate.bIsPsionic = true;
	
	CharTemplate.bHasFullDefaultAppearance = true;
	CharTemplate.bAppearanceDefinesPawn = true;

	CharTemplate.DefaultAppearance.nmPawn = 'XCom_Soldier_F';
	CharTemplate.DefaultAppearance.nmHead = 'CaucFem_D';
	CharTemplate.DefaultAppearance.iGender = 2;
	CharTemplate.DefaultAppearance.iRace = 0;
	CharTemplate.DefaultAppearance.nmHaircut = 'FemHair_F';
	CharTemplate.DefaultAppearance.iHairColor = 17;
	CharTemplate.DefaultAppearance.iFacialHair = 0;
	CharTemplate.DefaultAppearance.nmBeard = 'MaleBeard_Blank';
	CharTemplate.DefaultAppearance.iSkinColor = 0;
	CharTemplate.DefaultAppearance.iEyeColor = 6;
	CharTemplate.DefaultAppearance.nmFlag = 'Country_USA';;
	CharTemplate.DefaultAppearance.iVoice = 0;
	CharTemplate.DefaultAppearance.iAttitude = 6;
	CharTemplate.DefaultAppearance.iArmorDeco = 0;
	CharTemplate.DefaultAppearance.iArmorTint = 92;
	CharTemplate.DefaultAppearance.iArmorTintSecondary = 91;
	CharTemplate.DefaultAppearance.iWeaponTint = 7;
	CharTemplate.DefaultAppearance.iTattooTint = 10;
	CharTemplate.DefaultAppearance.nmWeaponPattern = 'Hex';
	CharTemplate.DefaultAppearance.nmTorso = 'RT_MamaMEA_Pathfinder_Und_Secondary_Torso_F';
	CharTemplate.DefaultAppearance.nmArms = 'PwrLgt_Std_A_F';
	CharTemplate.DefaultAppearance.nmLegs = 'RT_MamaMEA_Pathfinder_Und_Legs_F';
	CharTemplate.DefaultAppearance.nmHelmet = 'RT_MamaMEA_Remnant_Heavy_Helmet_F';
	CharTemplate.DefaultAppearance.nmEye = 'DefaultEyes_3';
	CharTemplate.DefaultAppearance.nmTeeth = 'DefaultTeeth';
	CharTemplate.DefaultAppearance.nmFacePropLower = 'Prop_FaceLower_Blank';
	CharTemplate.DefaultAppearance.nmFacePropUpper = 'Prop_FaceUpper_Blank';
	CharTemplate.DefaultAppearance.nmPatterns = 'Pat_Nothing';
	CharTemplate.DefaultAppearance.nmVoice = 'FemaleVoice2_English_US';
	//CharTemplate.DefaultAppearance.nmLanguage = None;
	CharTemplate.DefaultAppearance.nmTattoo_LeftArm = 'Tattoo_Arms_BLANK';
	CharTemplate.DefaultAppearance.nmTattoo_RightArm = 'Tattoo_Arms_BLANK';
	CharTemplate.DefaultAppearance.nmScars = 'Scars_BLANK';
	CharTemplate.DefaultAppearance.nmTorso_Underlay = 'CnvUnderlay_Std_A_F';
	CharTemplate.DefaultAppearance.nmArms_Underlay = 'CnvMed_Underlay_A_F';
	CharTemplate.DefaultAppearance.nmLegs_Underlay = 'CnvUnderlay_Std_A_F';
	//CharTemplate.DefaultAppearance.nmFacePaint = None;
	CharTemplate.DefaultAppearance.nmLeftArm = 'RT_MamaMEA_Pathfinder_Und_Secondary_Arm_Left_F';
	CharTemplate.DefaultAppearance.nmRightArm = 'RT_MamaMEA_Pathfinder_Und_Secondary_Arm_Right_F';
	CharTemplate.DefaultAppearance.nmLeftArmDeco = 'RT_MamaMEA_Remnant_Hvy_Arm_Left_F';
	CharTemplate.DefaultAppearance.nmRightArmDeco = 'RT_MamaMEA_Remnant_Hvy_Arm_Right_F';
	//CharTemplate.DefaultAppearance.nmLeftForearm = None;
	//CharTemplate.DefaultAppearance.nmRightForearm = None;
	//CharTemplate.DefaultAppearance.nmThighs = None;
	CharTemplate.DefaultAppearance.nmShins = 'RT_MamaMEA_Remnant_Hvy_Legs_F';
	CharTemplate.DefaultAppearance.nmTorsoDeco = 'RT_MamaMEA_Remnant_Hvy_Torso_F';
	CharTemplate.DefaultAppearance.bGhostPawn = False;

	CharTemplate.ReceivesProgramRankups = true;

	`RTLOG("Adding Queen's character template!");
	return CharTemplate;
}

static function X2CharacterTemplate CreateNovaTemplate()
{
	local RTCharacterTemplate CharTemplate;

	CharTemplate = CreateProgramSoldierTemplate('RTGhostGatherer');
	
	CharTemplate.DefaultSoldierClass = 'RT_Gatherer';
	CharTemplate.DefaultLoadout = 'RT_Gatherer';
	CharTemplate.bIsPsionic = true;
	
	CharTemplate.bHasFullDefaultAppearance = true;
	CharTemplate.bAppearanceDefinesPawn = true;

	CharTemplate.DefaultAppearance.nmPawn = 'XCom_Soldier_F';
	CharTemplate.DefaultAppearance.nmHead = 'CaucFem_B';
	CharTemplate.DefaultAppearance.iGender = 2;
	CharTemplate.DefaultAppearance.iRace = 0;
	CharTemplate.DefaultAppearance.nmHaircut = 'FemHair_G';
	CharTemplate.DefaultAppearance.iHairColor = 7;
	CharTemplate.DefaultAppearance.iFacialHair = 0;
	CharTemplate.DefaultAppearance.nmBeard = 'MaleBeard_Blank';
	CharTemplate.DefaultAppearance.iSkinColor = 0;
	CharTemplate.DefaultAppearance.iEyeColor = 3;
	CharTemplate.DefaultAppearance.nmFlag = 'Country_USA';;
	CharTemplate.DefaultAppearance.iVoice = 0;
	CharTemplate.DefaultAppearance.iAttitude = 2;
	CharTemplate.DefaultAppearance.iArmorDeco = 0;
	CharTemplate.DefaultAppearance.iArmorTint = 92;
	CharTemplate.DefaultAppearance.iArmorTintSecondary = 91;
	CharTemplate.DefaultAppearance.iWeaponTint = 7;
	CharTemplate.DefaultAppearance.iTattooTint = 16;
	CharTemplate.DefaultAppearance.nmWeaponPattern = 'Hex';
	CharTemplate.DefaultAppearance.nmTorso = 'RT_MamaMEA_Pathfinder_Und_Torso_F';
	CharTemplate.DefaultAppearance.nmArms = 'PwrLgt_Std_A_F';
	CharTemplate.DefaultAppearance.nmLegs = 'RT_MamaMEA_Pathfinder_Und_Legs_F';
	CharTemplate.DefaultAppearance.nmHelmet = 'RT_MamaMEA_Remnant_Heavy_Helmet_F';
	CharTemplate.DefaultAppearance.nmEye = 'DefaultEyes_3';
	CharTemplate.DefaultAppearance.nmTeeth = 'DefaultTeeth';
	CharTemplate.DefaultAppearance.nmFacePropLower = 'Prop_FaceLower_Blank';
	CharTemplate.DefaultAppearance.nmFacePropUpper = 'Prop_FaceUpper_Blank';
	CharTemplate.DefaultAppearance.nmPatterns = 'Pat_Nothing';
	CharTemplate.DefaultAppearance.nmVoice = 'FemaleVoice10_English_US';
	//CharTemplate.DefaultAppearance.nmLanguage = None;
	CharTemplate.DefaultAppearance.nmTattoo_LeftArm = 'Tattoo_Arms_BLANK';
	CharTemplate.DefaultAppearance.nmTattoo_RightArm = 'Tattoo_Arms_BLANK';
	CharTemplate.DefaultAppearance.nmScars = 'Scars_BLANK';
	CharTemplate.DefaultAppearance.nmTorso_Underlay = 'CnvUnderlay_Std_A_F';
	CharTemplate.DefaultAppearance.nmArms_Underlay = 'CnvMed_Underlay_A_F';
	CharTemplate.DefaultAppearance.nmLegs_Underlay = 'CnvUnderlay_Std_A_F';
	//CharTemplate.DefaultAppearance.nmFacePaint = None;
	CharTemplate.DefaultAppearance.nmLeftArm = 'RT_MamaMEA_Pathfinder_Und_Secondary_Arm_Left_F';
	CharTemplate.DefaultAppearance.nmRightArm = 'RT_MamaMEA_Pathfinder_Und_Secondary_Arm_Right_F';
	CharTemplate.DefaultAppearance.nmLeftArmDeco = 'RT_MamaMEA_Remnant_Hvy_Arm_Left_F';
	CharTemplate.DefaultAppearance.nmRightArmDeco = 'RT_MamaMEA_Remnant_Hvy_Arm_Right_F';
	//CharTemplate.DefaultAppearance.nmLeftForearm = None;
	//CharTemplate.DefaultAppearance.nmRightForearm = None;
	//CharTemplate.DefaultAppearance.nmThighs = None;
	CharTemplate.DefaultAppearance.nmShins = 'RT_MamaMEA_Remnant_Hvy_Legs_F';
	CharTemplate.DefaultAppearance.nmTorsoDeco = 'RT_MamaMEA_Remnant_Hvy_Torso_F';
	CharTemplate.DefaultAppearance.bGhostPawn = False;

	CharTemplate.ReceivesProgramRankups = true;

	`RTLOG("Adding Nova's character template!");
	return CharTemplate;
}

static function X2CharacterTemplate CreateKagaTemplate()
{
	local RTCharacterTemplate CharTemplate;

	CharTemplate = CreateProgramSoldierTemplate('RTGhostOperator');
	
	CharTemplate.DefaultSoldierClass = 'RT_Gatherer';
	CharTemplate.DefaultLoadout = 'RT_Operator';
	CharTemplate.bIsPsionic = true;
	
	CharTemplate.bHasFullDefaultAppearance = true;
	CharTemplate.bAppearanceDefinesPawn = true;

	CharTemplate.DefaultAppearance.nmPawn = 'XCom_Soldier_F';
	// She looks the same as Nova, too lazy to make her Asian... fuck
	CharTemplate.DefaultAppearance.nmHead = 'CaucFem_D';
	CharTemplate.DefaultAppearance.iGender = 2;
	CharTemplate.DefaultAppearance.iRace = 0;
	CharTemplate.DefaultAppearance.nmHaircut = 'FemHair_F';
	CharTemplate.DefaultAppearance.iHairColor = 17;
	CharTemplate.DefaultAppearance.iFacialHair = 0;
	CharTemplate.DefaultAppearance.nmBeard = 'MaleBeard_Blank';
	CharTemplate.DefaultAppearance.iSkinColor = 0;
	CharTemplate.DefaultAppearance.iEyeColor = 6;
	CharTemplate.DefaultAppearance.nmFlag = 'Country_USA';
	CharTemplate.DefaultAppearance.iVoice = 0;
	CharTemplate.DefaultAppearance.iAttitude = 6;
	CharTemplate.DefaultAppearance.iArmorDeco = 0;
	CharTemplate.DefaultAppearance.iArmorTint = 92;
	CharTemplate.DefaultAppearance.iArmorTintSecondary = 91;
	CharTemplate.DefaultAppearance.iWeaponTint = 7;
	CharTemplate.DefaultAppearance.iTattooTint = 10;
	CharTemplate.DefaultAppearance.nmWeaponPattern = 'Hex';
	CharTemplate.DefaultAppearance.nmTorso = 'RT_MamaMEA_Pathfinder_Und_Secondary_Torso_F';
	CharTemplate.DefaultAppearance.nmArms = 'PwrLgt_Std_A_F';
	CharTemplate.DefaultAppearance.nmLegs = 'RT_MamaMEA_Pathfinder_Und_Legs_F';
	CharTemplate.DefaultAppearance.nmHelmet = 'RT_MamaMEA_Remnant_Heavy_Helmet_F';
	CharTemplate.DefaultAppearance.nmEye = 'DefaultEyes_3';
	CharTemplate.DefaultAppearance.nmTeeth = 'DefaultTeeth';
	CharTemplate.DefaultAppearance.nmFacePropLower = 'Prop_FaceLower_Blank';
	CharTemplate.DefaultAppearance.nmFacePropUpper = 'Prop_FaceUpper_Blank';
	CharTemplate.DefaultAppearance.nmPatterns = 'Pat_Nothing';
	CharTemplate.DefaultAppearance.nmVoice = 'FemaleVoice2_English_US';
	//CharTemplate.DefaultAppearance.nmLanguage = None;
	CharTemplate.DefaultAppearance.nmTattoo_LeftArm = 'Tattoo_Arms_BLANK';
	CharTemplate.DefaultAppearance.nmTattoo_RightArm = 'Tattoo_Arms_BLANK';
	CharTemplate.DefaultAppearance.nmScars = 'Scars_BLANK';
	CharTemplate.DefaultAppearance.nmTorso_Underlay = 'CnvUnderlay_Std_A_F';
	CharTemplate.DefaultAppearance.nmArms_Underlay = 'CnvMed_Underlay_A_F';
	CharTemplate.DefaultAppearance.nmLegs_Underlay = 'CnvUnderlay_Std_A_F';
	//CharTemplate.DefaultAppearance.nmFacePaint = None;
	CharTemplate.DefaultAppearance.nmLeftArm = 'RT_MamaMEA_Pathfinder_Und_Secondary_Arm_Left_F';
	CharTemplate.DefaultAppearance.nmRightArm = 'RT_MamaMEA_Pathfinder_Und_Secondary_Arm_Right_F';
	CharTemplate.DefaultAppearance.nmLeftArmDeco = 'RT_MamaMEA_Remnant_Hvy_Arm_Left_F';
	CharTemplate.DefaultAppearance.nmRightArmDeco = 'RT_MamaMEA_Remnant_Hvy_Arm_Right_F';
	//CharTemplate.DefaultAppearance.nmLeftForearm = None;
	//CharTemplate.DefaultAppearance.nmRightForearm = None;
	//CharTemplate.DefaultAppearance.nmThighs = None;
	CharTemplate.DefaultAppearance.nmShins = 'RT_MamaMEA_Remnant_Hvy_Legs_F';
	CharTemplate.DefaultAppearance.nmTorsoDeco = 'RT_MamaMEA_Remnant_Hvy_Torso_F';
	CharTemplate.DefaultAppearance.bGhostPawn = False;

	// Since Kaga can't get level ups, give her some abilities now
	CharTemplate.Abilities.AddItem('RTCrushingGrasp');
	CharTemplate.Abilities.AddItem('RTPsionicLash');
	CharTemplate.Abilities.AddItem('RTUnfurlTheVeil');
	CharTemplate.Abilities.AddItem('Fade');

	CharTemplate.ReceivesProgramRankups = false;

	`RTLOG("Adding Kaga's character template!");
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

static function RTCharacterTemplate CreateProgramDroneTemplate(name TemplateName) {
	local RTCharacterTemplate CharTemplate;

	`CREATE_X2TEMPLATE(class'RTCharacterTemplate', CharTemplate, TemplateName);
	CharTemplate.CharacterGroupName = 'ProgramDrone';

	CharTemplate.BehaviorClass=class'XGAIBehavior';

	CharTemplate.DefaultLoadout='ProgramDrone_Loadout';
	CharTemplate.strPawnArchetypes.AddItem("ProgramDrone.Archetypes.DroneArchetype"); 

	//NEW CINEMATIC?

	CharTemplate.UnitSize = 1;

	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = false;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = false;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = false;
	CharTemplate.bCanUse_eTraversal_DropDown = false;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = false;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bCanUse_eTraversal_Launch = true;
	CharTemplate.bCanUse_eTraversal_Flying = true;
	CharTemplate.bCanUse_eTraversal_Land = true;
	CharTemplate.bAppearanceDefinesPawn = false;    
	CharTemplate.bCanTakeCover = false;

	CharTemplate.bIsAlien = false;
	CharTemplate.bIsAdvent = false;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = true;
	CharTemplate.bIsSoldier = true;
	CharTemplate.bAppearInBase = false;

	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bCanBeCriticallyWounded = false;
	CharTemplate.bIsAfraidOfFire = false;

	CharTemplate.bAllowSpawnFromATT = false;  // If true, this unit can be spawned from an Advent Troop Transport
	CharTemplate.bWeakAgainstTechLikeRobot = true;

	CharTemplate.DefaultSoldierClass = 'ProgramDrone';
	CharTemplate.Abilities.AddItem('Loot');
	CharTemplate.Abilities.AddItem('Evac');
	CharTemplate.Abilities.AddItem('PlaceEvacZone');
	CharTemplate.Abilities.AddItem('LiftOffAvenger');

	//CharTemplate.Abilities.AddItem('RTProgramDroneCloakingProtocol');
	//CharTemplate.Abilities.AddItem('RobotImmunities');
	//CharTemplate.Abilities.AddItem('FireOnDeath');

	CharTemplate.strScamperBT = "ScamperRoot_NoCover";
	CharTemplate.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.KnockbackDamageType);

	//TODO: (ID 507) investigate possibilities for adding first-sighting narrative moment for new unit
	//CharTemplate.SightedNarrativeMoments.AddItem(XComNarrativeMoment'X2NarrativeMoments.TACTICAL.AlienSitings.T_Central_AlienSightings_Muton');

	CharTemplate.strHackIconImage = "UILibrary_Common.TargetIcons.Hack_robot_icon";
	CharTemplate.strTargetIconImage = class'UIUtilities_Image'.const.TargetIcon_XCom;  

	return CharTemplate;
}

