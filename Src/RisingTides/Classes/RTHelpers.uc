// This is an Unreal Script
class RTHelpers extends Object config(RisingTides);

var config array<name> StandardShots, MeleeAbilities, SniperShots, OverwatchShots, PsionicAbilities, FreeActions;

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

