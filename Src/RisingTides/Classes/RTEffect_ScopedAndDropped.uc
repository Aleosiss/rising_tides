//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_ScopedAndDropped.uc
//  AUTHOR:  Aleosiss
//  DATE:    29 February 2016
//  PURPOSE: Defines the effect of Scoped And Dropped: Restore Action Points on 
//           exposed kills, negate squadsight aim penalties, and count number of 
//           kills per turn.
//---------------------------------------------------------------------------------------
//	Scoped And Dropped effect
//---------------------------------------------------------------------------------------
class RTEffect_ScopedAndDropped extends X2Effect_PersistentStatChange;

var localized string RTFriendlyName;
var localized string RTNotFriendlyName;
	

// Negate Squadsight distance penalty
function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfoAim, ModInfoCrit;
	local int Tiles, AimMod, CritMod; 
	local UnitValue NumTimesScopedAndDropped;
	
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
// Shots cannot graze
function bool ShotsCannotGraze() 
{
	return true;
}
// Register for events
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
// Killing an exposed target refunds the full cost of the shot
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
	local bool								bIsStandardFire;

	bIsStandardFire = false;
	if(kAbility.GetMyTemplateName() == 'RTStandardSniperShot' || kAbility.GetMyTemplateName() == 'DaybreakFlame' || kAbility.GetMyTemplateName() == 'PrecisionShot' || kAbility.GetMyTemplateName() == 'DisablingShot')
		bIsStandardFire = true;
	//  match the weapon associated with SnD to the attacking weapon and make sure it's a standard shot
	if (kAbility.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef && bIsStandardFire)
	{
		History = `XCOMHISTORY;
		//  check for a direct flanking kill shot
		TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
		if (TargetUnit != none && TargetUnit.IsDead())
		{
			if (`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, TargetUnit.ObjectID, VisInfo))
				{
					// Only care if there is no cover between this unit and the target unless they were concealed or have Daybreak Flame
					if (VisInfo.TargetCover == CT_None || Attacker.HasSoldierAbility('DaybreakFlameIcon') || Attacker.WasConcealed(History.GetEventChainStartIndex()) || Attacker.IsConcealed() || TargetUnit.GetCurrentStat(eStat_AlertLevel) == 0)
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
								//`log("SND TargetUnit Location: " @ `XWORLD.GetPositionFromTileCoordinates(TargetUnit.TileLocation)); 
								//`log("SND TargetUnit ObjectID: " @ TargetUnit.ObjectID);
								//return true;
							}
						}
					}
				}

			
		}
	}											  
	return false;
}
// Add Whisper's stats
simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}


DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "RTEffect_ScopedAndDropped"
}
