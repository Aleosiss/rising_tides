// This is an Unreal Script

class RTHelpers extends Object;

// copied here from X2Helpers_DLC_Day60.uc 
static function bool IsUnitAlienRuler(XComGameState_Unit UnitState)
{
	return UnitState.IsUnitAffectedByEffectName('AlienRulerPassive');
}
