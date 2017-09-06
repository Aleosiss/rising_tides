//---------------------------------------------------------------------------------------
//  FILE:    X2MeleePathingPath.uc
//  AUTHOR:  David Burchanowski  --  2/10/2014
//  PURPOSE: Specialized pathing pawn for activated melee pathing. Draws tiles around every unit the 
//           currently selected ability can melee from, and allows the user to select one to move there.
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2MeleePathingPawn_RT extends X2MeleePathingPawn;

//var protected XComGameState_Unit UnitState; // The unit we are currently using
//var protected XComGameState_Ability AbilityState; // The ability we are currently using
//var protected Actor TargetVisualizer; // Visualizer of the current target 
//var protected X2TargetingMethod_MeleePath TargetingMethod; // targeting method that spawned this pathing pawn, if any
//
//var protected array<TTile> PossibleTiles; // list of possible tiles to melee from
//
//// Instanced mesh component for the grapple target tile markup
//var protected InstancedStaticMeshComponent InstancedMeshComponent;
