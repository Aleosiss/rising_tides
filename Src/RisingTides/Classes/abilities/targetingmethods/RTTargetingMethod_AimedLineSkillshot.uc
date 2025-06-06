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

var int LineLengthTiles;					// if greater than 0, the line with have this length instead of the default
var bool bOriginateAtTargetLocation;		// if set, the line will originate from the target instead of the shooter

var protected vector NewTargetLocation, FiringLocation;
var protected TTile FiringTile;
var protected XComWorldData WorldData;
var private int LastTarget;
var protected bool bGoodTarget;
var protected X2Actor_LineTarget LineActor;
var protected X2Actor_LineTarget LineActorReversed;

function Init(AvailableAction InAction, int NewTargetIndex)
{
	local X2AbilityTemplate AbilityTemplate;

	super.Init(InAction, NewTargetIndex);

	// Make sure we have targets of some kind.
	`assert(Action.AvailableTargets.Length > 0);

	LastTarget = NewTargetIndex;
	LastTarget = LastTarget % Action.AvailableTargets.Length;
	if (LastTarget < 0) {
		LastTarget = Action.AvailableTargets.Length + LastTarget;
	}

	AbilityTemplate = Ability.GetMyTemplate( );
	if(AbilityTemplate.IsA('RTAbilityTemplate')) {
		LineLengthTiles = RTAbilityTemplate(AbilityTemplate).LineLengthTiles;
		bOriginateAtTargetLocation = RTAbilityTemplate(AbilityTemplate).bOriginateAtTargetLocation;
	} else {
		LineLengthTiles = 0;
		bOriginateAtTargetLocation = false;
	}

	`RTLOG("bOriginateAtTargetLocation " $ bOriginateAtTargetLocation);
	`RTLOG("LineLengthTiles " $ LineLengthTiles);


	WorldData = `XWORLD;
	FiringTile = UnitState.TileLocation;
	FiringLocation = WorldData.GetPositionFromTileCoordinates(UnitState.TileLocation);
	// shoot at their midpoint for now...
	FiringLocation.Z += class'XComWorldData'.const.WORLD_HalfFloorHeight;

	// set up the GUI line
	if (!AbilityTemplate.SkipRenderOfTargetingTemplate)
	{
		if(bOriginateAtTargetLocation) {
			SetupLineTargetOrigin();
		} else {
			SetupLineShooterOrigin();
		}
	}

	UpdatePostProcessEffects(true);
	// select the target before setting up the midpoint cam so we know where we are midpointing to
	DirectSetTarget(0);
}

private function SetupLineTargetOrigin() {
	local float FinalLineLength;
	local float TileLength;
	// setup the targeting mesh
	LineActor = `BATTLE.Spawn( class'X2Actor_LineTarget' );
	LineActorReversed = `BATTLE.Spawn( class'X2Actor_LineTarget' );

	if(LineLengthTiles > 0) {
		FinalLineLength = LineLengthTiles;
	} else {
		FinalLineLength = 200;
	}

	FinalLineLength = FinalLineLength / 2;
	//TileLength = FinalLineLength * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	TileLength = FinalLineLength;
	
	LineActor.MeshLocation = "UI_3D.Targeting.ConeRange";
	LineActor.InitLineMesh( TileLength );
	LineActor.SetLocation( FiringLocation );
	AimLineAtTargetLocation(GetTargetedActor().Location);

	LineActorReversed.MeshLocation = "UI_3D.Targeting.ConeRange";
	LineActorReversed.InitLineMesh( TileLength );
	LineActorReversed.SetLocation( FiringLocation );
	AimLineAtTargetLocation(GetTargetedActor().Location, true);
}

private function SetupLineShooterOrigin() {
	local float FinalLineLength;
	local float TileLength;

	// setup the targeting mesh
	LineActor = `BATTLE.Spawn( class'X2Actor_LineTarget' );
	LineActorReversed = `BATTLE.Spawn( class'X2Actor_LineTarget' );

	if(LineLengthTiles > 0) {
		FinalLineLength = LineLengthTiles;
	} else {
		FinalLineLength = 200;
	}

	//TileLength = FinalLineLength * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	TileLength = FinalLineLength;

	LineActor.MeshLocation = "UI_3D.Targeting.ConeRange";
	LineActor.InitLineMesh( TileLength );

	LineActor.SetLocation( FiringLocation );
	AimLineAtTargetLocation(GetTargetedActor().Location);
}

