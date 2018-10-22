class RTGameState_PersistentGhostSquad extends XComGameState_BaseObject;


var array<StateObjectReference> 			InitOperatives;
var array<StateObjectReference> 			Operatives;
var array<StateObjectReference> 			CapturedOperatives;
var private string							SquadName;
var private string							SquadBackground;
var private int								SquadID;
var bool									bIsDeployed;
var private name							AssociatedSitRepTemplateName;



function CreateSquad(int ID, String LocName, String LocBackground, name LocSitRepTemplateName) {
	SquadID = ID;
	SquadName = LocName;
	SquadBackground = LocBackground;
	AssociatedSitRepTemplateName = LocSitRepTemplateName;
}


function bool IsFullStrength() {
	return (InitOperatives.length == Operatives.length);
}

function name GetAssociatedSitRepTemplateName() {
	return AssociatedSitRepTemplateName;
}

function string GetName() {
	return SquadName;
}
