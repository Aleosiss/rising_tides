class RTItem extends X2Item_DefaultUpgrades config(RisingTides);

var config WeaponDamageValue PISTOL_PROGRAM_BASEDAMAGE_M1;
var config WeaponDamageValue PISTOL_PROGRAM_BASEDAMAGE_M2;
var config WeaponDamageValue PISTOL_PROGRAM_BASEDAMAGE_M3;
var config int PISTOL_PROGRAM_AIM;
var config int PISTOL_PROGRAM_CRITCHANCE;
var config int PISTOL_PROGRAM_ICLIPSIZE;
var config int PISTOL_PROGRAM_ISOUNDRANGE;
var config int PISTOL_PROGRAM_IENVIRONMENTDAMAGE;
var config int PISTOL_PROGRAM_IPOINTS;
var config name PISTOL_PROGRAM_TEMPLATENAME;

var config WeaponDamageValue SNIPERRIFLE_PROGRAM_BASEDAMAGE_M1;
var config WeaponDamageValue SNIPERRIFLE_PROGRAM_BASEDAMAGE_M2;
var config WeaponDamageValue SNIPERRIFLE_PROGRAM_BASEDAMAGE_M3;
var config int SNIPERRIFLE_PROGRAM_AIM;
var config int SNIPERRIFLE_PROGRAM_CRITCHANCE;
var config int SNIPERRIFLE_PROGRAM_ICLIPSIZE;
var config int SNIPERRIFLE_PROGRAM_ISOUNDRANGE;
var config int SNIPERRIFLE_PROGRAM_IENVIRONMENTDAMAGE;
var config name SNIPERRIFLE_PROGRAM_TEMPLATENAME;

var config WeaponDamageValue SHOTGUN_PROGRAM_BASEDAMAGE_M1;
var config WeaponDamageValue SHOTGUN_PROGRAM_BASEDAMAGE_M2;
var config WeaponDamageValue SHOTGUN_PROGRAM_BASEDAMAGE_M3;
var config int SHOTGUN_PROGRAM_AIM;
var config int SHOTGUN_PROGRAM_CRITCHANCE;
var config int SHOTGUN_PROGRAM_ICLIPSIZE;
var config int SHOTGUN_PROGRAM_ISOUNDRANGE;
var config int SHOTGUN_PROGRAM_IENVIRONMENTDAMAGE;
var config name SHOTGUN_PROGRAM_TEMPLATENAME;

var config WeaponDamageValue ASSAULTRIFLE_PROGRAM_BASEDAMAGE_M1;
var config WeaponDamageValue ASSAULTRIFLE_PROGRAM_BASEDAMAGE_M2;
var config WeaponDamageValue ASSAULTRIFLE_PROGRAM_BASEDAMAGE_M3;
var config int ASSAULTRIFLE_PROGRAM_AIM;
var config int ASSAULTRIFLE_PROGRAM_CRITCHANCE;
var config int ASSAULTRIFLE_PROGRAM_ICLIPSIZE;
var config int ASSAULTRIFLE_PROGRAM_ISOUNDRANGE;
var config int ASSAULTRIFLE_PROGRAM_IENVIRONMENTDAMAGE;
var config name ASSAULTRIFLE_PROGRAM_TEMPLATENAME;

var config WeaponDamageValue SWORD_PROGRAM_BASEDAMAGE_M1;
var config WeaponDamageValue SWORD_PROGRAM_BASEDAMAGE_M2;
var config WeaponDamageValue SWORD_PROGRAM_BASEDAMAGE_M3;
var config int SWORD_PROGRAM_AIM;
var config int SWORD_PROGRAM_CRITCHANCE;
var config int SWORD_PROGRAM_ISOUNDRANGE;
var config int SWORD_PROGRAM_IENVIRONMENTDAMAGE;
var config name SWORD_PROGRAM_TEMPLATENAME;

var config WeaponDamageValue WARPGRENADE_BASEDAMAGE;
var config int WARPGRENADE_ISOUNDRANGE;
var config int WARPGRENADE_IENVIRONMENTDAMAGE;
var config int WARPGRENADE_ISUPPLIES;
var config int WARPGRENADE_TRADINGPOSTVALUE;
var config int WARPGRENADE_IPOINTS;
var config int WARPGRENADE_ICLIPSIZE;
var config int WARPGRENADE_RANGE;
var config int WARPGRENADE_RADIUS;
var config int WARPGRENADE_SUPPLYCOST;

var config WeaponDamageValue WARPBOMB_BASEDAMAGE;
var config int WARPBOMB_ISOUNDRANGE;
var config int WARPBOMB_IENVIRONMENTDAMAGE;
var config int WARPBOMB_TRADINGPOSTVALUE;
var config int WARPBOMB_IPOINTS;
var config int WARPBOMB_ICLIPSIZE;
var config int WARPBOMB_RANGE;
var config int WARPBOMB_RADIUS;
var config int WARPBOMB_SUPPLYCOST;

var config name ARMOR_PROGRAM_TEMPLATENAME;
var config name ARMOR_PROGRAM_STATS_NAME;

var const array<name> ProgramWeaponTemplateNames;
var const array<name> UpgradableProgramWeaponTemplateNames;
var const array<name> WeaponTierSuffixes;

defaultproperties
{
	ProgramWeaponTemplateNames=(default.PISTOL_PROGRAM_TEMPLATENAME, default.SNIPERRIFLE_PROGRAM_TEMPLATENAME, default.SHOTGUN_PROGRAM_TEMPLATENAME, default.SWORD_PROGRAM_TEMPLATENAME, default.ASSAULTRIFLE_PROGRAM_TEMPLATENAME );
	UpgradableProgramWeaponTemplateNames=(default.SNIPERRIFLE_PROGRAM_TEMPLATENAME, default.SHOTGUN_PROGRAM_TEMPLATENAME, default.ASSAULTRIFLE_PROGRAM_TEMPLATENAME );
	WeaponTierSuffixes=( "_M1", "_M2", "_M3" );
}

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Items;
	local name IteratorName;
	
	//`RTLOG("Printing UpgradableProgramWeaponTemplateNames");
	//foreach default.UpgradableProgramWeaponTemplateNames(IteratorName) {
	//	`RTLOG("" $ IteratorName);
	//}
	//`RTLOG("Done----------------------------------------------");

	// Weapons
	Items.AddItem(CreateTemplate_ProgramPistol(1));
	Items.AddItem(CreateTemplate_ProgramPistol(2));
	Items.AddItem(CreateTemplate_ProgramPistol(3));

	Items.AddItem(CreateTemplate_ProgramSniperRifle(1));
	Items.AddItem(CreateTemplate_ProgramSniperRifle(2));
	Items.AddItem(CreateTemplate_ProgramSniperRifle(3));

	Items.AddItem(CreateTemplate_ProgramShotgun(1));
	Items.AddItem(CreateTemplate_ProgramShotgun(2));
	Items.AddItem(CreateTemplate_ProgramShotgun(3));

	Items.AddItem(CreateTemplate_ProgramBlade(1));
	Items.AddItem(CreateTemplate_ProgramBlade(2));
	Items.AddItem(CreateTemplate_ProgramBlade(3));

	Items.AddItem(CreateTemplate_ProgramAssaultRifle(1));
	Items.AddItem(CreateTemplate_ProgramAssaultRifle(2));
	Items.AddItem(CreateTemplate_ProgramAssaultRifle(3));

	// Weapon Upgrades
	Items.AddItem(CreateTemplate_CosmeticSilencer());

	// Armor
	Items.AddItem(CreateTemplate_ProgramArmor(1));
	Items.AddItem(CreateTemplate_ProgramArmor(2));
	Items.AddItem(CreateTemplate_ProgramArmor(3));

	// Gear


	// TEMPLAR
	Items.AddItem(CreateRTTemplarAutopistol('RTTemplarAutopistol_M1'));
	Items.AddItem(CreateRTTemplarAutopistol('RTTemplarAutopistol_M2'));
	Items.AddItem(CreateRTTemplarAutopistol('RTTemplarAutopistol_M3'));

	Items.AddItem(CreateRTTemplarGauntlet('RTTemplarGauntlet_M1'));
	Items.AddItem(CreateRTTemplarGauntlet('RTTemplarGauntlet_M2'));
	Items.AddItem(CreateRTTemplarGauntlet('RTTemplarGauntlet_M3'));

	Items.AddItem(CreateRTTemplarGauntlet_Left('RTTemplarGauntlet_M1'));
	Items.AddItem(CreateRTTemplarGauntlet_Left('RTTemplarGauntlet_M2'));
	Items.AddItem(CreateRTTemplarGauntlet_Left('RTTemplarGauntlet_M3'));

	Items.AddItem(CreateRTTemplarGauntlet('RTScholarGauntlet_M1'));
	Items.AddItem(CreateRTTemplarGauntlet('RTScholarGauntlet_M2'));
	Items.AddItem(CreateRTTemplarGauntlet('RTScholarGauntlet_M3'));

	Items.AddItem(CreateRTTemplarGauntlet_Left('RTScholarGauntlet_M1'));
	Items.AddItem(CreateRTTemplarGauntlet_Left('RTScholarGauntlet_M2'));
	Items.AddItem(CreateRTTemplarGauntlet_Left('RTScholarGauntlet_M3'));

	Items.AddItem(CreateRTTemplarPsiAmp('RTTemplarPsiAmp_M1'));
	Items.AddItem(CreateRTTemplarPsiAmp('RTTemplarPsiAmp_M2'));
	Items.AddItem(CreateRTTemplarPsiAmp('RTTemplarPsiAmp_M3'));

	Items.AddItem(CreateRTTemplarWarpGrenades());
	Items.AddItem(CreateRTTemplarWarpbombs());
	
	return Items;
}

