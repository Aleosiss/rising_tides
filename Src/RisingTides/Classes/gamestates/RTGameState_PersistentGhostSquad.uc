class RTGameState_PersistentGhostSquad extends XComGameState_BaseObject;

var array<StateObjectReference> 			InitOperatives;
var array<StateObjectReference> 			Operatives;
var array<StateObjectReference> 			CapturedOperatives;
var private string							SquadName;
var private string							SquadBackground;
var private int								SquadID;
var private name							AssociatedSitRepTemplateName;
var StateObjectReference					DeploymentRef;
var int										DeployedMissionPreviousMaxSoldiers; // how many soldiers were originally allowed on this mission - used to properly reset if we decide NOT to deploy
var ProgramDeploymentAvailablityInfo		AvailablityInfo;

function CreateSquad(int ID, String LocName, String LocBackground, name LocSitRepTemplateName, ProgramDeploymentAvailablityInfo info) {
	SquadID = ID;
	SquadName = LocName;
	SquadBackground = LocBackground;
	AssociatedSitRepTemplateName = LocSitRepTemplateName;
	AvailablityInfo = info;
}

function bool isDeployable(name MissionSource) {
	if(!AvailablityInfo.bIsDeployable) return false;

	if(AvailablityInfo.deployableMissionSources.Length == 0) return true;

	return AvailablityInfo.deployableMissionSources.Find(MissionSource) != INDEX_NONE;
}

function bool IsDeployed() {
	return DeploymentRef.ObjectID != 0;
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

function array<name> GetSoldiersAsSpecial(optional name MissionName) {
	local StateObjectReference OperativeRef;
	local array<name> SpecialSoldierTemplateNames;
	local XComGameStateHistory History;
	local name n;

	History = `XCOMHISTORY;

	foreach Operatives(OperativeRef) {
		n = XComGameState_Unit(History.GetGameStateForObjectID(OperativeRef.ObjectID)).GetMyTemplateName();
		SpecialSoldierTemplateNames.AddItem(n);
		if(MissionName != '') {
			`RTLOG("GetSoldiersAsSpecial: Adding a " $ n $ " to the SpecialSoldiers for Mission " $ MissionName);
		}
	}

	if(Operatives.Length != SpecialSoldierTemplateNames.Length) {
		`RTLOG("GetSoldiersAsSpecial for Squad " $ SquadName $ " failed, expected " $ Operatives.Length $ " but was " $ SpecialSoldierTemplateNames.Length, true, true, true);
	}

	return SpecialSoldierTemplateNames;
}
