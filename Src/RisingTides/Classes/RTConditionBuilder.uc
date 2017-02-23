// This is an Unreal Script

class RTConditionBuilder extends RTAbility_GhostAbilitySet config(RisingTides);

var X2Condition_UnitProperty LivingHostileUnitOnlyNonRoboticProperty;
var RTCondition_PsionicTarget PsionicTargetingProperty;








defaultproperties 
{
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


}