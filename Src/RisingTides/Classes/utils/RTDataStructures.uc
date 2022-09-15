class RTDataStructures extends Object;

struct ProgramDeploymentAvailablityInfo {
    var bool bIsDeployable;
    var array<name> deployableMissionSources; // if empty can be deployed on all missions
};