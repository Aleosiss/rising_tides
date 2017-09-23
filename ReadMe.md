## Rising Tides

Rising Tides is an XCOM 2 content addition mod that aims to provide a DLC-like experience. Currently I looking to provide the following:

>- Three "hero"-type units, each with unique three-branch skill trees
>- A single Ghost "superclass" extension (as Soldier is to the Vanilla classes) which provides the following:
>  - Additional default abilities ("Mind Control", "Mind Wrack", "Mind Meld")
>  - Shared abilities across child classes ("Teek", "Fade")
>- Special narrative missions to use these units in a controlled environment to ease balancing in a mod-rich environment

This would be a bare-bones content mod. I also have the following content in mind, but would be out of my current capability to do alone (IE I would either need to develop the skills and/or obtain additional contributors, either volunteers or contractors):

>- Voicework for each individual hero unit, as well as other characters
>- New models/animations for armor, weapons, and map assets (and possibly faces)
>- High-quality 2D artwork (Producing icons is possible ATM, but not much more)
>- New enemy units, possible returns from EW

###### Current TODOs:
	- Berserker:
		- nothing (Maybe allow Shadow Strike to target allies but do no damage)
	- Marksman:
		- nothing (Maybe rework time stop to only take place over 1 turn)
	- Gatherer:
		- Redo Guardian Angel (?)
		- Add Over the Shoulder exception for civilians that are actually faceless
	- General:
		- Animations/Visuals
		- Add x2/lw abilities to PsionicAbilityList

###### Current Table:
	- Shatter The Line: If this unit kills an enemy within X tiles, it triggers a flush effect on other enemies within X tiles. 2/3 turn cooldown. credits to /u/PostOfficeBuddy
	- Orpheus Warp: "…the hero of the broken moon. A pawn played by a negligent deity, a marionette maneuvered by an... epileptic..."
      		- Gain Stealth while preparing a massive psionic rift. On the following turn, the Stealth is broken and a rift is formed. Friendly units can use the rift to evac from the mission. The rift will persist for an additional two turns, or if this unit enters it.
	- Come up with a better solution for Over The Shoulder vs. concealed units	  
	- Purge: Add a remove debuffs effect. Additionally propagate this new effect across melded allies?
	- GFX for Bloodlust
	- Extinction Event needs to somehow stop revive units from reviving
	- SFX for Burst

###### Current Bugs:
	- Time Stop damage calculation isn't visualized properly
	- Time Stop damage calculation is fucked, use code from X2Effect_DLC_3AbsorptionField.uc to rewrite
	- Make extend effect duration happen on move for Aura Effects as well, possibly by breaking its logic out into a separate method that is called in either place
	- Psionic Storm only plays sound from one storm at a time, due to a base-game issue where a soundcue can only be played once per ObjectID
	- Networked OI does not work with CloseCombatSpecialistAttack or KillzoneShot. Unsure of exact cause, appears that CCS does not tick AbilityActivated
	- Shadow Strike does not highlight the tiles it can activate to. Should be possible without highlander, but a pain in the ass, so low priority.

###### Current Sprint Goals:
	- Get the Faction in the game
