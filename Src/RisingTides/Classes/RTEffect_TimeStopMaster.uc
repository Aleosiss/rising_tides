class RTEffect_TimeStopMaster extends X2Effect_PersistentStatChange;

var bool bShouldPauseTimer;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(kNewTargetState);
	
	// Could you, Madoka? Could you see me in my stopped time?
	// Uh, no...
	// Oh.
	AddPersistentStatChange(eStat_DetectionModifier, 1);

	// DetermineTimerStatus();
	// if(bShouldPauseTimer);
	// ModifyTimer(bShouldPauseTimer);
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
	local XComGameState_AIReinforcementSpawner OldSpawnerState, NewSpawnerState;
	local XComGameStateHistory		History;
	local int SpawnedUnitID;
  	
	History = `XCOMHISTORY;
	foreach History.IterateByClassType(class'XComGameState_AIReinforcementSpawner', OldSpawnerState) {
		NewSpawnerState = XComGameState_AIReinforcementSpawner(NewGamestate.CreateStateObject(class'XComGameState_AIReinforcementSpawner', OldSpawnerState.ObjectID));
		NewGameState.AddStateObject(NewSpawnerState);
		NewSpawnerState.CountDown += 1;
	}							
	return false;
}	

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	//ModifyTimer(!bShouldPauseTimer);
	
	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);
}

// Modify Timer, ripped from wghost's configure timers mod
// not using this atm...  
simulated function ModifyTimer(bool bEnabled) {
	local WorldInfo wInfo;
	local Sequence mainSequence;
	local array<SequenceObject> SeqObjs, LinkedObjs;
	local int i, j;
	local SeqVar_Int TimerVariable;
	local SeqVar_Bool TimerEngagedVariable;
	local GeneratedMissionData GeneratedMission;
	local XComGameState_BattleData BattleData;
	local string objectiveName;

	wInfo = `XWORLDINFO;
	mainSequence = wInfo.GetGameSequence();
	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	GeneratedMission = class'UIUtilities_Strategy'.static.GetXComHQ().GetGeneratedMissionData(BattleData.m_iMissionID);
	
	if(GeneratedMission.Mission.MapNames.Length != 0) {
		for(i = 0; i < GeneratedMission.Mission.MapNames.Length; i++) {
			if(InStr(GeneratedMission.Mission.MapNames[i], "Obj_") != -1) {
				objectiveName = GeneratedMission.Mission.MapNames[i];
				break;
			}
		}

		`Log("objectiveName = " $ objectiveName);

		if(objectiveName != "") {
			// This should cover the majority of timers
			if (mainSequence != None) {
				mainSequence.FindSeqObjectsByClass( class'SequenceVariable', true, SeqObjs);
				if(SeqObjs.Length != 0) {
					`Log("Kismet variables found");
					for(i = 0; i < SeqObjs.Length; i++) {
						if(InStr(string(SequenceVariable(SeqObjs[i]).VarName), "TimerEngaged") != -1) {
							`Log("Variable found: " $ SequenceVariable(SeqObjs[i]).VarName);
							`Log("bValue = " $ SeqVar_Bool(SeqObjs[i]).bValue);
							TimerEngagedVariable = SeqVar_Bool(SeqObjs[i]);

							if(bEnabled) {
								TimerEngagedVariable.bValue = 1;
							} else {
								TimerEngagedVariable.bValue = 0;
							}
							`Log("Timer modified!");
						}
					}
				}
				// I can't find what this actually does in kismet, from what I can tell
				// the above code should handle it fine. keeping it though
				if((objectiveName == "Obj_RecoverItem" || objectiveName == "Obj_RecoverFlightDevice")) {
					`Log("Recovery mission special handler");
					SeqObjs.Length = 0;
					mainSequence.FindSeqObjectsByClass( class'SeqAct_SetBool', true, SeqObjs);
					if(SeqObjs.Length != 0) {
						`Log("Kismet actions found");
						for(i = 0; i < SeqObjs.Length; i++) {
							if(InStr(SeqObjs[i].ObjComment, "Flag timer engaged") != -1) {
								`Log("Flag timer engaged found");
								SequenceOp(SeqObjs[i]).GetLinkedObjects(LinkedObjs, class'SeqVar_Bool', false);
								`Log("LinkedObjs.Length = " $ LinkedObjs.Length);
								for(j = 0; j < LinkedObjs.Length; j++) {
									`Log("Variable found: " $ SequenceVariable(LinkedObjs[j]).VarName);
									`Log("bValue = " $ SeqVar_Bool(LinkedObjs[j]).bValue);
									TimerEngagedVariable = SeqVar_Bool(LinkedObjs[j]);

									if(bEnabled) {
										TimerEngagedVariable.bValue = 1;
									} else {
										TimerEngagedVariable.bValue = 0;
									}
									`Log("Timer modified");
								}
							}
						}
					}
				}
				
			
				if(objectiveName == "Obj_SecureUFO") {
					`Log("UFO mission special handler");
					SeqObjs.Length = 0;
					mainSequence.FindSeqObjectsByClass( class'SequenceVariable', true, SeqObjs);
					if(SeqObjs.Length != 0) {
						`Log("Kismet variables found");
						for(i = 0; i < SeqObjs.Length; i++) {
							if(InStr(string(SequenceVariable(SeqObjs[i]).VarName), "DistressBeaconActive") != -1) {
								`Log("Variable found: " $ SequenceVariable(SeqObjs[i]).VarName);
								`Log("bValue = " $ SeqVar_Bool(SeqObjs[i]).bValue);
								TimerEngagedVariable = SeqVar_Bool(SeqObjs[i]);
								TimerEngagedVariable.bValue = 1;
								`Log("Timer disabled");
							}
							if(InStr(string(SequenceVariable(SeqObjs[i]).VarName), "DistressResolved") != -1) {
								`Log("Variable found: " $ SequenceVariable(SeqObjs[i]).VarName);
								`Log("bValue = " $ SeqVar_Bool(SeqObjs[i]).bValue);
								TimerEngagedVariable = SeqVar_Bool(SeqObjs[i]);
								TimerEngagedVariable.bValue = 1;
								`Log("Timer disabled");
							}
						}
					}
					SeqObjs.Length = 0;
					mainSequence.FindSeqObjectsByClass( class'SeqCond_CompareBool', true, SeqObjs);
					if(SeqObjs.Length != 0) {
						`Log("Kismet actions found");
						for(i = 0; i < SeqObjs.Length; i++) {
							if(InStr(SeqObjs[i].ObjComment, "Was beacon already disarmed?") != -1) {
								`Log("Was beacon already disarmed? found");
								SequenceOp(SeqObjs[i]).OutputLinks[1].bDisabled = true; //"false" link
							}
						}
					}
				}
				
				
			}
		}
	}
}

// TODO: DetermineTimerStatus
simulated function DetermineTimerStatus () { 

}
