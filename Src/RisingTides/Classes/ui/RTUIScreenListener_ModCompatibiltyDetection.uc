class RTUIScreenListener_ModCompatibiltyDetection extends UIScreenListener config(RTNullConfig);

var localized string m_strTitle_CI;
var localized string m_strText_CI;

event OnInit(UIScreen Screen) {
	if(UIShell(Screen) != none/* && UIShell(Screen).DebugMenuContainer == none*/) {
		TryShowPopup(Screen);
	}
}

simulated function TryShowPopup(UIScreen Screen) {
    local bool isCovertInfiltrationInstalled, isCIBridgeInstalled;
	
    isCovertInfiltrationInstalled = `DLCINFO.isModLoaded('CovertInfiltration');
    isCIBridgeInstalled = `DLCINFO.isModLoaded('SOCIBridgeTheProgram');

	if(isCovertInfiltrationInstalled && !isCIBridgeInstalled) {
		Screen.SetTimer(3.0f, false, nameof(CIBridgePopup), self);
	}
}

simulated function CIBridgePopup()
{
	local TDialogueBoxData kDialogData;

	kDialogData.eType = eDialog_Warning;
	kDialogData.strTitle = m_strTitle_CI;
	kDialogData.strText = m_strText_CI;
	kDialogData.fnCallback = PopupAcknowledgedCB;
	kDialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericContinue;

	`PRESBASE.UIRaiseDialog(kDialogData);
}

simulated function PopupAcknowledgedCB(Name eAction)
{
	`PRESBASE.PlayUISound(eSUISound_MenuSelect);
}