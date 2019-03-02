class RTHelpers_ItemTemplates extends X2ItemTemplate;

// extends X2ItemTemplate to modify protected properties

// Grimy code
static function AddFontColor(X2ItemTemplate EditTemplate, string HexColor) {
	if ( EditTemplate != none && InStr( EditTemplate.FriendlyName, "</font>" ) == -1 ) {
		EditTemplate.FriendlyName = "<font color='#" $ HexColor $ "'>" $ EditTemplate.FriendlyName $ "</font>";
		EditTemplate.FriendlyNamePlural = "<font color='#" $ HexColor $ "'>" $ EditTemplate.FriendlyNamePlural $ "</font>";
	}
}