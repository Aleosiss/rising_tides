// Code based on Musashi's Spec Ops -> Evasion ability
class RTEffect_GenerateAfterimage extends X2Effect_SpawnMimicBeacon;

var vector SpawnLocation;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit   UnitState;
	local XComWorldData World;

	World = `XWORLD;
	UnitState = XComGameState_Unit(kNewTargetState);

	if (UnitState != none)
	{
		SpawnLocation = GetRandomSpawnLocation(ApplyEffectParameters, 2);
		super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
	}
}

function vector GetSpawnLocation(const out EffectAppliedData ApplyEffectParameters) {
	return SpawnLocation;
}

simulated function vector GetRandomSpawnLocation(const out EffectAppliedData ApplyEffectParameters, int RBMaxOffset) {
	local TTile TileLocation, DesiredSpawnLocation;
	local XComWorldData World;
	local Actor TileActor;
	local vector RandSpawnLocation, RandomOffset, DesiredSpawnVector;
	local bool bValid;
	local XComGameState_Unit UnitState;

	World = `XWORLD;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	TileLocation = UnitState.TileLocation;

	while (!bValid)
	{
		RandomOffset.X = Rand(RBMaxOffset*2+1)-RBMaxOffset;
		RandomOffset.Y = Rand(RBMaxOffset*2+1)-RBMaxOffset;
		RandomOffset.Z = Rand(17)-8;

		DesiredSpawnLocation.X = TileLocation.X + RandomOffset.X;
		DesiredSpawnLocation.Y = TileLocation.Y + RandomOffset.Y;
		DesiredSpawnLocation.Z = TileLocation.Z + RandomOffset.Z;

		DesiredSpawnVector = World.FindClosestValidLocation(World.GetPositionFromTileCoordinates(DesiredSpawnLocation), false, true, false);
		DesiredSpawnLocation = World.GetTileCoordinatesFromPosition(DesiredSpawnVector);

		//since findclosestvalidlocation prefers locations at the same Z levels, soldiers sometimes spawn farther away than intended
		//this check prevents this
		if(DesiredSpawnLocation.X > TileLocation.X+RBMaxOffset || DesiredSpawnLocation.X < TileLocation.X-RBMaxOffset || DesiredSpawnLocation.Y > TileLocation.Y+RBMaxOffset || DesiredSpawnLocation.Y < TileLocation.Y-RBMaxOffset)
		{
			continue;
		}

		TileActor = World.GetActorOnTile(DesiredSpawnLocation);

		if (TileActor == none)
		{
			RandSpawnLocation = DesiredSpawnVector;
			bValid = true;
		}
	}
	return RandSpawnLocation;
}

function OnSpawnComplete(const out EffectAppliedData ApplyEffectParameters, StateObjectReference NewUnitRef, XComGameState NewGameState)
{
	local XComGameState_Unit MimicBeaconGameState, SourceUnitGameState, AttackingUnit;
	local XComGameStateContext_Ability AbilityContext;

	MimicBeaconGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(NewUnitRef.ObjectID));
	`assert(MimicBeaconGameState != none);


	SourceUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if( SourceUnitGameState == none)
	{
		SourceUnitGameState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID, eReturnType_Reference));
	}
	`assert(SourceUnitGameState != none);

	AttackingUnit = class'X2TacticalGameRulesetDataStructures'.static.GetAttackingUnitState(NewGameState);
	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());

	if(AbilityContext.InputContext.SourceObject.ObjectID == AttackingUnit.ObjectID)
	{
		AbilityContext.InputContext.PrimaryTarget.ObjectID = NewUnitRef.ObjectID;
	}
	super.OnSpawnComplete(ApplyEffectParameters, NewUnitRef, NewGameState);

	MimicBeaconGameState.SetCurrentStat(eStat_HP, 1);
	MimicBeaconGameState.SetBaseMaxStat(eStat_HP, 1, ECSMAR_None);
}

defaultproperties
{
	UnitToSpawnName="MimicBeacon"
	bCopyTargetAppearance=true
	bKnockbackAffectsSpawnLocation=false
	EffectName="SpawnMimicBeacon"
}
