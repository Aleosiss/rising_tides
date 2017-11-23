// Load PerkContents via this class PostBeginPlay
class RTEffect_LoadPerks extends X2Effect_Persistent;

var array<name> AbilitiesToLoad;
var name ReservedName;

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	super.AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, EffectApplyResult);
	LoadPerks(VisualizeGameState, ActionMetadata);
}

simulated function AddX2ActionsForVisualization_Sync(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata)
{
	super.AddX2ActionsForVisualization_Sync(VisualizeGameState, ActionMetadata);
	LoadPerks(VisualizeGameState, ActionMetadata);
}

simulated function LoadPerks(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata) {
	local XComContentManager		Content;
	local XComUnitPawnNativeBase	UnitPawnNativeBase;
	local XComGameState_Unit		UnitState;
	local name n;

	UnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);
	if(UnitState == none) {
		`RedScreen("Warning, was unable to find a UnitState for RTEffect_LoadPerks!");
		return;
	}

	UnitPawnNativeBase = XGUnit(UnitState.GetVisualizer()).GetPawn();
	if(UnitPawnNativeBase == none) {
		`RedScreen("Warning, was unable to find a UnitPawnNativeBase for RTEffect_LoadPerks!");
		return;
	}
	
	Content = `CONTENT;
	Content.BuildPerkPackageCache();
	foreach AbilitiesToLoad(n) {
		if(n == ReservedName)
			continue;
		Content.CachePerkContent(n);
		Content.AppendAbilityPerks(n, UnitPawnNativeBase);
	}
}

defaultproperties
{
	ReservedName = "RT_Reserved"
}
