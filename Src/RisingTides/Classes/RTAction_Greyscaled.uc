//---------------------------------------------------------------------------------------
//  FILE:    X2Action_DLC_Day60Freeze.uc
//  AUTHOR:  Joshua Bouscher
//  PURPOSE: Literally a copy-paste so that this shit compiles, please don't sue me
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class RTAction_Greyscaled extends X2Action;

var bool PlayIdle;

simulated function FreezeActionUnit()
{
	local CustomAnimParams AnimParams;

	AnimParams.AnimName = 'FreezePose';
	AnimParams.Looping = true;
	AnimParams.BlendTime = 0.0f;
	AnimParams.HasPoseOverride = true;
	AnimParams.Pose = UnitPawn.Mesh.LocalAtoms;

	UnitPawn.GetAnimTreeController().PlayFullBodyDynamicAnim(AnimParams);

	AnimParams.AnimName = 'ADD_FreezeStart';
	AnimParams.Looping = false;
	AnimParams.HasPoseOverride = false;
	if( UnitPawn.GetAnimTreeController().CanPlayAnimation(AnimParams.AnimName) )
	{
		UnitPawn.GetAnimTreeController().PlayAdditiveDynamicAnim(AnimParams);
	}

	// Ensure we disable aiming, snap it when they freeze since it would look weird for them
	// to aim (movement) while frozen
	UnitPawn.SetAiming(false, 0.0f);

	UnitPawn.GetAnimTreeController().SetAllowNewAnimations(false);
}

function ForceImmediateTimeout()
{
	// Do nothing. Since we want to ensure we freeze in the idle pose
}

event bool BlocksAbilityActivation()
{
	return true;
}

simulated state Executing
{
Begin:
	if( PlayIdle )
	{
		Unit.IdleStateMachine.PlayIdleAnim(true);
		Sleep(0.0f);
	}

	FreezeActionUnit();

	CompleteAction();
}
