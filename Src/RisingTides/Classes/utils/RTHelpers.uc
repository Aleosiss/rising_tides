// This is an Unreal Script
class RTHelpers extends Object config(RisingTides);

var config array<name> StandardShots, MeleeAbilities, SniperShots, OverwatchShots, PsionicAbilities, FreeActions;
var config name ProgramFactionName;

var config string PROGRAM_RED_COLOR;
var config string PROGRAM_WHITE_COLOR;

var name DebugEffectName;

defaultproperties
{
	DebugEffectName = "DebugEffectName"
}

enum ERTProgramFavorAvailablity {
	eAvailable,
	eUnavailable_NoFavors,
	eUnavailable_NoAvailableSquads,
	eUnavailable_NoFavorsRemainingThisMonth
};

enum ERTMatType {
	eMatType_MITV,
	eMatType_MIC
};


struct RTModVersion
{
	var int Major;
	var int Minor;
	var int Patch;
};

enum ERTChecklist {
	eChecklist_StandardShots,
	eChecklist_SniperShots,
	eChecklist_OverwatchShots,
	eChecklist_PsionicAbilities,
	eChecklist_MeleeAbilities,
	eChecklist_FreeActions
};

enum ERTColor {
	eRTColor_ProgramRed,
	eRTColor_ProgramWhite
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
	local name mod;

	b = `DLCINFO.DebuggingEnabled();
	if(!b) {
		return;
	}
	mod = 'RisingTides';

	`LOG(message, b, mod);
	if(bShouldRedScreenToo) {
		`RedScreen(mod $ ": " $ message);
	}
	if(bShouldOutputToConsoleToo) {
		class'Helpers'.static.OutputMsg(mod $ ": " $ message);
	}
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

static function String GetProgramColor(optional ERTColor colorEnum) {
	local ERTColor EmptyColor;

	if(colorEnum == EmptyColor) {
		return default.PROGRAM_RED_COLOR;
	}

	switch(colorEnum) {
		case eRTColor_ProgramRed:
			return default.PROGRAM_RED_COLOR;
		case eRTColor_ProgramWhite:
			return default.PROGRAM_WHITE_COLOR;
		default:
			return default.PROGRAM_RED_COLOR;
	}
}

static function String AddFontColor(String inString, String HexColor) {
	local String EmptyString;

	if(inString == EmptyString) {
		`RTLOG("AddFontColor Failed: empty, returning inString!");
		return inString;
	}

