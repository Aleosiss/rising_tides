// This is an Unreal Script

class RTGameState_Ability extends XComGameState_Ability;

function EventListenerReturn HeatChannelCheck(Object EventData, Object EventSource, XComGameState GameState, Name EventID) {
  local XComGameState_Unit SourceUnit, NewSourceUnit;
  local XComGameStateHistory History;
  local StateObjectReference AbilityRef;
  local XComGameState_Ability AbilityState, NewAbilityState;
  local XComGameStateContext_Ability AbilityContext;
  local XComGameState_Item OldWeaponState, NewWeaponState;
  local XComGameState NewGameState;
  local int iHeatChanneled;

  // EventData = AbilityState to Channel
  AbilityState = XComGameState_Ability(EventData);
  // Event Source = UnitState of AbilityState
  SourceUnit = XComGameState_Unit(EventSource);

  // immediately return if the event did not originate from ourselves
  if(OwnerStateObject.ObjectID != SourceUnit.ObjectID) {
    return ELR_NoInterrupt;
  }

  History = `XCOMHISTORY;
  AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
  if (AbilityContext == none) {
  	return ELR_NoInterrupt;	
  }

  OldWeaponState = SourceUnit.GetPrimaryWeapon();
  
  // return if there's no heat to be channeled
  if(OldWeaponState.Ammo == OldWeaponState.GetClipSize()) {
    return ELR_NoInterrupt;
  }

  if(!AbilityState.IsCoolingDown()) {
    `RedScreenOnce("The ability was used but isn't on cooldown!");
    return ELR_NoInterrupt;
  }

  NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
  NewWeaponState = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', OldWeaponState.ObjectID));
  NewSourceUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', SourceUnit.ObjectID));
  NewAbilityState = XComGameState_Ability(NewGameState.CreateStateObject(class'XComGameState_Ability', AbilityState.ObjectID));
  

  // get amount of heat channeled
  iHeatChanneled = OldWeaponState.GetClipSize() - OldWeaponState.Ammo;
  
  // channel heat
  if(AbilityState.iCooldown < iHeatChanneled) {
    NewAbilityState.iCooldown = 0;
  } else {
    NewAbilityState.iCooldown -= iHeatChanneled;
  }
  //  refill the weapon's ammo	
  NewWeaponState.Ammo = NewWeaponState.GetClipSize();
  
  // submit gamestate
  NewGameState.AddStateObject(NewWeaponState);
  NewGameState.AddStateObject(NewAbilityState);
  NewGameState.AddStateObject(NewSourceUnit);
  `TACTICALRULES.SubmitGameState(NewGameState);

  return ELR_NoInterrupt;
}
