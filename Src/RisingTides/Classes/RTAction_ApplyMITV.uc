// All credit goes to Musashi for this class
class RTAction_ApplyMITV extends X2Action;

var string MITVPath;
var bool bApplyToSecondaryWeaponOnly;

event bool BlocksAbilityActivation()
{
	return false;
}

function Init(const out VisualizationTrack InTrack)
{
	local XComWeapon							SecondaryWeapon;
	local MaterialInstanceTimeVarying			MITV;
	local SkeletalMeshComponent					SkelMesh;

	super.Init(InTrack);

	MITV = MaterialInstanceTimeVarying(DynamicLoadObject(MITVPath, class'MaterialInstanceTimeVarying'));

	if (bApplyToSecondaryWeaponOnly) {
		SecondaryWeapon = XComWeapon(Unit.GetInventory().m_kSecondaryWeapon.m_kEntity);
		if (SecondaryWeapon != none) {
			SkelMesh = SkeletalMeshComponent(SecondaryWeapon.Mesh);
			UnitPawn.ApplyMITVToSkeletalMeshComponent(SkelMesh, MITV);
		}
	}
	else {
		UnitPawn.ApplyMITV(MITV);
	}
}


simulated state Executing
{
Begin:
	CompleteAction();
}

defaultproperties
{
	bApplyToSecondaryWeaponOnly=false
}