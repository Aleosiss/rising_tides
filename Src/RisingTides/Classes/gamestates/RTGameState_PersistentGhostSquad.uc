class RTGameState_PersistentGhostSquad extends XComGameState_BaseObject;

var array<StateObjectReference> 			InitOperatives;
var array<StateObjectReference> 			Operatives;
var array<StateObjectReference> 			CapturedOperatives;
var private string							SquadName;
var private string							SquadBackground;
var private int								SquadID;
var private name							AssociatedSitRepTemplateName;
var private bool							bIsDeployable;
var StateObjectReference					DeployedMissionRef;
var int										DeployedMissionPreviousMaxSoldiers; // how many soldiers were originally allowed on this mission - used to properly reset if we decide NOT to deploy

function CreateSquad(int ID, String LocName, String LocBackground, name LocSitRepTemplateName, bool LocCanBeDeployed) {
	SquadID = ID;
	SquadName = LocName;
	SquadBackground = LocBackground;
	AssociatedSitRepTemplateName = LocSitRepTemplateName;
	bIsDeployable = LocCanBeDeployed;
}

function bool isDeployable() {
	return bIsDeployable;
}

function bool IsDeployed() {
	return DeployedMissionRef.ObjectID != 0;
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