private function AddTargetingCamera(Actor NewTargetActor, bool ShouldUseMidpointCamera)
{
	local X2Camera_Midpoint MidpointCamera;
	local X2Camera_OTSTargeting OTSCamera;
	local X2Camera_MidpointTimed LookAtMidpointCamera;
	local bool bCurrentTargetingCameraIsMidpoint;
	local bool bShouldAddNewTargetingCameraToStack;

	if( FiringUnit.TargetingCamera != None )
	{
		bCurrentTargetingCameraIsMidpoint = (X2Camera_Midpoint(FiringUnit.TargetingCamera) != None);

		if( bCurrentTargetingCameraIsMidpoint != ShouldUseMidpointCamera )
		{
			RemoveTargetingCamera();
		}
	}

	if( ShouldUseMidpointCamera )
	{
		if( FiringUnit.TargetingCamera == None )
		{
			FiringUnit.TargetingCamera = new class'X2Camera_Midpoint';
			bShouldAddNewTargetingCameraToStack = true;
		}

		MidpointCamera = X2Camera_Midpoint(FiringUnit.TargetingCamera);
		MidpointCamera.TargetActor = NewTargetActor;
		MidpointCamera.ClearFocusActors();
		MidpointCamera.AddFocusActor(FiringUnit);
		MidpointCamera.AddFocusActor(NewTargetActor);

		// the following only needed if bQuickTargetSelectEnabled were desired
		//if( TacticalHud.m_kAbilityHUD.LastTargetActor != None )
		//{
		//	MidpointCamera.AddFocusActor(TacticalHud.m_kAbilityHUD.LastTargetActor);
		//}

		if( bShouldAddNewTargetingCameraToStack ) {
			`CAMERASTACK.AddCamera(FiringUnit.TargetingCamera);
		}

		MidpointCamera.RecomputeLookatPointAndZoom(false);
	}
	else
	{
		if( FiringUnit.TargetingCamera == None )
		{
			FiringUnit.TargetingCamera = new class'X2Camera_OTSTargeting';
			bShouldAddNewTargetingCameraToStack = true;
}

		OTSCamera = X2Camera_OTSTargeting(FiringUnit.TargetingCamera);
		OTSCamera.FiringUnit = FiringUnit;
		OTSCamera.CandidateMatineeCommentPrefix = UnitState.GetMyTemplate().strTargetingMatineePrefix;
		OTSCamera.ShouldBlend = class'X2Camera_LookAt'.default.UseSwoopyCam;
		OTSCamera.ShouldHideUI = false;

		if( bShouldAddNewTargetingCameraToStack )
{
			`CAMERASTACK.AddCamera(FiringUnit.TargetingCamera);
		}

		// add swoopy midpoint
		if( !OTSCamera.ShouldBlend ) {
			LookAtMidpointCamera = new class'X2Camera_MidpointTimed';
			LookAtMidpointCamera.AddFocusActor(FiringUnit);
			LookAtMidpointCamera.LookAtDuration = 0.0f;
			LookAtMidpointCamera.AddFocusPoint(OTSCamera.GetTargetLocation());
			OTSCamera.PushCamera(LookAtMidpointCamera);
		}

		// have the camera look at the new target
		OTSCamera.SetTarget(NewTargetActor);
	}
}


