// X2MeleePathingPawn, except no line to the target. Still working on not actually requiring a path to the target but this will do for now.

class RTMeleePathingPawn extends X2MeleePathingPawn;

// overridden to always just show the slash UI, regardless of cursor location or other considerations
simulated protected function UpdatePuckVisuals(XComGameState_Unit ActiveUnitState,
												const out TTile PathDestination,
												Actor TargetActor,
												X2AbilityTemplate MeleeAbilityTemplate)
{
	local XComWorldData WorldData;
	local XGUnit Unit;
	local vector MeshTranslation;
	local Rotator MeshRotation;
	local vector MeshScale;
	local vector FromTargetTile;
	local float UnitSize;

	WorldData = `XWORLD;

	// determine target puck size and location
	MeshTranslation = TargetActor.Location;

	Unit = XGUnit(TargetActor);
	if(Unit != none)
	{
		UnitSize = Unit.GetVisualizedGameState().UnitSize;
		MeshTranslation = Unit.GetPawn().CollisionComponent.Bounds.Origin;
	}
	else
	{
		UnitSize = 1.0f;
	}

	MeshTranslation.Z = WorldData.GetFloorZForPosition(MeshTranslation) + PathHeightOffset;

	// when slashing, we will technically be out of range.
	// hide the out of range mesh, show melee mesh
	OutOfRangeMeshComponent.SetHidden(true);
	SlashingMeshComponent.SetHidden(false);
	SlashingMeshComponent.SetTranslation(MeshTranslation);

	// rotate the mesh to face the thing we are slashing
	FromTargetTile = WorldData.GetPositionFromTileCoordinates(PathDestination) - MeshTranslation;
	MeshRotation.Yaw = atan2(FromTargetTile.Y, FromTargetTile.X) * RadToUnrRot;

	SlashingMeshComponent.SetRotation(MeshRotation);
	SlashingMeshComponent.SetScale(UnitSize);

	// the normal puck is always visible, and located wherever the unit
	// will actually move to when he executes the move
	PuckMeshComponent.SetHidden(false);
	PuckMeshComponent.SetStaticMeshes(GetMeleePuckMeshForAbility(MeleeAbilityTemplate), PuckMeshConfirmed);
	//<workshop> SMOOTH_TACTICAL_CURSOR AMS 2016/01/22
	//INS:
	PuckMeshCircleComponent.SetHidden(false);
	PuckMeshCircleComponent.SetStaticMesh(GetMeleePuckMeshForAbility(MeleeAbilityTemplate));
	//</workshop>


	MeshTranslation = VisualPath.GetEndPoint(); // make sure we line up perfectly with the end of the path ribbon
	MeshTranslation.Z = WorldData.GetFloorZForPosition(MeshTranslation) + PathHeightOffset;
	PuckMeshComponent.SetTranslation(MeshTranslation);
	//<workshop> SMOOTH_TACTICAL_CURSOR AMS 2016/01/22
	//INS:
	PuckMeshCircleComponent.SetTranslation(MeshTranslation);
	//</workshop>

	MeshScale.X = ActiveUnitState.UnitSize;
	MeshScale.Y = ActiveUnitState.UnitSize;
	MeshScale.Z = 1.0f;
	PuckMeshComponent.SetScale3D(MeshScale);
	//<workshop> SMOOTH_TACTICAL_CURSOR AMS 2016/01/22
	//INS:
	PuckMeshCircleComponent.SetScale3D(MeshScale);
	//</workshop>
}

// this is the overarching function that rebuilds all of the pathing information when the destination or active unit changes.
// if you need to add some other information (markers, tiles, etc) that needs to be updated when the path does, you should add a
// call to that update function to this function.

simulated protected function RebuildPathingInformation(TTile PathDestination, Actor TargetActor, X2AbilityTemplate MeleeAbilityTemplate, TTile CursorTile)
{
	super.RebuildPathingInformation(PathDestination, TargetActor, MeleeAbilityTemplate, CursorTile);
	RenderablePath.SetHidden(true);

}

simulated function HideRenderablePath(bool bShouldHidePath) {
	RenderablePath.SetHidden(bShouldHidePath);
}

function GetTargetMeleePath(out array<TTile> OutPathTiles)
{
	OutPathTiles.Length = 0;

	OutPathTiles.AddItem(LastDestinationTile);
}


simulated function UpdateMeleeTarget(XComGameState_BaseObject Target)
{
	local X2AbilityTemplate AbilityTemplate;
	local vector TileLocation;

	//<workshop> Francois' Smooth Cursor AMS 2016/04/07
	//INS:
	local TTile InvalidTile;
	InvalidTile.X = -1;
	InvalidTile.Y = -1;
	InvalidTile.Z = -1;
	//</workshop>

	if(Target == none)
	{
		`Redscreen("X2MeleePathingPawn::UpdateMeleeTarget: Target is none!");
		return;
	}

	TargetVisualizer = Target.GetVisualizer();
	AbilityTemplate = AbilityState.GetMyTemplate();

	PossibleTiles.Length = 0;

	if(class'RTAbilityTarget_TeleportMelee'.static.SelectAttackTile(UnitState, Target, AbilityTemplate, PossibleTiles))
	{
		// build a path to the default (best) tile
		//<workshop> Francois' Smooth Cursor AMS 2016/04/07
		//WAS:
		//RebuildPathingInformation(PossibleTiles[0], TargetVisualizer, AbilityTemplate);	
		//RebuildPathingInformation(PossibleTiles[0], TargetVisualizer, AbilityTemplate, InvalidTile);
		//</workshop>

		// and update the tiles to reflect the new target options
		UpdatePossibleTilesVisuals();

		if(`ISCONTROLLERACTIVE)
		{
			// move the 3D cursor to the new target
			if(`XWORLD.GetFloorPositionForTile(PossibleTiles[0], TileLocation))
			{
				`CURSOR.CursorSetLocation(TileLocation, true, true);
			}
		}
	}
	//<workshop> TACTICAL_CURSOR_PROTOTYPING AMS 2015/12/07
	//INS:
	DoUpdatePuckVisuals(PossibleTiles[0], Target.GetVisualizer(), AbilityTemplate);
	//</workshop>
}


simulated event Tick(float DeltaTime)
{
	local XCom3DCursor Cursor;
	local XComWorldData WorldData;
	local vector CursorLocation;
	local TTile PossibleTile;
	local TTile CursorTile;
	local TTile ClosestTile;
	local X2AbilityTemplate AbilityTemplate;
	local float ClosestTileDistance;
	local float TileDistance;

	local TTile InvalidTile;
	InvalidTile.X = -1;
	InvalidTile.Y = -1;
	InvalidTile.Z = -1;
	
	if(TargetVisualizer == none) 
	{
		return;
	}

	Cursor = `CURSOR;
	WorldData = `XWORLD;

	CursorLocation = Cursor.GetCursorFeetLocation();
	CursorTile = WorldData.GetTileCoordinatesFromPosition(CursorLocation);

	// mouse needs to actually highlight a specific tile, controller tabs through them
	if(`ISCONTROLLERACTIVE)
	{
		ClosestTileDistance = -1;

		if(VSizeSq2D(CursorLocation - TargetVisualizer.Location) > 0.1f)
		{
			CursorLocation = TargetVisualizer.Location + (Normal(Cursor.Location - TargetVisualizer.Location) * class'XComWorldData'.const.WORLD_StepSize);
			foreach PossibleTiles(PossibleTile)
			{
				TileDistance = VSizeSq(WorldData.GetPositionFromTileCoordinates(PossibleTile) - CursorLocation);
				if(ClosestTileDistance < 0 || TileDistance < ClosestTileDistance)
				{
					ClosestTile = PossibleTile;
					ClosestTileDistance = TileDistance;
				}
			}

			if(ClosestTile != LastDestinationTile)
			{
				AbilityTemplate = AbilityState.GetMyTemplate();
				// RebuildPathingInformation(ClosestTile, TargetVisualizer, AbilityTemplate, InvalidTile);
				DoUpdatePuckVisuals(ClosestTile, TargetVisualizer, AbilityTemplate);
				LastDestinationTile = ClosestTile;
			}

			// put the cursor back on the unit
			Cursor.CursorSetLocation(TargetVisualizer.Location, true);
		}
	}
	else
	{
		if(CursorTile != LastDestinationTile)
		{
			foreach PossibleTiles(PossibleTile)
			{
				if(PossibleTile == CursorTile)
				{
					AbilityTemplate = AbilityState.GetMyTemplate();
					// RebuildPathingInformation(CursorTile, TargetVisualizer, AbilityTemplate, InvalidTile);
					DoUpdatePuckVisuals(CursorTile, TargetVisualizer, AbilityTemplate);
					LastDestinationTile = CursorTile;
					break;
				}
			}
		}
	}
}