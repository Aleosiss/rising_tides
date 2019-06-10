class RTStrategyElement_ProgramStaffSlots extends X2StrategyElement_XpackStaffSlots config(ProgramFaction);

var name StaffSlotTemplateName;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> StaffSlots;

	// Facilities
	StaffSlots.AddItem(CreateCovertActionSoldierStaffSlot_NotTemplar());

	return StaffSlots;
}

static function X2DataTemplate CreateCovertActionSoldierStaffSlot_NotTemplar() {
	local X2StaffSlotTemplate Template;

	Template = CreateCovertActionSoldierStaffSlotTemplate(default.StaffSlotTemplateName);
	Template.IsUnitValidForSlotFn = IsUnitNotTemplar;

	return Template;
}

static function bool IsUnitNotTemplar(XComGameState_StaffSlot SlotState, StaffUnitInfo UnitInfo) {
	local XComGameState_Unit UnitState;
	
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitInfo.UnitRef.ObjectID));

	if (UnitState.GetSoldierClassTemplateName() == 'Templar') {
		return false;
	}

	return IsUnitValidForCovertActionSoldierSlot(SlotState, UnitInfo);
}

defaultproperties
{
	StaffSlotTemplateName = "RTSoldierStaffSlot"
}