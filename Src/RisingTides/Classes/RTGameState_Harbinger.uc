// This is an Unreal Script

class RTGameState_Harbinger extends XComGameState_Effect;

function EventListenerReturn RemoveHarbingerEffect(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameStateContext_EffectRemoved RemoveContext;
	local XComGameState_Effect EffectState, NewGameState;
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
			EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef));
			if(EffectState.GetX2Effect().EffectName == 'HarbingerTagEffect') {
				NewEffectState = NewGameState.CreateStateObject(EffectState.class, EffectState.ObjectID);
				NewEffectState.RemoveEffect(NewGameState, GameState);
			}	
		}

		SubmitNewGameState(NewGameState);
	}

	return ELR_NoInterrupt;
}