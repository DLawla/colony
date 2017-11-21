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
- [DONE] Make sample body using Chipmunk
- [DONE] Percentage transfer on transfer lanes
####TODO

- [] Refactor transfer lanes to not use body's and shapes, a bit too much overkill
- [] Refactor ZIndices into a module (one was added)
- [] If a planet is selected, clicking it should toggle click on/off
- [] If a planet is selected, clicking a non-transferrable, friendly planet should change selection to that planet
- [] Make faction-owned planet grow in population faster and start with a boosted population
- [] Create an indicator of some sort for population relative to max (maybe a circumference line)
        - Could maybe do this with simple triangles? Would look better with arcs or solid circle
- [] Change fleet animation size depending on population size
- [] Make fleets not transfer immediately, but still really fast (perhaps halt all growth during this time)
- [] Import music
   Have two .ogg files, but this is awesome too: Miracle by Blackmill﻿ OR Know You Well (Feat. Laura Hahn) by Michael St﻿ Laurent
- [] Import music toggle
- [] Start menu w/ start game button
        button library option: https://github.com/Aerotune/Gosu-Cloudy-Ui
- [] Support for ending a game, showing total time, and allowing a restart

####Building an AI
- [] Have to work out some sort of interface to do simple transfers of a percentage from planet x to y
    - Should probably properly protect this w/ permissions to future-proof it a bit
- [] ...

####Cool additions
- [] animations: trailing lines behind fleets, add eliptical trajectories to fleets

####Next phase
- Rebuild using a more feature rich library like Chingu
- Networking support (two players playing against each other). Networking engine might be possible through EventMachine(https://github.com/eventmachine/eventmachine)
- Teach a neural network to play as the AI -- can use Ruby FANN possibly (https://www.practicalai.io/teaching-a-neural-network-to-play-a-game-with-q-learning/)