private function RemoveTargetingCamera()
{
	if( FiringUnit.TargetingCamera != none )
	{
		`CAMERASTACK.RemoveCamera(FiringUnit.TargetingCamera);
		FiringUnit.TargetingCamera = none;
	}
}

function Canceled()
{
	super.Canceled();
	RemoveTargetingCamera();

	FiringUnit.IdleStateMachine.bTargeting = false;
	NotifyTargetTargeted(false);

	AOEMeshActor.Destroy();
	ClearTargetedActors();
	LineActor.Destroy();
	LineActorReversed.Destroy();


	UpdatePostProcessEffects(false);
}

function Committed()
{
	AOEMeshActor.Destroy();
	ClearTargetedActors();
	LineActor.Destroy();
	LineActorReversed.Destroy();

	if(!Ability.GetMyTemplate().bUsesFiringCamera)
	{
		RemoveTargetingCamera();
	}

	UpdatePostProcessEffects(false);
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
	local Actor NewTargetActor;
	local bool ShouldUseMidpointCamera;
	local array<TTile> Tiles, TargetTiles;
	local TTile IteratorTile;
	local XComDestructibleActor Destructible;
	local Vector TilePosition;
	local TTile CurrentTile;
	local XComWorldData World;
	local array<Actor> CurrentlyMarkedTargets;

	Pres = `PRES;
	World = `XWORLD;
	
	NotifyTargetTargeted(false);

	// make sure our target is in bounds (wrap around out of bounds values)
	LastTarget = TargetIndex;
	LastTarget = LastTarget % Action.AvailableTargets.Length;
	if (LastTarget < 0) LastTarget = Action.AvailableTargets.Length + LastTarget;

	ShouldUseMidpointCamera = ShouldUseMidpointCameraForTarget(Action.AvailableTargets[LastTarget].PrimaryTarget.ObjectID) || !`Battle.ProfileSettingsGlamCam();

	NewTargetActor = GetTargetedActor();

	AddTargetingCamera(NewTargetActor, ShouldUseMidpointCamera);
	
	// put the targeting reticle on the new target
	TacticalHud = Pres.GetTacticalHUD();
	TacticalHud.TargetEnemy(GetTargetedObjectID());

	FiringUnit.IdleStateMachine.bTargeting = true;
	FiringUnit.IdleStateMachine.CheckForStanceUpdate();

	class'WorldInfo'.static.GetWorldInfo().PlayAKEvent(AkEvent'SoundTacticalUI.TacticalUI_TargetSelect');

	NotifyTargetTargeted(true);

	// aoe of target (car, enemy with homing mine)
	Destructible = XComDestructibleActor(NewTargetActor);
	if( Destructible != None )
	{
		Destructible.GetRadialDamageTiles(TargetTiles);
	}
	else
	{
		GetEffectAOETiles(TargetTiles);
	}

	//	reset these values when changing targets
	bFriendlyFireAgainstObjects = false;
	bFriendlyFireAgainstUnits = false;

	NewTargetLocation = WorldData.GetPositionFromTileCoordinates(XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(GetTargetedObjectID())).TileLocation);
	//NewTargetLocation = WorldData.GetPositionFromTileCoordinates(TargetTile);
	NewTargetLocation.Z = WorldData.GetFloorZForPosition(NewTargetLocation, true) + class'XComWorldData'.const.WORLD_HalfFloorHeight;

	GetTargetedActors(NewTargetLocation, CurrentlyMarkedTargets, Tiles);
	`RTLOG("Tiles.Length " $ Tiles.Length);
	if(bOriginateAtTargetLocation && LineLengthTiles > 0) {
		FilterByRange(Tiles, CurrentlyMarkedTargets, NewTargetLocation);
	}
	`RTLOG("Tiles.Length after culling: " $ Tiles.Length $ "; Should be equal to 2 * " $ LineLengthTiles $ " + 1");


	// add in the target tiles now; they aren't affect by our range culling
	foreach TargetTiles(IteratorTile) {
		Tiles.AddItem(IteratorTile);
	}
	
	if( ShouldUseMidpointCamera )
	{
		foreach Tiles(CurrentTile)
		{
			TilePosition = World.GetPositionFromTileCoordinates(CurrentTile);
			if( World.Volume.EncompassesPoint(TilePosition) )
			{
				X2Camera_Midpoint(FiringUnit.TargetingCamera).AddFocusPoint(TilePosition, true);
			}
		}
	}

	if(bOriginateAtTargetLocation) {
		LineActor.SetLocation( GetTargetedActor().Location );
		LineActorReversed.SetLocation( GetTargetedActor().Location );
		AimLineAtTargetLocation(NewTargetLocation, true);
	} else {
		AimLineAtTargetLocation(NewTargetLocation);
	}
	
	GetTargetedActorsInTiles(Tiles, CurrentlyMarkedTargets, false);
	CheckForFriendlyUnit(CurrentlyMarkedTargets);
	MarkTargetedActors(CurrentlyMarkedTargets, (!AbilityIsOffensive) ? FiringUnit.GetTeam() : eTeam_None);
	`RTLOG("CurrentlyMarkedTargets.Length " $ CurrentlyMarkedTargets.Length);
	DrawAOETiles(Tiles);
	AOEMeshActor.SetHidden(false);
}

private function AimLineAtTargetLocation(vector TargetLocation, optional bool bReverse = false) {
	local vector ShooterToTarget;
	local Rotator LineRotator;

	if (LineActor != none) {
		ShooterToTarget = TargetLocation - FiringLocation;
		LineRotator = rotator( ShooterToTarget );

		LineActor.SetRotation( LineRotator );
	}

	if(LineActorReversed != none && bReverse) {
		ShooterToTarget = FiringLocation - TargetLocation;
		LineRotator = rotator( ShooterToTarget );

		LineActorReversed.SetRotation( LineRotator );
	}
}

private function GetEffectAOETiles(out array<TTile> TilesToBeDamaged)
{
	local XComGameState_Unit TargetUnit;
	local XComGameStateHistory History;
	local XComGameState_Effect EffectState;
	local StateObjectReference EffectRef;
	local XComGameState_Unit SourceUnit;

	History = `XCOMHISTORY;

	TargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(GetTargetedObjectID()));
	if( TargetUnit != None )
	{
		foreach TargetUnit.AffectedByEffects(EffectRef)
		{
			EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
			if( EffectState != None )
			{
				SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
				if( SourceUnit != None )
				{
					EffectState.GetX2Effect().GetAOETiles(SourceUnit, TargetUnit, TilesToBeDamaged);
				}
			}
		}
	}
}

