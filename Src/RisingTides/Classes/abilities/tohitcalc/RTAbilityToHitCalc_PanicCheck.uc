// This is an Unreal Script

class RTAbilityToHitCalc_PanicCheck extends X2AbilityToHitCalc_StatCheck config(RisingTides);

var config array<Name> FeedbackImmunityEffects;      //  list of abilities which provide panic immunity all of the time

function int GetDefendValue(XComGameState_Ability kAbility, StateObjectReference TargetRef)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(TargetRef.ObjectID));

	if(UnitState.IsRobotic())
		return UnitState.GetCurrentStat(eStat_HackDefense);

	return UnitState.GetCurrentStat(eStat_Will);
}

function int GetAttackValue(XComGameState_Ability kAbility, StateObjectReference TargetRef)
{
	return kAbility.PanicEventValue;
}

function RollForAbilityHit(XComGameState_Ability kAbility, AvailableTarget kTarget, out AbilityResultContext ResultContext)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local name ImmuneName;

	History = `XCOMHISTORY;
	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(kTarget.PrimaryTarget.ObjectID));
	foreach default.FeedbackImmunityEffects(ImmuneName)
	{
		if (UnitState.AffectedByEffectNames.Find(ImmuneName) != INDEX_NONE)
		{
			`log("Unit has effect" @ ImmuneName @ "which provides feedback immunity. No feedback allowed.",,'XCom_HitRolls');
			ResultContext.HitResult = eHit_Miss;
			return;
		}
	}

	super.RollForAbilityHit(kAbility, kTarget, ResultContext);
}