class RTProgramStrategyCardTemplate extends X2StrategyCardTemplate;

var localized string QuoteTextLong;
//---------------------------------------------------------------------------------------
function XComGameState_StrategyCard CreateInstanceFromTemplate(XComGameState NewGameState)
{
	local RTGameState_StrategyCard CardState;

	CardState = RTGameState_StrategyCard(NewGameState.CreateNewStateObject(class'RTGameState_StrategyCard', self));
	class'RTHelpers'.static.RTLog("Creating new StrategyCard " $ DataName);
	return CardState;
}