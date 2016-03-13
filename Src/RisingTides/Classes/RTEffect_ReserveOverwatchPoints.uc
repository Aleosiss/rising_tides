//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_ReserveActionPoints.uc
//  AUTHOR:  Aleosiss
//  DATE:    10 March 2016
//  PURPOSE: Calculate the number of shots that Whisper can take on overwatc         
//---------------------------------------------------------------------------------------
//	Reserve Action Points
//---------------------------------------------------------------------------------------

class RTEffect_ReserveOverwatchPoints extends X2Effect_ReserveOverwatchPoints;

simulated protected function int GetNumPoints(XComGameState_Unit UnitState)
{
	if(UnitState.HasSoldierAbility('SixOClock'))
	{
	    return NumPoints;
	}
	else
	{
		return NumPoints;
	}
}

defaultproperties
{
	NumPoints = 1;
}
