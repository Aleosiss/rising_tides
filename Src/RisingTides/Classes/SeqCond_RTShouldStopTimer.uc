//---------------------------------------------------------------------------------------
//  FILE:    SeqCond_RTShouldStopTimer.uc
//  AUTHOR:  Aleosiss
//  DATE:    3 November 2016
//  PURPOSE: Determine whether or not the timer should stop 
//---------------------------------------------------------------------------------------
class SeqCond_RTShouldStopTimer extends SequenceCondition;

event Activated() {
  local XComGameState_Unit IteratorUnitState, UnitState;
  local XComGameStateHistory History;

  `LOG("Rising Tides: Looking for TimeStopMasterEffect.");
  History = `XCOMHISTORY;
  foreach History.IterateByClassType(class'XComGameState_Unit', IteratorUnitState) {
    if(IteratorUnitState.GetTeam() == eTeam_XCom) {
        if(IteratorUnitState.IsUnitAffectedByEffectName('TimeStopTagEffect')) {
          UnitState = IteratorUnitState;
          break;
        }
    }
  }

  // if we didn't find a unit affected by the master, time wasn't stopped
  if(UnitState == none) {
	`LOG("Didn't find it.");
    OutputLinks[0].bHasImpulse = true;
  } else {
	`LOG("Found it.");
    OutputLinks[1].bHasImpulse = true;
  }

}

defaultproperties
{
	ObjName="Is Time Stopped?"
	ObjCategory="Check"

	bAutoActivateOutputLinks=false
	bCanBeUsedForGameplaySequence=true
	bConvertedForReplaySystem=true

	InputLinks(0)=(LinkDesc="In")
	OutputLinks(0)=(LinkDesc="No")
	OutputLinks(1)=(LinkDesc="Yes")
}