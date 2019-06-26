2.1.0:
- Add new covert action line to the Program to eliminate the Templars!
    - 3 New Covert Actions - locate, inflitrate, and lure the Templars out from their HQ.
        - New mission (Templar Ambush Retaliation)
            - A local Templar cult has stumbled upon your plans.
            - You can escape, but if word gets back to Geist, your efforts will have been for nothing!
    - New mission (Assault Templar High Coven)
        - Attack the heart of Templar activities and kill Geist once and for all
        - The Program will grant excellent rewards for completing this action, but be warned: your Templar soldiers WILL NOT BE HAPPY with your decision... (they will desert)
- New perks. If you want them in an ongoing campaign, regenerate your Program operatives with the command 'RT_RegenerateProgramOperatives'.
    - Repositioning: Replaces Damn Good Ground on the Infiltrator's perk tree.
        - If your last (3) shots were taken from (9) tiles away, retain concealment on your next shot.
    - Unfurl The Veil: Replaces Meld Induction on the Gatherer's perk tree.
        - If all active enemies are affected by Over the Shoulder, gain concealment. (6) turn cooldown.
- Balance Changes
  - Daybreak Flame no longer auto procs Scoped and Dropped.
  - Program operative HP nerfed by 5.
  - Program operative aim decreased by 10.
  - Program operative weaponry now scales with XCOM's.
- Changes
  - Time Stands Still now takes place over a single turn. Instead of three turns with 2 AP each, the unit now receives 6 AP immediately and no action is turn-ending.
  - Program operatives now evacuate the combat zone when greviously wounded.

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