//---------------------------------------------------------------------------------------
//  FILE:    RTTacticalVisibilityHelpers.uc
//  AUTHOR:  Aleosiss
//  DATE:    6 March 2016
//  PURPOSE: Container class that holds methods specific to tactical that help filter /
//           serve queries for tactical mechanics.
//
//---------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------
class RTTacticalVisibilityHelpers extends X2TacticalVisibilityHelpers;

// custom GetAllVisibleAlliesForUnit function
/// <summary>
/// Returns an out param, VisibleUnits, containing all the allied units that a given unit can see
/// </summary>
simulated static function GetAllVisibleAlliesForUnit(int SourceStateObjectID,
													  out array<StateObjectReference> VisibleUnits,
													  optional array<X2Condition> RequiredConditions,
													  int HistoryIndex = -1)
{
	local int Index;
	local XComGameStateHistory History;
	local X2GameRulesetVisibilityManager VisibilityMgr;
	local XComGameState_unit SourceState;

	History = `XCOMHISTORY;
	VisibilityMgr = `TACTICALRULES.VisibilityMgr;

	SourceState = XComGameState_Unit(History.GetGameStateForObjectID(SourceStateObjectID, , HistoryIndex));

	//Set default conditions (visible units need to be alive and game play visible) if no conditions were specified
	if( RequiredConditions.Length == 0 )
	{
		RequiredConditions = default.LivingGameplayVisibleFilter;
	}

	VisibilityMgr.GetAllVisibleToSource(SourceStateObjectID, VisibleUnits, class'XComGameState_Unit', HistoryIndex, RequiredConditions);

	for( Index = VisibleUnits.Length - 1; Index > -1; --Index )
	{
		//Remove non-allies from the list
		if( !SourceState.TargetIsAlly(VisibleUnits[Index].ObjectID, HistoryIndex) )
		{
			VisibleUnits.Remove(Index, 1);
		}
	}
}
// custom GetAllVisibleAlliesForPlayer function
/// <summary>
/// Returns an out param, VisibleUnits, containing all the allied units that a given player can see
/// </summary>
static event GetAllVisibleAlliesForPlayer(int PlayerStateObjectID,
														out array<StateObjectReference> VisibleUnits,
														int HistoryIndex = -1,
														bool IncludeNonUnits = false)
{
	local int Index;
	local XComGameState_Unit PlayerUnit;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_Unit', PlayerUnit, , , HistoryIndex)
	{
		if( PlayerUnit.ControllingPlayer.ObjectID == PlayerStateObjectID )
		{
			break;
		}
	}

	//The player must have at least one unit to see enemies
	if( PlayerUnit != none )
	{
		GetAllVisibleObjectsForPlayer(PlayerStateObjectID, VisibleUnits, , HistoryIndex, IncludeNonUnits);

		for( Index = VisibleUnits.Length - 1; Index > -1; --Index )
		{
			//Remove non-allies from the list
			if(!PlayerUnit.TargetIsAlly(VisibleUnits[Index].ObjectID, HistoryIndex))
			{
				VisibleUnits.Remove(Index, 1);
			}
		}
	}
}
// custom GetAllSquadsightAlliesForUnit function
/// <summary>
/// Returns an out param, VisibleUnits, containing all the allied units that a given unit can see via squadsight
/// </summary>
simulated static function GetAllSquadsightAlliedForUnit(int SourceStateObjectID,
														 out array<StateObjectReference> VisibleUnits,
														 int HistoryIndex = -1,
														 bool IncludeNonUnits = false)
{
	local XComGameState_Unit UnitState;
	local XComGameStateHistory History;
	local X2GameRulesetVisibilityManager VisMan;
	local GameRulesCache_VisibilityInfo VisInfo;
	local array<StateObjectReference> VisibleToPlayer, VisibleToUnit;
	local int i, j;
	local bool bFound;

	History = `XCOMHISTORY;
	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(SourceStateObjectID, , HistoryIndex));
	if (UnitState != none)
	{
		VisMan = `TACTICALRULES.VisibilityMgr;
		GetAllVisibleAlliesForPlayer(UnitState.ControllingPlayer.ObjectID, VisibleToPlayer, HistoryIndex, IncludeNonUnits);
		GetAllVisibleAlliesForUnit(SourceStateObjectID, VisibleToUnit,, HistoryIndex);
		for (i = 0; i < VisibleToPlayer.Length; ++i)
		{
			bFound = false;
			for (j = 0; j < VisibleToUnit.Length; ++j)
			{
				if (VisibleToUnit[j] == VisibleToPlayer[i])
				{
					bFound = true;
					break;
				}
			}
			if (!bFound)
			{
				if( VisMan.GetVisibilityInfo(SourceStateObjectID, VisibleToPlayer[i].ObjectID, VisInfo, HistoryIndex) )
				{
					if (VisInfo.bClearLOS)
						VisibleUnits.AddItem(VisibleToPlayer[i]);
				}
			}
		}
	}
}
