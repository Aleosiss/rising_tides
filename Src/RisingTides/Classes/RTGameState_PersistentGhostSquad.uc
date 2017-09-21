class RTGameState_PersistentGhostSquad extends XComGameState_BaseObject;


var array<StateObjectReference> 	InitOperatives;
var array<StateObjectReference> 	Operatives;
var string													SquadName;
var string													SquadBackground;
var int														SquadID;
var bool													bIsDeployed;



function CreateSquad(int ID, String LocName, String LocBackground) {
	SquadID = ID;
	SquadName = LocName;
	SquadBackground = LocBackground;
}


function bool IsFullStrength() {
	return (InitOperatives.length == Operatives.length);
}
