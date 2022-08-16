class RTAction extends X2Action;


enum ERTMatType {
	eMatType_MITV,
	eMatType_MIC
};
 
protected static function bool CheckMaterial(ERTMatType desiredMaterialType, EMatPriority eMaterialPriority, name materialName, MaterialInterface material) {
    local bool bFoundMaterial;

    switch(desiredMaterialType) {
        case eMatType_MITV:
            bFoundMaterial = material.IsA('MaterialInstanceTimeVarying');
            break;
        case eMatType_MIC:
            bFoundMaterial = material.IsA('MaterialInstanceConstant');
            break;
        default:
            bFoundMaterial = false;
    }

    if(!bFoundMaterial) {
        return false;
    }

    if(material.name != materialName) {
        return false;
    };

    return true;
}