private function FilterByRange(out array<TTile> ValidTiles, out array<Actor> CurrentlyMarkedTargets, Vector Location) {
	local TTile IteratorTile;
	local XComWorldData LocalWorldData;
	local float Dist;
	local int TileDist;
	local Actor IteratorActor;
	local array<TTile> FilteredTiles;
	local array<Actor> FilteredTargets;

	LocalWorldData = `XWORLD;
	
	// Filter tiles
	foreach ValidTiles(IteratorTile) {
		Dist = VSize(Location - LocalWorldData.GetPositionFromTileCoordinates(IteratorTile));
		TileDist = Dist / LocalWorldData.WORLD_StepSize;
		if(TileDist <= (LineLengthTiles / 2)) {
			FilteredTiles.AddItem(IteratorTile);
		}
	}
	ValidTiles = FilteredTiles;

	// Filter actors
	foreach CurrentlyMarkedTargets(IteratorActor) {
		Dist = VSize(Location - IteratorActor.Location);
		TileDist = Dist / LocalWorldData.WORLD_StepSize;
		if(TileDist <= (LineLengthTiles / 2)) {
			FilteredTargets.AddItem(IteratorActor);
		}
	}
	CurrentlyMarkedTargets = FilteredTargets;
}

private function NotifyTargetTargeted(bool Targeted)
{
	local XComGameStateHistory History;
	local XGUnit TargetUnit;

	History = `XCOMHISTORY;

	if( LastTarget != -1 )
	{
		TargetUnit = XGUnit(History.GetVisualizer(GetTargetedObjectID()));
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
	if( FiringUnit.TargetingCamera != None )
	{
		Focus = FiringUnit.TargetingCamera.GetTargetLocation();
	}
	else
	{
		Focus = GetTargetedActor().Location;
	}
	return true;
}

static function bool ShouldWaitForFramingCamera()
{
	// we only need to disable the framing camera if we are pushing an OTS targeting camera, which we don't do when user
	// has disabled glam cams
	return !`BATTLE.ProfileSettingsGlamCam();
}

defaultproperties
{
	LastTarget = -1;
}