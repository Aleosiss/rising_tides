class RTGameState_DestroyedHaven extends XComGameState_Haven;

var name ChampionClassName;
/**

This class is nesscessary when destroying base game factions. If it is not present, the UIStrategyMap faction wheel
will not get properly filled, resulting in all further scanning sites being misaligned.

*/

function bool ShouldBeVisible()
{
    return false;
}

simulated function string GetUIButtonIcon()
{
	return "";
}

function bool IsResistanceFactionMet()
{
	return false;
}

function InitializeRuins(XComGameState NewGameState) {
	local RTGameState_DestroyedFaction Faction;

	Faction = RTGameState_DestroyedFaction(NewGameState.CreateNewStateObject(class'RTGameState_DestroyedFaction'));
	Faction.ChampionClassNamePlaceholder = ChampionClassName;
}