// This is an Unreal Script

class RTAbilityTarget_TeleportMelee extends X2AbilityTarget_MovingMelee;



simulated function name GetPrimaryTargetOptions(const XComGameState_Ability Ability, out array<AvailableTarget> Targets) {
	local name AvailableCode;
	local AvailableTarget Target, EmptyTarget;
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;

	`LOG("Called GetPrimaryTargetOptions");

	AvailableCode = super.GetPrimaryTargetOptions(Ability, Targets);

	History = `XCOMHISTORY;
	`LOG("Found Targets:");
	foreach Targets(Target) {
		`LOG(XComGameState_Unit(History.GetGameStateForObjectID(Target.PrimaryTarget.ObjectID)).GetFullName());
	}


   
	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState) {
		Target = EmptyTarget;
		if(UnitState.ObjectID == Ability.OwnerStateObject.ObjectID)
			continue;

		Target.PrimaryTarget = UnitState.GetReference();
		if(Targets.Find('PrimaryTarget', Target.PrimaryTarget) == INDEX_NONE) {
			`LOG("Adding a " @ UnitState.GetFullName() @ " to the targets array");

			Targets.AddItem(Target);
		}
	}


	return AvailableCode;
}

simulated function bool ValidatePrimaryTargetOption(const XComGameState_Ability Ability, XComGameState_Unit SourceUnit, XComGameState_BaseObject TargetObject) {
	return true;
}

// Finds the melee tiles available to the unit, if any are available to the source unit. If IdealTile is specified,
// it will select the closest valid attack tile to the ideal (and will simply return the ideal if it is valid). If no array us provided for
// SortedPossibleTiles, will simply return true or false based on whether or not a tile is available
simulated static function bool SelectAttackTile(XComGameState_Unit UnitState, 
														   XComGameState_BaseObject TargetState, 
														   X2AbilityTemplate MeleeAbilityTemplate,
														   optional out array<TTile> SortedPossibleTiles, // index 0 is the best option.
														   optional out TTile IdealTile, // If this tile is available, will just return it
														   optional bool Unsorted = false) { // if unsorted is true, just returns the list of possible tiles
	local array<TTile> Tiles;
	local TTile Tile, IteratorTile;

	if(XComGameState_Unit(TargetState) != none) {
		Tile = XComGameState_Unit(TargetState).TileLocation;
	}  else if(XComGameState_Destructible(TargetState) != none) {
		Tile = XComGameState_Destructible(TargetState).TileLocation;
	} else return super.SelectAttackTile(UnitState, TargetState, MeleeAbilityTemplate, SortedPossibleTiles, IdealTile, Unsorted);

	class'RTHelpers'.static.GetAdjacentTiles(Tile, Tiles);
	foreach Tiles(IteratorTile) {
		if(IsValidAttackTile(UnitState, IteratorTile, Tile))
			SortedPossibleTiles.AddItem(IteratorTile);
	}

	return SortedPossibleTiles.Length != 0;
		

}

// returns true the given unit can perform a melee attack from SourceTile to TargetTile. Only checks spatial considerations, such as distance
// and walls. You still need to check if the melee ability is valid at all by validating its conditions.
simulated static function bool IsValidAttackTile(XComGameState_Unit UnitState, const out TTile SourceTile, const out TTile TargetTile) {
	return !`XWORLD.IsAdjacentTileBlocked(SourceTile, TargetTile) && (`XWORLD.IsFloorTile(SourceTile) || `XWORLD.IsGroundTile(SourceTile));
}
