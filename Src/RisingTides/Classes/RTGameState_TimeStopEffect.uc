//---------------------------------------------------------------------------------------
//  FILE:    RTGameState_TimeStopEffect.uc
//  AUTHOR:  Aleosiss  
//  DATE:    21 June 2016
//  PURPOSE: Extended GameState_Effect that holds damage taken value for the time stop
//---------------------------------------------------------------------------------------

class RTGameState_TimeStopEffect extends XComGameState_Effect config(RTGhost);

var int DamageTaken;
var bool bTookExplosiveDamage;			
var array<name> DamageTypesTaken;			


