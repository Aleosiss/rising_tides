class RTCharacterGenerator_Templar extends XGCharacterGenerator_Templar config(ProgramFaction);

var config array<Name> FemalePeonTorsos;
var config array<Name> FemalePeonLeftArms;
var config array<Name> FemalePeonRightArms;
var config array<Name> FemalePeonLegs;

var config array<Name> MalePeonTorsos;
var config array<Name> MalePeonLeftArms;
var config array<Name> MalePeonRightArms;
var config array<Name> MalePeonLegs;

var config array<Name> FemaleTemplarHelmets;
var config array<Name> FemaleTemplarLeftArms;
var config array<Name> FemaleTemplarLegs;
var config array<Name> FemaleTemplarRightArms;
var config array<Name> FemaleTemplarThighs;
var config array<Name> FemaleTemplarTorsoDecos;
var config array<Name> FemaleTemplarTorsos;
var config array<Name> FemaleTemplarLeftArmDecos;
var config array<Name> FemaleTemplarRightArmDecos;

var config array<Name> MaleTemplarHelmets;
var config array<Name> MaleTemplarLeftArms;
var config array<Name> MaleTemplarLegs;
var config array<Name> MaleTemplarRightArms;
var config array<Name> MaleTemplarThighs;
var config array<Name> MaleTemplarTorsoDecos;
var config array<Name> MaleTemplarTorsos;
var config array<Name> MaleTemplarLeftArmDecos;
var config array<Name> MaleTemplarRightArmDecos;

var config array<Name> FemaleScholarHelmets;
var config array<Name> FemaleScholarTorsoDecos;

var config array<Name> MaleScholarHelmets;
var config array<Name> MaleScholarTorsoDecos;

