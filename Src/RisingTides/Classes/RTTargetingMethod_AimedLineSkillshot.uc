//---------------------------------------------------------------------------------------
//  FILE:    RTTargetingMethod_AimedLineSkillshot.uc
//  AUTHOR:  Aleosiss  
//  DATE:    18 March 2016
//  PURPOSE: Targeting method that aims a line at a target.
//           
//---------------------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------------------

class RTTargetingMethod_AimedLineSkillshot extends X2TargetingMethod;
var protected vector NewTargetLocation, FiringLocation;
var protected TTile FiringTile;
var protected XComWorldData WorldData;
var private X2Camera_Midpoint MidpointCamera; // if the user has glam cams turned off in the options menu, then use a midpoint camera instead of the normal OTS cam to target the units
var private int LastTarget;
var protected bool bGoodTarget;
var protected X2Actor_LineTarget LineActor;

function Init(AvailableAction InAction)
{
	local X2Camera_OTSTargeting TargetingCamera;
	local X2Camera_MidpointTimed LookAtMidpointCamera;
	local X2AbilityTemplate AbilityTemplate;
	local float TileLength;
	
	super.Init(InAction);

	// Make sure we have targets of some kind.
	`assert(Action.AvailableTargets.Length > 0);

	AbilityTemplate = Ability.GetMyTemplate( );
	WorldData = `XWORLD;
	FiringTile = UnitState.TileLocation;
	FiringLocation = WorldData.GetPositionFromTileCoordinates(UnitState.TileLocation);
	FiringLocation.Z += class'XComWorldData'.const.WORLD_HalfFloorHeight;

	if(`Battle.ProfileSettingsGlamCam()) // no ots cameras if the user has glam cams off. We should stay in 3/4 view
	{
		// setup the camera. This will be a compound camera, where we get the unit onscreen,
		// then accent in to him, then cut to the ots cam
		TargetingCamera = new class'X2Camera_OTSTargeting';
		TargetingCamera.FiringUnit = FiringUnit;
		TargetingCamera.CandidateMatineeCommentPrefix = UnitState.GetMyTemplate().strTargetingMatineePrefix;
		TargetingCamera.ShouldBlend = class'X2Camera_LookAt'.default.UseSwoopyCam;
		TargetingCamera.ShouldHideUI = false;
		FiringUnit.TargetingCamera = TargetingCamera;
		`CAMERASTACK.AddCamera(TargetingCamera);
	}

	// select the target before setting up the midpoint cam so we know where we are midpointing to
	DirectSetTarget(0);

	// if we aren't using swoopy cams, then midpoint to the thing we are targeting before transitioning to the ots camera,
	// so that the user can see what they are about to target in the world
	if(!class'X2Camera_LookAt'.default.UseSwoopyCam)
	{
		LookAtMidpointCamera = new class'X2Camera_MidpointTimed';
		LookAtMidpointCamera.AddFocusActor(FiringUnit);
		LookAtMidpointCamera.LookAtDuration = 0.0f;
		LookAtMidpointCamera.AddFocusPoint(TargetingCamera.GetTargetLocation());
		TargetingCamera.PushCamera(LookAtMidpointCamera);
	}

	// set up the GUI line
	if (!AbilityTemplate.SkipRenderOfTargetingTemplate)
	{
		// setup the targeting mesh
		LineActor = `BATTLE.Spawn( class'X2Actor_LineTarget' );
		TileLength = 200 * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
		LineActor.MeshLocation = "UI_3D.Targeting.ConeRange";
		LineActor.InitLineMesh( TileLength  );
		LineActor.SetLocation( FiringLocation );
	}
}

private function RemoveCamera()
{
	if(FiringUnit.TargetingCamera != none)
	{
		`CAMERASTACK.RemoveCamera(FiringUnit.TargetingCamera);
		FiringUnit.TargetingCamera = none;
	}
}

function Canceled()
{
	RemoveCamera();

	FiringUnit.IdleStateMachine.bTargeting = false;
	NotifyTargetTargeted(false);

	if(MidpointCamera != none)
	{
		`CAMERASTACK.RemoveCamera(MidpointCamera);
		MidpointCamera = none;
	}
	AOEMeshActor.Destroy();
	ClearTargetedActors();
	LineActor.Destroy();
}

function Committed()
{
	if(!Ability.GetMyTemplate().bUsesFiringCamera)
	{
		RemoveCamera();
	}

	if(MidpointCamera != none)
	{
		`CAMERASTACK.RemoveCamera(MidpointCamera);
		MidpointCamera = none;
	}
	AOEMeshActor.Destroy();
	ClearTargetedActors();
	LineActor.Destroy();
}

function Update(float DeltaTime);

function NextTarget()
{
	DirectSetTarget(LastTarget + 1);
}

function PrevTarget()
{
	DirectSetTarget(LastTarget - 1);
}

function int GetTargetIndex()
{
	return LastTarget;
}

