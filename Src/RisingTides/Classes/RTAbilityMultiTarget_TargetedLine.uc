//---------------------------------------------------------------------------------------
//  FILE:    RTAbilityMultiTarget_Line.uc
//  AUTHOR:  Aleosiss
//  DATE:    March 24 2016 
//
//  PURPOSE: Implement GetMultiTargetOptions for Line target schema         
//---------------------------------------------------------------------------------------
//  
//---------------------------------------------------------------------------------------
class RTAbilityMultiTarget_TargetedLine extends X2AbilityMultiTarget_Line;

simulated function GetMultiTargetOptions(const XComGameState_Ability Ability, out array<AvailableTarget> Targets)
{
	local XComGameStateHistory				History;
	local int								i;
	local vector							NewTargetLocation;
	local XComGameState_Unit				TargetUnit, AdditionalUnitState;
	local AvailableTarget					Target;
	local StateObjectReference				AdditionalTarget;

	if(Targets.Length == 0)
	{
		`Redscreen("RisingTides: Empty Targets array for RTAbilityMultiTarget_Line \n" $ GetScriptTrace());
		return;
	}
	if(Targets.Length > 1)
	{
		`Redscreen("RisingTides: Multiple primary targets for RTAbilityMultiTarget_Line #shootme\n" $ GetScriptTrace());
	}
	`Redscreen("######################################--------------RTAbilityMultiTarget_TargetedLine--------------######################################");
	

	TargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Targets[0].PrimaryTarget.ObjectID));
	NewTargetLocation = `XWORLD.GetPositionFromTileCoordinates(TargetUnit.TileLocation);

	Target.PrimaryTarget = Targets[0].PrimaryTarget;
	GetMultiTargetsForLocation(Ability, NewTargetLocation, Target);
	for(i = Target.AdditionalTargets.Length - 1; i >= 0; --i)
	{
		if(TargetUnit.ObjectID != Target.AdditionalTargets[i].ObjectID)
		{
			AdditionalUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Target.AdditionalTargets[i].ObjectID));
			Targets[0].AdditionalTargets.AddItem(AdditionalUnitState.GetReference());
		}
	}

}

simulated function GetMultiTargetsForLocation(const XComGameState_Ability Ability, const vector Location, out AvailableTarget Target)
{
	super.GetMultiTargetsForLocation(Ability, Location, Target);
}

simulated function GetValidTilesForLocation(const XComGameState_Ability Ability, const vector Location, out array<TTile> ValidTiles)
{
	super.GetValidTilesForLocation(Ability, Location, ValidTiles);
}

simulated function name CheckFilteredMultiTargets(const XComGameState_Ability Ability, const AvailableTarget Target)
{
	return super.CheckFilteredMultiTargets(Ability, Target);
}

simulated function bool CalculateValidLocationsForLocation(const XComGameState_Ability Ability, const vector Location, AvailableTarget AvailableTargets, out array<vector> ValidLocations)
{
	return super.CalculateValidLocationsForLocation(Ability, Location, AvailableTargets, ValidLocations);
}



defaultProperties
{
	bUseWeaponRadius=false
	bIgnoreBlockingCover=true  // unused here, but kept for reference
	//fTargetRadius;          //  Meters! (for now) If bUseWeaponRadius is true, this value is added on.
	//fTargetCoveragePercentage;
	bAddPrimaryTargetAsMultiTarget=false     //unused here, but kept for reference -- GetMultiTargetOptions & GetMultiTargetsForLocation will remove the primary target and add it to the multi target array.
	bAllowDeadMultiTargetUnits=false	//unused here, but kept for reference
	bAllowSameTarget=false
}