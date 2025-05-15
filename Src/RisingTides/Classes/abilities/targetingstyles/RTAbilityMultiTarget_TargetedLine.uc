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

var int LineLengthTiles;					// if greater than 0, the line with have this length instead of the default
var bool bOriginateAtTargetLocation;		// if set, the line will originate from the target instead of the shooter


// ----------- Have to override this native function in X2AbilityMultiTargetStyle, as all others are native-to-native calls and cannot be intercepted -----------------
/**
 * GetMultiTargetOptions
 * @param Targets will have valid PrimaryTarget filled out already
 * @return Targets with AdditionalTargets filled out given the PrimaryTarget in each element
 */
simulated function GetMultiTargetOptions(const XComGameState_Ability Ability, out array<AvailableTarget> Targets)
{
	local int								i;
	local vector							TargetUnitLocation;
	local XComGameState_Unit				TargetUnit;
	local XComGameState_Unit				IteratorTargetUnit;
	local AvailableTarget					Target;
	local XComWorldData						World;
	local XComGameStateHistory				History;
	local StateObjectReference				IteratorTargetRef;
	local array<StateObjectReference>		FilteredAdditionalTargets;

	World = `XWORLD;
	History = `XCOMHISTORY;

	// I have no idea how I would go about implementing this myself, so just hijack GetMultiTargetsForLocation
	// Get the TargetUnitLocation from the primary target of the targets array, then save the primary target
	// so it doesn't get overwritten
	for(i = 0; i < Targets.Length; i++)
	{
		// reset this array for each target, otherwise each shot hits every enemy that can be aimed at at once
		Target.AdditionalTargets.Length = 0;

		TargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(Targets[i].PrimaryTarget.ObjectID));
		TargetUnitLocation = World.GetPositionFromTileCoordinates(TargetUnit.TileLocation);

		Target.PrimaryTarget = Targets[i].PrimaryTarget;
		GetMultiTargetsForLocation(Ability, TargetUnitLocation, Target);

		if(bOriginateAtTargetLocation && LineLengthTiles > 0) {
			FilteredAdditionalTargets.Length = 0;
			
			foreach Target.AdditionalTargets(IteratorTargetRef) {
				IteratorTargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(IteratorTargetRef.ObjectID));
				if(TargetUnit.TileDistanceBetween(IteratorTargetUnit) <= (LineLengthTiles / 2)) {
					FilteredAdditionalTargets.AddItem(IteratorTargetRef);
				}
			}
			
			Target.AdditionalTargets = FilteredAdditionalTargets;
		}
		
		Targets[i] = Target;
	}
}

simulated function GetMultiTargetsForLocation(const XComGameState_Ability Ability, const vector Location, out AvailableTarget Target)
{
	super.GetMultiTargetsForLocation(Ability, Location, Target);
	return;
}

function AddAbilityBonusWidth(name AbilityName, int BonusWidth)
{
	super.AddAbilityBonusWidth(AbilityName, BonusWidth);
	return;
}

simulated function GetValidTilesForLocation(const XComGameState_Ability Ability, const vector Location, out array<TTile> ValidTiles)
{
	local TTile IteratorTile;
	local Vector IteratorTileLocation;
	local XComWorldData WorldData;
	local float Dist;
	local int Tiles;
	local array<TTile> FilteredTiles;

	super.GetValidTilesForLocation(Ability, Location, ValidTiles);

	WorldData = `XWORLD;
	foreach ValidTiles(IteratorTile) {
		Dist = VSize(Location - WorldData.GetPositionFromTileCoordinates(IteratorTile));
		Tiles = Dist / WorldData.WORLD_StepSize;
		if(Tiles <= (LineLengthTiles / 2)) {
			FilteredTiles.AddItem(IteratorTile);
		}
	}
	
	ValidTiles = FilteredTiles;
	return;
}


/**
* CheckFilteredMultiTargets
* @param Target will contain a filtered primary target with its filtered multi-targets
* @return Return value should indicate if this primary target is valid, given the list of multi-targets (used to further filter the primary targets).
*/
simulated function name CheckFilteredMultiTargets(const XComGameState_Ability Ability, const AvailableTarget Target)
{
	return super.CheckFilteredMultiTargets(Ability, Target);
}

// Used to collect TargetLocations for an Ability
simulated function bool CalculateValidLocationsForLocation(const XComGameState_Ability Ability, const vector Location, AvailableTarget AvailableTargets, out array<vector> ValidLocations)
{
	return super.CalculateValidLocationsForLocation(Ability, Location, AvailableTargets, ValidLocations);
}
