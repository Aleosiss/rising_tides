class RTEffect_BumpInTheNight extends RTEffect_GhostPerkBase config(RisingTides);

var int iTileDistanceToActivate;
// Register for events
function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local RTGameState_BumpInTheNightEffect BITNEffectState;
	local XComGameState_Unit UnitState;
	local Object EffectObj, FilterObj;

	EventMgr = `XEVENTMGR;
	BITNEffectState = RTGameState_BumpInTheNightEffect(EffectGameState);


	EffectObj = BITNEffectState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	FilterObj = UnitState;
	
	EventMgr.RegisterForEvent(EffectObj, 'AbilityActivated', BITNEffectState.RTBumpInTheNight, ELD_OnStateSubmitted, 40, FilterObj);


}

defaultproperties
{
	GameStateEffectClass = class'RTGameState_BumpInTheNightEffect'
}
