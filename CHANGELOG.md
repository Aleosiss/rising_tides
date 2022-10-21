2.2.1:
- Fix several bugs
  - fix issues where program operatives would not get recovered after a deployment ('undeployed')
  - fix issue where a codex clone would not properly be interrupted by Sovereign, leading to a bad interaction
  - fix issue where rebuilding program operatives via RT_RegenerateProgramOperatives would fail to apply rank ups
  - fix an issue where clicking the loadout button would cause a stack overflow :clown:

2.2.0:
- Add CovertInfiltration support
	- Covert Actions can be undertaken by 'HIGHLANDER'
	- Infiltrations can be undertaken by 'SPECTRE'
	- SPECTRE continues to be able to do normal missions
	- Bridge mod is required and a notification will be shown if it is not present
- Majorly improve how One Small Favor is handled behind-the-scenes.
	- No behavior changes, but it may screw with a save game. 
		- If you have no favors, use RT_CheatModifyProgramFavors 1 to add one
		- If you have none remaining this month (no timeslots), use RT_CheatModifyProgramFavorTracker 1 to add one
		- If you have no squads, use RT_RegenerateProgramOperatives to rebuild them
- The Program Info Screen will now inform you why you cannot call in a Favor (none left, no squads available to take the mission, no timeslots left that month)
- Fix missing upgrade visuals on Program weapons
- Modify Over the Shoulder visualization of enemy units in FOW to those of Target Definition
	- this should be tremendously more performant than the old one when dealing with many targets
	- set the 'UseOldOTSGFX' config property to bring back the old VFX
- Fix soldiers getting stuck in a Covert Action if it was in-progress when the Templars were destroyed
- Fix Chosen showing up on Templar Missions
- Later perks in the Program Operative trees are now mutually exclusive
- Modify Drone VFX attachment point
- Many minor code refactoring changes

2.1.12:
- Disallow Spectre clones from using Program Sustain, thereby fixing issues where Program Operatives would not be properly revived after the death of their shadowbound clone.

2.1.11:
- Added new Strategy UI images courtesy of Steam user ne|V|esis.
- Increased the power of Echoed Agony. Feedback should have a higher chance to proc.
- Make civilians valid targets for Cloaking Protocol.

2.1.10:
- Improvements to the Program Briefing screen. The progress bar will now track your progress towards the next stage of influence, rather than the questline. Since they are pretty closely tied together, this should give you a better understanding of when the next stage will be available.
- Fix support for custom AvailabilityCodes. I took this from the discord, but I don't remember who exactly from, apologies.
- Fix issue where the Program would increase faction influence by two instead of one.
- Minor code cleanup (compiler warnings, debug logging)

2.1.9:
- Add support for the 2020 WOTC Target Icons mod. If you use it, hostile Templars will have spiffy new target icons.
- Add check for missing technologies. This occured when continuing a campaign from before the 2.1.0 patch. If you completed the questline, you can run the 'RT_Patch219' command to see what you missed.

2.1.8:
- Fix issue where Over the Shoulder would throw an assert when receiving invalid input from an event

2.1.7:
- Fixed Focus gains visualizing in FOW. This is done by patching the Focus visualization itself. You can disable this in RisingTides.ini if it breaks something.
- Add support for visualization of Hostile Templar Focus. You can disable this in RisingTides.ini if it breaks something. 
- Clean up Time Stop code
- Fix regression where adding the mod to an in-progress campaign would not activate the Program
- Add command 'RT_ForceInitFaction' to handle old cases.
- Fix Over the Shoulder not lining up with its visualization - the range has been MASSIVELY increased.

2.1.6:
- Fixed issue where new Covert Actions (Grant Favor, Call in Favor) were not being created properly.
- Increased maximum possible chance of getting a Templar Ambush risk to 100% from 50%. 

2.1.5:
- Add MindWrackKillsRulers flag in RisingTides.ini. It defaults to True. If disabled, Mind Wrack will deal 1/4 of the Ruler's maximum HP instead of killing it outright.

2.1.4:
- Fix issue where the Program Info Screen incorrectly displayed 0 favors available as -1 favors available. This was visual only- the player never went below 0 favors available.
- Add RT_DebugFYOW command to attempt to identify why players continously report FYOW not working even though I cannot actually get it to BREAK in testing.
	- Simply type the command on the geoscape while FYOW is activated and post the results in the Bug Reports thread if you're having problems.

