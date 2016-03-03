//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_ScopedAndDropped.uc
//  AUTHOR:  Aleosiss
//  DATE:    29 February 2016
//  PURPOSE: Defines the effect of Scoped And Dropped
//           
//---------------------------------------------------------------------------------------
//	Scoped And Dropped effect
//---------------------------------------------------------------------------------------
class RTEffect_ScopedAndDropped extends X2Effect_Persistent;

var localized string RTFriendlyName;

//Negate Squadsight distance penalty
function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;
	local int Tiles, AimMod;

	Tiles = Attacker.TileDistanceBetween(Target);
	//  remove number of tiles within visible range (which is in meters, so convert to units, and divide that by tile size)
	`log("Scoped and Dropped P1 working.");
	Tiles -= Attacker.GetVisibilityRadius() * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
	if (Tiles > 0)     //  pretty much should be since a squadsight target is by definition beyond sight range. but... 
		AimMod = ((class'X2AbilityToHitCalc_StandardAim'.default.SQUADSIGHT_DISTANCE_MOD * Tiles) * -1);
	
	ModInfo.ModType = eHit_Success;
	ModInfo.Reason = RTFriendlyName;
	ModInfo.Value = AimMod;
	ShotModifiers.AddItem(ModInfo);
	
}

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'ScopedAndDropped', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}
//Killing an exposed target refunds the full cost of the shot
function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit Attacker, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Unit TargetUnit;
	local X2EventManager EventMgr;
	local XComGameState_Ability AbilityState;
	local GameRulesCache_VisibilityInfo VisInfo;

	`log("Starting ScopedAndDropped P2");
	//  match the weapon associated with SnD to the attacking weapon
	//if (kAbility.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef)
	//{
		//`log("Starting ScopedAndDropped P2.1");
		//  check for a direct flanking kill shot 
		TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
		if (TargetUnit != none && TargetUnit.IsDead())
		{
			//`log("Starting ScopedAndDropped P2.2");
			if (`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, TargetUnit.ObjectID, VisInfo))
				{
					//`log("Starting ScopedAndDropped P2.3 Confirm");
					//`log(VisInfo.TargetCover == CT_None);
					// && TargetUnit.CanTakeCover() && VisInfo.TargetCover == CT_None
					if (VisInfo.TargetCover == CT_None)
					{
						//`log("Starting ScopedAndDropped P2.4");
						//  restore the pre cost action points to fully refund this action
						if (Attacker.ActionPoints.Length != PreCostActionPoints.Length)
						{
							//`log("Starting ScopedAndDropped P2.5");
							AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
							if (AbilityState != none)
							{
								//`log("Starting ScopedAndDropped P2.6");
								Attacker.ActionPoints = PreCostActionPoints;

								EventMgr = `XEVENTMGR;
								EventMgr.TriggerEvent('ScopedAndDropped', AbilityState, Attacker, NewGameState);

								return true;
							}
						}
					}
				}

			
		}
	//}
	return false;
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "Squadsight"
}