static function X2DataTemplate CreateTemplate_ProgramPistol(int iTier)
{
	local X2WeaponTemplate Template;
	local name tierSuffix;

	tierSuffix = `RTS.getSuffixForTier(iTier);

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, `RTS.concatName(default.PISTOL_PROGRAM_TEMPLATENAME, tierSuffix));
	Template.WeaponPanelImage = "_Pistol";                       // used by the UI. Probably determines iconview of the weapon.

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'pistol';
	Template.WeaponTech = 'conventional';
	Template.strImage = "img:///UILibrary_DLC2Images.BeamShadowKeeper";
	Template.EquipSound = "Secondary_Weapon_Equip_Beam";
	Template.Tier = iTier + 1;

	Template.RangeAccuracy = class'X2Item_DefaultWeapons'.default.SHORT_BEAM_RANGE;

	switch(iTier) {
		case 1:
			Template.BaseDamage = default.PISTOL_PROGRAM_BASEDAMAGE_M1;
			break;
		case 2:
			Template.BaseDamage = default.PISTOL_PROGRAM_BASEDAMAGE_M2;
			break;
		case 3:
			Template.BaseDamage = default.PISTOL_PROGRAM_BASEDAMAGE_M3;
			break;
		default:
			`RTLOG("Warning, " $ GetFuncName() $ " was provided invalid tier, returning tier 3!", true, false);
			Template.BaseDamage = default.PISTOL_PROGRAM_BASEDAMAGE_M3;
			break;
	}	

	Template.Aim = default.PISTOL_PROGRAM_AIM;
	Template.CritChance = default.PISTOL_PROGRAM_CRITCHANCE;
	Template.iClipSize = default.PISTOL_PROGRAM_ICLIPSIZE;
	Template.iSoundRange = default.PISTOL_PROGRAM_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.PISTOL_PROGRAM_IENVIRONMENTDAMAGE;

	Template.OverwatchActionPoint = class'X2CharacterTemplateManager'.default.PistolOverwatchReserveActionPoint;
	Template.InfiniteAmmo = true;

	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.Abilities.AddItem('PistolOverwatch');
	Template.Abilities.AddItem('PistolOverwatchShot');
	Template.Abilities.AddItem('PistolReturnFire');
	//Template.Abilities.AddItem('HotLoadAmmo');
	//Template.Abilities.AddItem('Reload');
	//Template.Abilities.AddItem('Shadowfall');

	Template.SetAnimationNameForAbility('FanFire', 'FF_FireMultiShotBeamA');

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "FX_Beam_HunterPistol_RT.Weapons.WP_HunterPistol_RT";

	Template.iPhysicsImpulse = 5;

	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = false;
	Template.HideInInventory = true;

	Template.DamageTypeTemplateName = 'Projectile_BeamXCom';

	Template.bHideClipSizeStat = true;

	//class'RTHelpers_ItemTemplates'.static.AddFontColor(Template, `RTS.GetProgramColor());

	return Template;
}

static function X2DataTemplate CreateTemplate_ProgramSniperRifle(int iTier)
{
	local X2WeaponTemplate Template;
	local name tierSuffix;

	tierSuffix = `RTS.getSuffixForTier(iTier);

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, `RTS.concatName(default.SNIPERRIFLE_PROGRAM_TEMPLATENAME, tierSuffix));
	Template.WeaponPanelImage = "_BeamSniperRifle";

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'sniper_rifle';
	Template.WeaponTech = 'conventional';
	Template.strImage = "img:///UILibrary_Common.UI_BeamSniper.BeamSniper_Base";
	Template.EquipSound = "Beam_Weapon_Equip";
	Template.Tier = iTier + 1;

	Template.RangeAccuracy = class'X2Item_DefaultWeapons'.default.LONG_BEAM_RANGE;

	switch(iTier) {
		case 1:
			Template.BaseDamage = default.SNIPERRIFLE_PROGRAM_BASEDAMAGE_M1;
			break;
		case 2:
			Template.BaseDamage = default.SNIPERRIFLE_PROGRAM_BASEDAMAGE_M2;
			break;
		case 3:
			Template.BaseDamage = default.SNIPERRIFLE_PROGRAM_BASEDAMAGE_M3;
			break;
		default:
			`RTLOG("Warning, " $ GetFuncName() $ " was provided invalid tier, returning tier 3!", true, false);
			Template.BaseDamage = default.SNIPERRIFLE_PROGRAM_BASEDAMAGE_M3;
			break;
	}	

	Template.Aim = default.SNIPERRIFLE_PROGRAM_AIM;
	Template.CritChance = default.SNIPERRIFLE_PROGRAM_CRITCHANCE;
	Template.iClipSize = default.SNIPERRIFLE_PROGRAM_ICLIPSIZE;
	Template.iSoundRange = default.SNIPERRIFLE_PROGRAM_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SNIPERRIFLE_PROGRAM_IENVIRONMENTDAMAGE;
	Template.NumUpgradeSlots = 2;
	Template.iTypicalActionCost = 2;

	Template.InventorySlot = eInvSlot_PrimaryWeapon;
	Template.Abilities.AddItem('SniperStandardFire');
	Template.Abilities.AddItem('SniperRifleOverwatch');
	Template.Abilities.AddItem('OverwatchShot');
	Template.Abilities.AddItem('Reload');
	Template.Abilities.AddItem('HotLoadAmmo');
	
	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "FX_Beam_SniperRifle_RT.Weapons.WP_SniperRifle_RT";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Sniper';
	Template.AddDefaultAttachment('Optic', "BeamSniper.Meshes.SM_BeamSniper_OpticA", , "img:///UILibrary_Common.UI_BeamSniper.BeamSniper_OpticA");
	Template.AddDefaultAttachment('Mag', "BeamSniper.Meshes.SM_BeamSniper_MagA", , "img:///UILibrary_Common.UI_BeamSniper.BeamSniper_MagA");
	Template.AddDefaultAttachment('Suppressor', "BeamSniper.Meshes.SM_BeamSniper_SuppressorA", , "img:///UILibrary_Common.UI_BeamSniper.BeamSniper_SupressorA");
	Template.AddDefaultAttachment('Core', "BeamSniper.Meshes.SM_BeamSniper_CoreA", , "img:///UILibrary_Common.UI_BeamSniper.BeamSniper_CoreA");
	Template.AddDefaultAttachment('HeatSink', "BeamSniper.Meshes.SM_BeamSniper_HeatSinkA", , "img:///UILibrary_Common.UI_BeamSniper.BeamSniper_HeatsinkA");
	Template.AddDefaultAttachment('Light', "BeamAttachments.Meshes.BeamFlashLight");

	Template.iPhysicsImpulse = 5;

	Template.CanBeBuilt = false;
	Template.bInfiniteItem = false;
	Template.HideInInventory = true;

	Template.DamageTypeTemplateName = 'Projectile_BeamXCom';

	//class'RTHelpers_ItemTemplates'.static.AddFontColor(Template, `RTS.GetProgramColor());

	return Template;
}

