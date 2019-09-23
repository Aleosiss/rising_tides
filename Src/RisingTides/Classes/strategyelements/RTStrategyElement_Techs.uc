//---------------------------------------------------------------------------------------
//  FILE:    X2StrategyElement_DLC_Day90Techs.uc
//  AUTHOR:  Joe Weinhoffer
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class RTStrategyElement_Techs extends X2StrategyElement config(ProgramFaction);

var config int DRONE_DAYS_TO_BUILD;
var config int DRONE_COST_ALLOYS;
var config int DRONE_COST_CORES;
var config int DRONE_COST_ELERIUM;
var config int DRONE_COST_SUPPLIES;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Techs;

	Techs.AddItem(CreateBuildDroneTemplate());
	
	return Techs;
}

//---------------------------------------------------------------------------------------
// Helper function for calculating project time
static function int StafferXDays(int iNumScientists, int iNumDays)
{
	return (iNumScientists * 5) * (24 * iNumDays); // Scientists at base skill level
}

static function bool IsTemplarQuestlineComplete()
{
	return `RTS.GetProgramState().IsTemplarQuestlineComplete();
}

static function X2DataTemplate CreateBuildDroneTemplate()
{
	local X2TechTemplate Template;
	local ArtifactCost Artifacts;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'RTBuildProgramDrone');
	Template.PointsToComplete = StafferXDays(1, default.DRONE_DAYS_TO_BUILD);
	Template.SortingTier = 1;
	Template.strImage = "img:///RisingTidesContentPackage.UIImages.AutopsyDrone";

	Template.bProvingGround = true;
	Template.bRepeatable = true;
	Template.ResearchCompletedFn = CreateProgramDrone;
	
	// Narrative Requirements
	Template.Requirements.SpecialRequirementsFn = IsTemplarQuestlineComplete;
	
	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = default.DRONE_COST_SUPPLIES;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	Resources.ItemTemplateName = 'AlienAlloy';
	Resources.Quantity = default.DRONE_COST_ALLOYS;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	Resources.ItemTemplateName = 'EleriumDust';
	Resources.Quantity = default.DRONE_COST_ELERIUM;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	Artifacts.ItemTemplateName = 'EleriumCore';
	Artifacts.Quantity = default.DRONE_COST_CORES;
	Template.Cost.ArtifactCosts.AddItem(Artifacts);

	return Template;
}

static function CreateProgramDrone(XComGameState NewGameState, XComGameState_Tech TechState)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Unit DroneState;
	local X2CharacterTemplateManager CharTemplateMgr;
	local X2CharacterTemplate CharacterTemplate;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	CharTemplateMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	CharacterTemplate = CharTemplateMgr.FindCharacterTemplate('ProgramDrone');

	DroneState = CharacterTemplate.CreateInstanceFromTemplate(NewGameState);
	DroneState.SetStatus(eStatus_Active);
	DroneState.bNeedsNewClassPopup = false;
	DroneState.SetUnitName("", CharacterTemplate.strCharacterName, "");
	DroneState.SetCountry('Country_USA');

	XComHQ.AddToCrew(NewGameState, DroneState);
	if (TechState != none)
	{
		TechState.UnitRewardRef = DroneState.GetReference();
	}
}