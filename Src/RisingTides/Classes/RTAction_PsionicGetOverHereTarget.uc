//-----------------------------------------------------------
// Used by the visualizer system to control a Visualization Actor
//-----------------------------------------------------------
class RTAction_PsionicGetOverHereTarget extends X2Action_ViperGetOverHereTarget;

simulated state Executing
{
Begin:
	//Wait for our turn to complete... and then set our rotation to face the destination exactly
	while(UnitPawn.m_kGameUnit.IdleStateMachine.IsEvaluatingStance())
	{
		Sleep(0.01f);
	}

	UnitPawn.EnableRMA(true,true);
	UnitPawn.EnableRMAInteractPhysics(true);
	UnitPawn.bSkipIK = true;

	Params.AnimName = 'NO_StrangleStart'; //TODO:: CHANGE THIS!!!
	DesiredRotation = Rotator(Normal(DesiredLocation - UnitPawn.Location));
	StartingAtom.Rotation = QuatFromRotator(DesiredRotation);
	StartingAtom.Translation = UnitPawn.Location;
	StartingAtom.Scale = 1.0f;
	UnitPawn.GetAnimTreeController().GetDesiredEndingAtomFromStartingAtom(Params, StartingAtom);
	UnitPawn.GetAnimTreeController().PlayFullBodyDynamicAnim(Params);

	// hide the targeting icon
	Unit.SetDiscState(eDS_None);

	DistanceToTargetSquared = VSizeSq(DesiredLocation - UnitPawn.Location);
	while(DistanceToTargetSquared > Square(UnitPawn.fStrangleStopDistance))
	{
		Sleep(0.0f);
		DistanceToTargetSquared = VSizeSq(DesiredLocation - UnitPawn.Location);
	}

	UnitPawn.bSkipIK = false;          //TODO:: CHANGE THIS!!!
	Params.AnimName = 'NO_StrangleStop';
	Params.HasDesiredEndingAtom = true;
	Params.DesiredEndingAtom.Scale = 1.0f;
	Params.DesiredEndingAtom.Translation = DesiredLocation;
	DesiredRotation = UnitPawn.Rotation;
	DesiredRotation.Pitch = 0.0f;
	DesiredRotation.Roll = 0.0f;
	Params.DesiredEndingAtom.Rotation = QuatFromRotator(DesiredRotation);
	FinishAnim(UnitPawn.GetAnimTreeController().PlayFullBodyDynamicAnim(Params));

	CompleteAction();
}

DefaultProperties
{
}
