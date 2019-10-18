class RTUIScreenListener_MOTD extends UIScreenListener config(RTNullConfig);

var config bool bHasDismissedLatest;
var config int LastVersion;

var localized string m_strTitle;
var localized string m_strText;

event OnInit(UIScreen Screen) {
	if(UIScreen(Screen) != INDEX_NONE) {
		TryShowPopup();
	}
}

simulated function TryShowPopup() {
	// if we've updated
	if(`DLCINFO.GetVersionInt() > LastVersion) {
			bHasDismissedLatest = false;
			self.SaveConfig();

			ShowPopup();
	// the normal loaded case
	} else if(`DLCINFO.GetVersionInt() == LastVersion) {
		if(!bHasDismissedLatest) {
			ShowPopup();
		}
	// what the f--!
	} else {
		`RTLOG("The local version is higher than the loaded version?!!", true, false);
		return;
	}
}

event OnRemoved(UIScreen Screen) {
	ManualGC();
}

simulated function ManualGC() {

}

simulated function ShowPopup()
{
	local TDialogueBoxData kDialogData;

	kDialogData.eType = eDialog_Normal;
	kDialogData.strTitle = m_strTitle;
	kDialogData.strText = m_strText;
	kDialogData.fnCallback = PopupAcknowledgedCB;
	kDialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericContinue;

	`PRESBASE.UIRaiseDialog(kDialogData);
}

simulated function PopupAcknowledgedCB(Name eAction)
{
	`PRESBASE.PlayUISound(eSUISound_MenuSelect);

	LastVersion = `DLCINFO.GetVersionInt();
	bHasDismissedLatest = true;

	self.SaveConfig();
}