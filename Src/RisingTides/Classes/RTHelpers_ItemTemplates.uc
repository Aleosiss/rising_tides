class RTHelpers_ItemTemplates extends X2ItemTemplate;

// extends X2ItemTemplate to modify protected properties

// Grimy code
static function AddFontColor(X2ItemTemplate EditTemplate, string HexColor) {
	if ( EditTemplate != none && InStr( EditTemplate.FriendlyName, "</font>" ) == -1 ) {
		`RTLOG("AddFontColor succeeded, final string is: \n<font color='#" $ HexColor $ "'><b>" $ EditTemplate.FriendlyName $ "<b/></font>");
		EditTemplate.FriendlyName = "<font color='#" $ HexColor $ "'><b>" $ EditTemplate.FriendlyName $ "<b/></font>";
		EditTemplate.FriendlyNamePlural = "<font color='#" $ HexColor $ "'><b>" $ EditTemplate.FriendlyNamePlural $ "<b/></font>";
	}
}