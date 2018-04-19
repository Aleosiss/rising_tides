# Rising Tides

Rising Tides is an XCOM 2 content addition mod that aims to provide a DLC-like experience. Currently I looking to provide the following:

>- Three "hero"-type units, each with unique three-branch skill trees
>- A single Ghost "superclass" extension (as Soldier is to the Vanilla classes) which provides the following:
>- Additional default abilities ("Mind Control", "Mind Wrack", "Mind Meld")
>- Shared abilities across child classes ("Teek", "Fade")
>- Special narrative missions to use these units in a controlled environment to ease balancing in a mod-rich environment

This would be a bare-bones content mod. I also have the following content in mind, but would be out of my current capability to do alone (IE I would either need to develop the skills and/or obtain additional contributors, either volunteers or contractors):

>- Voicework for each individual hero unit, as well as other characters
>- New models/animations for armor, weapons, and map assets (and possibly faces)
>- High-quality 2D artwork (Producing icons is possible ATM, but not much more)
>- New enemy units, possible returns from EW

## Current To Test

	- Direct Neural Manipulation

## Current Bugs (High Priority)
	- The Program still has many of the base-game Covert Actions
	- The Program cannot complete the Golden Path actions related to their Chosen

## Current Table

	- Berserker:
		- Shadow Strike: Idea: Target allies (no damage), implement by having a helper ability which activates subabilities based on selection
		- GFX for Bloodlust
		- SFX for Burst
		- Purge: Idea: Add a remove debuffs effect. Additionally propagate this new effect across melded allies?
		- New Capstone Perk Idea: Orpheus Warp: "…the hero of the shattered moon. A pawn played by a negligent deity, a marionette maneuvered by a epileptic..."
				- Gain Stealth while preparing a massive psionic rift. On the following turn, the Stealth is broken and a rift is formed. Friendly units can use the rift to evac from the mission. The rift will end after two turns, or if caster's connection is broken.
	- Marksman:
		- Maybe rework time stop to only take place over 1 turn
		- rework boring perks (Knock Them Down, Your Hands, My Eyes, Eye in the Sky)
	- Gatherer:
		- Redo Guardian Angel (?, no one has told me if it actually works or not)
		- Add Over the Shoulder exception for civilians that are actually faceless
		- Extinction Event needs to somehow stop revive units from reviving
		- Come up with a better solution for Over The Shoulder vs. concealed units
	- General:
		- none
	- The Program (New Faction):
		- get new icon and faceplate
		- create customizations for all ghosts
		- figure out a way to either remove certain covert actions for the Program or simply template them as previously done
		- Strategy Card: One Small Favor: once per month, send a Program squad on a mission in place of an XCOM squad. Can't send on Golden Path missions. Guarenteed to be the first card unlocked.
		- Strategy Card: Just Passing Through: There is a small chance for a Program operative to join XCOM on a non-story mission.
		- Strategy Card: Wideband Psionic Jamming: Reduce the will of enemy units by a flat value.
		- Strategy Card: Old World Training: Increase the detection modifier of XCom by a flat value.
		- Strategy Card: Forty Years of War: Instantly construct Resistance Outposts.
		- Strategy Card: Direct Neural Manipulation: Bonded Soldiers recieve bonus experience if they survive a mission together.
		- Strategy Card: Resistance Sabotage: Other Resistance Factions gain an additional Card Slot.
	- Prognosticator (New Class)
		- this word sounded cool, so I will make it into a class
		- wtf will it do? not sure how "seeing the future" can work in real life
			- is it possible to force the AI to use a behavior tree?

## Current Bugs (low priority)

	- Time Stop damage calculation isn't visualized properly
	- Time Stop damage calculation is fucked, use code from X2Effect_DLC_3AbsorptionField.uc to rewrite
	- Make extend effect duration happen on ObjectMoved for Aura Effects as well, possibly by breaking its logic out into a separate method that is called in either place
	- Psionic Storm only plays sound from one storm at a time, due to a base-game issue where a looping soundcue can only be played once per ObjectID
	- Networked OI does not work with CloseCombatSpecialistAttack or KillzoneShot. Unsure of exact cause, appears that CCS does not tick AbilityActivated
	- Shadow Strike does not highlight the tiles it can activate to
	- Have to travel to a region that is building an outpost to activate Forty Years of War