	if(InStr(inString, "</font>") != -1) {
		`RTLOG("AddFontColor Failed: fontdata present, returning inString!");
		return inString;
	}

	//RTLOG("AddFontColor succeeded, final string is: \n<font color='#" $ HexColor $ "'><b>" $ inString $ "<b/></font>");
	return "<font color='#" $ HexColor $ "'><b>" $ inString $ "<b/></font>";
}

static function array<Name> GetCompletedXCOMTechNames() {
	local array<Name> names;
	local array<XComGameState_Tech> CompletedTechs;
	local XComGameState_Tech CompletedTechState;

	CompletedTechs = `XCOMHQ.GetAllCompletedTechStates();
	foreach CompletedTechs(CompletedTechState) { // Check if a tech which upgrades the base has been researched
		names.AddItem(CompletedTechState.GetMyTemplateName());
	}

	return names;
}

static function CheckpointDebug(out int checkpointNum, optional bool bShouldRedScreenToo = false, optional bool bShouldOutputToConsoleToo = false) {
	checkpointNum++;
	`RTLOG("Checkpoint " $ checkpointNum, bShouldRedScreenToo, bShouldOutputToConsoleToo);
}

static function PrintEffectsAndMICTVsForUnitState(XComGameState_Unit UnitState, bool bShouldRemove) {
	local XGUnit UnitVisualizer;
	local XComUnitPawn UnitPawn;

	UnitVisualizer = XGUnit(UnitState.GetVisualizer());
	UnitPawn = UnitVisualizer.GetPawn();

	`RTLOG("Printing all particle effects, MICs, and MITVs for " $ UnitState.GetFullName(), false, true);
	PrintEffectsAndMICTVsForUnitPawn(UnitPawn, bShouldRemove);
}

static function PrintEffectsAndMICTVsForUnitPawn(XComUnitPawn UnitPawn, bool bShouldRemove) {
	local ParticleSystemComponent PSComponent, TestPSComponent;
	local MeshComponent MeshComp;
	local MaterialInstanceTimeVarying MITV;
	local MaterialInstanceConstant MIC;
	local int i;

	foreach UnitPawn.Mesh.AttachedComponents( class'ParticleSystemComponent', TestPSComponent )
	{
		`RTLOG("Found Attached PSComponent: " $ PathName( TestPSComponent.Template ), false, true);
		if(bShouldRemove) {
			PSComponent = TestPSComponent;
			UnitPawn.Mesh.DetachComponent( PSComponent );
			PSComponent.DeactivateSystem();
		}
	}

	foreach UnitPawn.ComponentList( class'ParticleSystemComponent', TestPSComponent )
	{
		`RTLOG("Found Floating PSComponent: " $ PathName( TestPSComponent.Template ), false, true);
		if(bShouldRemove) {
			PSComponent = TestPSComponent;
			UnitPawn.Mesh.DetachComponent( PSComponent );
			PSComponent.DeactivateSystem();
		}
	}

	foreach UnitPawn.AllOwnedComponents(class'MeshComponent', MeshComp)
	{
		`RTLOG("--------------------------------------------------------------------", false, true);
		`RTLOG("Found MeshComponent: " $ PathName(MeshComp), false, true);
		`RTLOG(PathName(MeshComp) $ " has " $ MeshComp.Materials.Length $ " materials.", false, true);
		for (i = 0; i < MeshComp.Materials.Length; i++)
		{
			if (MeshComp.GetMaterial(i).IsA('MaterialInstanceTimeVarying'))
			{
				MITV = MaterialInstanceTimeVarying(MeshComp.GetMaterial(i));
				`RTLOG("Found MITV PrimaryMaterial: " $ PathName(MITV), false, true);
				if(bShouldRemove) 
					MeshComp.PopMaterial(i, eMatPriority_AnimNotify);
			} else if(MeshComp.GetMaterial(i).IsA('MaterialInstanceConstant')) {
				MIC = MaterialInstanceConstant(MeshComp.GetMaterial(i));
				`RTLOG("Found MIC PrimaryMaterial: " $ PathName(MIC), false, true);
				if(bShouldRemove) {
					`RTLOG("Not removing MIC. That would be odd.", false, true);
				}
			}
		}

		`RTLOG(PathName(MeshComp) $ " has " $ MeshComp.AuxMaterials.Length $ " aux materials.", false, true);
		for (i = 0; i < MeshComp.AuxMaterials.Length; i++)
		{
			if (MeshComp.GetMaterial(i).IsA('MaterialInstanceTimeVarying'))
			{
				MITV = MaterialInstanceTimeVarying(MeshComp.GetMaterial(i));
				`RTLOG("Found MITV AuxMaterial: " $ PathName(MITV), false, true);
				if(bShouldRemove)
					MeshComp.PopMaterial(i, eMatPriority_AnimNotify);
			} else if(MeshComp.GetMaterial(i).IsA('MaterialInstanceConstant')) {
				MIC = MaterialInstanceConstant(MeshComp.GetMaterial(i));
				`RTLOG("Found MIC AuxMaterial: " $ PathName(MIC), false, true);
				if(bShouldRemove) {
					`RTLOG("Not removing MIC. That would be odd.", false, true);
				}
			}
		}
	}

	UnitPawn.UpdateAllMeshMaterials();
}

static function name getSuffixForTier(int iTier) {
	switch(iTier) {
		case 1:
			return '_M1';
		case 2:
			return '_M2';
		case 3:
			return '_M3';
		default:
			`RTLOG("Warning, getSuffixForTier failed validation! Returning tier 3!", true, false);
			return '_M3';
	}
}

static function name concatName(name a, name b) {
	return name(string(a) $ string(b));
}

static function String DamageToString(WeaponDamageValue damageValue) {
	local String p1, p2;
	p1 = "(Damage = " $ damageValue.Damage $ ", Spread = " $ damageValue.Spread $ ", PlusOne = " $ damageValue.PlusOne $ ", Crit = " $ damageValue.Crit $ ", Pierce = " $ damageValue.Pierce $ ", ";
	p2 = "Rupture = " $ damageValue.Rupture $ ", Shred = " $ damageValue.Shred $ ", Tag = " $ damageValue.Tag $ ", DamageType = " $ damageValue.DamageType $ ")";

	return p1 $ p2;
}