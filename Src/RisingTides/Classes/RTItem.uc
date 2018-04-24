class RTItem extends X2Item config(RisingTides);


var config WeaponDamageValue PROGRAMPISTOL_BEAM_BASEDAMAGE;
var config int PROGRAMPISTOL_BEAM_AIM;
var config int PROGRAMPISTOL_BEAM_CRITCHANCE;
var config int PROGRAMPISTOL_BEAM_ICLIPSIZE;
var config int PROGRAMPISTOL_BEAM_ISOUNDRANGE;
var config int PROGRAMPISTOL_BEAM_IENVIRONMENTDAMAGE;
var config int PROGRAMPISTOL_BEAM_IPOINTS;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Items;

	Items.AddItem(CreateTemplate_ProgramPistol());


	return Items;
}


static function X2DataTemplate CreateTemplate_ProgramPistol()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'ProgramPistol');
	Template.WeaponPanelImage = "_Pistol";                       // used by the UI. Probably determines iconview of the weapon.

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'pistol';
	Template.WeaponTech = 'beam';
	Template.strImage = "img:///UILibrary_DLC2Images.BeamShadowKeeper";
	Template.EquipSound = "Secondary_Weapon_Equip_Beam";
	Template.Tier = 5;

	Template.RangeAccuracy = class'X2Item_DefaultWeapons'.default.SHORT_BEAM_RANGE;
	Template.BaseDamage = default.PROGRAMPISTOL_BEAM_BASEDAMAGE;
	Template.Aim = default.PROGRAMPISTOL_BEAM_AIM;
	Template.CritChance = default.PROGRAMPISTOL_BEAM_CRITCHANCE;
	Template.iClipSize = default.PROGRAMPISTOL_BEAM_ICLIPSIZE;
	Template.iSoundRange = default.PROGRAMPISTOL_BEAM_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.PROGRAMPISTOL_BEAM_IENVIRONMENTDAMAGE;

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
	Template.GameArchetype = "DLC_60_WP_HunterPistol_BM.WP_HunterPistol_BM";

	Template.iPhysicsImpulse = 5;

	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = false;

	Template.DamageTypeTemplateName = 'Projectile_BeamXCom';

	Template.bHideClipSizeStat = true;

	return Template;
}