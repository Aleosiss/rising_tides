class RTGameState_Unit extends XComGameState_Unit config (RisingTides);

function ApplyBestGearLoadout(XComGameState NewGameState)
{
	// don't do anything, we already have equipped what we need to
}

function MakeItemsAvailable(XComGameState NewGameState, optional bool bStoreOldItems = true, optional array<EInventorySlot> SlotsToClear)
{
	// don't do anything, we don't equip XCom gear
}

function AddAbilitySetupData(X2AbilityTemplateManager AbilityTemplateManager, name AbilityName, out array<AbilitySetupData> arrData, out array<Name> ExcludedAbilityNames, AbilitySetupData InitialAbilitySetupData) {
	local X2AbilityTemplate AbilityTemplate;
	local AbilitySetupData Data, EmptyData;
	local name IteratorAbilityName;

	if(ExcludedAbilityNames.Find(InitialAbilitySetupData.TemplateName) != INDEX_NONE) {
		`Redscreen("Chain beginning in " $ InitialAbilitySetupData.TemplateName $ " attempted to add a duplicate copy of $ " $ AbilityName $ ", returning NONE!");
		return;
	}

	AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityName);
	if( AbilityTemplate != none &&
		(!AbilityTemplate.bUniqueSource || arrData.Find('TemplateName', AbilityTemplate.DataName) == INDEX_NONE) &&
		AbilityTemplate.ConditionsEverValidForUnit(self, false) )
	{
		Data = EmptyData;
		Data.TemplateName = AbilityName;
		Data.Template = AbilityTemplate;
		Data.SourceWeaponRef = InitialAbilitySetupData.SourceWeaponRef;
		arrData.AddItem(Data);

		ExcludedAbilityNames.AddItem(AbilityName);

		// recursively handle any additional data
		foreach Data.Template.AdditionalAbilities(IteratorAbilityName) {
			AddAbilitySetupData(AbilityTemplateManager, IteratorAbilityName, arrData, ExcludedAbilityNames, InitialAbilitySetupData);
		}
		
	}
}	