function TSoldier CreateTSoldier( optional name CharacterTemplateName, optional EGender eForceGender, optional name nmCountry = '', optional int iRace = -1, optional name ArmorName ) {
	switch(CharacterTemplateName) {
		case 'RTTemplarWarrior_M1':
		case 'RTTemplarWarrior_M2':
		case 'RTTemplarWarrior_M3':
		case 'RTTemplar_HighCovenWarrior':
			return CreateTemplar(CharacterTemplateName, eForceGender, nmCountry, iRace, ArmorName, false);
		case 'RTTemplarPeon_M1':
		case 'RTTemplarPeon_M2':
		case 'RTTemplarPeon_M3':
			return CreateTemplarPeon(CharacterTemplateName, eForceGender, nmCountry, iRace, ArmorName);
		case 'RTTemplarScholar_M1':
		case 'RTTemplarScholar_M2':
		case 'RTTemplarScholar_M3':
		case 'RTTemplar_HighCovenScholar':
		case 'RTTemplarPriest_M1':
		case 'RTTemplarPriest_M2':
		case 'RTTemplarPriest_M3':
		case 'RTTemplar_HighCovenPriest':
			return CreateTemplar(CharacterTemplateName, eForceGender, nmCountry, iRace, ArmorName, true);
		default:
			`RTLOG("RTCharacterGenerator_Templar Got an invalid CharacterTemplateName, returning a TemplarWarrior!", true, false);
			return CreateTemplar(CharacterTemplateName, eForceGender, nmCountry, iRace, ArmorName);
	}
}

function TSoldier CreateTemplar( optional name CharacterTemplateName, optional EGender eForceGender, optional name nmCountry = '', optional int iRace = -1, optional name ArmorName, optional bool bIsScholar )
{
	local XComLinearColorPalette HairPalette;
	local X2SimpleBodyPartFilter BodyPartFilter;
	local X2CharacterTemplate CharacterTemplate;
	local TAppearance DefaultAppearance;
	local int iArmDecoSync;

	kSoldier.kAppearance = DefaultAppearance;	
	CharacterTemplate = SetCharacterTemplate(CharacterTemplateName, ArmorName);
	SetCountry('Country_Templar');

	BodyPartFilter = `XCOMGAME.SharedBodyPartFilter;
	UpdateDLCPackFilters();
	SetCountry(nmCountry);
	SetRace(iRace);
	SetGender(eForceGender);
	SetArmorTints(CharacterTemplate);	

	if(eForceGender == eGender_Female) {
		kSoldier.kAppearance.nmHelmet = default.FemaleTemplarHelmets[`SYNC_RAND(FemaleTemplarHelmets.Length)];
		kSoldier.kAppearance.nmTorso = default.FemaleTemplarTorsos[`SYNC_RAND(FemaleTemplarTorsos.Length)];
		kSoldier.kAppearance.nmLeftArm = default.FemaleTemplarLeftArms[`SYNC_RAND(FemaleTemplarLeftArms.Length)];
		kSoldier.kAppearance.nmRightArm = default.FemaleTemplarRightArms[`SYNC_RAND(FemaleTemplarRightArms.Length)];
		kSoldier.kAppearance.nmLegs = default.FemaleTemplarLegs[`SYNC_RAND(FemaleTemplarLegs.Length)];
		kSoldier.kAppearance.nmTorsoDeco = default.FemaleTemplarTorsoDecos[`SYNC_RAND(FemaleTemplarTorsoDecos.Length)];
		kSoldier.kAppearance.nmThighs = default.FemaleTemplarThighs[`SYNC_RAND(FemaleTemplarThighs.Length)];

		iArmDecoSync = `SYNC_RAND(FemaleTemplarLeftArmDecos.Length);
		kSoldier.kAppearance.nmLeftArmDeco = default.FemaleTemplarLeftArmDecos[iArmDecoSync];
		kSoldier.kAppearance.nmLeftArmDeco = default.FemaleTemplarRightArmDecos[iArmDecoSync];

		if(bIsScholar) {
			kSoldier.kAppearance.nmHelmet = default.FemaleScholarHelmets[`SYNC_RAND(FemaleScholarHelmets.Length)];
			kSoldier.kAppearance.nmHelmet = default.FemaleScholarTorsoDecos[`SYNC_RAND(FemaleScholarTorsoDecos.Length)];
			
		}
	} else {
		kSoldier.kAppearance.nmHelmet = default.MaleTemplarHelmets[`SYNC_RAND(MaleTemplarHelmets.Length)];
		kSoldier.kAppearance.nmTorso = default.MaleTemplarTorsos[`SYNC_RAND(MaleTemplarTorsos.Length)];
		kSoldier.kAppearance.nmLeftArm = default.MaleTemplarLeftArms[`SYNC_RAND(MaleTemplarLeftArms.Length)];
		kSoldier.kAppearance.nmRightArm = default.MaleTemplarRightArms[`SYNC_RAND(MaleTemplarRightArms.Length)];
		kSoldier.kAppearance.nmLegs = default.MaleTemplarLegs[`SYNC_RAND(MaleTemplarLegs.Length)];
		kSoldier.kAppearance.nmTorsoDeco = default.MaleTemplarTorsoDecos[`SYNC_RAND(MaleTemplarTorsoDecos.Length)];
		kSoldier.kAppearance.nmThighs = default.MaleTemplarThighs[`SYNC_RAND(MaleTemplarThighs.Length)];

		iArmDecoSync = `SYNC_RAND(FemaleTemplarLeftArmDecos.Length);
		kSoldier.kAppearance.nmLeftArmDeco = default.MaleTemplarLeftArmDecos[iArmDecoSync];
		kSoldier.kAppearance.nmLeftArmDeco = default.MaleTemplarRightArmDecos[iArmDecoSync];

		if(bIsScholar) {
			kSoldier.kAppearance.nmHelmet = default.MaleScholarHelmets[`SYNC_RAND(MaleScholarHelmets.Length)];
			kSoldier.kAppearance.nmHelmet = default.MaleScholarTorsoDecos[`SYNC_RAND(MaleScholarTorsoDecos.Length)];
		}
	}

	BodyPartFilter.Set(EGender(kSoldier.kAppearance.iGender), ECharacterRace(kSoldier.kAppearance.iRace), kSoldier.kAppearance.nmTorso, true, , DLCNames);
	SetBanditHead(BodyPartFilter, CharacterTemplate);
	SetBanditAccessories(BodyPartFilter, CharacterTemplateName);

	HairPalette = `CONTENT.GetColorPalette(ePalette_HairColor);
	ColorizeHead(HairPalette);

	SetTemplarVoice(CharacterTemplateName, nmCountry);
	SetAttitude();

	BioCountryName = kSoldier.nmCountry;
	return kSoldier;
}

function TSoldier CreateTemplarPeon( optional name CharacterTemplateName, optional EGender eForceGender, optional name nmCountry = '', optional int iRace = -1, optional name ArmorName )
{
	local XComLinearColorPalette HairPalette;
	local X2SimpleBodyPartFilter BodyPartFilter;
	local X2CharacterTemplate CharacterTemplate;
	local TAppearance DefaultAppearance;

	kSoldier.kAppearance = DefaultAppearance;	
	CharacterTemplate = SetCharacterTemplate(CharacterTemplateName, ArmorName);
	if (nmCountry == '') {
		nmCountry = PickOriginCountry();
	}

	BodyPartFilter = `XCOMGAME.SharedBodyPartFilter;
	UpdateDLCPackFilters();
	SetCountry(nmCountry);
	SetRace(iRace);
	SetGender(eForceGender);
	SetArmorTints(CharacterTemplate);	

	if(eForceGender == eGender_Female) {
		kSoldier.kAppearance.nmTorso = default.FemalePeonTorsos[`SYNC_RAND(FemalePeonTorsos.Length)];
		kSoldier.kAppearance.nmLeftArm = default.FemalePeonLeftArms[`SYNC_RAND(FemalePeonLeftArms.Length)];
		kSoldier.kAppearance.nmRightArm = default.FemalePeonRightArms[`SYNC_RAND(FemalePeonRightArms.Length)];
		kSoldier.kAppearance.nmLegs = default.FemalePeonLegs[`SYNC_RAND(FemalePeonLegs.Length)];
	} else {
		kSoldier.kAppearance.nmTorso = default.MalePeonTorsos[`SYNC_RAND(MalePeonTorsos.Length)];
		kSoldier.kAppearance.nmLeftArm = default.MalePeonLeftArms[`SYNC_RAND(MalePeonLeftArms.Length)];
		kSoldier.kAppearance.nmRightArm = default.MalePeonRightArms[`SYNC_RAND(MalePeonRightArms.Length)];
		kSoldier.kAppearance.nmLegs = default.MalePeonLegs[`SYNC_RAND(MalePeonLegs.Length)];
	}

	BodyPartFilter.Set(EGender(kSoldier.kAppearance.iGender), ECharacterRace(kSoldier.kAppearance.iRace), kSoldier.kAppearance.nmTorso, true, , DLCNames);
	SetBanditHead(BodyPartFilter, CharacterTemplate);
	SetAccessories(BodyPartFilter, CharacterTemplateName);
	SetBanditAccessories(BodyPartFilter, CharacterTemplateName);

	HairPalette = `CONTENT.GetColorPalette(ePalette_HairColor);
	ColorizeHead(HairPalette);

	SetVoice(CharacterTemplateName, nmCountry);
	SetAttitude();

	BioCountryName = kSoldier.nmCountry;
	kSoldier.kAppearance.nmHelmet = '';
	return kSoldier;
}

function ColorizeHead(XComLinearColorPalette HairPalette) {
	kSoldier.kAppearance.iHairColor = ChooseHairColor(kSoldier.kAppearance, HairPalette.BaseOptions); // Only generate with base options
	kSoldier.kAppearance.iEyeColor = Rand(5); 
	kSoldier.kAppearance.iWeaponTint = 5; //should make it gun metal grey
	kSoldier.kAppearance.iSkinColor = Rand(5);
}

function SetHead(X2SimpleBodyPartFilter BodyPartFilter, X2CharacterTemplate CharacterTemplate)
{
	super.SetHead(BodyPartFilter, CharacterTemplate);

	if (kSoldier.kAppearance.iGender == eGender_Male)
	{
		kSoldier.kAppearance.nmHead = default.MaleHeads[`SYNC_RAND(default.MaleHeads.Length)];
	}
	else
	{
		kSoldier.kAppearance.nmHead = default.FemaleHeads[`SYNC_RAND(default.FemaleHeads.Length)];
	}
}

function bool IsSoldier(name CharacterTemplateName) {
	return false;
}

function SetArmorTints(X2CharacterTemplate CharacterTemplate)
{
	super.SetArmorTints(CharacterTemplate);

	kSoldier.kAppearance.iArmorTint = default.PrimaryArmorColors[`SYNC_RAND(default.PrimaryArmorColors.Length)];
	kSoldier.kAppearance.iArmorTintSecondary = default.SecondaryArmorColors[`SYNC_RAND(default.SecondaryArmorColors.Length)];
}

function SetTemplarVoice(name CharacterTemplateName, name CountryName)
{
	local bool UseAlternate;

	UseAlternate = `SYNC_RAND(100) > 50;
	if (kSoldier.kAppearance.nmVoice == '')
	{
		if (kSoldier.kAppearance.iGender == eGender_Male)
		{
			kSoldier.kAppearance.nmVoice = (UseAlternate) ? 'TemplarMaleVoice2_Localized' : 'TemplarMaleVoice1_Localized';
		}
		else
		{
			kSoldier.kAppearance.nmVoice = (UseAlternate) ? 'TemplarFemaleVoice2_Localized' : 'TemplarFemaleVoice1_Localized';
		}
	}
	
}

function SetBanditAccessories(X2SimpleBodyPartFilter BodyPartFilter, name CharacterTemplateName)
{
	local X2BodyPartTemplateManager PartTemplateManager;

	PartTemplateManager = class'X2BodyPartTemplateManager'.static.GetBodyPartTemplateManager();

	if(kSoldier.kAppearance.iGender == eGender_Male)
	{
		if(`SYNC_FRAND() < NewSoldier_BeardChance){
			RandomizeSetBodyPart(PartTemplateManager, kSoldier.kAppearance.nmBeard, "Beards", BodyPartFilter.FilterByGenderAndNonSpecialized);
		}
		else{
			SetBodyPartToFirstInArray(PartTemplateManager, kSoldier.kAppearance.nmBeard, "Beards", BodyPartFilter.FilterAny);
		}
	}
	//Custom settings depending on whether the unit is a soldier or not
	RandomizeSetBodyPart(PartTemplateManager, kSoldier.kAppearance.nmPatterns, "Patterns", BodyPartFilter.FilterAny);
	RandomizeSetBodyPart(PartTemplateManager, kSoldier.kAppearance.nmWeaponPattern, "Patterns", BodyPartFilter.FilterAny);
	//RandomizeSetBodyPart(PartTemplateManager, kSoldier.kAppearance.nmTattoo_LeftArm, "Tattoos", BodyPartFilter.FilterAny);
	//RandomizeSetBodyPart(PartTemplateManager, kSoldier.kAppearance.nmTattoo_RightArm, "Tattoos", BodyPartFilter.FilterAny);
	RandomizeSetBodyPart(PartTemplateManager, kSoldier.kAppearance.nmHaircut, "Hair", BodyPartFilter.FilterByGenderAndNonSpecialized);
	//RandomizeSetBodyPart(PartTemplateManager, kSoldier.kAppearance.nmFacepaint, "Facepaint", BodyPartFilter.FilterAny);
	
}

function SetBanditHead(X2SimpleBodyPartFilter BodyPartFilter, X2CharacterTemplate CharacterTemplate)
{
	local X2BodyPartTemplateManager PartTemplateManager;

	PartTemplateManager = class'X2BodyPartTemplateManager'.static.GetBodyPartTemplateManager();

	BodyPartFilter.AddCharacterFilter('Soldier', CharacterTemplate.bHasCharacterExclusiveAppearance); // Make sure heads get filtered properly
	RandomizeSetBodyPart(PartTemplateManager, kSoldier.kAppearance.nmHead, "Head", BodyPartFilter.FilterByGenderAndRaceAndCharacter);
	RandomizeSetBodyPart(PartTemplateManager, kSoldier.kAppearance.nmEye, "Eyes", BodyPartFilter.FilterAny);
	RandomizeSetBodyPart(PartTemplateManager, kSoldier.kAppearance.nmTeeth, "Teeth", BodyPartFilter.FilterAny);
}