// This is an Unreal Script

class RTGameState_Harbinger extends XComGameState_Effect;

function EventListenerReturn RemoveHarbingerEffect(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameStateContext_EffectRemoved RemoveContext;
	local XComGameState_Effect EffectState, NewEffectState;
	local StateObjectReference EffectRef;
	local XComGameState_Unit	SourceUnitState;
	local XComGameState NewGameState;
	local XComGameStateHistory History;
	
	if (!bRemoved)	
	{
		RemoveContext = class'XComGameStateContext_EffectRemoved'.static.CreateEffectRemovedContext(self);
		NewGameState = `XCOMHISTORY.CreateNewGameState(true, RemoveContext);
		RemoveEffect(NewGameState, GameState);

		History = `XCOMHISTORY;
		SourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
		foreach SourceUnitState.AffectedByEffects(EffectRef) {
			EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
			if(EffectState.GetX2Effect().EffectName == 'HarbingerTagEffect') {
				NewEffectState = XComGameState_Effect(NewGameState.CreateStateObject(EffectState.class, EffectState.ObjectID));
				NewEffectState.RemoveEffect(NewGameState, GameState);
			}	
		}

		SubmitNewGameState(NewGameState);
	}

	return ELR_NoInterrupt;
}

private function SubmitNewGameState(out XComGameState NewGameState)
{
	local X2TacticalGameRuleset TacticalRules;
	local XComGameStateHistory History;

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		TacticalRules = `TACTICALRULES;
		TacticalRules.SubmitGameState(NewGameState);

		//  effects may have changed action availability - if a unit died, took damage, etc.
	}
	else
	{
		History = `XCOMHISTORY;
		History.CleanupPendingGameState(NewGameState);
	}
}