function DirectSetTarget(int TargetIndex)
{
	local XComPresentationLayer Pres;
	local UITacticalHUD TacticalHud;
	local XComGameStateHistory History;
	local Actor NewTargetActor;
	local array<Actor> CurrentlyMarkedTargets;
	local TTile TargetTile;
	local array<TTile> Tiles;
	local vector ShooterToTarget;
	local Rotator LineRotator;

	Pres = `PRES;
	History = `XCOMHISTORY;
	
	NotifyTargetTargeted(false);

	// make sure our target is in bounds (wrap around out of bounds values)
	LastTarget = TargetIndex;
	LastTarget = LastTarget % Action.AvailableTargets.Length;
	if(LastTarget < 0) LastTarget = Action.AvailableTargets.Length + LastTarget;

	NewTargetActor = History.GetVisualizer(Action.AvailableTargets[LastTarget].PrimaryTarget.ObjectID);

	NewTargetLocation = WorldData.GetPositionFromTileCoordinates(XComGameState_Unit(History.GetGameStateForObjectID(Action.AvailableTargets[LastTarget].PrimaryTarget.ObjectID)).TileLocation);
	TargetTile = WorldData.GetTileCoordinatesFromPosition(NewTargetLocation);
	//NewTargetLocation = WorldData.GetPositionFromTileCoordinates(TargetTile);
	NewTargetLocation.Z = WorldData.GetFloorZForPosition(NewTargetLocation, true) + class'XComWorldData'.const.WORLD_HalfFloorHeight;

	if (TargetTile == FiringTile)
	{
		bGoodTarget = false;
		return;
	}
	bGoodTarget = true;

	GetTargetedActors(NewTargetLocation, CurrentlyMarkedTargets, Tiles);
	CheckForFriendlyUnit(CurrentlyMarkedTargets);	
	MarkTargetedActors(CurrentlyMarkedTargets, (!AbilityIsOffensive) ? FiringUnit.GetTeam() : eTeam_None );

	DrawAOETiles(Tiles);

	if (LineActor != none)
	{
		ShooterToTarget = NewTargetLocation - FiringLocation;
		LineRotator = rotator( ShooterToTarget );
		LineActor.SetRotation( LineRotator );
	}


	// put the targeting reticle on the new target
	TacticalHud = Pres.GetTacticalHUD();
	TacticalHud.TargetEnemy(LastTarget);

	// have the camera look at the new target
	FiringUnit.TargetingCamera.SetTarget(NewTargetActor);

	FiringUnit.IdleStateMachine.bTargeting = true;
	FiringUnit.IdleStateMachine.CheckForStanceUpdate();

	class'WorldInfo'.static.GetWorldInfo().PlayAKEvent(AkEvent'SoundTacticalUI.TacticalUI_TargetSelect');

	NotifyTargetTargeted(true);

	// if the user has glam cams turned off, we won't have an OTS targeting cam. So midpoint instead.
	if(MidpointCamera != none)
	{
		`CAMERASTACK.RemoveCamera(MidpointCamera);
		MidpointCamera = none;
	}

	if(!`Battle.ProfileSettingsGlamCam())
	{
		MidpointCamera = new class'X2Camera_Midpoint';
		MidpointCamera.AddFocusActor(FiringUnit);
		MidpointCamera.AddFocusActor(NewTargetActor);
		`CAMERASTACK.AddCamera(MidpointCamera);
	}

	
}

private function NotifyTargetTargeted(bool Targeted)
{
	local XComGameStateHistory History;
	local XGUnit TargetUnit;

	History = `XCOMHISTORY;

	if( LastTarget != -1 )
	{
		TargetUnit = XGUnit(History.GetVisualizer(Action.AvailableTargets[LastTarget].PrimaryTarget.ObjectID));
	}

	if( TargetUnit != None )
	{
		// only have the target peek if he isn't peeking into the shooters tile. Otherwise they get really kissy.
		// setting the "bTargeting" flag will make the unit do the hold peek.
		TargetUnit.IdleStateMachine.bTargeting = Targeted && !FiringUnit.HasSameStepoutTile(TargetUnit);
		TargetUnit.IdleStateMachine.CheckForStanceUpdate();
	}
}

function bool GetCurrentTargetFocus(out Vector Focus)
{
	Focus = FiringUnit.TargetingCamera.GetTargetLocation();
	return true;
}

static function bool ShouldWaitForFramingCamera()
{
	// we only need to disable the framing camera if we are pushing an OTS targeting camera, which we don't do when user
	// has disabled glam cams
	return !`BATTLE.ProfileSettingsGlamCam();
}

function bool GetAdditionalTargets(out AvailableTarget AdditionalTargets)
{
	NewTargetLocation = WorldData.GetPositionFromTileCoordinates(XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Action.AvailableTargets[LastTarget].PrimaryTarget.ObjectID)).TileLocation);
	Ability.GatherAdditionalAbilityTargetsForLocation(NewTargetLocation, AdditionalTargets);
	return true;
}

function GetTargetLocations(out array<Vector> TargetLocations)
{
	TargetLocations.Length = 0;
	TargetLocations.AddItem(NewTargetLocation);
}

function name ValidateTargetLocations(const array<Vector> TargetLocations)
{
	if (TargetLocations.Length == 1 && bGoodTarget)
	{
		return 'AA_Success';
	}
	return 'AA_NoTargets';
}

defaultproperties
{
	LastTarget = -1;
}