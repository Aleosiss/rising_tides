class RTGameState_SquadViewer extends XComGameState_SquadViewer;

var StateObjectReference AssociatedUnit;


event UpdateGameplayVisibility(out GameRulesCache_VisibilityInfo InOutVisibilityInfo)
{
	InOutVisibilityInfo.bVisibleGameplay = InOutVisibilityInfo.bVisibleBasic;

}

event EForceVisibilitySetting ForceModelVisible()
{
	return eForceNone;
}

defaultproperties
{
	RevealUnits=true
}