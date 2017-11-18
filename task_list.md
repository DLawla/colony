#Tasks

####DONE
- [DONE] Two planets (drawn), rendered w/ mouse selection and image change when selected
- [DONE] Import planet sprites
- [DONE] Create random planet sizing, give planet a size trait, and adjust selection box accordingly
- [DONE] Create populations (increase by planet size, so hold a population and max population value) and ensure they max out out
- [DONE] When selected, support moving ALL planet's population to an adjacent selected planet
- [DONE] When a planet is selected, on mousing over a nearby planet
- [DONE] Planet transfer animation
- [DONE] Extracting all planet selection logic into Selection.rb
- [DONE] Clean up planet.rb, if required
- [DONE] Random planet location generator
- [DONE] Figure out a way to capture what an adjacent planet is -- DONE via row instance variable
- [DONE] Create new objects for transferring populations (ships), which tranfer from planet to planet
   and take time to move (would look cool as trailing lines)

####TODO

- [] When a planet is selected, draw a line (thick, so maybe many) to all planets that can transfer to
- [] When hovering over transfer line, or its planet, make it be a new color
- [] Support variable population transfer percentage
- [] Change fleet size depending on fleet population size
- [] Create an indicator of some sort for population relative to max (maybe a circumference line)
- [] Make fleets not transfer immediately, but when invading/transferring, population grows more slowly or not at all
- [] Import music
   Have two .ogg files, but this is awesome too: Miracle by Blackmill﻿ OR Know You Well (Feat. Laura Hahn) by Michael St﻿ Laurent
- [] Import music toggle
- [] Start menu w/ start game button
- [] Support for ending a game, showing total time, and allowing a restart

####Cool additions
- [] animations: trailing lines behind fleets, add eliptical trajectories to fleets

####Next phase
- Networking support (two players playing against each other). Networking engine might be possible through EventMachine(https://github.com/eventmachine/eventmachine)