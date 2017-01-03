// This is an Unreal Script

class RTGameState_EveryMomentMatters extends RTGameState_Effect;

function EventListenerReturn EveryMomentMattersCheck(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState NewGameState;
	local XComGameState_Unit SourceUnit;
	local XComGameStateHistory History;

	`LOG("Rising Tides - Every Moment Matters Activated!");

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext != none) {
		if (AbilityContext.InputContext.SourceObject.ObjectID == ApplyEffectParameters.SourceStateObjectRef.ObjectID) {
			History = `XCOMHISTORY;
			SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
			if (`TACTICALRULES.GetCachedUnitActionPlayerRef().ObjectID == SourceUnit.ControllingPlayer.ObjectID) {

				// We only want to grant points when the source is actually shooting a shot
				`LOG("Rising Tides - Every Moment Matters: Checking For a sniper shot! AbilityTemplateName: " @ AbilityContext.InputContext.AbilityTemplateName @"----------------------------------------------------------------");		
				if( !class'RTHelpers'.static.CheckAbilityActivated(AbilityContext.InputContext.AbilityTemplateName, eChecklist_SniperShots)) {
						`LOG("Rising Tides - Every Moment Matters: Wasn't a sniper shot! AbilityTemplateName: " @ AbilityContext.InputContext.AbilityTemplateName @"----------------------------------------------------------------");
						return ELR_NoInterrupt;
				} 

			   `LOG("Rising Tides - Every Moment Matters: Checking for the last shot! Ammo Count: " @ SourceUnit.GetItemInSlot(eInvSlot_PrimaryWeapon).Ammo @"----------------------------------------------------------------");
				if(SourceUnit.GetItemInSlot(eInvSlot_PrimaryWeapon).Ammo == 0) {	
					NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
					XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = EveryMomentMattersVisualizationFn;
					SourceUnit = XComGameState_Unit(NewGameState.CreateStateObject(SourceUnit.Class, SourceUnit.ObjectID));
					SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.MoveActionPoint);
					NewGameState.AddStateObject(SourceUnit);
					`TACTICALRULES.SubmitGameState(NewGameState);
				
				} else {
					`LOG("Rising Tides - Every Moment Matters: Wasn't the last shot! Ammo Count: " @ SourceUnit.GetItemInSlot(eInvSlot_PrimaryWeapon).Ammo @"----------------------------------------------------------------");
						
				}	
			}
		}
	}


	return ELR_NoInterrupt;
}

function EveryMomentMattersVisualizationFn(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{
	local XComGameState_Unit UnitState;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local VisualizationTrack BuildTrack;
	local XComGameStateHistory History;
	local X2AbilityTemplate AbilityTemplate;

	History = `XCOMHISTORY;
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, BuildTrack.StateObject_OldState, BuildTrack.StateObject_NewState, , VisualizeGameState.HistoryIndex);
		BuildTrack.StateObject_NewState = UnitState;
		BuildTrack.TrackActor = UnitState.GetVisualizer();

		AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('RTEveryMomentMatters');
		if (AbilityTemplate != none)
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "Every Moment Matters", '', eColor_Good, AbilityTemplate.IconImage);

			OutVisualizationTracks.AddItem(BuildTrack);
		} else {
			`LOG("Rising Tides - Every Moment Matters: Couldn't find AbilityTemplate for visualization!------------------------------------------------------------------------------------");
		}
		break;
	}
}