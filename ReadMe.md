## Rising Tides

Rising Tides is an XCOM 2 content addition mod that aims to provide a DLC-like experience. Currently I looking to provide the following:

>- Three "hero"-type units, each with unique three-branch skill trees
>- A single Ghost "superclass" extension (as Soldier is to the Vanilla classes) which provides the following:
>  - Additional mobility options ("Icarus"-style vertical mobility, fall damage negation)
>  - Additional default abilities ("Mind Control", "Mind Wrack", "Mind Meld", "Reflection")
>  - Shared abilities across child classes ("Teek", "Vital Point Targeting", "Fade")
>- Special narrative missions to use these units in a controlled environment to ease balancing in a mod-rich environment

This would be a bare-bones content mod. I also have the following content in mind, but would be out of my current capability to do alone (IE I would either need to develop the skills and/or obtain additional contributors, either volunteers or contractors):

>- Voicework for each individual hero unit, as well as other characters 
>- New models/animations for armor, weapons, and map assets (and possibly faces)
>- High-quality 2D artwork (Producing Icons is possible ATM, but not much more)
>- New enemy units, possible returns from EW

###### Current TODOs: 
	- Berserker:
		- Shadow Strike unbound targeting style
		- Mentor feedback cleanse effect
		- Move the Acid stack count off the template
	- Marksman:
		- nothing
	- Gatherer: 
		- Let's try to move away from scanning protocol-- it's ugly and unimmersive. Instead, we'll directly set the visibility in RTEffect_MobileSquadViewer.
		- More investigation seems to indicate that ObjectMoved will trigger on each tile, good for Over The Shoulder. Set the Tile Listener to slightly higher priority than the ObjectMoved listener.
		- Investigate bug related to removing Aura Effects; first try removing Guardian Angel to see if that is the cause
		- Triangulation
		- AbilitySet
	- General:
		- Animations/Visuals
		- Meld respond to feedback event
		- implement new RTEffectBuilder class: https://hastebin.com/raxahacezo.uc
			- replace effects in various abilitysets with constructors from the builder/factory class
		- implement configuration for RTEffectBuilder
		- implement new TargetAbility condition: https://hastebin.com/eleboyigib.uc
		- I may have broken the feedback panic visualization, investigate
		- Add x2/lw abilities to PsionicAbilityList
	
###### Current Table:
      - Shatter The Line: If this unit kills an enemy within X tiles, it triggers a flush effect on other enemies within X tiles. 2/3 turn cooldown. credits to /u/PostOfficeBuddy
      
###### Current Bugs:
      - Time Stop damage calculation isn't visualized properly
      - Time Stop probably won't work on Frozen enemies
      - Time Stop doesn't work on Stasis'd units (despite this making no sense whatsoever) because it's hard-coded
      - Shock And Awe readout not displayed
              
              
