class SeqAct_RTGetObjectiveInfo extends SeqAct_GetObjectiveInfo;

/*
*
* This class can handle an ObjectiveSpawnTag, which the base one could not.
* 
 */

event Activated()
{
	local XComGameStateHistory History;
	local XComTacticalMissionManager MissionManager;
	local string MissionType;
	local XComGameState_ObjectiveInfo ObjectiveInfo;
	local array<XComGameState_ObjectiveInfo> ObjectiveInfos;
	local TTile Tile;

	History = `XCOMHISTORY;
	MissionManager = `TACTICALMISSIONMGR;

	MissionType = MissionManager.ActiveMission.sType;

	// get all objectives that are valid for this kismet map
	`RTLOG("Looking for ObjectiveInfos matching " $ MissionType);
	foreach History.IterateByClassType(class'XComGameState_ObjectiveInfo', ObjectiveInfo)
	{
		if(MissionType == ObjectiveInfo.MissionType)
		{
			ObjectiveInfos.AddItem(ObjectiveInfo);
		}
	}

	NumObjectives = ObjectiveInfos.Length;

	// if a tag was specified, find it
	if(ObjectiveSpawnTag != "")
	{
		`RTLOG("RTGetObjectiveInfo: looking for OSP with OSPTag " $ ObjectiveSpawnTag);
		foreach ObjectiveInfos(ObjectiveInfo)
		{
			if(ObjectiveInfo.OSPSpawnTag != ObjectiveSpawnTag)
			{
				ObjectiveInfo = none;
			}
			else
			{
				`RTLOG("Found it.");
				break;
			}
		}
	
		if(ObjectiveInfo == none)
		{
			`RTLOG("SeqAct_GetObjectiveInfo::Activated()\n Assert FAILED: ObjectiveSpawnTag was specified, but no object has that tag!\n"
				$ "ObjectiveSpawnTag: " $ ObjectiveSpawnTag $ "\n", true);
		}
	}
	else if(ObjectiveIndex < ObjectiveInfos.Length)
	{
		// sort them by objectid. This guarantees that the indices are always the same, regardless of what order
		// the objectives were loaded
		ObjectiveInfos.Sort(SortInfos);
		ObjectiveInfo = ObjectiveInfos[ObjectiveIndex];
	}
	else
	{
		`RTLOG("SeqAct_GetObjectiveInfo::Activated()\n Assert FAILED: ObjectiveIndex is greater than ObjectiveInfos.Length!\n"
			$ "ObjectiveIndex: " $ ObjectiveIndex $ "\n"
			$ "ObjectiveInfos.Length" $ ObjectiveInfos.Length, true);
		return;
	}

	// now fill out the kismet vars		
	ObjectiveUnit = XComGameState_Unit(ObjectiveInfo.FindComponentObject(class'XComGameState_Unit', true));
	ObjectiveObject = XComGameState_InteractiveObject(ObjectiveInfo.FindComponentObject(class'XComGameState_InteractiveObject', true));
	ObjectiveActor = History.GetVisualizer(ObjectiveInfo.ObjectID);

	// get the location
	if(ObjectiveUnit != none)
	{
		// special case units. They are special
		ObjectiveUnit.GetKeystoneVisibilityLocation(Tile);
		ObjectiveLocation = class'XComWorldData'.static.GetWorldData().GetPositionFromTileCoordinates(Tile);
	}
	else if(ObjectiveObject != None)
	{
		// special case interactive objects. They are special-ish
		`RTLOG("Setting location for object.");
		Tile = ObjectiveObject.TileLocation;
		ObjectiveLocation = class'XComWorldData'.static.GetWorldData().GetPositionFromTileCoordinates(Tile);
	}
	else
	{
		// not a special object, just look at the actor
		ObjectiveLocation = ObjectiveActor.Location;
	}
}

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