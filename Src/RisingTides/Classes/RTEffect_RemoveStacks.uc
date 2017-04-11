class RTEffect_RemoveStacks extends X2Effect;

var name EffectNameToPurge;
var int iStacksToRemove;
var bool bCleanse;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Effect EffectState, PurgedState;
	local StateObjectReference  EffectRef;
	local X2Effect_Persistent  PersistentEffectTemplate;
	local XComGameState_Unit  TargetUnitState;
	local XComGameStateHistory	History;

	TargetUnitState = XComGameState_Unit(kNewTargetState);
	if(TargetUnitState == none){
		super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
		return;
	}
	`LOG("Rising Tides: Purging " @ iStacksToRemove @ " stacks from " @ EffectNameToPurge);
	History = `XCOMHISTORY;
	foreach TargetUnitState.AffectedByEffects(EffectRef) {
		EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
		`LOG("Rising Tides: found effect " @ EffectState.GetX2Effect().EffectName);
		if(EffectState.GetX2Effect().EffectName != EffectNameToPurge) {
			continue;
		}
		`LOG ("Rising Tides: Found effect with " @ EffectState.iStacks @" stacks.");
		if(EffectState.iStacks < 1) {
			`RedScreenOnce("Rising Tides: " @ EffectState.GetX2Effect().EffectName @ " already has no stacks!");
			super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
			return;
		}
		if((EffectState.iStacks - iStacksToRemove) < 1) {
			EffectState.RemoveEffect(NewGameState, NewGameState, bCleanse);
		} else {
			PurgedState = XComGameState_Effect(NewGameState.CreateStateObject(EffectState.class, EffectState.ObjectID));
			PurgedState.iStacks -= iStacksToRemove;
			NewGameState.AddStateObject(PurgedState);
			//EffectState.iStacks -= iStacksToRemove;
		}
		break;
	}
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}
