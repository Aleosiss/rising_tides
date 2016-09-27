// This is an Unreal Script

class RTGameState_Ability extends XComGameState_Ability;

function EventListenerReturn HeatChannelCheck(Object EventData, Object EventSource, XComGameState GameState, Name EventID) {
  local XComGameState_Unit OldSourceUnit, NewSourceUnit;
  local XComGameStateHistory History;
  local StateObjectReference AbilityRef;
  local XComGameState_Ability OldAbilityState, NewAbilityState;
  local XComGameStateContext_Ability AbilityContext;
  local XComGameState_Item OldWeaponState, NewWeaponState;
  local XComGameState NewGameState;
  local int iHeatChanneled;

  `LOG("Rising Tides: Starting HeatChannel");
  // EventData = AbilityState to Channel
  OldAbilityState = XComGameState_Ability(EventData);
  // Event Source = UnitState of AbilityState
  OldSourceUnit = XComGameState_Unit(EventSource);

  // immediately return if the event did not originate from ourselves
  if(OwnerStateObject.ObjectID != OldSourceUnit.ObjectID) {
    return ELR_NoInterrupt;
  }

  History = `XCOMHISTORY;
  AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
  if (AbilityContext == none) {
  	return ELR_NoInterrupt;	
  }

  OldWeaponState = OldSourceUnit.GetPrimaryWeapon();
  
  // return if there's no heat to be channeled
  if(OldWeaponState.Ammo == OldWeaponState.GetClipSize()) {
    return ELR_NoInterrupt;
  }

  if(!OldAbilityState.IsCoolingDown()) {
    `RedScreenOnce("The ability was used but isn't on cooldown!");
    return ELR_NoInterrupt;
  }

  NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
  NewWeaponState = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', OldWeaponState.ObjectID));
  NewSourceUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', OldSourceUnit.ObjectID));
  NewAbilityState = XComGameState_Ability(NewGameState.CreateStateObject(class'XComGameState_Ability', OldAbilityState.ObjectID));
  

  // get amount of heat channeled
  iHeatChanneled = OldWeaponState.GetClipSize() - OldWeaponState.Ammo;
  
  // channel heat
  if(OldAbilityState.iCooldown < iHeatChanneled) {
    NewAbilityState.iCooldown = 0;
  } else {
    NewAbilityState.iCooldown -= iHeatChanneled;
  }

  //  refill the weapon's ammo	
  NewWeaponState.Ammo = NewWeaponState.GetClipSize();
  
  `LOG("Rising Tides: Finishing HeatChannel");

  // submit gamestate
  NewGameState.AddStateObject(NewWeaponState);
  NewGameState.AddStateObject(NewAbilityState);
  NewGameState.AddStateObject(NewSourceUnit);
  `TACTICALRULES.SubmitGameState(NewGameState);

  return ELR_NoInterrupt;
}
	
function EventListenerReturn ReprobateWaltzListener( Object EventData, Object EventSource, XComGameState GameState, Name EventID) {
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit WaltzUnit;
	local int iStackCount;
	local float fStackModifier, fFinalPercentChance;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	WaltzUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));

	iStackCount = getBloodlustStackCount(WaltzUnit, AbilityContext);
	fFinalPercentChance = 100 -  ( class'RTAbility_BerserkerAbilitySet'.default.REPROBATE_WALTZ_BASE_CHANCE + ( class'RTAbility_BerserkerAbilitySet'.default.REPROBATE_WALTZ_BLOODLUST_STACK_CHANCE * iStackCount ));
		
	if(`SYNC_RAND(100) <= int(fFinalPercentChance)) {
		AbilityTriggerAgainstSingleTarget(AbilityContext.InputContext.PrimaryTarget, false);
	}		
	return ELR_NoInterrupt;
}
   
private function int getBloodlustStackCount(XComGameState_Unit WaltzUnit,  XComGameStateContext_Ability AbilityContext) {
   local int iStackCount;
   local StateObjectReference IteratorObjRef;
   local RTGameState_BloodlustEffect BloodlustEffectState;

   if (AbilityContext != none && WaltzUnit != none) {
		// get our stacking effect
		foreach WaltzUnit.AffectedByEffects(IteratorObjRef) {
			BloodlustEffectState = RTGameState_BloodlustEffect(`XCOMHISTORY.GetGameStateForObjectID(IteratorObjRef.ObjectID));
			if(BloodlustEffectState != none) {
				break;
			}
		}
		if(BloodlustEffectState != none) {
			iStackCount = BloodlustEffectState.iStacks;
		} else {
			iStackCount = 0;
		}
	} else  {
		`LOG("Rising Tides: No AbilityContext or SourceUnit found for getBloodlustStackCount!");
	}
	return iStackCount;
}