class RTAction_RemoveMITV extends X2Action;

event bool BlocksAbilityActivation()
{
	return false;
}

function Init()
{
	super.Init();
	//`RTLOG("-----------------------------RTAction_RemoveMITV BEFORE--------------------------------", false, true);
	//`RTS.PrintEffectsAndMITVsForUnitPawn(UnitPawn, false);
	//`RTLOG("-----------------------------RTAction_RemoveMITV BEFORE--------------------------------", false, true);
	`RTLOG("Cleaning up MITVs!", false, true);
	UnitPawn.CleanUpMITV();
	//`RTLOG("-----------------------------RTAction_RemoveMITV AFTER--------------------------------", false, true);
	//`RTS.PrintEffectsAndMITVsForUnitPawn(UnitPawn, false);
	//`RTLOG("-----------------------------RTAction_RemoveMITV AFTER--------------------------------", false, true);
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