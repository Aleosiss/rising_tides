// All credit goes to Musashi for this class
class RTAction_ApplyMITV extends RTAction;

var string MITVPath;
var name MITVName;
var EMatPriority eMaterialPriority;
var ERTMatType eMaterialType;

event bool BlocksAbilityActivation()
{
	return false;
}

function Init()
{
	local MaterialInstance						Material;
	local string								MaterialFullPath;
	local XComGameState_Unit					UnitState;

	super.Init();

	MaterialFullPath = MITVPath $ "." $ MITVName;

	switch(eMaterialType) {
		case eMatType_MITV:
			Material = MaterialInstanceTimeVarying(DynamicLoadObject(MaterialFullPath, class'MaterialInstanceTimeVarying'));
			break;
		case eMatType_MIC:
			Material = MaterialInstanceConstant(DynamicLoadObject(MaterialFullPath, class'MaterialInstanceConstant'));
			break;
		default:
	}

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitPawn.m_kGameUnit.ObjectID));
	//`RTLOG("Applying material: " $ Material $ " with priority" $ eMaterialPriority $ " to " $ UnitState.GetFullName(), false, true);
	ApplyMaterial(UnitPawn, Material, eMaterialPriority, eMaterialType);
	//`RTS.PrintEffectsAndMICTVsForUnitState(UnitState, false);
}

static function ApplyMaterial(XComUnitPawn StaticUnitPawn, MaterialInterface material, EMatPriority MaterialPriority, ERTMatType staticMaterialType)
{
	local SkeletalMeshComponent MeshComp;
	local int i;
	
	foreach StaticUnitPawn.AllOwnedComponents(class'SkeletalMeshComponent', MeshComp)
	{
		switch(staticMaterialType) {
			case eMatType_MITV:
				ApplyMITVToSkeletalMeshComponent(StaticUnitPawn, MeshComp, material, MaterialPriority);
				break;
			case eMatType_MIC:
				for(i = 0; i < MeshComp.GetNumElements() - 1; i++) {
					MeshComp.PushMaterial(i, Material, MaterialPriority);
				}
				break;
		}
		
	}
	StaticUnitPawn.MarkAuxParametersAsDirty(StaticUnitPawn.m_bAuxParamNeedsPrimary,StaticUnitPawn.m_bAuxParamNeedsSecondary,StaticUnitPawn.m_bAuxParamUse3POutline);
	StaticUnitPawn.UpdateAllMeshMaterials();
}

static function ApplyMITVToSkeletalMeshComponent(XComUnitPawn StaticUnitPawn, SkeletalMeshComponent MeshComp, MaterialInterface material, EMatPriority MaterialPriority)
{
	local MaterialInstanceTimeVarying MITV_Ghost;
	local SkeletalMeshComponent AttachedComponent;
	local int i;

	for (i = 0; i < MeshComp.SkeletalMesh.Materials.Length; i++)
	{
		MeshComp.PushMaterial(i, material, MaterialPriority);
		MITV_Ghost = MeshComp.CreateAndSetMaterialInstanceTimeVarying(i);
		MITV_Ghost.SetDuration(MITV_Ghost.GetMaxDurationFromAllParameters());
	}

	// (BSG:mwinfield,2012.03.13) This shouldn't work, but it does. What we really want to do is replace the AuxMaterials, 
	// but if I use SetAuxMaterial(), I can't create and set the Material instance and the effect doesn't work. Strangely,
	// if I set the material using the aux material index it does. To Do: Gain a better understanding of how this works.
	for (i = 0; i < MeshComp.AuxMaterials.Length; i++)
	{
		MeshComp.PushMaterial(i, material, MaterialPriority);
		MITV_Ghost = MeshComp.CreateAndSetMaterialInstanceTimeVarying(i);
		MITV_Ghost.SetDuration(MITV_Ghost.GetMaxDurationFromAllParameters());
	}

	// Loop over all of the SkeletalMeshComponents attached to this MeshComp and
	// apply the Ghost MITV to them as well. (Things like weapon attachements)
	for(i = 0; i < MeshComp.Attachments.Length; ++i)
	{
		AttachedComponent = SkeletalMeshComponent(MeshComp.Attachments[i].Component);
		if(AttachedComponent != none)
		{
			ApplyMITVToSkeletalMeshComponent(StaticUnitPawn, AttachedComponent, material, MaterialPriority);
		}
	}
}


simulated state Executing
{
Begin:
	CompleteAction();
}

defaultproperties
{
	eMaterialPriority=eMatPriority_AnimNotify
}
