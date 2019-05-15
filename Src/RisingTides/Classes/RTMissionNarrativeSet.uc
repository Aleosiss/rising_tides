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

	// general failure narratives
	Template.NarrativeMoments[0]="XPACK_NarrativeMoments.X2_XP_CEN_T_Neutralize_Comm_Squad_Wipe";
	Template.NarrativeMoments[1]="XPACK_NarrativeMoments.X2_XP_CEN_T_Neutralize_Comm_Squad_Heavy_Losses";
	
	// tactical intro
	Template.NarrativeMoments[2]="X2NarrativeMoments.TACTICAL.Neutralize.Neutralize_TacIntro";
	
	// mission failure
	Template.NarrativeMoments[3]="X2NarrativeMoments.TACTICAL.Neutralize.CEN_Neut_FailureAbortHL";
	
	// mission success
	//Template.NarrativeMoments[4]="XPACK_NarrativeMoments.X2_XP_CEN_T_Neutralize_Comm_Mission_Accomplished";
	//Template.NarrativeMoments[4]="X2NarrativeMoments.TACTICAL.General.GenTactical_BurnoutSecured";
	Template.NarrativeMoments[4]="X2NarrativeMoments.TACTICAL.General.CEN_Gen_BurnoutSecured_02";
	//Template.NarrativeMoments[4]="X2NarrativeMoments.TACTICAL.General.CEN_Gen_BurnoutSecured_03";

	// mission abort
	Template.NarrativeMoments[5]="XPACK_NarrativeMoments.X2_XP_CEN_T_Neutralize_Comm_Mission_Aborted";
	
	// target spotted
	Template.NarrativeMoments[6]="RisingTidesContentPackage.Maps.GenericTargetSpotted_Moment";
	
	// unused
	Template.NarrativeMoments[7]="XPACK_NarrativeMoments.X2_XP_CEN_T_Neutralize_Comm_General_Near_EVAC";
	
	// target killed
	//Template.NarrativeMoments[8]="XPACK_NarrativeMoments.X2_XP_CEN_T_Neutralize_Comm_General_Killed";
	Template.NarrativeMoments[8]="XPACK_NarrativeMoments.X2_XP_CEN_T_Covert_Escape_Captain Dead";

	// unused
	Template.NarrativeMoments[9]="XPACK_NarrativeMoments.X2_XP_CEN_T_Neutralize_Comm_General_Escaped";
	
	// proceed to sweep
	Template.NarrativeMoments[10]="X2NarrativeMoments.TACTICAL.Recover.CEN_Reco_ProceedToSweep";
	
	// unused
	Template.NarrativeMoments[11]="XPACK_NarrativeMoments.X2_XP_CEN_T_Neutralize_Comm_ADVENT_EVAC_Ready";
	Template.NarrativeMoments[12]="XPACK_NarrativeMoments.X2_XP_CEN_T_Neutralize_Comm_ADVENT_EVAC_Blocked";
	Template.NarrativeMoments[13]="XPACK_NarrativeMoments.X2_XP_CEN_T_Neutralize_Comm_ADVENT_EVAC_Approach";
	
	return Template;
}

static function X2MissionNarrativeTemplate CreateTemplarCovenAssaultNarrative() {
	local X2MissionNarrativeTemplate Template;

	`CREATE_X2MISSIONNARRATIVE_TEMPLATE(Template, 'RTNarrative_TemplarCovenAssault');

	Template.MissionType = "RT_TemplarHighCovenAssault";

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