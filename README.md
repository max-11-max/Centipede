# Centipede

Download MARS Assembly Simulator from this link http://courses.missouristate.edu/KenVollmar/mars/

Open centipede.s in the MARS simulator. In tools, create a bitmap display, with 8 pixel width, and 8 pixel height, and 256x256 display width/height, and $gp, base address for display. Connect the bitmap display to MIPS, and also in tools, create a keyboard and MMIO display simulator, and connect it to MIPS. Assemble and run to play a game based off the 1980 Atari Centipede Arcade Game.

Commands:
j: move left
k: move right
x: shoot dart
s: restart game

Rules:
Shoot the centipede 3 times, and the game ends, in which case you can restart the game to play again. Mushrooms block both centipede movement, and darts, but will be destroyed by the darts shot by the bug blaster. There is also a flea that descends vertically, and if the bug blaster gets hit by it, the game ends as well.
