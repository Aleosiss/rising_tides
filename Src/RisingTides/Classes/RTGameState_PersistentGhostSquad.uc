class RTGameState_PersistentGhostSquad extends XComGameState_BaseObject;

var array<StateObjectReference> Ghosts;
var string						SquadName;
var string						SquadBackground;	   
var int							SquadID;



function CreateSquad(int ID, String LocName, String LocBackground) {
	SquadID = ID;
	SquadName = LocName;
	SquadBackground = LocBackground;
}