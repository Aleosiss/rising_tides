class RTEffect_Stasis extends X2Effect_Stasis config(RisingTides);

simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
	local X2Action_PlayAnimation PlayAnimation;

	super.AddX2ActionsForVisualization_Removed(VisualizeGameState, ActionMetadata, EffectApplyResult, RemovedEffect);

	if (XComGameState_Unit(ActionMetadata.StateObject_NewState) != none)
	{
		if( XComGameState_Unit(ActionMetadata.StateObject_NewState).IsTurret() )
		{
			class'X2Action_UpdateTurretAnim'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded);
		}
		else
		{
			// The unit is not a turret
			PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
			PlayAnimation.Params.AnimName = StunStopAnim;
		}
		class'X2StatusEffects'.static.UpdateUnitFlag(ActionMetadata, VisualizeGameState.GetContext());

		// We don't want a remove notification
		/*
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ActionMetadata, VisualizeGameState.GetContext(), default.StasisRemoved, '', eColor_Good, class'UIUtilities_Image'.const.UnitStatus_Stunned, 2.0f);
		class'X2StatusEffects'.static.AddEffectMessageToTrack(
			ActionMetadata,
			default.StasisRemovedText,
			VisualizeGameState.GetContext(),
			class'UIEventNoticesTactical'.default.StasisTitle,
			"img:///UILibrary_PerkIcons.UIPerk_stasis",
			eUIState_Good
		);
		*/
	}
}