// This is an Unreal Script

class RTGameState_HeatChannel extends XComGameState_Effect;

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

  if(OldAbilityState == none) {
	`RedScreenOnce("EventData was not an XComGameState_Ability!");
	return ELR_NoInterrupt;
  }

  // immediately return if the event did not originate from ourselves
  if(OwnerStateObject.ObjectID != OldSourceUnit.ObjectID) {
	`RedScreenOnce("EventSource was not unit with Heat Channel!");
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
