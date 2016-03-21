//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_ScopedAndDropped.uc
//  AUTHOR:  Aleosiss
//  DATE:    29 February 2016
//  PURPOSE: Defines the effect of Scoped And Dropped: Restore Action Points on kill,
//           Negate squadsight aim penalties, and count number of kills per turn.
//---------------------------------------------------------------------------------------
//	Scoped And Dropped effect
//---------------------------------------------------------------------------------------
class RTEffect_ScopedAndDropped extends X2Effect_Persistent;

var localized string RTFriendlyName;
var localized string RTNotFriendlyName;
	

//Negate Squadsight distance penalty
function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfoAim, ModInfoCrit;
	local int Tiles, AimMod, CritMod; 
	local UnitValue NumTimesScopedAndDropped;

	local int DebugAim;
	DebugAim = 100;
	
	Tiles = Attacker.TileDistanceBetween(Target);
	//  remove number of tiles within visible range (which is in meters, so convert to units, and divide that by tile size)
	Tiles -= Attacker.GetVisibilityRadius() * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	if (Tiles > 0)     //  pretty much should be since a squadsight target is by definition beyond sight range. but... 
		AimMod = ((class'X2AbilityToHitCalc_StandardAim'.default.SQUADSIGHT_DISTANCE_MOD * Tiles) * -1);
	
	ModInfoAim.ModType = eHit_Success;
	ModInfoAim.Reason = RTFriendlyName;
	ModInfoAim.Value = AimMod;
	ShotModifiers.AddItem(ModInfoAim);

	Attacker.GetUnitValue('NumTimesScopedAndDropped', NumTimesScopedAndDropped);
	CritMod = int(NumTimesScopedAndDropped.fValue) * 10;

	ModInfoCrit.ModType = eHit_Crit;
	ModInfoCrit.Reason = RTNotFriendlyName;
	ModInfoCrit.Value = -(CritMod);
	ShotModifiers.AddItem(ModInfoCrit);

	
}
function bool ShotsCannotGraze() { return true;}
function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'ScopedAndDropped', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
	EventMgr.RegisterForEvent(EffectObj, 'SovereignTrigger', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}
//Killing an exposed target refunds the full cost of the shot
function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit Attacker, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Unit				TargetUnit, PanicTargetUnit;
	local X2EventManager					EventMgr;
	local XComGameState_Ability				AbilityState;
	local GameRulesCache_VisibilityInfo		VisInfo;
	local XComGameStateHistory				History;
	local UnitValue							NumTimes;
	local array<StateObjectReference>		VisibleUnits;
	local int								Index, RandRoll;

	//  match the weapon associated with SnD to the attacking weapon
	if (kAbility.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef)
	{
		History = `XCOMHISTORY;
		//  check for a direct flanking kill shot
		TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
		if (TargetUnit != none && TargetUnit.IsDead())
		{
			if (`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, TargetUnit.ObjectID, VisInfo))
				{
					// Sovereign check
					if(Attacker.HasSoldierAbility('Sovereign'))
					{
						// Getting all visible units to the dead target
						class'RTTacticalVisibilityHelpers'.static.GetAllVisibleAlliesForUnit(TargetUnit.ObjectID, VisibleUnits/*, -1, false*/);
						for(Index = 0; Index < VisibleUnits.Length; Index++)
						{
							// Units within 5 tiles of the source that aren't psionic or robotic or the source
							PanicTargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(VisibleUnits[Index].ObjectID));
							if(TargetUnit.TileDistanceBetween(PanicTargetUnit) < 2) 
							{
								if(!PanicTargetUnit.IsRobotic() && !PanicTargetUnit.IsPsionic())
								{
									// 15% chance
									RandRoll = `SYNC_RAND(100);
									`COMBATLOG("Sovereign rolled " @ RandRoll @ "; Target is 49!");
									if(RandRoll < 50)
									{
										// T-T-Triggered
										EventMgr = `XEVENTMGR;
										EventMgr.TriggerEvent('SovereignTrigger', PanicTargetUnit, Attacker, NewGameState);
									}
								}
							}
						}
					}
					
					
					// Only care if there is no cover between this unit and the target unless they were concealed or have Daybreak Flame
					if (VisInfo.TargetCover == CT_None || Attacker.HasSoldierAbility('DaybreakFlame') || Attacker.WasConcealed(History.GetEventChainStartIndex()) || Attacker.IsConcealed() || TargetUnit.GetCurrentStat(eStat_AlertLevel) == 0)
					{
						// Negate changes to the number of action points
						if (Attacker.ActionPoints.Length != PreCostActionPoints.Length)
						{
							AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
							if (AbilityState != none && AbilityState.GetMyTemplateName() != 'RTOverwatchShot')
							{
								Attacker.ActionPoints = PreCostActionPoints;
								// If the UnitValue doesn't exist, make it, and start it at one since we just shot something
								if(!Attacker.GetUnitValue('NumTimesScopedAndDropped', NumTimes)) 
								{
									Attacker.SetUnitFloatValue('NumTimesScopedAndDropped', 1, eCleanup_BeginTurn);
								}
								// Else, get the value and increment it by one
								else
								{
									Attacker.GetUnitValue('NumTimesScopedAndDropped', NumTimes);
									NumTimes.fValue = NumTimes.fValue + 1;
									Attacker.SetUnitFloatValue('NumTimesScopedAndDropped', NumTimes.fValue, eCleanup_BeginTurn);
								}
								
								
								EventMgr = `XEVENTMGR;
								EventMgr.TriggerEvent('ScopedAndDropped', AbilityState, Attacker, NewGameState);

								return true;
							}
						}
					}
				}

			
		}
	}											  
	return false;
}


DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "Squadsight"
}