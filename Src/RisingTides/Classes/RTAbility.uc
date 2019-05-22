//---------------------------------------------------------------------------------------
//  FILE:    RTAbility.uc
//  AUTHOR:  Aleosiss
//  DATE:    8 February 2016
//  PURPOSE: Defines methods used by all Rising Tides ability sets.
//
//---------------------------------------------------------------------------------------

class RTAbility extends X2Ability config(RisingTides);
	var protected X2Condition_UnitProperty						LivingFriendlyUnitOnlyProperty;
	var protected X2Condition_UnitEffectsWithAbilitySource		OverTheShoulderProperty;
	var protected X2Condition_UnitProperty						LivingHostileUnitOnlyNonRoboticProperty;
	var protected RTCondition_PsionicTarget						PsionicTargetingProperty;
	var protected RTCondition_UnitSize							StandardSizeProperty;
	var protected EffectReason									TagReason;


static function Passive(X2AbilityTemplate Template) {
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
}

static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
//	local name Tag;

//	Tag = name(InString);

	return false;
}


defaultproperties
{
	Begin Object Class=X2Condition_UnitProperty Name=DefaultLivingFriendlyUnitOnlyProperty
		ExcludeAlive=false
		ExcludeDead=true
		ExcludeFriendlyToSource=false
		ExcludeHostileToSource=true
		TreatMindControlledSquadmateAsHostile=false
		FailOnNonUnits=true
		ExcludeCivilian=true
	End Object
	LivingFriendlyUnitOnlyProperty = DefaultLivingFriendlyUnitOnlyProperty

	Begin Object Class=X2Condition_UnitProperty Name=DefaultLivingHostileUnitOnlyNonRoboticProperty
		ExcludeAlive=false
		ExcludeDead=true
		ExcludeFriendlyToSource=true
		ExcludeHostileToSource=false
		TreatMindControlledSquadmateAsHostile=true
		ExcludeRobotic=true
		FailOnNonUnits=true
	End Object
	LivingHostileUnitOnlyNonRoboticProperty = DefaultLivingHostileUnitOnlyNonRoboticProperty

	Begin Object Class=RTCondition_PsionicTarget Name=DefaultPsionicTargetingProperty
		bIgnoreRobotic=false
		bIgnorePsionic=false
		bIgnoreGHOSTs=false
		bIgnoreDead=true
		bIgnoreEnemies=false
		bTargetAllies=false
		bTargetCivilians=false
	End Object
	PsionicTargetingProperty = DefaultPsionicTargetingProperty

	Begin Object Class=RTCondition_UnitSize Name=DefaultStandardSizeProperty
	End Object
	StandardSizeProperty = DefaultStandardSizeProperty
}