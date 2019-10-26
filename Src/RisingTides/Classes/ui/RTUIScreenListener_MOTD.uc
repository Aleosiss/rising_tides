class RTUIScreenListener_MOTD extends UIScreenListener config(RTNullConfig);

var config bool bHasDismissedLatest;
var config RTModVersion LastVersion;

var localized string m_strTitle;
var localized string m_strText;

event OnInit(UIScreen Screen) {
	if(UIShell(Screen) != none/* && UIShell(Screen).DebugMenuContainer == none*/) {
		TryShowPopup(Screen);
	}
}

simulated function TryShowPopup(UIScreen Screen) {
	local RTModVersion CurrentVersion;

	CurrentVersion = `DLCINFO.GetModVersion();
	
	if(CurrentVersion.Major > LastVersion.Major
	|| CurrentVersion.Minor > LastVersion.Minor
	) {
		// if we've updated
		bHasDismissedLatest = false;
		self.SaveConfig();

		Screen.SetTimer(2.0f, false, nameof(ShowPopup), self);
	} else if(CurrentVersion.Major == LastVersion.Major
			&& CurrentVersion.Minor == LastVersion.Minor
	) {
		// same version
		if(!bHasDismissedLatest) {
			Screen.SetTimer(2.0f, false, nameof(ShowPopup), self);
		}
	} else {
		// out-of-bounds
		`RTLOG("The local version is higher than the loaded version?!!", true, false);
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

	LastVersion = `DLCINFO.GetModVersion();
	bHasDismissedLatest = true;

	self.SaveConfig();
}