// This is an Unreal Script

class RTEffect_TimeStopEnd extends X2Effect_RemoveEffects;

simulated function bool ShouldRemoveEffect(XComGameState_Effect EffectState, X2Effect_Persistent PersistentEffect)
{
	local bool bShouldRemove;

	bShouldRemove = false;
	if(EffectState.GetX2Effect().IsA('RTEffect_TimeStop')) {
		bShouldRemove = true;
	}

	return bShouldRemove;
}
