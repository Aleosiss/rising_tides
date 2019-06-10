class RTGameState_PersistentGhostSquad extends XComGameState_BaseObject;


var array<StateObjectReference> 			InitOperatives;
var array<StateObjectReference> 			Operatives;
var array<StateObjectReference> 			CapturedOperatives;
var private string							SquadName;
var private string							SquadBackground;
var private int								SquadID;
var bool									bIsDeployed;
var private name							AssociatedSitRepTemplateName;
var private bool							bCanBeDeployed;



function CreateSquad(int ID, String LocName, String LocBackground, name LocSitRepTemplateName, bool LocCanBeDeployed) {
	SquadID = ID;
	SquadName = LocName;
	SquadBackground = LocBackground;
	AssociatedSitRepTemplateName = LocSitRepTemplateName;
	bCanBeDeployed = LocCanBeDeployed;
}

function bool CanBeDeployed() {
	return bCanBeDeployed;
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