static function X2DataTemplate CreateTemplate_ProgramShotgun(int iTier)
{
	local X2WeaponTemplate Template;
	local name tierSuffix;

	tierSuffix = `RTS.getSuffixForTier(iTier);

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, `RTS.concatName(default.SHOTGUN_PROGRAM_TEMPLATENAME, tierSuffix));
	Template.WeaponPanelImage = "_BeamShotgun";

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'shotgun';
	Template.WeaponTech = 'conventional';
	Template.strImage = "img:///UILibrary_Common.UI_BeamShotgun.BeamShotgun_Base";
	Template.EquipSound = "Beam_Weapon_Equip";
	Template.Tier = iTier + 1;

	Template.RangeAccuracy = class'X2Item_DefaultWeapons'.default.SHORT_BEAM_RANGE;

	switch(iTier) {
		case 1:
			Template.BaseDamage = default.SHOTGUN_PROGRAM_BASEDAMAGE_M1;
			break;
		case 2:
			Template.BaseDamage = default.SHOTGUN_PROGRAM_BASEDAMAGE_M2;
			break;
		case 3:
			Template.BaseDamage = default.SHOTGUN_PROGRAM_BASEDAMAGE_M3;
			break;
		default:
			`RTLOG("Warning, " $ GetFuncName() $ " was provided invalid tier, returning tier 3!", true, false);
			Template.BaseDamage = default.SHOTGUN_PROGRAM_BASEDAMAGE_M3;
			break;
	}	

	Template.Aim = default.SHOTGUN_PROGRAM_AIM;
	Template.CritChance = default.SHOTGUN_PROGRAM_CRITCHANCE;
	Template.iClipSize = default.SHOTGUN_PROGRAM_ICLIPSIZE;
	Template.iSoundRange = default.SHOTGUN_PROGRAM_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SHOTGUN_PROGRAM_IENVIRONMENTDAMAGE;
	Template.NumUpgradeSlots = 2;

	Template.InventorySlot = eInvSlot_PrimaryWeapon;
	Template.Abilities.AddItem('StandardShot');
	Template.Abilities.AddItem('Overwatch');
	Template.Abilities.AddItem('OverwatchShot');
	Template.Abilities.AddItem('Reload');
	Template.Abilities.AddItem('HotLoadAmmo');
	
	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "FX_Beam_Shotgun_RT.Weapons.WP_Shotgun_RT";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Shotgun';
	Template.AddDefaultAttachment('Mag', "BeamShotgun.Meshes.SM_BeamShotgun_MagA", , "img:///UILibrary_Common.UI_BeamShotgun.BeamShotgun_MagA");
	Template.AddDefaultAttachment('Suppressor', "BeamShotgun.Meshes.SM_BeamShotgun_SuppressorA", , "img:///UILibrary_Common.UI_BeamShotgun.BeamShotgun_SupressorA");
	Template.AddDefaultAttachment('Core_Left', "BeamShotgun.Meshes.SM_BeamShotgun_CoreA", , "img:///UILibrary_Common.UI_BeamShotgun.BeamShotgun_CoreA");
	Template.AddDefaultAttachment('Core_Right', "BeamShotgun.Meshes.SM_BeamShotgun_CoreA");
	Template.AddDefaultAttachment('HeatSink', "BeamShotgun.Meshes.SM_BeamShotgun_HeatSinkA", , "img:///UILibrary_Common.UI_BeamShotgun.BeamShotgun_HeatsinkA");
	Template.AddDefaultAttachment('Foregrip', "BeamShotgun.Meshes.SM_BeamShotgun_ForegripA", , "img:///UILibrary_Common.UI_BeamShotgun.BeamShotgun_Foregrip");
	Template.AddDefaultAttachment('Light', "BeamAttachments.Meshes.BeamFlashLight");

	Template.iPhysicsImpulse = 5;

	Template.fKnockbackDamageAmount = 10.0f;
	Template.fKnockbackDamageRadius = 16.0f;

	Template.CanBeBuilt = false;
	Template.bInfiniteItem = false;
	Template.HideInInventory = true;

	Template.DamageTypeTemplateName = 'Projectile_BeamXCom';

	//class'RTHelpers_ItemTemplates'.static.AddFontColor(Template, `RTS.GetProgramColor());

	return Template;
}

static function X2DataTemplate CreateTemplate_ProgramAssaultRifle(int iTier)
{
	local X2WeaponTemplate Template;
	local name tierSuffix;

	tierSuffix = `RTS.getSuffixForTier(iTier);

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, `RTS.concatName(default.ASSAULTRIFLE_PROGRAM_TEMPLATENAME, tierSuffix));
	Template.WeaponPanelImage = "_BeamRifle";                       // used by the UI. Probably determines iconview of the weapon.

	Template.WeaponCat = 'rifle';
	Template.WeaponTech = 'conventional';
	Template.ItemCat = 'weapon';
	Template.strImage = "img:///UILibrary_Common.UI_BeamAssaultRifle.BeamAssaultRifle_Base";
	Template.EquipSound = "Beam_Weapon_Equip";
	Template.Tier = iTier + 1;

	Template.RangeAccuracy = class'X2Item_DefaultWeapons'.default.MEDIUM_BEAM_RANGE;

	switch(iTier) {
		case 1:
			Template.BaseDamage = default.ASSAULTRIFLE_PROGRAM_BASEDAMAGE_M1;
			break;
		case 2:
			Template.BaseDamage = default.ASSAULTRIFLE_PROGRAM_BASEDAMAGE_M2;
			break;
		case 3:
			Template.BaseDamage = default.ASSAULTRIFLE_PROGRAM_BASEDAMAGE_M3;
			break;
		default:
			`RTLOG("Warning, " $ GetFuncName() $ " was provided invalid tier, returning tier 3!", true, false);
			Template.BaseDamage = default.ASSAULTRIFLE_PROGRAM_BASEDAMAGE_M3;
			break;
	}

	Template.Aim = default.ASSAULTRIFLE_PROGRAM_AIM;
	Template.CritChance = default.ASSAULTRIFLE_PROGRAM_CRITCHANCE;
	Template.iClipSize = default.ASSAULTRIFLE_PROGRAM_ICLIPSIZE;
	Template.iSoundRange = default.ASSAULTRIFLE_PROGRAM_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.ASSAULTRIFLE_PROGRAM_IENVIRONMENTDAMAGE;

	Template.NumUpgradeSlots = 2;
	
	Template.InventorySlot = eInvSlot_PrimaryWeapon;
	Template.Abilities.AddItem('StandardShot');
	Template.Abilities.AddItem('Overwatch');
	Template.Abilities.AddItem('OverwatchShot');
	Template.Abilities.AddItem('Reload');
	Template.Abilities.AddItem('HotLoadAmmo');
	
	Template.GameArchetype = "FX_Beam_Rifle_RT.Weapons.WP_AssaultRifle_RT";
	Template.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
	Template.AddDefaultAttachment('Mag', "BeamAssaultRifle.Meshes.SM_BeamAssaultRifle_MagA", , "img:///UILibrary_Common.UI_BeamAssaultRifle.BeamAssaultRifle_MagA");
	Template.AddDefaultAttachment('Suppressor', "BeamAssaultRifle.Meshes.SM_BeamAssaultRifle_SuppressorA", , "img:///UILibrary_Common.UI_BeamAssaultRifle.BeamAssaultRifle_SupressorA");
	Template.AddDefaultAttachment('Core', "BeamAssaultRifle.Meshes.SM_BeamAssaultRifle_CoreA", , "img:///UILibrary_Common.UI_BeamAssaultRifle.BeamAssaultRifle_CoreA");
	Template.AddDefaultAttachment('HeatSink', "BeamAssaultRifle.Meshes.SM_BeamAssaultRifle_HeatSinkA", , "img:///UILibrary_Common.UI_BeamAssaultRifle.BeamAssaultRifle_HeatsinkA");
	Template.AddDefaultAttachment('Light', "BeamAttachments.Meshes.BeamFlashLight");

	Template.iPhysicsImpulse = 5;

	Template.CanBeBuilt = false;
	Template.bInfiniteItem = false;
	Template.HideInInventory = true;

	Template.DamageTypeTemplateName = 'Projectile_BeamXCom';

	//class'RTHelpers_ItemTemplates'.static.AddFontColor(Template, `RTS.GetProgramColor());

	return Template;
}

