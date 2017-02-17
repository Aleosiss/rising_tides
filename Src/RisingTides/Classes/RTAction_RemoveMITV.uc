// All credit goes to Musashi for this class.
class RTAction_RemoveMITV extends X2Action;

event bool BlocksAbilityActivation()
{
	return false;
}

function Init(const out VisualizationTrack InTrack)
{
	super.Init(InTrack);

	CleanUpMITV();
}

simulated state Executing
{
Begin:
	CompleteAction();
}

simulated function CleanUpMITV()
{
	local MeshComponent MeshComp;
	local int i;

	foreach UnitPawn.AllOwnedComponents(class'MeshComponent', MeshComp)
	{
		for (i = 0; i < MeshComp.Materials.Length; i++)
		{
			if (MeshComp.GetMaterial(i).IsA('MaterialInstanceTimeVarying'))
			{
				MeshComp.SetMaterial(i, none);
			}
		}
	}

	UnitPawn.UpdateAllMeshMaterials();
}