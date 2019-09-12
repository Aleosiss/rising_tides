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

// X2AbilityTemplateManager AbilityTemplateManager, name AbilityName, out array<AbilitySetupData> arrData, out array<Name> ExcludedAbilityNames, AbilitySetupData InitialAbilitySetupData, optional X2DataTemplate InitialAbilityProviderTemplate
function AddAbilitySetupData(	X2AbilityTemplateManager AbilityTemplateManager,
								name AbilityName,
								out array<AbilitySetupData> arrData,
								out array<Name> ExcludedAbilityNames,
								String InitialAbilityProvider,
								optional AbilitySetupData InitialAbilitySetupData,
								optional XComGameState_Item InventoryItem,
								optional int AbilitySetupRecursionDepth = 0
) {
	local X2AbilityTemplate AbilityTemplate;
	local AbilitySetupData Data, EmptyData;
	local name IteratorAbilityName;

	if(AbilitySetupRecursionDepth > MAX_ABILITY_SETUP_RECURSION_DEPTH) {
		`RedScreen("AbilitySetupData collection chain beginning in " $ InitialAbilitySetupData.TemplateName $ " exceeded max recursion depth " $ MAX_ABILITY_SETUP_RECURSION_DEPTH $ ", returning NONE!");
		return;
	}

	AbilitySetupRecursionDepth++;

	if(InitialAbilitySetupData != EmptyData) {
		if(ExcludedAbilityNames.Find(InitialAbilitySetupData.TemplateName) != INDEX_NONE) {
			`Redscreen("AbilitySetupData collection chain beginning in " $ InitialAbilitySetupData.TemplateName $ " attempted to add a duplicate copy of $ " $ AbilityName $ ", returning NONE!");
			return;
		}
	}

	AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityName);
	if( AbilityTemplate != none &&
		(!AbilityTemplate.bUniqueSource || arrData.Find('TemplateName', AbilityTemplate.DataName) == INDEX_NONE) &&
		AbilityTemplate.ConditionsEverValidForUnit(self, false) )
	{
		Data = EmptyData;
		Data.TemplateName = AbilityName;
		Data.Template = AbilityTemplate;

		if(InventoryItem != none) {
			Data.SourceWeaponRef = InventoryItem.GetReference();
		} else if(InitialAbilitySetupData != EmptyData) {
			Data.SourceWeaponRef = InitialAbilitySetupData.SourceWeaponRef;
		}

		arrData.AddItem(Data);
		ExcludedAbilityNames.AddItem(AbilityName);

		if(InitialAbilitySetupData == EmptyData) {
			InitialAbilitySetupData = Data;
		}

		// recursively handle any additional data
		foreach Data.Template.AdditionalAbilities(IteratorAbilityName) {
			AddAbilitySetupData(AbilityTemplateManager, IteratorAbilityName, arrData, ExcludedAbilityNames, InitialAbilityProvider, InitialAbilitySetupData, InventoryItem, AbilitySetupRecursionDepth);
		}
	} else if(AbilityTemplate == none) {
		if(InitialAbilityProvider == "") {
			`RedScreen("Unknown ability template provider specifies unknown ability: " $ AbilityName);
		} else {
			`Redscreen(InitialAbilityProvider $ " specifies unknown ability: " $ AbilityName);
		}
	}
}
/*
function RankUpSoldier(XComGameState NewGameState, optional name SoldierClass, optional bool bRecoveredFromBadClassData)
{
	local X2SoldierClassTemplate Template;
	local int RankIndex, i, MaxStat, NewMaxStat, StatVal, NewCurrentStat, StatCap;
	local float APReward;
	local bool bInjured;
	local array<SoldierClassStatType> StatProgression;
	local XComGameState_HeadquartersXCom XComHQ;
	local array<SoldierClassAbilityType> RankAbilities;
	
	XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom', true));
	bInjured = IsInjured();

	if (!class'X2ExperienceConfig'.default.bUseFullXpSystem)
		bRankedUp = true;

	RankIndex = m_SoldierRank;
	if (m_SoldierRank == 0)
	{
		if(SoldierClass == '')
		{
			SoldierClass = XComHQ.SelectNextSoldierClass();
		}

		SetSoldierClassTemplate(SoldierClass);
		BuildAbilityTree();
		
		if (GetSoldierClassTemplateName() == 'PsiOperative')
		{
			RollForPsiAbilities();

			// Adjust the soldiers appearance to have white hair and purple eyes - not permanent
			kAppearance.iHairColor = 25;
			kAppearance.iEyeColor = 19;
		}
		else
		{
			// Add new Squaddie abilities to the Unit if they aren't a Psi Op
			RankAbilities = AbilityTree[0].Abilities;
			for (i = 0; i < RankAbilities.Length; ++i)
			{
				BuySoldierProgressionAbility(NewGameState, 0, i);
			}

			bNeedsNewClassPopup = true;
		}
	}
	
	Template = GetSoldierClassTemplate();
	
	// Attempt to recover from having an invalid class
	if(Template == none)
	{
		`RedScreen("Invalid ClassTemplate detected, this unit has been reset to Rookie and given a new promotion. Please inform sbatista and provide a save.\n\n" $ GetScriptTrace());
		ResetRankToRookie();

		// This check prevents an infinite loop in case a valid class is not found
		if(!bRecoveredFromBadClassData)
		{
			RankUpSoldier(NewGameState, XComHQ.SelectNextSoldierClass(), true);
			return;
		}
	}

	if (RankIndex >= 0 && RankIndex < Template.GetMaxConfiguredRank())
	{
		m_SoldierRank++;

		StatProgression = Template.GetStatProgression(RankIndex);
		if (m_SoldierRank > 0)
		{
			for (i = 0; i < class'X2SoldierClassTemplateManager'.default.GlobalStatProgression.Length; ++i)
			{
				StatProgression.AddItem(class'X2SoldierClassTemplateManager'.default.GlobalStatProgression[i]);
			}
		}

		for (i = 0; i < StatProgression.Length; ++i)
		{
			StatVal = StatProgression[i].StatAmount;
			//  add random amount if any
			if (StatProgression[i].RandStatAmount > 0)
			{
				StatVal += `SYNC_RAND(StatProgression[i].RandStatAmount);
			}

			if((StatProgression[i].StatType == eStat_HP) && `SecondWaveEnabled('BetaStrike' ))
			{
				StatVal *= class'X2StrategyGameRulesetDataStructures'.default.SecondWaveBetaStrikeHealthMod;
			}

			MaxStat = GetMaxStat(StatProgression[i].StatType);
			//  cap the new value if required
			if (StatProgression[i].CapStatAmount > 0)
			{
				if((i == eStat_Will) || (i == eStat_PsiOffense)) {
					// don't respect the cap for this stat.
					continue;
				}

				StatCap = StatProgression[i].CapStatAmount;

				if((i == eStat_HP) && `SecondWaveEnabled('BetaStrike' ))
				{
					StatCap *= class'X2StrategyGameRulesetDataStructures'.default.SecondWaveBetaStrikeHealthMod;
				}

				if (StatVal + MaxStat > StatCap)
					StatVal = StatCap - MaxStat;
			}

			// If the Soldier has been shaken, save any will bonus from ranking up to be applied when they recover
			if (StatProgression[i].StatType == eStat_Will && bIsShaken)
			{
				SavedWillValue += StatVal;
			}
			else
			{				
				NewMaxStat = MaxStat + StatVal;
				NewCurrentStat = int(GetCurrentStat(StatProgression[i].StatType)) + StatVal;
				SetBaseMaxStat(StatProgression[i].StatType, NewMaxStat);
				if (StatProgression[i].StatType != eStat_HP || !bInjured)
				{
					SetCurrentStat(StatProgression[i].StatType, NewCurrentStat);
				}
			}
		}

		// When the soldier ranks up to Corporal, they start earning Ability Points
		if (m_SoldierRank >= 2 && !bIsSuperSoldier)
		{
			if (IsResistanceHero())
			{
				APReward = GetResistanceHeroAPAmount(m_SoldierRank, ComInt);
			}
			else if(Template.bAllowAWCAbilities)
			{
				APReward = GetBaseSoldierAPAmount(ComInt);
			}
			AbilityPoints += Round(APReward);
			
			if (APReward > 0)
			{
				`XEVENTMGR.TriggerEvent('AbilityPointsChange', self, , NewGameState);
			}
		}

		`XEVENTMGR.TriggerEvent('UnitRankUp', self, , NewGameState);
	}

	if (m_SoldierRank == class'X2SoldierClassTemplateManager'.default.NickNameRank)
	{
		if (strNickName == "" && Template.RandomNickNames.Length > 0)
		{
			strNickName = GenerateNickname();
		}
	}

	if (XComHQ != none)
	{
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		if(XComHQ != none)
		{
			if(XComHQ.HighestSoldierRank < m_SoldierRank)
			{
				XComHQ.HighestSoldierRank = m_SoldierRank;
			}
		
			// If this soldier class can gain AWC abilities
			if (Template.bAllowAWCAbilities)
			{
				RollForTrainingCenterAbilities(); // Roll for Training Center extra abilities if they haven't been already generated
			}
		}
	}
}
*/

