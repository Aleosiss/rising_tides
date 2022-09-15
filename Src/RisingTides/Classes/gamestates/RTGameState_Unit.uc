class RTGameState_Unit extends XComGameState_Unit config (RisingTides);

var config int MAX_ABILITY_SETUP_RECURSION_DEPTH;

function ApplyBestGearLoadout(XComGameState NewGameState)
{
	// don't do anything, we already have equipped what we need to
}

function MakeItemsAvailable(XComGameState NewGameState, optional bool bStoreOldItems = true, optional array<EInventorySlot> SlotsToClear)
{
	// don't do anything, we don't equip XCom gear
}

simulated function bool CanAddItemToInventory(const X2ItemTemplate ItemTemplate, const EInventorySlot Slot, optional XComGameState CheckGameState, optional int Quantity=1, optional XComGameState_Item Item)
{
	if(GetMyTemplateName() == 'ProgramDrone') {
		return false;
	}

	return super.CanAddItemToInventory(ItemTemplate, Slot, CheckGameState, Quantity, Item);
}

simulated function XComUnitPawn GetPawnArchetype( string strArchetype="", optional const XComGameState_Unit ReanimatedFromUnit = None )
{
	local Object kPawn;
	
	//`RTLOG("GetPawnArchetype for " $ self.GetName(eNameType_Nick) $ " ");

	if(strArchetype == "")
	{
		strArchetype = GetMyTemplate().GetPawnArchetypeString(self, ReanimatedFromUnit);
	}

	//`RTLOG("CP1: " $ strArchetype);

	// backup plan
	if(strArchetype == "") {
		switch(EGender(kAppearance.iGender)) {
			case eGender_Male:
				strArchetype = "GameUnit_Reaper.ARC_Reaper_M"; // yeah idk
				break;
			case eGender_Female:
				strArchetype = "GameUnit_Reaper.ARC_Reaper_F";
				break;
			default:
				`RTLOG("Gender was not male or female, something is seriously wrong!", true);
		}
	}
	//`RTLOG("CP2: " $ strArchetype);

	kPawn = `CONTENT.RequestGameArchetype(strArchetype);
	if (kPawn != none && kPawn.IsA('XComUnitPawn'))
		return XComUnitPawn(kPawn);
	return none;
}