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