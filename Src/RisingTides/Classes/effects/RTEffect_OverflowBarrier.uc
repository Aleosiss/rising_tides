// This is an Unreal Script

class RTEffect_OverflowBarrier extends X2Effect_EnergyShield;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{       local XComGameStateHistory History;
		local XComGameState_Unit SourceUnitState;
		local RTGameState_MeldEffect MeldEffectState;
		local UnitValue TotalShieldPoolValue;
		local int iNumMeldMembers, iShieldValue;

		History = `XCOMHISTORY;

		m_aStatChanges.Length = 0; // Reset the template shield strength, since it is dynamically generated. maybe I should make a RTEffect_DynamicStatChange
		SourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID)); // unit with Overflow Barrier
		MeldEffectState = RTGameState_MeldEffect(SourceUnitState.GetUnitAffectedByEffectState(class'RTEffect_Meld'.default.EffectName));
		if(MeldEffectState == none) {
			// no meld on source, cannot share :[ (this should never happen)
			NewEffectState.RemoveEffect(NewGameState, NewGameState, true, true);
			return;
		} else {
			iNumMeldMembers = MeldEffectState.Members.Length;
		}

		SourceUnitState.GetUnitValue('RTLastOverkillDamage', TotalShieldPoolValue);
		if(TotalShieldPoolValue.fValue > 0) {
			iShieldValue = max(1, (int(TotalShieldPoolValue.fValue) / iNumMeldMembers));
			AddPersistentStatChange(eStat_ShieldHP, iShieldValue);

		}

		super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
		return;
}

defaultproperties
{
	DuplicateResponse = eDupe_Allow;
}
