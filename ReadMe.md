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
              - Tidy up class files (remove legacy code, document, etc)
              - Finish up current features
                - Give TimeStop a RTGameState to track the amount of damage dealt during the time stop
                - Decrease vision radius / detection radius of greyscaled units to 0 (Enemy only?)
                - Implement Harbinger
              - Extract Sovereign code from Scopped and Dropped
              - Brainstorm the rest of Whisper's abilities
                - Offense tree (Daybreak Flame), Utility tree (Time Stands Still), Defense tree (???)
                  - 
                  
http://hastebin.com/ipulitayis.coffee

http://hastebin.com/wevumocitu.avrasm
              
###### Current Unresolved:
              - Time Stop isn't preventing units from scampering, and interacts with units in FOW strangely 
              - PS: Force immobility by setting their ECharStat_Mobility to 0
