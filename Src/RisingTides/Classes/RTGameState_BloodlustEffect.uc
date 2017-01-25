class RTGameState_BloodlustEffect extends RTGameState_Effect;

// this check grants the mobility change described in for the "Bump In The Night" ability
function EventListenerReturn BumpInTheNightStatCheck(Object EventData, Object EventSource, XComGameState GameState, Name EventID) {
local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit UnitState, NewUnitState;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState NewGameState;
	local UnitValue BloodlustStackCount;
	local RTGameState_BloodlustEffect TempEffect;
	local RTEffect_Bloodlust		BloodlustEffect;

	
	UnitState = XComGameState_Unit(GameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	if (UnitState == None)
		UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	`assert(UnitState != None);
                        
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
	NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));

	TempEffect = self;
	NewUnitState.UnApplyEffectFromStats(TempEffect, NewGameState);
                        
	StatChanges.Length = 0;
	TempEffect.StatChanges.Length = 0;

	if(UnitState.HasSoldierAbility('RTQueenOfBlades')) {
		AddPersistentStatChange(StatChanges, eStat_Mobility, (RTEffect_Bloodlust(GetX2Effect()).iMobilityMod) * iStacks);
		TempEffect.AddPersistentStatChange(StatChanges, eStat_Mobility, (RTEffect_Bloodlust(GetX2Effect()).iMobilityMod) * iStacks);
	} else {
		AddPersistentStatChange(StatChanges, eStat_Mobility, -(RTEffect_Bloodlust(GetX2Effect()).iMobilityMod) * iStacks);
		TempEffect.AddPersistentStatChange(StatChanges, eStat_Mobility, -(RTEffect_Bloodlust(GetX2Effect()).iMobilityMod) * iStacks);
	}


	//XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = BloodlustStackVisualizationFn;		  //TODO: this

	NewUnitState.ApplyEffectToStats(TempEffect, NewGameState);
                        
	NewGameState.AddStateObject(NewUnitState);
	`TACTICALRULES.SubmitGameState(NewGameState);
		
	

	return ELR_NoInterrupt;
}

// AddPersistentStatChange(out array<StatChange> m_aStatChanges, ECharStatType StatType, float StatAmount, optional EStatModOp InModOp=MODOP_Addition )
simulated function AddPersistentStatChange(out array<StatChange> m_aStatChanges, ECharStatType StatType, float StatAmount, optional EStatModOp InModOp=MODOP_Addition )
{
	local StatChange NewChange;
	
	NewChange.StatType = StatType;
	NewChange.StatAmount = StatAmount;
	NewChange.ModOp = InModOp;

	m_aStatChanges.AddItem(NewChange);
}