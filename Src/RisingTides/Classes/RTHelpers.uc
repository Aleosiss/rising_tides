// This is an Unreal Script
class RTHelpers extends Object config(RisingTides);

var config array<name> StandardShots, MeleeAbilities, SniperShots, OverwatchShots, PsionicAbilities, FreeActions;
var config name ProgramFactionName;

enum ERTChecklist {
	eChecklist_StandardShots,
	eChecklist_SniperShots,
	eChecklist_OverwatchShots,
	eChecklist_PsionicAbilities,
	eChecklist_MeleeAbilities,
	eChecklist_FreeActions
};

// copied here from X2Helpers_DLC_Day60.uc
static function bool IsUnitAlienRuler(XComGameState_Unit UnitState)
{
	return UnitState.IsUnitAffectedByEffectName('AlienRulerPassive');
}

static function ListDefaultAbilityLists() {
	local name n;

	foreach default.StandardShots(n) {
		`RTLOG("Standard Shots: " @ n);
	}

	foreach default.MeleeAbilities(n) {
		`RTLOG("Melee Abilities: " @ n);
	}

	foreach default.SniperShots(n) {
		`RTLOG("Sniper Shots: " @ n);
	}

	foreach default.OverwatchShots(n) {
		`RTLOG("Overwatch Shots: " @ n);
	}

	foreach default.PsionicAbilities(n) {
		`RTLOG("Psionic Abilities: " @ n);
	}

	foreach default.FreeActions(n) {
		`RTLOG("Free Actions: " @ n);
	}
}