2.1.3:
- More work on the removal of Templar soldiers from the game :scream:

2.1.2:
- Skipped 2.1.1 due to build issues
- Fix issue where CA's were failing by default
- Add additional logging and checks to old method of removing Templar soldiers from the game... I can't replicate this issue but it's serious enough to take additional precautions.

2.1.0:
- Add new covert action line to the Program to eliminate the Templars!
	- 3 New Covert Actions - locate, inflitrate, and lure the Templars out from their HQ.
		- New mission (Templar Ambush Retaliation)
			- A local Templar cult has stumbled upon your plans.
			- You can escape, but if word gets back to Geist, your efforts will have been for nothing!
	- New mission (Assault Templar High Coven)
		- Attack the heart of Templar activities and kill Geist once and for all
		- The Program will grant excellent rewards for completing this action, but be warned: your Templar soldiers WILL NOT BE HAPPY with your decision... (they will desert)
	- Program Favor Rework
		- No longer gain a favor for free every month
		- One Small Favor Resistance Order still required to call in favor
		- Favors are now granted by completing steps of the Templar Questline, or as a reward from a special Covert Action
- New Covert Action: Earn a Program Favor
- New perks. If you want them in an ongoing campaign, regenerate your Program operatives with the command 'RT_RegenerateProgramOperatives'.
	- Repositioning: Replaces Damn Good Ground on the Infiltrator's perk tree.
		- If your last (3) shots were taken from (9) tiles away, retain concealment on your next shot.
	Explanation: I felt that the DGG was a boring perk on a list of boring perks.
	- Unfurl The Veil: Replaces Meld Induction on the Gatherer's perk tree.
		- If all active enemies are affected by Over the Shoulder, gain concealment. (6) turn cooldown.
	Explanation: Meld Induction was probably overpowered, probably buggy, and definitely a little confusing. Unfurl the Veil allows the Gatherer to regain concealment, similar to the others.
- Balance Changes
  - General
	- Program operative HP nerfed by 5.
	- Program operative aim decreased by 10.
	- Program operative weaponry and armor now scales with XCOM's (still 1 tier above at all times).
	- Program Berserker:
		- Queen of Blades: Negates mobility penalty instead of reversing it.
	- Program Infiltrator:
		- Daybreak Flame: Now is a toggled ability. Activate the toggle to begin using Daybreak Flame.
		- Daybreak Flame no longer auto procs Scoped and Dropped.
		Explanation:
			Daybreak Flame was probably too strong and had multiple pain points: too much cover destruction, and the risk of shooting out your own floor. These changes hit both.
- Changes
  - Time Stands Still now takes place over a single turn. Instead of three turns with 2 AP each, the unit now receives 6 AP immediately and no action is turn-ending.
  - Program operatives now evacuate the combat zone when greviously wounded.
  - Added config option to show/hide Program operative helmets.

2.0.12:
- Made JPT actually use the value set in config

2.0.11:
- (hopefully) Fixed issue with duplicate strategy cards being generated through resistance ops, will not fix in-progress campaigns affected
- Fixed issue where you could access the soldier customization page of Program Operatives through the bond process (by removing the ability to bond at all)

2.0.10:
- Updated Perk Icons with new art thanks to Steam user ne|V|esis.
- Pour one out for UIPerk_swordSlash, ladies and gents.

2.0.9:
- Fix issue where removing One Small Favor wouldn't return it to the deck.
- If this issue affects your campaign, execute the console command "RT_RecreateOneSmallFavor" to fix it.

2.0.8:
- Updated Program Resistance Order and Rectangular portrait image, courtesy of Steam user ne|V|esis

2.0.7:
- Fixed issues where clicking the Button did not actually activate One Small Favor.
- New Campaigns are not affected by the bug.
- Campaigns affected by the bug should try to run the console command 'RT_RegenerateProgramOperatives' and see if that fixes it

2.0.6:
- Updated short localization of Mind Wrack to include Feedback
- Updated Guardian Angel long localization to clearly state that it will not cleanse nor prevent Feedback's effect
- Fixed a bug where Six Paths of Pain still had an input-trigger even though it could not be input-triggered, which caused the Gatherer to not be able to end turn by default.
- Switched how One Small Favor is gained. Instead of being the only low-influence Resistance Order available, it now is forcibly selected by the Program when the faction is met and the Program gains Faction Orders like other factions.

