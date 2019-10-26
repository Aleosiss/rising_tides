class RTCondition_HackingTarget extends X2Condition;

var bool bIntrusionProtocol;
var name RequiredAbilityName;
var float RequiredRange;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
	return 'AA_Success';
}

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	local XComGameState_Unit SourceUnit;
	local XComGameState_InteractiveObject TargetObject;
	local XComInteractiveLevelActor TargetVisualizer;
	local GameRulesCache_VisibilityInfo VisInfo;

	SourceUnit = XComGameState_Unit(kSource);
	TargetObject = XComGameState_InteractiveObject(kTarget);
	
	if (TargetObject != none)     //  Haywire is ONLY allowed to target units
	{
		TargetVisualizer = XComInteractiveLevelActor(TargetObject.GetVisualizer());

		// This will do for now
		// Ideally want some kind of visible to player targeting + range limit. However, since the hack object is technically always visible, this may be a challenge
		if (!`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(SourceUnit.ObjectID, TargetObject.ObjectID, VisInfo)
			|| !VisInfo.bVisibleGameplay)
		{
			return 'AA_NotInRange';
		}

		if( TargetVisualizer != none && TargetVisualizer.HackAbilityTemplateName != RequiredAbilityName && RequiredAbilityName != '' )
			return 'AA_AbilityUnavailable';

		if (TargetObject.Health == 0) // < 0 is a sentinel for indestructible
			return 'AA_NoTargets';

		if (TargetObject.CanInteractHack(SourceUnit))
			return 'AA_Success';
	}

	return 'AA_TargetHasNoLoot';
}