static function bool CheckAbilityActivated(name AbilityTemplateName, ERTChecklist Checklist, optional bool bDebug = false) {
	local bool b;
	local string n;
	b = true;

	//ListDefaultAbilityLists();

	switch(Checklist) {
		case eChecklist_MeleeAbilities:
					n = "Melee Abilities";
					if( default.MeleeAbilities.Find(AbilityTemplateName) == INDEX_NONE )
					{ b = false; }
					break;
		case eChecklist_SniperShots:
					n = "Sniper Shots";
					if( default.SniperShots.Find(AbilityTemplateName) == INDEX_NONE )
					{ b = false; }
					break;
		case eChecklist_OverwatchShots:
					n = "Overwatch Shots";
					if( default.OverwatchShots.Find(AbilityTemplateName) == INDEX_NONE )
					{ b = false; }
					break;
		case eChecklist_PsionicAbilities:
					n = "Psionic Abilities";
					if( default.PsionicAbilities.Find(AbilityTemplateName) == INDEX_NONE )
					{ b = false; }
					break;
		case eChecklist_StandardShots:
					n = "Standard Shots";
					if( default.StandardShots.Find(AbilityTemplateName) == INDEX_NONE )
					{ b = false; }
					break;
		case eChecklist_FreeActions:
					n = "Free Actions";
					if( default.FreeActions.Find(AbilityTemplateName) == INDEX_NONE )
					{ b = false; }
					break;
		default:
					b = false;
	}

	if(!b && bDebug) {
		`RTLOG(AbilityTemplateName $ " was not found in " $ n);
	}

	return b;
}

static function bool MultiCatCheckAbilityActivated(name AbilityTemplateName, array<ERTChecklist> Checklists, optional bool bDebug = false) {
	local ERTChecklist Iterator;
	local bool b;

	b = false;
	foreach Checklists(Iterator) {
		b = CheckAbilityActivated(AbilityTemplateName, Iterator, bDebug);
		if(b) {
			break;
		}
	}

	return b;
}

static function GetAdjacentTiles(TTile TargetTile, out array<TTile> AdjacentTiles) {
	local int x, y;
	local TTile Tile;

	for(x = -1; x <= 1; x++) {
		for(y = -1; y <= 1; y++) {
			Tile = TargetTile;
			Tile.X += x;
			Tile.Y += y;
			if(x == 0 && y == 0)
				continue;

			AdjacentTiles.AddItem(Tile);
		}
	}
}

static function RTGameState_ProgramFaction GetProgramState(optional XComGameState NewGameState) {
	local RTGameState_ProgramFaction Program;

	if(NewGameState != none) {
		foreach NewGameState.IterateByClassType(class'RTGameState_ProgramFaction', Program) {
			break;
		}
	}

	if(Program == none) {
		foreach `XCOMHISTORY.IterateByClassType(class'RTGameState_ProgramFaction', Program) {
			break;
		}
	}

	if(Program == none) {
		Program = RTGameState_ProgramFaction(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'RTGameState_ProgramFaction'));
	}

	if(Program == none) {
		`RTLOG("ERROR, Could not find a ProgramStateObject, returning NONE!", true, false);
	}
	
	return Program;
}

static function RTGameState_ProgramFaction GetNewProgramState(XComGameState NewGameState) {
	local RTGameState_ProgramFaction Program;

	Program = GetProgramState(NewGameState);
	if(Program == none) {
		return none;
	}

	Program = RTGameState_ProgramFaction(NewGameState.ModifyStateObject(class'RTGameState_ProgramFaction', Program.ObjectID));
	return Program;
}


static function RTLog(string message, optional bool bShouldRedScreenToo = false, optional bool bShouldOutputToConsoleToo = false) {
	local bool b;

	b = DebuggingEnabled();
	`LOG(message, b, 'Rising Tides');
	if(bShouldRedScreenToo && b) {
		`RedScreen("RisingTides: " $ message);
	}
	if(bShouldOutputToConsoleToo && b) {
		class'Helpers'.static.OutputMsg(message);
	}
}

static function bool DebuggingEnabled() {
	return class'X2DownloadableContentInfo_RisingTides'.static.DebuggingEnabled();
}

static function PrintCovertActionsForFaction(XComGameState_ResistanceFaction Faction) {
	local StateObjectReference StateObjRef;
	local XComGameState_CovertAction CovertActionState;
	local X2CovertActionTemplate CovertActionTemplate;

	foreach Faction.CovertActions(StateObjRef) {
		CovertActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(StateObjRef.ObjectID));
		if(CovertActionState == none)
			continue;
		CovertActionTemplate = CovertActionState.GetMyTemplate();
		RTLog("" $ CovertActionTemplate.DataName);
	}
}

static function PrintGoldenPathActionsForFaction(XComGameState_ResistanceFaction Faction) {
	local StateObjectReference StateObjRef;
	local XComGameState_CovertAction CovertActionState;
	local X2CovertActionTemplate CovertActionTemplate;

	foreach Faction.GoldenPathActions(StateObjRef) {
		CovertActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(StateObjRef.ObjectID));
		if(CovertActionState == none)
			continue;
		CovertActionTemplate = CovertActionState.GetMyTemplate();
		RTLog("" $ CovertActionTemplate.DataName);
	}
}

static function PrintMiscInfoForFaction(XComGameState_ResistanceFaction Faction) {
	//local XComGameState_HeadquartersXCom XComHQ;

}

static function SubmitGameState(XComGameState NewGameState) {
	if(NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		`XCOMHISTORY.CleanupPendingGameState(NewGameState);
	}
}

static function XComGameState_HeadquartersXCom GetXComHQState()
{
	local XComGameState_HeadquartersXCom NewXComHQ;

	NewXComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	if(NewXComHQ == none) {
		RTLog("Warning, could not find the XCOM HQ, returning null!");
		return none;
	}

	return NewXComHQ;
}

static function XComGameState_ResistanceFaction GetTemplarFactionState()
{
	local XComGameState_ResistanceFaction TemplarState;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', TemplarState)
	{
		if(TemplarState.GetMyTemplateName() == 'Faction_Templars')
		{
			break;
		}
	}

	if(TemplarState == none) {
		RTLog("Warning, could not find TemplarState, returning null!");
		return none;
	}

	return TemplarState;
}

simulated static function bool IsInvalidMission(X2MissionSourceTemplate Template) {
	return class'RTGameState_ProgramFaction'.default.InvalidMissionSources.Find(Template.DataName) != INDEX_NONE;
}