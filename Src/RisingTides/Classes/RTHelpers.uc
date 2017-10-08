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
		`LOG("Rising Tides: Standard Shots: " @ n);
	}

	foreach default.MeleeAbilities(n) {
		`LOG("Rising Tides: Melee Abilities: " @ n);
	}

	foreach default.SniperShots(n) {
		`LOG("Rising Tides: Sniper Shots: " @ n);
	}

	foreach default.OverwatchShots(n) {
		`LOG("Rising Tides: Overwatch Shots: " @ n);
	}

	foreach default.PsionicAbilities(n) {
		`LOG("Rising Tides: Psionic Abilities: " @ n);
	}

	foreach default.FreeActions(n) {
		`LOG("Rising Tides: Free Actions: " @ n);
	}
}


static function bool CheckAbilityActivated(name AbilityTemplateName, ERTChecklist Checklist) {
	local bool b, d;
	local string n;
	b = true;
	d = false; // debug flag

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

	if(!b && d) {
		`LOG("Rising Tides: " @ AbilityTemplateName @ " was not found in " @ n);
	}


	return b;
}

static function bool MultiCatCheckAbilityActivated (name AbilityTemplateName, array<ERTChecklist> Checklists) {
	local ERTChecklist Iterator;
	local bool b;

	b = false;
	foreach Checklists(Iterator) {
		b = CheckAbilityActivated(AbilityTemplateName, Iterator);
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

static function PanicLoopBeginFn( X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState )
{
	local XComGameState_Unit UnitState;

	// change the height
	UnitState = XComGameState_Unit( NewGameState.CreateStateObject( class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID ) );
	UnitState.bPanicked = true;

	NewGameState.AddStateObject( UnitState );
}

static function PanicLoopEndFn( X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed )
{
	local XComGameState_Unit UnitState;

	// change the height
	UnitState = XComGameState_Unit( NewGameState.CreateStateObject( class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID ) );
	UnitState.bPanicked = false;

	NewGameState.AddStateObject( UnitState );
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

	return Program;
}

static function RTGameState_ProgramFaction GetNewProgramState(optional XComGameState NewGameState) {
	local RTGameState_ProgramFaction Program;

	Program = GetProgramState(NewGameState);
	Program = RTGameState_ProgramFaction(NewGameState.ModifyStateObject(class'RTGameState_ProgramFaction', Program.ObjectID));
	return Program;
}


static function RTLog(string message, optional bool bShouldRedScreenToo = false) {
	if(!class'X2DownloadableContentInfo_RisingTides'.static.DebuggingEnabled())
		return;
	`LOG("Rising Tides: " $ message);
	if(bShouldRedScreenToo)
		`RedScreen("Rising Tides: " $ message);
}

static function PrintCovertActionsForFaction(XComGameState_ResistanceFaction Faction) {
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
	local XComGameState_HeadquartersXCom XComHQ;

	RTLog("Getting the Psi Training Rate...");
	XComHQ = GetXComHQState();
	RTLog("It's " $ XComHQ.PsiTrainingRate);
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
