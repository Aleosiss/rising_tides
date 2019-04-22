class RTGameState_Haven extends XComGameState_Haven;

function class<UIStrategyMapItem> GetUIClass()
{
	`RTLOG("RTGameState_Haven::GetUIClass");
	return class'RTUIStrategyMapItem_ProgramHQ';
}