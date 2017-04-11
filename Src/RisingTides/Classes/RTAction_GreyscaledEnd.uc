//---------------------------------------------------------------------------------------
//  FILE:    X2Action_DLC_Day60FreezeEnd.uc
//  AUTHOR:  Joshua Bouscher
//	PURPOSE: Copypastaed so that Time Stop will compile
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class RTAction_GreyscaledEnd extends X2Action;

simulated function UnFreezeActionUnit()
{
	local CustomAnimParams AnimParams;

	UnitPawn.GetAnimTreeController().SetAllowNewAnimations(true);

	AnimParams.AnimName = 'ADD_FreezeStop';
	if( UnitPawn.GetAnimTreeController().CanPlayAnimation(AnimParams.AnimName) )
	{
		UnitPawn.GetAnimTreeController().PlayAdditiveDynamicAnim(AnimParams);
	}

	Unit.IdleStateMachine.PerformFlinch();
}

event bool BlocksAbilityActivation()
{
	return true;
}

simulated state Executing
{
Begin:
	UnFreezeActionUnit();

	CompleteAction();
}
