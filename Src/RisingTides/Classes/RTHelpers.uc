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

	if(!b) {
		//`LOG("Rising Tides: " @ AbilityTemplateName @ " was not found in " @ n);
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
