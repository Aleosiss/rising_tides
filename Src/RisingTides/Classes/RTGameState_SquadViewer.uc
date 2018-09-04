class RTGameState_SquadViewer extends XComGameState_SquadViewer;

var StateObjectReference AssociatedUnit;


function SyncVisualizer(optional XComGameState GameState = none)
{
	DestroyVisualizer();
	if(!bRemoved) {
		FindOrCreateVisualizer(GameState);
	} else {
		RevealUnits = false;
	}
}

defaultproperties
{
	RevealUnits=true
}
