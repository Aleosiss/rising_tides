// This is an Unreal Script

class RTConditionBuilder extends RTAbility_GhostAbilitySet config(RisingTides);

var protected X2Condition_UnitProperty LivingHostileUnitOnlyNonRoboticProperty;



static function RTCondition_Conditional CreatePsionicTargetingProperty() {
	local RTCondition_Conditional Condition;

	Condition = new class 'RTCondition_Conditional';
	Condition.Conditionals.AddItem(CreateTechnopathyProperty());
	Condition.PassConditions.AddItem(default.LivingHostileUnitOnlyProperty);
	Condition.FailConditions.AddItem(default.LivingHostileUnitOnlyNonRoboticProperty);
	
	return Condition;
}

static function X2Condition_AbilityProperty CreateTechnopathyProperty() {
	local X2Condition_AbilityProperty Condition;

	Condition = new class'X2Condition_AbilityProperty';
	Condition.OwnerHasSoldierAbilities.AddItem(default.RTTechnopathyTemplateName);

	return Condition;
}




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
	LivingHostileUnitOnlyNonRoboticProperty = DefaultLivingHostileUnitOnlyNonRoboticProperty;

}