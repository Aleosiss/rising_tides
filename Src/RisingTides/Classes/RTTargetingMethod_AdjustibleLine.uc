class RTTargetingMethod_AdjustibleLine extends X2TargetingMethod_Line;

var int LineLengthLimit;

function Init(AvailableAction InAction, int NewTargetIndex)
{
	local X2AbilityTemplate AbilityTemplate;
	local float TileLength;

	super.Init(InAction, NewTargetIndex);
	WorldData = `XWORLD;

	AbilityTemplate = Ability.GetMyTemplate( );

	FiringTile = UnitState.TileLocation;
	FiringLocation = WorldData.GetPositionFromTileCoordinates(UnitState.TileLocation);
	FiringLocation.Z += class'XComWorldData'.const.WORLD_HalfFloorHeight;

	Cursor = `Cursor;

	if (!AbilityTemplate.SkipRenderOfTargetingTemplate)
	{
		// setup the targeting mesh
		LineActor = `BATTLE.Spawn( class'X2Actor_LineTarget' );

                 // get the length in tiles for comparison
                TileLength = VSize(Cursor.Location - `XWORLD.GetPositionFromTileCoordinates(UnitState.TileLocation)) / class'XComWorldData'.const.WORLD_StepSize;
                if(TileLength > LineLengthLimit) {
                        TileLength = LineLengthLimit;
                }
                TileLength = TileLength * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER;
		if(AbilityIsOffensive)
		{
			LineActor.MeshLocation = "UI_3D.Targeting.ConeRange";
		}
		LineActor.InitLineMesh( TileLength );
		LineActor.SetLocation( FiringLocation );
	}
}

function Canceled()
{
	super.Canceled();
	// unlock the 3d cursor
	Cursor.m_fMaxChainedDistance = -1;

	// clean up the ui
	LineActor.Destroy();
	ClearTargetedActors();
}

function Committed()
{
	Canceled();
}

function Update(float DeltaTime)
{
	local array<Actor> CurrentlyMarkedTargets;
	local vector ShooterToTarget;
	local TTile TargetTile;
	local array<TTile> Tiles;
	local Rotator LineRotator;
	local Vector Direction;
	local float VisibilityRadius;
        local float TileLength;

	NewTargetLocation = Cursor.GetCursorFeetLocation();
	TargetTile = WorldData.GetTileCoordinatesFromPosition(NewTargetLocation);
	//NewTargetLocation = WorldData.GetPositionFromTileCoordinates(TargetTile);
	NewTargetLocation.Z = WorldData.GetFloorZForPosition(NewTargetLocation, true) + class'XComWorldData'.const.WORLD_HalfFloorHeight;

	if (TargetTile == FiringTile)
	{
		bGoodTarget = false;
		return;
	}
	bGoodTarget = true;

	if (NewTargetLocation != CachedTargetLocation)
	{
		GetTargetedActors(NewTargetLocation, CurrentlyMarkedTargets, Tiles);
		CheckForFriendlyUnit(CurrentlyMarkedTargets);
		MarkTargetedActors(CurrentlyMarkedTargets, (!AbilityIsOffensive) ? FiringUnit.GetTeam() : eTeam_None );

		DrawAOETiles(Tiles);

		if (LineActor != none)
		{
			TileLength = VSize(Cursor.Location - `XWORLD.GetPositionFromTileCoordinates(UnitState.TileLocation)) / class'XComWorldData'.const.WORLD_StepSize;
			if(TileLength > LineLengthLimit) {
				TileLength = LineLengthLimit;
			}
            TileLength = TileLength * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER;

            ShooterToTarget = NewTargetLocation - FiringLocation;
			LineRotator = rotator( ShooterToTarget );
			LineActor.SetRotation( LineRotator );

            LineActor.UpdateLengthScale(TileLength);
		}
	}

	Direction = NewTargetLocation - FiringLocation;
	VisibilityRadius = UnitState.GetVisibilityRadius() * class'XComWorldData'.const.WORLD_StepSize;
	AimingLocation = FiringLocation + (Direction / VSize(Direction)) * VisibilityRadius;

	AimingLocation = ClampTargetLocation(FiringLocation, AimingLocation, WorldData.Volume);
	super.Update(DeltaTime);
}

function Vector ClampTargetLocation(const out Vector StartingLocation, const out Vector EndLocation, Actor LevelVolume) {
        return super.ClampTargetLocation(StartingLocation, EndLocation, LevelVolume);
}

function GetTargetLocations(out array<Vector> TargetLocations)
{
	TargetLocations.Length = 0;
	TargetLocations.AddItem(AimingLocation);
}

function name ValidateTargetLocations(const array<Vector> TargetLocations)
{
	if (TargetLocations.Length == 1 && bGoodTarget)
	{
		return 'AA_Success';
	}
	return 'AA_NoTargets';
}

function int GetTargetIndex()
{
	return 0;
}

function bool GetAdditionalTargets(out AvailableTarget AdditionalTargets)
{
	Ability.GatherAdditionalAbilityTargetsForLocation(NewTargetLocation, AdditionalTargets);
	return true;
}

function bool GetCurrentTargetFocus(out Vector Focus)
{
	Focus = NewTargetLocation;
	return true;
}

defaultproperties
{
	LineLengthLimit = 5;
}