function array<AbilitySetupData> GatherUnitAbilitiesForInit(optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	local name AbilityName, UnlockName;
	local AbilitySetupData Data, EmptyData;
	local array<AbilitySetupData> arrData;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate AbilityTemplate;
	local X2CharacterTemplate CharacterTemplate;
	local array<XComGameState_Item> CurrentInventory;
	local XComGameState_Item InventoryItem;
	local X2EquipmentTemplate EquipmentTemplate;
	local X2SoldierAbilityUnlockTemplate AbilityUnlockTemplate;
	local array<SoldierClassAbilityType> EarnedSoldierAbilities;
	local int i, j, OverrideIdx;
	local array<X2WeaponUpgradeTemplate> WeaponUpgradeTemplates;
	local X2WeaponUpgradeTemplate WeaponUpgradeTemplate;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local array<X2DownloadableContentInfo> DLCInfos;
	local X2DownloadableContentInfo DLCInfo;
	local XComGameState_AdventChosen ChosenState;
	local X2TraitTemplate TraitTemplate;
	local X2EventListenerTemplateManager TraitTemplateManager;
	local XComGameState_BattleData BattleDataState;
	local X2SitRepEffect_GrantAbilities SitRepEffect;
	local array<name> GrantedAbilityNames;
	local StateObjectReference ObjectRef;
	local XComGameState_Tech BreakthroughTech;
	local X2TechTemplate TechTemplate;
	local XComGameState_HeadquartersResistance ResHQ;
	local array<StateObjectReference> PolicyCards;
	local StateObjectReference PolicyRef;
	local XComGameState_StrategyCard PolicyState;
	local X2StrategyCardTemplate PolicyTemplate;

	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability AbilityState;
	local int ScanEffect;
	local X2Effect_SpawnUnit SpawnUnitEffect;
	
	local array<name> ExcludedAbilityNames;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom', true));

	if(StartState != none)
		MergeAmmoAsNeeded(StartState);

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	CharacterTemplate = GetMyTemplate();

	//  Gather default abilities if allowed
	if (!CharacterTemplate.bSkipDefaultAbilities)
	{
		foreach class'X2Ability_DefaultAbilitySet'.default.DefaultAbilitySet(AbilityName)
		{
			// X2AbilityTemplateManager AbilityTemplateManager, name AbilityName, out array<AbilitySetupData> arrData, out array<Name> ExcludedAbilityNames, AbilitySetupData InitialAbilitySetupData, optional X2DataTemplate InitialAbilityProviderTemplate
			AddAbilitySetupData(AbilityTemplateManager, AbilityName, arrData, ExcludedAbilityNames, "X2Ability_DefaultAbilitySet");
		}
	}
	//  Gather character specific abilities
	foreach CharacterTemplate.Abilities(AbilityName)
	{
		// X2AbilityTemplateManager AbilityTemplateManager, name AbilityName, out array<AbilitySetupData> arrData, out array<Name> ExcludedAbilityNames, AbilitySetupData InitialAbilitySetupData, optional X2DataTemplate InitialAbilityProviderTemplate
		AddAbilitySetupData(AbilityTemplateManager, AbilityName, arrData, ExcludedAbilityNames, string(CharacterTemplate.class) @ string(CharacterTemplate.DataName));
	}
	// If a Chosen, gather abilities from strengths and weakness
	if(IsChosen() && StartState != none)
	{
		ChosenState = GetChosenGameState();

		foreach ChosenState.Strengths(AbilityName)
		{
			AddAbilitySetupData(AbilityTemplateManager, AbilityName, arrData, ExcludedAbilityNames, string(ChosenState.GetMyTemplate().class) @ string(ChosenState.GetMyTemplateName() @ "Strength");
		}

		if(!ChosenState.bIgnoreWeaknesses)
		{
			foreach ChosenState.Weaknesses(AbilityName)
			{
				AddAbilitySetupData(AbilityTemplateManager, AbilityName, arrData, ExcludedAbilityNames, string(ChosenState.GetMyTemplate().class) @ string(ChosenState.GetMyTemplateName() @ "Weakness");
			}
		}
	}

	// If this is a spawned unit, perform any necessary inventory modifications before item abilities are added
	AbilityContext = XComGameStateContext_Ability(StartState.GetContext());
	if (AbilityContext != None)
	{
		AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
		if (AbilityState != None)
		{
			AbilityTemplate = AbilityState.GetMyTemplate();
			if (AbilityTemplate != None)
			{
				for (ScanEffect = 0; ScanEffect < AbilityTemplate.AbilityTargetEffects.Length; ++ScanEffect)
				{
					SpawnUnitEffect = X2Effect_SpawnUnit(AbilityTemplate.AbilityTargetEffects[ScanEffect]);
					if (SpawnUnitEffect != None)
					{
						SpawnUnitEffect.ModifyItemsPreActivation(GetReference(), StartState);
					}
				}
			}
		}
	}

	//  Gather abilities from the unit's inventory
	CurrentInventory = GetAllInventoryItems(StartState);
	foreach CurrentInventory(InventoryItem)
	{
		if (InventoryItem.bMergedOut || InventoryItem.InventorySlot == eInvSlot_Unknown)
			continue;
		EquipmentTemplate = X2EquipmentTemplate(InventoryItem.GetMyTemplate());
		if (EquipmentTemplate != none)
		{
			foreach EquipmentTemplate.Abilities(AbilityName)
			{
				AddAbilitySetupData(AbilityTemplateManager, AbilityName, arrData, ExcludedAbilityNames, string(EquipmentTemplate.class) @ string(EquipmentTemplate.DataName), none, InventoryItem);
			}
		}
		//  Gather abilities from any weapon upgrades
		WeaponUpgradeTemplates = InventoryItem.GetMyWeaponUpgradeTemplates();
		foreach WeaponUpgradeTemplates(WeaponUpgradeTemplate)
		{
			foreach WeaponUpgradeTemplate.BonusAbilities(AbilityName)
			{
				AddAbilitySetupData(AbilityTemplateManager, AbilityName, arrData, ExcludedAbilityNames, string(WeaponUpgradeTemplate.class) @ string(WeaponUpgradeTemplate.DataName), none, InventoryItem);
			}
		}

		// Gather abilities from applicable tech breakthroughs
		// if it's someone the player brought onto the mission
		if ((XComHQ != none) && (GetTeam() == eTeam_XCom) && !bMissionProvided)
		{
			foreach XComHQ.TacticalTechBreakthroughs(ObjectRef)
			{
				BreakthroughTech = XComGameState_Tech(History.GetGameStateForObjectID(ObjectRef.ObjectID));
				TechTemplate = BreakthroughTech.GetMyTemplate();

				if (TechTemplate.BreakthroughCondition != none && TechTemplate.BreakthroughCondition.MeetsCondition(InventoryItem))
				{
					AddAbilitySetupData(AbilityTemplateManager, TechTemplate.RewardName, arrData, ExcludedAbilityNames, string(TechTemplate.class) @ string(TechTemplate.DataName), none, InventoryItem);
				}
				
			}
		}
	}
	//  Gather soldier class abilities
	EarnedSoldierAbilities = GetEarnedSoldierAbilities();
	for (i = 0; i < EarnedSoldierAbilities.Length; ++i)
	{
		AbilityName = EarnedSoldierAbilities[i].AbilityName;
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityName);
		if( AbilityTemplate != none &&
			(!AbilityTemplate.bUniqueSource || arrData.Find('TemplateName', AbilityTemplate.DataName) == INDEX_NONE) &&
		   AbilityTemplate.ConditionsEverValidForUnit(self, false) )
		{
			Data = EmptyData;
			Data.TemplateName = AbilityName;
			Data.Template = AbilityTemplate;
			if (EarnedSoldierAbilities[i].ApplyToWeaponSlot != eInvSlot_Unknown)
			{
				foreach CurrentInventory(InventoryItem)
				{
					if (InventoryItem.bMergedOut)
						continue;
					if (InventoryItem.InventorySlot == EarnedSoldierAbilities[i].ApplyToWeaponSlot)
					{
						Data.SourceWeaponRef = InventoryItem.GetReference();

						if (EarnedSoldierAbilities[i].ApplyToWeaponSlot != eInvSlot_Utility)
						{
							//  stop searching as this is the only valid item
							break;
						}
						else
						{
							//  add this item if valid and keep looking for other utility items
							if (InventoryItem.GetWeaponCategory() == EarnedSoldierAbilities[i].UtilityCat)							
							{
								arrData.AddItem(Data);
							}
						}
					}
				}
				//  send an error if it wasn't a utility item (primary/secondary weapons should always exist)
				if (Data.SourceWeaponRef.ObjectID == 0 && EarnedSoldierAbilities[i].ApplyToWeaponSlot != eInvSlot_Utility)
				{
					`RedScreen("Soldier ability" @ AbilityName @ "wants to attach to slot" @ EarnedSoldierAbilities[i].ApplyToWeaponSlot @ "but no weapon was found there.");
				}
			}
			//  add data if it wasn't on a utility item
			if (EarnedSoldierAbilities[i].ApplyToWeaponSlot != eInvSlot_Utility)
			{
				if (AbilityTemplate.bUseLaunchedGrenadeEffects)     //  could potentially add another flag but for now this is all we need it for -jbouscher
				{
					//  populate a version of the ability for every grenade in the inventory
					foreach CurrentInventory(InventoryItem)
					{
						if (InventoryItem.bMergedOut) 
							continue;

						if (X2GrenadeTemplate(InventoryItem.GetMyTemplate()) != none)
						{ 
							Data.SourceAmmoRef = InventoryItem.GetReference();
							arrData.AddItem(Data);
						}
					}
				}
				else
				{
					arrData.AddItem(Data);
				}
			}
		}
	}
	//  Add abilities based on the player state
	if (PlayerState != none && PlayerState.IsAIPlayer())
	{
		foreach class'X2Ability_AlertMechanics'.default.AlertAbilitySet(AbilityName)
		{
			AddAbilitySetupData(AbilityTemplateManager, GrantedAbilityNames[i], arrData, ExcludedAbilityNames, "X2Ability_AlertMechanics");
		}
	}
	if (PlayerState != none && PlayerState.SoldierUnlockTemplates.Length > 0)
	{
		foreach PlayerState.SoldierUnlockTemplates(UnlockName)
		{
			AbilityUnlockTemplate = X2SoldierAbilityUnlockTemplate(class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate(UnlockName));
			if (AbilityUnlockTemplate == none)
				continue;
			if (!AbilityUnlockTemplate.UnlockAppliesToUnit(self))
				continue;

			AddAbilitySetupData(AbilityTemplateManager, AbilityUnlockTemplate.AbilityName, arrData, ExcludedAbilityNames, string(AbilityUnlockTemplate.class) @ string(AbilityUnlockTemplate.DataName));
		}
	}

	//	Check for abilities from traits
	TraitTemplateManager = class'X2EventListenerTemplateManager'.static.GetEventListenerTemplateManager();

	for( i = 0; i < AcquiredTraits.Length; ++i )
	{
		TraitTemplate = X2TraitTemplate(TraitTemplateManager.FindEventListenerTemplate(AcquiredTraits[i]));
		if( TraitTemplate != None && TraitTemplate.Abilities.Length > 0 )
		{
			for( j = 0; j < TraitTemplate.Abilities.Length; ++j )
			{
				AddAbilitySetupData(AbilityTemplateManager, TraitTemplate.Abilities[j], arrData, ExcludedAbilityNames, string(TraitTemplate.class) @ string(TraitTemplate.DataName));
			}
		}
	}

	// Gather sitrep granted abilities
	BattleDataState = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData', true));
	if (BattleDataState != none)
	{
		foreach class'X2SitreptemplateManager'.static.IterateEffects(class'X2SitRepEffect_GrantAbilities', SitRepEffect, BattleDataState.ActiveSitReps)
		{
			SitRepEffect.GetAbilitiesToGrant(self, GrantedAbilityNames);
			for (i = 0; i < GrantedAbilityNames.Length; ++i)
			{
				AddAbilitySetupData(AbilityTemplateManager, GrantedAbilityNames[i], arrData, ExcludedAbilityNames, string(SitRepEffect.class) @ string(SitRepEffect.DataName));
			}
		}
	}

	// Gather Policy granted abilities
	ResHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance', true));
	
	if (ResHQ != none)
	{
		PolicyCards = ResHQ.GetAllPlayedCards( true );

		foreach PolicyCards( PolicyRef )
		{
			if (PolicyRef.ObjectID == 0)
				continue;

			PolicyState = XComGameState_StrategyCard(History.GetGameStateForObjectID(PolicyRef.ObjectID));
			`assert( PolicyState != none );

			PolicyTemplate = PolicyState.GetMyTemplate( );
			if (PolicyTemplate.GetAbilitiesToGrantFn != none)
			{
				GrantedAbilityNames.Length = 0;
				PolicyTemplate.GetAbilitiesToGrantFn( self, GrantedAbilityNames );
				for (i = 0; i < GrantedAbilityNames.Length; ++i)
				{
					AddAbilitySetupData(AbilityTemplateManager, GrantedAbilityNames[i], arrData, ExcludedAbilityNames, string(PolicyTemplate.class) @ string(PolicyTemplate.DataName));
				}
			}
		}
	}

	//  Check for ability overrides AGAIN - in case the additional abilities want to override something
	for (i = arrData.Length - 1; i >= 0; --i)
	{
		if (arrData[i].Template.OverrideAbilities.Length > 0)
		{
			for (j = 0; j < arrData[i].Template.OverrideAbilities.Length; ++j)
			{
				OverrideIdx = arrData.Find('TemplateName', arrData[i].Template.OverrideAbilities[j]);
				if (OverrideIdx != INDEX_NONE)
				{
					arrData[OverrideIdx].Template = arrData[i].Template;
					arrData[OverrideIdx].TemplateName = arrData[i].TemplateName;
					//  only override the weapon if requested. otherwise, keep the original source weapon for the override ability
					if (arrData[i].Template.bOverrideWeapon)
						arrData[OverrideIdx].SourceWeaponRef = arrData[i].SourceWeaponRef;
				
					arrData.Remove(i, 1);
					break;
				}
			}
		}
	}	

	if (XComHQ != none)
	{
		// remove any abilities whose requirements are not met
		for( i = arrData.Length - 1; i >= 0; --i )
		{
			if( !XComHQ.MeetsAllStrategyRequirements(arrData[i].Template.Requirements) )
			{
				arrData.Remove(i, 1);
			}
		}
	}
	else
	{
		`log("No XComHeadquarters data available to filter unit abilities");
	}

	// for any abilities that specify a default source slot and do not have a source item yet,
	// set that up now
	for( i = 0; i < arrData.Length; ++i )
	{
		if( arrData[i].Template.DefaultSourceItemSlot != eInvSlot_Unknown && arrData[i].SourceWeaponRef.ObjectID <= 0 )
		{
			//	terrible terrible thing to do but it's the easiest at this point.
			//	everyone else has a gun for their primary weapon - templars have it as their secondary.
			if (arrData[i].Template.DefaultSourceItemSlot == eInvSlot_PrimaryWeapon && m_TemplateName == 'TemplarSoldier')
				arrData[i].SourceWeaponRef = GetItemInSlot(eInvSlot_SecondaryWeapon).GetReference();
			else
				arrData[i].SourceWeaponRef = GetItemInSlot(arrData[i].Template.DefaultSourceItemSlot).GetReference();
		}
	}

	if (AbilityState != none)
	{
		AbilityTemplate = AbilityState.GetMyTemplate(); // We already have the AbilityState from earlier in the function
		if (AbilityTemplate != None)
		{
			for (ScanEffect = 0; ScanEffect < AbilityTemplate.AbilityTargetEffects.Length; ++ScanEffect)
			{
				SpawnUnitEffect = X2Effect_SpawnUnit(AbilityTemplate.AbilityTargetEffects[ScanEffect]);
				if (SpawnUnitEffect != None)
				{
					SpawnUnitEffect.ModifyAbilitiesPreActivation(GetReference(), arrData, StartState);
				}
			}
		}
	}

	DLCInfos = `ONLINEEVENTMGR.GetDLCInfos(false);
	foreach DLCInfos(DLCInfo)
	{
		DLCInfo.FinalizeUnitAbilitiesForInit(self, arrData, StartState, PlayerState, bMultiplayerDisplay);
	}

	return arrData;
}