static function X2DataTemplate CreateTemplate_ProgramBlade(int iTier)
{
	local X2WeaponTemplate Template;
	local name tierSuffix;

	tierSuffix = `RTS.getSuffixForTier(iTier);

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, `RTS.concatName(default.SWORD_PROGRAM_TEMPLATENAME, tierSuffix));
	Template.WeaponPanelImage = "_Sword";                       // used by the UI. Probably determines iconview of the weapon.

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'sword';
	Template.WeaponTech = 'conventional';
	Template.strImage = "img:///UILibrary_Common.BeamSecondaryWeapons.BeamSword";
	Template.EquipSound = "Sword_Equip_Beam";
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.StowedLocation = eSlot_RightBack;
	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "FX_Beam_Sword_RT.WP_Sword_RT";
	Template.AddDefaultAttachment('R_Back', "BeamSword.Meshes.SM_BeamSword_Sheath", false);
	Template.Tier = iTier + 1;

	Template.iRadius = 1;
	Template.NumUpgradeSlots = 2;
	Template.InfiniteAmmo = true;
	Template.iPhysicsImpulse = 5;

	Template.iRange = 0;

	switch(iTier) {
		case 1:
			Template.BaseDamage = default.SWORD_PROGRAM_BASEDAMAGE_M1;
			break;
		case 2:
			Template.BaseDamage = default.SWORD_PROGRAM_BASEDAMAGE_M2;
			break;
		case 3:
			Template.BaseDamage = default.SWORD_PROGRAM_BASEDAMAGE_M3;
			break;
		default:
			`RTLOG("Warning, " $ GetFuncName() $ " was provided invalid tier, returning tier 3!", true, false);
			Template.BaseDamage = default.SWORD_PROGRAM_BASEDAMAGE_M3;
	}

	Template.Aim = default.SWORD_PROGRAM_AIM;
	Template.CritChance = default.SWORD_PROGRAM_CRITCHANCE;
	Template.BaseDamage.DamageType='Melee';
	Template.iSoundRange = default.SWORD_PROGRAM_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SWORD_PROGRAM_IENVIRONMENTDAMAGE;

	Template.CanBeBuilt = false;
	Template.bInfiniteItem = false;
	Template.HideInInventory = true;

	Template.DamageTypeTemplateName = 'Melee';

	//class'RTHelpers_ItemTemplates'.static.AddFontColor(Template, `RTS.GetProgramColor());
	
	return Template;
}

static function X2DataTemplate CreateTemplate_ProgramArmor(int iTier)
{
	local X2ArmorTemplate Template;
	local name tierSuffix;

	tierSuffix = `RTS.getSuffixForTier(iTier);

	`CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, `RTS.concatName(default.ARMOR_PROGRAM_TEMPLATENAME, tierSuffix));
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Warden_Armor";
	Template.ItemCat = 'armor';
	Template.bAddsUtilitySlot = true;
	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = false;
	Template.Abilities.AddItem(`RTS.concatName(default.ARMOR_PROGRAM_STATS_NAME, tierSuffix));
	Template.ArmorTechCat = 'powered';
	Template.ArmorClass = 'medium';
	Template.Tier = iTier + 1;

	switch(iTier) {
		case 1:
			Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'RTAbility_Program'.default.PROGRAM_ARMOR_HEALTH_BONUS_M1, true);
			Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'RTAbility_Program'.default.PROGRAM_ARMOR_MITIGATION_AMOUNT_M1);
			break;
		case 2:
			Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'RTAbility_Program'.default.PROGRAM_ARMOR_HEALTH_BONUS_M2, true);
			Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'RTAbility_Program'.default.PROGRAM_ARMOR_MITIGATION_AMOUNT_M2);
			break;
		case 3:
			Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'RTAbility_Program'.default.PROGRAM_ARMOR_HEALTH_BONUS_M3, true);
			Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'RTAbility_Program'.default.PROGRAM_ARMOR_MITIGATION_AMOUNT_M3);
			break;
		default:
			`RTLOG("Warning, " $ GetFuncName() $ " was provided invalid tier, returning tier 3!", true, false);
			Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'RTAbility_Program'.default.PROGRAM_ARMOR_HEALTH_BONUS_M3, true);
			Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'RTAbility_Program'.default.PROGRAM_ARMOR_MITIGATION_AMOUNT_M3);
	}

	Template.HideInInventory = true;
	

	//class'RTHelpers_ItemTemplates'.static.AddFontColor(Template, `RTS.GetProgramColor());
	
	return Template;
}

static function X2DataTemplate CreateTemplate_CosmeticSilencer() {
	local X2WeaponUpgradeTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponUpgradeTemplate', Template, 'RTCosmetic_Suppressor');

	SetUpCosmeticSilencerUpgrade(Template);

	Template.HideInInventory = true;
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.BeamAssaultRifle_SupressorB_inv";
	
	return Template;
}

