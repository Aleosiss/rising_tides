//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_Meld.uc
//  AUTHOR:  Aleosiss  
//  DATE:    18 March 2016
//  PURPOSE: Meld effect
//           
//---------------------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------------------

class RTEffect_MeldRemoved extends X2Effect_PersistentStatChange config(RTGhost);

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Effect_RTMeld		MeldEffectState;
	local XComGameState_Unit				OldTargetUnitState, NewTargetUnitState;
	local X2EventManager					EventMgr;
	local StateObjectReference				EffectRef;
	local XComGameState_Effect				Effect;
	local XComGameStateHistory				History;
	local Object							ListenerObj;
	local bool								EffectRemoved;

	EventMgr = `XEVENTMGR;
	History = `XCOMHISTORY;

	OldTargetUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if (OldTargetUnitState != none)
	{
		`LOG("Rising Tides: " @ OldTargetUnitState.GetFullName() @ " is attempting to leave the Meld.");

		EffectRemoved = false;

		// Check the old target state for condition effects
		foreach OldTargetUnitState.AffectedByEffects(EffectRef)
		{
			Effect = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));

			if (Effect.GetX2Effect().EffectName == 'RTEffect_Meld')
			{
				if (!Effect.GetX2Effect().bInfiniteDuration)
				{
					// Finite effects get ticked down and/or cleansed
					if (Effect.iTurnsRemaining > 1)
					{
						Effect.iTurnsRemaining--;
						
						//`LOG("Rising Tides: reduced " @ string(Effect.GetX2Effect().EffectName) @ " duration from " @ string(Effect.iTurnsRemaining + 1) @ " to " @ string(Effect.iTurnsRemaining) @ ".");
					}
					else
					{
						Effect.RemoveEffect(NewGameState, NewGameState, true);

						//`LOG("Rising Tides:  cleansed " @ string(Effect.GetX2Effect().EffectName) @ " (end of duration).");
					}

					EffectRemoved = true;
				}
				else
				{
					// Infinite effects get cleansed
					Effect.RemoveEffect(NewGameState, NewGameState, true);

					//`LOG("Rising Tides: cleansed " @ string(Effect.GetX2Effect().EffectName) @ " (infinite duration).");

					EffectRemoved = true;
				}

				if (NewTargetUnitState == none)
				{
					NewTargetUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', OldTargetUnitState.ObjectID));
					NewGameState.AddStateObject(NewTargetUnitState);
				}
			}
		}

		// If any condition removal occurred, pop up the flyover text
		//if (EffectRemoved)
		//{
			//AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(kNewEffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
			//if (AbilityState != none)
			//{
				//EventMgr = `XEVENTMGR;
				//EventMgr.TriggerEvent('ShakeItOffTriggered', AbilityState, NewTargetUnitState, NewGameState);
			//}
		//}

		`LOG("Rising Tides: " @ OldTargetUnitState.GetFullName() @ " has finished leaving the Meld.");
	}
	else
	{
		`LOG("Rising Tides: MeldLeave attempted failed (no primary target).");
	}

	
}