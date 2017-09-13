class RTAction_RemoveMITV extends X2Action;

event bool BlocksAbilityActivation()
{
	return false;
}

function Init()
{
	super.Init();
	UnitPawn.CleanUpMITV();
	//CleanUpMITV();
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
				MeshComp.PopMaterial(i, eMatPriority_AnimNotify);
			}
		}

		for (i = 0; i < MeshComp.AuxMaterials.Length; i++)
		{
			if (MeshComp.GetMaterial(i).IsA('MaterialInstanceTimeVarying'))
			{
				MeshComp.PopMaterial(i, eMatPriority_AnimNotify);
			}
		}
	}

	UnitPawn.UpdateAllMeshMaterials();
}