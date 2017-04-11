//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_SnapshotEffect.uc
//  AUTHOR:  Aleosiss
//  DATE:    6 March 2016
//  PURPOSE: Gives Snapshot its aim penalty
//
//---------------------------------------------------------------------------------------
//	Snapshot aim penalty
//---------------------------------------------------------------------------------------

class RTEffect_SnapshotEffect extends X2Effect_Persistent config(RisingTides);

var int SNAPSHOT_AIM_PENALTY;
var localized string RTFriendlyName;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local UnitValue MovesThisTurn;
	local ShotModifierInfo ShotInfo;
	Attacker.GetUnitValue('MovesThisTurn', MovesThisTurn);
	if(MovesThisTurn.fValue > 0 || Attacker.NumAllActionPoints() == 1)
	{
		if(AbilityState.GetMyTemplateName() != 'PistolStandardShot')
		{
			ShotInfo.ModType = eHit_Success;
			ShotInfo.Reason = RTFriendlyName;
			ShotInfo.Value = -(SNAPSHOT_AIM_PENALTY);
			ShotModifiers.AddItem(ShotInfo);
		}
	}
}
DefaultProperties
{
	EffectName="RTSnapshot"
}