static function SetUpCosmeticSilencerUpgrade(out X2WeaponUpgradeTemplate Template) {
	local name IteratorName;

	SetUpWeaponUpgrade(Template);

	Template.MutuallyExclusiveUpgrades.AddItem('FreeKillUpgrade');
	Template.MutuallyExclusiveUpgrades.AddItem('FreeKillUpgrade_Bsc');
	Template.MutuallyExclusiveUpgrades.AddItem('FreeKillUpgrade_Adv');
	Template.MutuallyExclusiveUpgrades.AddItem('FreeKillUpgrade_Sup');
	
	// Program Weapons and Tiers
	foreach default.WeaponTierSuffixes(IteratorName) {
		Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Suppressor', "BeamAssaultRifle.Meshes.SM_BeamAssaultRifle_SuppressorB", "", `RTS.concatName(default.ASSAULTRIFLE_PROGRAM_TEMPLATENAME, IteratorName), , "img:///UILibrary_Common.UI_BeamAssaultRifle.BeamAssaultRifle_SupressorB", "img:///UILibrary_StrategyImages.X2InventoryIcons.BeamAssaultRifle_SupressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
		Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Shotgun_Suppressor', "BeamShotgun.Meshes.SM_BeamShotgun_SuppressorB", "", `RTS.concatName(default.SHOTGUN_PROGRAM_TEMPLATENAME, IteratorName), , "img:///UILibrary_Common.UI_BeamShotgun.BeamShotgun_SupressorB", "img:///UILibrary_StrategyImages.X2InventoryIcons.BeamShotgun_SupressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
		Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Sniper_Suppressor', "BeamSniper.Meshes.SM_BeamSniper_SuppressorB", "", `RTS.concatName(default.SNIPERRIFLE_PROGRAM_TEMPLATENAME, IteratorName), , "img:///UILibrary_Common.UI_BeamSniper.BeamSniper_SupressorB", "img:///UILibrary_StrategyImages.X2InventoryIcons.BeamSniper_SupressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	}

	// Assault Rifles
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Suppressor', "ConvAssaultRifle.Meshes.SM_ConvAssaultRifle_SuppressorB", "", 'AssaultRifle_CV', , "img:///UILibrary_Common.ConvAssaultRifle.ConvAssault_SuppressorB", "img:///UILibrary_StrategyImages.X2InventoryIcons.ConvAssault_SuppressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Suppressor', "MagAssaultRifle.Meshes.SM_MagAssaultRifle_SuppressorB", "", 'AssaultRifle_MG', , "img:///UILibrary_Common.UI_MagAssaultRifle.MagAssaultRifle_SupressorB", "img:///UILibrary_StrategyImages.X2InventoryIcons.MagAssaultRifle_SupressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Suppressor', "BeamAssaultRifle.Meshes.SM_BeamAssaultRifle_SuppressorB", "", 'AssaultRifle_BM', , "img:///UILibrary_Common.UI_BeamAssaultRifle.BeamAssaultRifle_SupressorB", "img:///UILibrary_StrategyImages.X2InventoryIcons.BeamAssaultRifle_SupressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	Template.AddUpgradeAttachment('Suppressor', '', "", "", 'AssaultRifle_Central', , "", "", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");

	// Shotguns
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Shotgun_Suppressor', "ConvShotgun.Meshes.SM_ConvShotgun_SuppressorB", "", 'Shotgun_CV', , "img:///UILibrary_Common.ConvShotgun.ConvShotgun_SuppressorB", "img:///UILibrary_StrategyImages.X2InventoryIcons.ConvShotgun_SuppressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Shotgun_Suppressor', "MagShotgun.Meshes.SM_MagShotgun_SuppressorB", "", 'Shotgun_MG', , "img:///UILibrary_Common.UI_MagShotgun.MagShotgun_SuppressorB", "img:///UILibrary_StrategyImages.X2InventoryIcons.MagShotgun_SuppressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Shotgun_Suppressor', "BeamShotgun.Meshes.SM_BeamShotgun_SuppressorB", "", 'Shotgun_BM', , "img:///UILibrary_Common.UI_BeamShotgun.BeamShotgun_SupressorB", "img:///UILibrary_StrategyImages.X2InventoryIcons.BeamShotgun_SupressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");

	// Sniper Rifles
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Sniper_Suppressor', "ConvSniper.Meshes.SM_ConvSniper_SuppressorB", "", 'SniperRifle_CV', , "img:///UILibrary_Common.ConvSniper.ConvSniper_SuppressorB", "img:///UILibrary_StrategyImages.X2InventoryIcons.ConvSniper_SuppressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Sniper_Suppressor', "MagSniper.Meshes.SM_MagSniper_SuppressorB", "", 'SniperRifle_MG', , "img:///UILibrary_Common.UI_MagSniper.MagSniper_SuppressorB", "img:///UILibrary_StrategyImages.X2InventoryIcons.MagSniper_SuppressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Sniper_Suppressor', "BeamSniper.Meshes.SM_BeamSniper_SuppressorB", "", 'SniperRifle_BM', , "img:///UILibrary_Common.UI_BeamSniper.BeamSniper_SupressorB", "img:///UILibrary_StrategyImages.X2InventoryIcons.BeamSniper_SupressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");

	// Cannons
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Cannon_Suppressor', "ConvCannon.Meshes.SM_ConvCannon_SuppressorB", "", 'Cannon_CV', , "img:///UILibrary_Common.ConvCannon.ConvCannon_SuppressorB", "img:///UILibrary_StrategyImages.X2InventoryIcons.ConvCannon_SuppressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Cannon_Suppressor', "MagCannon.Meshes.SM_MagCannon_SuppressorB", "", 'Cannon_MG', , "img:///UILibrary_Common.UI_MagCannon.MagCannon_SuppressorB", "img:///UILibrary_StrategyImages.X2InventoryIcons.MagCannon_SuppressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Cannon_Suppressor', "BeamCannon.Meshes.SM_BeamCannon_SuppressorB", "", 'Cannon_BM', , "img:///UILibrary_Common.UI_BeamCannon.BeamCannon_SupressorB", "img:///UILibrary_StrategyImages.X2InventoryIcons.BeamCannon_SupressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");

	// Bullpups
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Shotgun_Suppressor', "CnvSMG.Meshes.SM_HOR_Cnv_SMG_SuppressorB", "", 'Bullpup_CV', , "img:///UILibrary_XPACK_Common.ConvSMG_SuppressorB", "img:///UILibrary_XPACK_StrategyImages.ConvSMG_SuppressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Shotgun_Suppressor', "MagSMG.Meshes.SM_HOR_Mag_SMG_SuppressorB", "", 'Bullpup_MG', , "img:///UILibrary_XPACK_Common.MagSMG_SuppressorB", "img:///UILibrary_XPACK_StrategyImages.MagSMG_SuppressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Shotgun_Suppressor', "BemSMG.Meshes.SM_HOR_Bem_SMG_SuppressorB", "", 'Bullpup_BM', , "img:///UILibrary_XPACK_Common.BeamSMG_SuppressorB", "img:///UILibrary_XPACK_StrategyImages.BeamSMG_SuppressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");

	// Vektor Rifles
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Sniper_Suppressor', "CnvReaperRifle.Meshes.SM_HOR_Cnv_ReaperRifle_SuppressorB", "", 'VektorRifle_CV', , "img:///UILibrary_XPACK_Common.ConvVektor_SuppressorB", "img:///UILibrary_XPACK_StrategyImages.ConvVektor_SuppressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Sniper_Suppressor', "MagReaperRifle.Meshes.SM_HOR_Mag_ReaperRifle_SuppressorB", "", 'VektorRifle_MG', , "img:///UILibrary_XPACK_Common.MagVektor_SuppressorB", "img:///UILibrary_XPACK_StrategyImages.MagVektor_SuppressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	Template.AddUpgradeAttachment('Suppressor', 'UIPawnLocation_WeaponUpgrade_Sniper_Suppressor', "BemReaperRifle.Meshes.SM_HOR_Bem_ReaperRifle_SuppressorB", "", 'VektorRifle_BM', , "img:///UILibrary_XPACK_Common.BeamVektor_SuppressorB", "img:///UILibrary_XPACK_StrategyImages.BeamVektor_SuppressorB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");

	// Chosen Weapons
	Template.AddUpgradeAttachment('Suppressor', '', "", "", 'ChosenRifle_XCOM', , "", "", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	Template.AddUpgradeAttachment('Suppressor', '', "", "", 'ChosenSniperRifle_XCOM', , "", "", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");
	Template.AddUpgradeAttachment('Suppressor', '', "", "", 'ChosenShotgun_XCOM', , "", "", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_barrel");

}

static function AddProgramAttachmentTemplates() {
	local X2WeaponUpgradeTemplate Template;
	local X2ItemTemplateManager ItemMgr;
	local array<X2WeaponUpgradeTemplate> Templates;
	local name IteratorName;
	// ClipSizeUpgrade_Sup
	// CritUpgrade_Sup

	ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Templates = ItemMgr.GetAllUpgradeTemplates();

	foreach Templates(Template) {
		foreach default.WeaponTierSuffixes(IteratorName) {
			switch(Template.DataName) {
				case 'ClipSizeUpgrade_Sup':
					Template.AddUpgradeAttachment('Mag', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Mag', "BeamAssaultRifle.Meshes.SM_BeamAssaultRifle_MagB", "", `RTS.concatName(default.ASSAULTRIFLE_PROGRAM_TEMPLATENAME, IteratorName), , "img:///UILibrary_Common.UI_BeamAssaultRifle.BeamAssaultRifle_MagB", "img:///UILibrary_StrategyImages.X2InventoryIcons.BeamAssaultRifle_MagB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_clip");
					Template.AddUpgradeAttachment('Mag', 'UIPawnLocation_WeaponUpgrade_Shotgun_Mag', "BeamShotgun.Meshes.SM_BeamShotgun_MagB", "", `RTS.concatName(default.SHOTGUN_PROGRAM_TEMPLATENAME, IteratorName), , "img:///UILibrary_Common.UI_BeamShotgun.BeamShotgun_MagB", "img:///UILibrary_StrategyImages.X2InventoryIcons.BeamShotgun_MagB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_clip", NoReloadUpgradePresent);
					Template.AddUpgradeAttachment('Mag', 'UIPawnLocation_WeaponUpgrade_Sniper_Mag', "BeamSniper.Meshes.SM_BeamSniper_MagB", "", `RTS.concatName(default.SNIPERRIFLE_PROGRAM_TEMPLATENAME, IteratorName), , "img:///UILibrary_Common.UI_BeamSniper.BeamSniper_MagB", "img:///UILibrary_StrategyImages.X2InventoryIcons.BeamSniper_MagB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_clip");
					break;
				case 'CritUpgrade_Sup':
					Template.AddUpgradeAttachment('Optic', 'UIPawnLocation_WeaponUpgrade_AssaultRifle_Optic', "BeamAssaultRifle.Meshes.SM_BeamAssaultRifle_OpticB", "", `RTS.concatName(default.ASSAULTRIFLE_PROGRAM_TEMPLATENAME, IteratorName), , "img:///UILibrary_Common.UI_BeamAssaultRifle.BeamAssaultRifle_OpticA", "img:///UILibrary_StrategyImages.X2InventoryIcons.BeamAssaultRifle_OpticA_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_scope");
					Template.AddUpgradeAttachment('Optic', 'UIPawnLocation_WeaponUpgrade_Shotgun_Optic', "BeamShotgun.Meshes.SM_BeamShotgun_OpticB", "", `RTS.concatName(default.SHOTGUN_PROGRAM_TEMPLATENAME, IteratorName), , "img:///UILibrary_Common.UI_BeamShotgun.BeamShotgun_OpticA", "img:///UILibrary_StrategyImages.X2InventoryIcons.BeamShotgun_OpticA_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_scope");
					Template.AddUpgradeAttachment('Optic', 'UIPawnLocation_WeaponUpgrade_Sniper_Optic', "BeamSniper.Meshes.SM_BeamSniper_OpticB", "", `RTS.concatName(default.SNIPERRIFLE_PROGRAM_TEMPLATENAME, IteratorName), , "img:///UILibrary_Common.UI_BeamSniper.BeamSniper_OpticB", "img:///UILibrary_StrategyImages.X2InventoryIcons.BeamSniper_OpticB_inv", "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_weaponIcon_scope");
					break;
			}
		}
	}
}

static function X2DataTemplate CreateRTTemplarAutopistol(name TemplateName)
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, TemplateName);
	Template.WeaponPanelImage = "_Pistol";                       // used by the UI. Probably determines iconview of the weapon.
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'sidearm';
	Template.HideInInventory = true;

	switch(TemplateName) {
		case 'RTTemplarAutopistol_M1':
			Template.GameArchetype = "WP_TemplarAutoPistol_CV.WP_TemplarAutoPistol_CV";
			Template.WeaponTech = 'conventional';
			Template.DamageTypeTemplateName = 'Projectile_Conventional';
			Template.strImage = "img:///UILibrary_XPACK_StrategyImages.Inv_ConvTPistol_Base";
			
			Template.RangeAccuracy = class'X2Item_DefaultWeapons'.default.SHORT_CONVENTIONAL_RANGE;
			Template.BaseDamage = class'X2Item_XpackWeapons'.default.SIDEARM_CONVENTIONAL_BASEDAMAGE;
			Template.Aim = class'X2Item_XpackWeapons'.default.SIDEARM_CONVENTIONAL_AIM;
			Template.CritChance = class'X2Item_XpackWeapons'.default.SIDEARM_CONVENTIONAL_CRITCHANCE;
			Template.iClipSize = class'X2Item_XpackWeapons'.default.SIDEARM_CONVENTIONAL_ICLIPSIZE;
			Template.iSoundRange = class'X2Item_XpackWeapons'.default.SIDEARM_CONVENTIONAL_ISOUNDRANGE;
			Template.iEnvironmentDamage =class'X2Item_XpackWeapons'.default.SIDEARM_CONVENTIONAL_IENVIRONMENTDAMAGE;
			Template.iIdealRange = 4;
			break;
		case 'RTTemplarAutopistol_M2':
			Template.GameArchetype = "WP_TemplarAutoPistol_MG.WP_TemplarAutoPistol_MG";
			Template.WeaponTech = 'magnetic';
			Template.DamageTypeTemplateName = 'Projectile_MagXCom';
			Template.strImage = "img:///UILibrary_XPACK_StrategyImages.Inv_MagTPistol_Base";

			Template.RangeAccuracy = class'X2Item_DefaultWeapons'.default.SHORT_MAGNETIC_RANGE;
			Template.BaseDamage = class'X2Item_XpackWeapons'.default.SIDEARM_MAGNETIC_BASEDAMAGE;
			Template.Aim = class'X2Item_XpackWeapons'.default.SIDEARM_MAGNETIC_AIM;
			Template.CritChance = class'X2Item_XpackWeapons'.default.SIDEARM_MAGNETIC_CRITCHANCE;
			Template.iClipSize = class'X2Item_XpackWeapons'.default.SIDEARM_MAGNETIC_ICLIPSIZE;
			Template.iSoundRange = class'X2Item_XpackWeapons'.default.SIDEARM_MAGNETIC_ISOUNDRANGE;
			Template.iEnvironmentDamage =class'X2Item_XpackWeapons'.default.SIDEARM_MAGNETIC_IENVIRONMENTDAMAGE;
			Template.iIdealRange = 4;
			break;
		case 'RTTemplarAutopistol_M3':
			Template.GameArchetype = "WP_TemplarAutoPistol_BM.WP_TemplarAutoPistol_BM";
			Template.WeaponTech = 'beam';
			Template.DamageTypeTemplateName = 'Projectile_BeamXCom';
			Template.strImage = "img:///UILibrary_XPACK_StrategyImages.Inv_BeamTPistol_Base";

			Template.RangeAccuracy = class'X2Item_DefaultWeapons'.default.SHORT_BEAM_RANGE;
			Template.BaseDamage = class'X2Item_XpackWeapons'.default.SIDEARM_BEAM_BASEDAMAGE;
			Template.Aim = class'X2Item_XpackWeapons'.default.SIDEARM_BEAM_AIM;
			Template.CritChance = class'X2Item_XpackWeapons'.default.SIDEARM_BEAM_CRITCHANCE;
			Template.iClipSize = class'X2Item_XpackWeapons'.default.SIDEARM_BEAM_ICLIPSIZE;
			Template.iSoundRange = class'X2Item_XpackWeapons'.default.SIDEARM_BEAM_ISOUNDRANGE;
			Template.iEnvironmentDamage =class'X2Item_XpackWeapons'.default.SIDEARM_BEAM_IENVIRONMENTDAMAGE;
			Template.iIdealRange = 4;
			break;
		default:
			`RTLOG("Error, tried to make an invalid RTTemplarAutopistol! " $ TemplateName $ "", true, false);
			return none;
	}

	Template.EquipSound = "Secondary_Weapon_Equip_Conventional";

	Template.InfiniteAmmo = true;
	Template.OverwatchActionPoint = class'X2CharacterTemplateManager'.default.PistolOverwatchReserveActionPoint;
	
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.Abilities.AddItem('PistolStandardShot');
	Template.Abilities.AddItem('PistolOverwatch');
	Template.Abilities.AddItem('PistolOverwatchShot');
	Template.Abilities.AddItem('PistolReturnFire');
	Template.Abilities.AddItem('HotLoadAmmo');
	Template.Abilities.AddItem('Reload');

	Template.SetAnimationNameForAbility('FanFire', 'FF_FireMultiShotConvA');	

	Template.iPhysicsImpulse = 5;
	Template.CanBeBuilt = false;
	//Template.bHideClipSizeStat = true;

	return Template;
}

static function X2DataTemplate CreateRTTemplarGauntlet(name TemplateName)
{
	local X2PairedWeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2PairedWeaponTemplate', Template, TemplateName);
	Template.WeaponPanelImage = "_Sword";                       // used by the UI. Probably determines iconview of the weapon.
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'gauntlet';

	Template.PairedSlot = eInvSlot_TertiaryWeapon;
	Template.PairedTemplateName = name(TemplateName $ '_Left'); // CreateRTTemplarGauntlet_Left mirrors this

	Template.InventorySlot = eInvSlot_PrimaryWeapon;
	Template.bUseArmorAppearance = true;
	Template.iRadius = 1;
	Template.NumUpgradeSlots = 0;
	Template.InfiniteAmmo = true;
	Template.iPhysicsImpulse = 5;
	Template.iRange = 0;
	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;
	Template.DamageTypeTemplateName = 'Melee';
	Template.HideInInventory = true;

	Template.Abilities.AddItem('Rend');
	Template.Abilities.AddItem('TemplarFocus');
	Template.Abilities.AddItem('RTScholarVolt');

	switch(TemplateName) {
		case 'RTTemplarGauntlet_M1':
			CreateConventionalGauntlet(Template);
			break;
		case 'RTTemplarGauntlet_M2':
			CreateMagneticGauntlet(Template);
			Template.Abilities.AddItem('Parry');
			Template.Abilities.AddItem('DeepFocus');
			Template.Abilities.AddItem('TemplarInvert');
			Template.Abilities.AddItem('Fortress');
			break;
		case 'RTTemplarGauntlet_M3':
			CreateBeamGauntlet(Template);
			Template.Abilities.AddItem('Parry');
			Template.Abilities.AddItem('Deflect');
			Template.Abilities.AddItem('Reflect');
			Template.Abilities.AddItem('DeepFocus');
			Template.Abilities.AddItem('TemplarInvert');
			Template.Abilities.AddItem('Fortress');
			Template.Abilities.AddItem('TemplarBladestorm');
			Template.Abilities.AddItem('ArcWavePassive');
			break;
		case 'RTScholarGauntlet_M1':
			CreateConventionalGauntlet(Template);
			break;
		case 'RTScholarGauntlet_M2':
			CreateMagneticGauntlet(Template);
			Template.Abilities.AddItem('StunStrike');
			Template.Abilities.AddItem('Amplify');
			break;
		case 'RTScholarGauntlet_M3':
			CreateBeamGauntlet(Template);
			Template.Abilities.AddItem('RTScholarIonicStorm');
			Template.Abilities.AddItem('StunStrike');
			Template.Abilities.AddItem('Amplify');
			break;
		default:
			`RTLOG("Error, CreateRTTemplarGauntlet recieved invalid TemplateName, " $ TemplateName $ "", true, false);
			return none;
	}
	Template.BaseDamage.DamageType = 'Psi';


	return Template;
}

static function X2DataTemplate CreateRTTemplarGauntlet_Left(name TemplateName)
{
	local X2WeaponTemplate Template;

	TemplateName = name(TemplateName $ '_Left');
	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, TemplateName);
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'gauntlet';
	Template.InventorySlot = eInvSlot_TertiaryWeapon;
	Template.bUseArmorAppearance = true;
	Template.iRadius = 1;
	Template.NumUpgradeSlots = 0;
	Template.InfiniteAmmo = true;
	Template.iPhysicsImpulse = 5;
	Template.iRange = 0;
	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;
	Template.DamageTypeTemplateName = 'Melee';
	Template.HideInInventory = true;

	switch(TemplateName) {
		case 'RTTemplarGauntlet_M1_Left':
			CreateConventionalGauntlet(Template, true);
			break;
		case 'RTTemplarGauntlet_M2_Left':
			CreateMagneticGauntlet(Template, true);
			break;
		case 'RTTemplarGauntlet_M3_Left':
			CreateBeamGauntlet(Template, true);
			break;
		case 'RTScholarGauntlet_M1_Left':
			CreateConventionalGauntlet(Template, true);
			break;
		case 'RTScholarGauntlet_M2_Left':
			CreateMagneticGauntlet(Template, true);
			break;
		case 'RTScholarGauntlet_M3_Left':
			CreateBeamGauntlet(Template, true);
			break;
		default:
			`RTLOG("Error, CreateRTTemplarGauntlet_Left recieved invalid TemplateName, " $ TemplateName $ "", true, false);
			return none;
	}
	Template.BaseDamage.DamageType = 'Melee';

	return Template;
}

static function CreateConventionalGauntlet(X2WeaponTemplate Template, optional bool bIsLeft = false) {
	Template.WeaponTech = 'conventional';
	Template.strImage = "img:///UILibrary_XPACK_StrategyImages.Inv_ConvTGauntlet";
	Template.EquipSound = "Sword_Equip_Conventional";
	Template.GameArchetype = "WP_TemplarGauntlet.WP_TemplarGauntlet";
	Template.AltGameArchetype = "WP_TemplarGauntlet.WP_TemplarGauntlet_F";
	Template.GenderForAltArchetype = eGender_Female;
	Template.BaseDamage = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_CONVENTIONAL_BASEDAMAGE;
	Template.ExtraDamage = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_CONVENTIONAL_EXTRADAMAGE;
	Template.Aim = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_CONVENTIONAL_AIM;
	Template.CritChance = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_CONVENTIONAL_CRITCHANCE;
	Template.iSoundRange = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_CONVENTIONAL_ISOUNDRANGE;
	Template.iEnvironmentDamage = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_CONVENTIONAL_IENVIRONMENTDAMAGE;
	Template.HideInInventory = true;

	if(bIsLeft) {
		Template.GameArchetype = "WP_TemplarGauntlet.WP_TemplarGauntletL";
		Template.AltGameArchetype = "WP_TemplarGauntlet.WP_TemplarGauntletL_F";
	}
}

static function CreateMagneticGauntlet(X2WeaponTemplate Template, optional bool bIsLeft = false) {
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///UILibrary_XPACK_StrategyImages.Inv_MagTGauntlet";
	Template.EquipSound = "Sword_Equip_Magnetic";
	Template.GameArchetype = "WP_TemplarGauntlet.WP_TemplarGauntlet_MG";
	Template.AltGameArchetype = "WP_TemplarGauntlet.WP_TemplarGauntlet_F_MG";
	Template.GenderForAltArchetype = eGender_Female;
	Template.BaseDamage = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_MAGNETIC_BASEDAMAGE;
	Template.ExtraDamage = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_MAGNETIC_EXTRADAMAGE;
	Template.Aim = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_MAGNETIC_AIM;
	Template.CritChance = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_MAGNETIC_CRITCHANCE;
	Template.iSoundRange = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_MAGNETIC_ISOUNDRANGE;
	Template.iEnvironmentDamage = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_MAGNETIC_IENVIRONMENTDAMAGE;
	Template.HideInInventory = true;

	if(bIsLeft) {
		Template.GameArchetype = "WP_TemplarGauntlet.WP_TemplarGauntletL_MG";
		Template.AltGameArchetype = "WP_TemplarGauntlet.WP_TemplarGauntletL_F_MG";
	}
}

static function CreateBeamGauntlet(X2WeaponTemplate Template, optional bool bIsLeft = false) {
	Template.WeaponTech = 'beam';
	Template.strImage = "img:///UILibrary_XPACK_StrategyImages.Inv_BeamTGauntlet";
	Template.EquipSound = "Sword_Equip_Beam";
	Template.GameArchetype = "WP_TemplarGauntlet.WP_TemplarGauntlet_BM";
	Template.AltGameArchetype = "WP_TemplarGauntlet.WP_TemplarGauntlet_F_BM";
	Template.GenderForAltArchetype = eGender_Female;
	Template.BaseDamage = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_BEAM_BASEDAMAGE;
	Template.ExtraDamage = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_BEAM_EXTRADAMAGE;
	Template.Aim = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_BEAM_AIM;
	Template.CritChance = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_BEAM_CRITCHANCE;
	Template.iSoundRange = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_BEAM_ISOUNDRANGE;
	Template.iEnvironmentDamage = class'X2Item_XpackWeapons'.default.SHARDGAUNTLET_BEAM_IENVIRONMENTDAMAGE;
	Template.HideInInventory = true;

	if(bIsLeft) {
		Template.GameArchetype = "WP_TemplarGauntlet.WP_TemplarGauntletL_BM";
		Template.AltGameArchetype = "WP_TemplarGauntlet.WP_TemplarGauntletL_F_BM";
	}
}

static function X2DataTemplate CreateRTTemplarWarpGrenades()
{
	local X2GrenadeTemplate Template;
	local X2Effect_ApplyWeaponDamage WeaponDamageEffect;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2GrenadeTemplate', Template, 'RTWarpGrenade');

	Template.strImage = "img:///RisingTidesImagesPackage.Inv_Warp_Grenade";
	Template.EquipSound = "StrategyUI_Grenade_Equip";
	Template.AddAbilityIconOverride('ThrowGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_emp");
	Template.AddAbilityIconOverride('LaunchGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_emp");
	Template.iRange = default.WARPGRENADE_RANGE;
	Template.iRadius = default.WARPGRENADE_RADIUS;
	Template.fCoverage = 100;
	
	Template.BaseDamage = default.WARPGRENADE_BASEDAMAGE;
	Template.iSoundRange = default.WARPGRENADE_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.WARPGRENADE_IENVIRONMENTDAMAGE;
	Template.TradingPostValue = default.WARPGRENADE_TRADINGPOSTVALUE;
	Template.PointsToComplete = default.WARPGRENADE_IPOINTS;
	Template.iClipSize = default.WARPGRENADE_ICLIPSIZE;
	Template.Tier = 1;
	
	Template.Abilities.AddItem('ThrowGrenade');
	Template.Abilities.AddItem('GrenadeFuse');

	// immediate damage
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.bExplosiveDamage = true;
	Template.ThrownGrenadeEffects.AddItem(WeaponDamageEffect);

	Template.LaunchedGrenadeEffects = Template.ThrownGrenadeEffects;
	
	Template.GameArchetype = "RT_Grenade_Warp.RT_WP_Grenade_Warp_Lv2";

	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = default.WARPGRENADE_SUPPLYCOST;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Template.Requirements.SpecialRequirementsFn = IsTemplarQuestlineComplete;

	Template.CanBeBuilt = true;
	Template.HideIfResearched = 'AdvancedGrenades';

	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , default.WARPGRENADE_RANGE);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , default.WARPGRENADE_RADIUS);

	return Template;
}

static function X2DataTemplate CreateRTTemplarWarpBombs()
{
	local X2GrenadeTemplate Template;
	local X2Effect_ApplyWeaponDamage WeaponDamageEffect;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2GrenadeTemplate', Template, 'RTWarpBomb');

	Template.strImage = "img:///RisingTidesImagesPackage.Inv_Warp_GrenadeMK2";
	Template.EquipSound = "StrategyUI_Grenade_Equip";
	Template.AddAbilityIconOverride('ThrowGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_emp");
	Template.AddAbilityIconOverride('LaunchGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_emp");
	Template.iRange = default.WARPBOMB_RANGE;
	Template.iRadius = default.WARPBOMB_RADIUS;
	Template.fCoverage = 100;
	
	Template.BaseDamage = default.WARPBOMB_BASEDAMAGE;
	Template.iSoundRange = default.WARPBOMB_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.WARPBOMB_IENVIRONMENTDAMAGE;
	Template.TradingPostValue = default.WARPBOMB_TRADINGPOSTVALUE;
	Template.PointsToComplete = default.WARPBOMB_IPOINTS;
	Template.iClipSize = default.WARPBOMB_ICLIPSIZE;
	Template.Tier = 3;
	
	Template.Abilities.AddItem('ThrowGrenade');
	Template.Abilities.AddItem('GrenadeFuse');

	// immediate damage
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.bExplosiveDamage = true;
	Template.ThrownGrenadeEffects.AddItem(WeaponDamageEffect);

	Template.LaunchedGrenadeEffects = Template.ThrownGrenadeEffects;
	
	Template.GameArchetype = "RT_Grenade_Warp.RT_WP_Grenade_Warp_Lv2";

	Template.CreatorTemplateName = 'AdvancedGrenades'; // The schematic which creates this item
	Template.BaseItem = 'RTWarpGrenade'; // Which item this will be upgraded from

	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = default.WARPBOMB_SUPPLYCOST;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Template.Requirements.SpecialRequirementsFn = IsTemplarQuestlineComplete;
	Template.Requirements.RequiredTechs.AddItem('AdvancedGrenades');

	Template.CanBeBuilt = true;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , default.WARPBOMB_RANGE);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , default.WARPBOMB_RADIUS);

	return Template;
}

static function X2DataTemplate CreateRTTemplarPsiAmp(name TemplateName)
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, TemplateName);
	Template.WeaponPanelImage = "_PsiAmp";                       // used by the UI. Probably determines iconview of the weapon.
	Template.RemoveTemplateAvailablility(Template.BITFIELD_GAMEAREA_Multiplayer); //invalidates multiplayer availability

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'psiamp';
	Template.CanBeBuilt = false;
	Template.DamageTypeTemplateName = 'Psi';

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Psi_Amp";
	Template.InventorySlot = eInvSlot_TertiaryWeapon;
	Template.StowedLocation = eSlot_RightBack;
	// This all the resources; sounds, animations, models, physics, the works.
	Template.HideInInventory = true;

	Template.GameArchetype = "WP_AdvPriestPsiAmp.WP_AdvPriestPsiAmp";

	Template.Abilities.AddItem('PriestPsiMindControl');

	switch(TemplateName) {
		case 'RTTemplarPsiAmp_M1':
			Template.WeaponTech = 'conventional';
			
			Template.Abilities.AddItem('PriestStasis');
			Template.Abilities.AddItem('HolyWarriorM1');
			break;
		case 'RTTemplarPsiAmp_M2':
			Template.WeaponTech = 'magnetic';

			Template.Abilities.AddItem('PriestStasis');
			Template.Abilities.AddItem('HolyWarriorM2');
			break;
		case 'RTTemplarPsiAmp_M3':
			Template.WeaponTech = 'beam';
		
			Template.Abilities.AddItem('PriestStasis');
			Template.Abilities.AddItem('HolyWarriorM3');
			Template.Abilities.AddItem('Fortress');
			break;
		default:
			`RTLOG("Error, tried to make an invalid RTTemplarPsiAmp! " $ TemplateName $ "", true, false);
			return none;
	}	

	return Template;
}

//---------------------------------------------------------------------------------------
static function bool IsTemplarQuestlineComplete()
{
	return `RTS.GetProgramState().IsTemplarQuestlineComplete();
}
