class RTGameState_StrategyCard extends XComGameState_StrategyCard config(ProgramFaction);

//---------------------------------------------------------------------------------------
static function SetUpStrategyCards(XComGameState StartState)
{
	local X2StrategyElementTemplateManager StratMgr;
	local array<X2StrategyElementTemplate> AllCardTemplates;
	local RTProgramStrategyCardTemplate CardTemplate;
	local XComGameState_StrategyCard CardState;
	local array<XComGameState_StrategyCard> PossibleContinentBonusCards;
	local XComGameState_Continent ContinentState;
	local int idx, RandIndex;
	local bool bReplace;
	
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	AllCardTemplates = StratMgr.GetAllTemplatesOfClass(class'RTProgramStrategyCardTemplate');

	for(idx = 0; idx < AllCardTemplates.Length; idx++)
	{
		CardTemplate = RTProgramStrategyCardTemplate(AllCardTemplates[idx]);

		// Only Create Resistance Cards here, Chosen cards need to be created on the fly
		if(CardTemplate != none && CardTemplate.Category == "ResistanceCard")
		{
			CardState = CardTemplate.CreateInstanceFromTemplate(StartState);

			if (CardTemplate.bContinentBonus)
			{
				PossibleContinentBonusCards.AddItem(CardState);
			}
		}
	}

	// Grab All Continents and assign cards as their bonus, IF this is the start state
	if(StartState.GetContext().IsStartState())
	{
		foreach `XCOMHistory.IterateByClassType(class'XComGameState_Continent', ContinentState)
		{
			bReplace = false;

			if(PossibleContinentBonusCards.Length > 0 && `SYNC_RAND_STATIC(100) > 90); //10% chance to replace per continent.
				bReplace = true;

			if (PossibleContinentBonusCards.Length > 0 && bReplace)
			{
				ContinentState = XComGameState_Continent(StartState.ModifyStateObject(class'XComGameState_Continent', ContinentState.ObjectID));
				CardState = ContinentState.GetContinentBonusCard();
				CardState = XComGameState_StrategyCard(StartState.ModifyStateObject(class'XComGameState_StrategyCard', CardState.ObjectID));
				CardState.bDrawn = false;//so the card we replaced is available later on

				RandIndex = `SYNC_RAND_STATIC(PossibleContinentBonusCards.Length);
				CardState = PossibleContinentBonusCards[RandIndex];
				ContinentState.ContinentBonusCard = CardState.GetReference();
				CardState.bDrawn = true; // Flag the card as drawn so it doesn't show up elsewhere in the game
				break; //we replace only one continent
			}
			//no ned to worry about it not having enough, this is basically a roll to replace a continent bonus
		}
	}
}


//---------------------------------------------------------------------------------------
function XComGameState_ResistanceFaction GetAssociatedFaction()
{
	local RTGameState_ProgramFaction Program;

	if(!IsResistanceCard()) {
		return none;
	}

	foreach `XCOMHISTORY.IterateByClassType(class'RTGameState_ProgramFaction', Program) {
		if(Program.GetMyTemplateName() == GetAssociatedFactionName()) {
			return Program;
		}
	}

	return none;
}
