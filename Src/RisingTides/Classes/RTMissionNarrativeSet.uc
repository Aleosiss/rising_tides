class RTMissionNarrativeSet extends X2MissionNarrative;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2MissionNarrativeTemplate> Templates;
	`RTLOG("Building mission narratives!");
	//recreation of base-game mission narratives for LW-specific variations
	Templates.AddItem(CreateTemplarAmbushNarrative()); // sweep
	Templates.AddItem(CreateTemplarCovenAssaultNarrative()); // kill geist + sweep

	return Templates;
}


static function X2MissionNarrativeTemplate CreateTemplarAmbushNarrative() {
	local X2MissionNarrativeTemplate Template;

	`CREATE_X2MISSIONNARRATIVE_TEMPLATE(Template, 'RTNarrative_TemplarAmbush');

	Template.MissionType = "RT_TemplarAmbush";
	
	// intro narrative	
	// menance 1-5, target location confirmed, kill any hostile units in the AO
	Template.NarrativeMoments[0]="X2NarrativeMoments.TACTICAL.Neutralize.Neutralize_TacIntro";

	// victory narrative(s)
	// status confirm, target eliminate (templar leader)
	Template.NarrativeMoments[1]="XPACK_NarrativeMoments.X2_XP_CEN_T_Covert_Escape_Captain Dead";

	// victory narrative(s)
	// all targets are down and the area is secure
	Template.NarrativeMoments[2]="X2NarrativeMoments.TACTICAL.General.CEN_Gen_BurnoutSecured";
	Template.NarrativeMoments[3]="X2NarrativeMoments.TACTICAL.General.CEN_Gen_BurnoutSecured_02";
	Template.NarrativeMoments[4]="X2NarrativeMoments.TACTICAL.General.CEN_Gen_BurnoutSecured_03";
	
	// general failure narratives
	Template.NarrativeMoments[5]="XPACK_NarrativeMoments.X2_XP_CEN_T_Covert_Escape_Squad Wipe";
	Template.NarrativeMoments[6]="XPACK_NarrativeMoments.X2_XP_CEN_T_Covert_Escape_Squad Extracted";
	Template.NarrativeMoments[7]="XPACK_NarrativeMoments.X2_XP_CEN_T_Covert_Escape_Partial Squad Recovery";
	Template.NarrativeMoments[8]="XPACK_NarrativeMoments.X2_XP_CEN_T_Covert_Escape_Operative Down";
	Template.NarrativeMoments[9]="XPACK_NarrativeMoments.X2_XP_CEN_T_Covert_Escape_Operative Dead";
	
	return Template;
}

static function X2MissionNarrativeTemplate CreateTemplarCovenAssaultNarrative() {
	local X2MissionNarrativeTemplate Template;

	`CREATE_X2MISSIONNARRATIVE_TEMPLATE(Template, 'RTNarrative_TemplarCovenAssault');

	Template.MissionType = "RT_TemplarCovenAssault";

	// intro narrative	
	// menance 1-5, target location confirmed, kill any hostile units in the AO
	Template.NarrativeMoments[0]="X2NarrativeMoments.TACTICAL.Neutralize.Neutralize_TacIntro";
	// geist spotted
	Template.NarrativeMoments[1]="X2NarrativeMoments.TACTICAL.Neutralize.Neutralize_VIPSpotted";
	// victory narrative(s)
	// geist killed
	Template.NarrativeMoments[2]="X2NarrativeMoments.TACTICAL.Neutralize.Neutralize_VIPExecuted";
	// sweep completed
	Template.NarrativeMoments[17]="X2NarrativeMoments.TACTICAL.General.CEN_Gen_BurnoutSecured_01";
	Template.NarrativeMoments[17]="X2NarrativeMoments.TACTICAL.General.CEN_Gen_BurnoutSecured_02";
	Template.NarrativeMoments[17]="X2NarrativeMoments.TACTICAL.General.CEN_Gen_BurnoutSecured_03";
	// general failure narratives
	Template.NarrativeMoments[12]="X2NarrativeMoments.TACTICAL.General.GenTactical_SquadWipe";
	Template.NarrativeMoments[13]="X2NarrativeMoments.TACTICAL.General.GenTactical_FullEVAC";
	Template.NarrativeMoments[14]="X2NarrativeMoments.TACTICAL.General.GenTactical_PartialEVAC";

	return Template;
}