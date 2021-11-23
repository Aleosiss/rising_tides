class RTAction_RemoveMITV extends RTAction;

var name MITVName;
var EMatPriority eMaterialPriority;
var ERTMatType eMaterialType;

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
	//`RTLOG("Cleaning up MITVs!", false, true);
	CleanUpMITV();
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

			if (CheckMaterial(eMaterialType, eMaterialPriority, MITVName, MeshComp.GetMaterial(i)))
			{
				MeshComp.PopMaterial(i, eMaterialPriority);
			}
		}

		for (i = 0; i < MeshComp.AuxMaterials.Length; i++)
		{
			if (CheckMaterial(eMaterialType, eMaterialPriority, MITVName, MeshComp.GetMaterial(i)))
			{
				MeshComp.PopMaterial(i, eMaterialPriority);
			}
		}
	}

	UnitPawn.UpdateAllMeshMaterials();
}

defaultproperties
{
	eMaterialType=eMatType_MITV
	eMaterialPriority=eMatPriority_AnimNotify
	MITVName=""
}