## Rising Tides

Rising Tides is an XCOM 2 content addition mod that aims to provide a DLC-like experience. Currently I looking to provide the following:

>- Three "hero"-type units, each with unique three-branch skill trees
>- A single Ghost "superclass" extension (as Soldier is to the Vanilla classes) which provides the following:
>  - Additional default abilities ("Mind Control", "Mind Wrack", "Mind Meld", "Reflection")
>  - Shared abilities across child classes ("Teek", "Vital Point Targeting", "Fade")
>- Special narrative missions to use these units in a controlled environment to ease balancing in a mod-rich environment

This would be a bare-bones content mod. I also have the following content in mind, but would be out of my current capability to do alone (IE I would either need to develop the skills and/or obtain additional contributors, either volunteers or contractors):

>- Voicework for each individual hero unit, as well as other characters
>- New models/animations for armor, weapons, and map assets (and possibly faces)
>- High-quality 2D artwork (Producing icons is possible ATM, but not much more)
>- New enemy units, possible returns from EW

###### Current TODOs:
	- Berserker:
		- nothing
	- Marksman:
		- nothing (Maybe rework time stop to only take place over 1 turn)
	- Gatherer:
		- Redo Guardian Angel (?)
		- Add Over the Shoulder exception for civilians that are actually faceless
		- Rework Assuming Direct Control to enable bonus abilities instead of bonus damage
	- General:
		- Animations/Visuals
		- Add x2/lw abilities to PsionicAbilityList
		- Mind Control

###### Current Table:
	- Shatter The Line: If this unit kills an enemy within X tiles, it triggers a flush effect on other enemies within X tiles. 2/3 turn cooldown. credits to /u/PostOfficeBuddy
	- Orpheus Warp: "…the hero of the broken moon. A pawn played by a negligent deity, a marionette maneuvered by an... epileptic..."
      		- Gain Stealth while preparing a massive psionic rift. On the following turn, the Stealth is broken and a rift is formed. Friendly units can use the rift to evac from the mission. The rift will persist for an additional two turns, or if this unit enters it.
	- RTEffect_ExtendEffectDuration: change to use PreStateSubmitted
	- Come up with a better solution for Over The Shoulder vs. concealed units


###### Current Bugs:
	- Time Stop damage calculation isn't visualized properly
	- Time Stop damage calculation is fucked, use code from X2Effect_DLC_3AbsorptionField.uc to rewrite
	- Make extend effect duration happen on move for Aura Effects as well, possibly by breaking its logic out into a separate method that is called in either place

###### Current Sprint Goals:
	- Verify that Networked OI works with CCS
	- Mind Control

###### Current Overrides: X2MeleePathingPawn