2.0.5:
- Removed any possibility that the Program could try to hunt the Chosen
- Adding missing icon for Resistance Order tab filtering

2.0.4:
- Fixed an issue where JPT was activating at every opportunity (I toggled the debug flag by accident)

2.0.3
- Fixed a bug where Resistance Sabotage could be activated repeatedly

2.0.2
- Fix a long-standing bug with Over The Shoulder erronously showing units FOW
- Increase the range of Over the Shoulder a bit to match the VFX better
- Fix a bug where OSF did not properly check for a victory
- Add some compatibility configuration for NPSBD
- Modify Infiltrator's custom sniper shots to allow for shots against targets affected by OTS

2.0.1
- Changed effects that refund action points on kill to also refund action points on bleedout
- Increased the radius of Over the Shoulder to 23 tiles (from 17) 
- Over the Shoulder now forces a concealment break on units it affects 
- Moved Over The Shoulder visual effect to foot level 
- Added Program Shotgun, Assault Rifle, and Sniper Rifle (tier above Beam)

2.0.0
- Added new Faction: The Program
	- Added new Strategy Cards:
		- One Small Favor: once per month, send a Program squad on a mission in place of an XCOM squad. Can't send on story missions. Guaranteed to be the first card unlocked.
			- Gain influence with the Program every 3 missions.
			- Program operatives level up after every mission, and cannot be killed or captured.
		- Just Passing Through: There is a small chance for a Program operative to join XCOM on a non-story mission.
		- Wideband Psionic Jamming: Reduce the will of enemy units by 20.
		- Old World Training: Increase the detection modifier of XCom by 20%.
		- Forty Years of War: Instantly construct Resistance Outposts.
		- Direct Neural Manipulation: Bonded Soldiers recieve bonus experience if they survive a mission together.
		- Resistance Sabotage: Other Resistance Factions gain an additional Card Slot.
	- Added new equipment (only for Program operatives)
		- Program Assault Rifle (8-10 dmg)
		- Program Sniper Rifle (10-12 dmg)
		- Program Shotgun (10-12 dmg)
		- Program Shadowkeeper (4-6 dmg, no Shadowfall)
		- Cosmetic Silencer (for those who like the look of the suppressors but don't like recheaters)
	- Added Encyclopedia entries for the Program
- Removed Rising Tides classes from the class decks (cannot be gained normally)
- Removed Extinction Event from Gatherer Ability Tree
	- Moved Unwilling Conduits up as replacement
	- Added Psionic Lance to fill Unwilling Conduits' spot
- Fixed several bugs related to abilities still being able to be cast after death (Psionic Storm, Six Paths of Pain)
- Swapped the position of Six Paths of Pain and Knowledge of Power on Gatherer Ability Tree
- Scoped And Dropped now triggers off of kills made by pistols and Kubikuri
- Added a range limit to Mind Wrack (6 tiles)
- Fixed several bugs related to how the Meld applies its stats
- Added a small will recovery to Guardian Angel
- Guardian Angel now affects the caster
- Changed effects that refund action points on kill to also refund action points on bleedout
- Increased the radius of Over the Shoulder to 23 tiles (from 17)
- Over the Shoulder now forces a concealment break on units it affects
- Moved Over The Shoulder visual effect to foot level

1.1.2
- enabled WOTC class features such as bonding
- made nearly every psionic ability interruptible (if you notice one that isn't, post it in the bugs discussion)
- Sovereign actually works now, because of this.
- fixed an issue where Feedback wasn't being applied properly
- possibly some other random tweaks

1.1.1
- removed X2MeleePathingPawn override (should be fully compatible with Gotcha)
- let Ghosts (Gatherer and Berserker) Headshot The Lost (Infiltrator already does this by default)
- removed accidentally-included debugging loadouts (this is why they started with endgame armor/weapons)

1.1.0
- Update to War of the Chosen!
- Integrate Long War Perks (Close Combat Specialist, Kubikuri)
- Fix bug where directly confirming Shadow Strike from the UI (i.e. not selecting the desired tile via the cursor) would send an invalid (-1,-1,-1) vector to the Teleport method, sending units to a corner of the map
- Fix issue where the melee indicator for Shadow Strike was not attached to the targeted unit
- Fix missing localization for The Six Paths of Pain passive icon
- Fix missing icons for Unwilling Conduits and Echoed Agony (now properly displaying swordslash placeholder ecks dee)
- Extinction Event now renders the soldier who used it unconcious.