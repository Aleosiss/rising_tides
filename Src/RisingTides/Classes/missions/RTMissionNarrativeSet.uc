class RTMissionNarrativeSet extends X2MissionNarrative;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2MissionNarrativeTemplate> Templates;

	Templates.AddItem(CreateTemplarAmbushNarrative()); // sweep
	Templates.AddItem(CreateTemplarHighCovenAssaultNarrative()); // kill geist + sweep

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

static function X2MissionNarrativeTemplate CreateTemplarHighCovenAssaultNarrative() {
	local X2MissionNarrativeTemplate Template;

	`CREATE_X2MISSIONNARRATIVE_TEMPLATE(Template, 'RTNarrative_TemplarHighCovenAssault');

	Template.MissionType = "RT_TemplarHighCovenAssault";

	// endmission.failedbysquadwipe
	Template.NarrativeMoments[0]="X2NarrativeMoments.TACTICAL.General.GenTactical_SquadWipe";
	// heavy losses
	Template.NarrativeMoments[1]="XPACK_NarrativeMoments.X2_XP_CEN_T_Neutralize_Comm_Squad_Heavy_Losses";
	// intro narrative	
	// menance 1-5, target location confirmed, kill any hostile units in the AO
	Template.NarrativeMoments[2]="X2NarrativeMoments.TACTICAL.Forge.Forge_TacIntro";
	// failed primary objective
	Template.NarrativeMoments[3]="X2NarrativeMoments.TACTICAL.General.GenTactical_SquadWipe";
	// winner
	Template.NarrativeMoments[4]="X2NarrativeMoments.TACTICAL.Terror.CEN_Terr_STWin";
	// abort
	Template.NarrativeMoments[5]="X2NarrativeMoments.TACTICAL.Neutralize.CEN_Neut_FailureAbort";
	// los to geist
	Template.NarrativeMoments[6]="RisingTidesContentPackage.Maps.GenericTargetSpotted_Moment";
	// continue -> kill geist
	Template.NarrativeMoments[7]="X2NarrativeMoments.TACTICAL.ProtectDevice.T_Protect_Device_PrDv_ProceedToSweep";
	// geist killed
	Template.NarrativeMoments[8]="XPACK_NarrativeMoments.X2_XP_CEN_T_Neutralize_Comm_General_Killed";
	// geist escaped (unused)
	Template.NarrativeMoments[9]="XPACK_NarrativeMoments.X2_XP_CEN_T_Neutralize_Comm_General_Escaped";
	// continue -> sweep
	Template.NarrativeMoments[10]="X2NarrativeMoments.TACTICAL.Recover.CEN_Reco_ProceedToSweep";
	// high coven leaders killed (unused)
	Template.NarrativeMoments[11]="X2NarrativeMoments.TACTICAL.Recover.CEN_Reco_ProceedToSweep";
	// los to network link
	Template.NarrativeMoments[12]="X2NarrativeMoments.TACTICAL.Broadcast.Broadcast_ObjSpotted";
	// los to archives
	Template.NarrativeMoments[13]="X2NarrativeMoments.TACTICAL.Sabotage.CEN_Sabotage_BombSpotted_02";
	// continue -> hack archives
	Template.NarrativeMoments[14]="X2NarrativeMoments.TACTICAL.Hack.Central_Hack_AllEnemiesDefeatedContinue";
	// archives hacked
	Template.NarrativeMoments[15]="X2NarrativeMoments.TACTICAL.General.CEN_ExtrGEN_STObjDestroyed";
	// psionic network link hacked (program line)
	Template.NarrativeMoments[16]="RisingTidesContentPackage.Maps.ProgramReinforcementsIncoming_Moment";

	return Template;
}