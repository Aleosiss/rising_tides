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
	local int								i;
	local vector							TargetUnitLocation;
	local XComGameState_Unit				TargetUnit;
	local AvailableTarget					Target;

	// I have no idea how I would go about implementing this myself, so just hijack GetMultiTargetsForLocation
	// Get the TargetUnitLocation from the primary target of the targets array, then save the primary target
	// so it doesn't get overwritten 
	for(i = 0; i < Targets.Length; i++)
	{
		TargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Targets[i].PrimaryTarget.ObjectID));
		TargetUnitLocation = `XWORLD.GetPositionFromTileCoordinates(TargetUnit.TileLocation);
		Target.PrimaryTarget = Targets[i].PrimaryTarget;
		GetMultiTargetsForLocation(Ability, TargetUnitLocation, Target);
		Targets[i] = Target; 
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
