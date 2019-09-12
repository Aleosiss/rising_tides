class SeqAct_RTGetObjectiveInfo extends SeqAct_GetObjectiveInfo;

defaultproperties
{
	ObjName="Get Objective Info"
	ObjCategory="RisingTides"
	bCallHandler=false
	bAutoActivateOutputLinks=true

	bConvertedForReplaySystem=true
	bCanBeUsedForGameplaySequence=true

	VariableLinks.Empty;
	VariableLinks(0)=(ExpectedType=class'SeqVar_Int',LinkDesc="Index",PropertyName=ObjectiveIndex)
	VariableLinks(1)=(ExpectedType=class'SeqVar_String',LinkDesc="ObjectiveSpawnTag",PropertyName=ObjectiveSpawnTag)
	VariableLinks(2)=(ExpectedType=class'SeqVar_GameUnit',LinkDesc="Unit",PropertyName=ObjectiveUnit,bWriteable=true)
	VariableLinks(3)=(ExpectedType=class'SeqVar_Object',LinkDesc="Actor",PropertyName=ObjectiveActor,bWriteable=true)
	VariableLinks(4)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Location",PropertyName=ObjectiveLocation,bWriteable=true)
	VariableLinks(5)=(ExpectedType=class'SeqVar_InteractiveObject',LinkDesc="ObjectiveObject",PropertyName=ObjectiveObject,bWriteable=true)
	VariableLinks(6)=(ExpectedType=class'SeqVar_Int',LinkDesc="Num Objectives",PropertyName=NumObjectives,bWriteable=true)
}