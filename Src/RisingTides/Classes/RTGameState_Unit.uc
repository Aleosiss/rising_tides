class RTGameState_Unit extends XComGameState_Unit config (RisingTides);

function ApplyBestGearLoadout(XComGameState NewGameState)
{
    // don't do anything, we already have equipped what we need to
}

function MakeItemsAvailable(XComGameState NewGameState, optional bool bStoreOldItems = true, optional array<EInventorySlot> SlotsToClear)
{
    // don't do anything, we don't equip XCom gear
}