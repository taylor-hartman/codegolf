# codegolf

![preview](/preview.png)

codegolf is a 3 hole mingolf game that fits in the boot sector

In order to assemble and run use the following:

```
nasm -f bin codegolf.asm -o codegolf.bin
qemu-system-i386 -hda codegolf.bin
```

## How To Play

Change the x and y velocities of the ball with the WASD keys. 
To hit the ball press X. 
Hit the ball into the red hole to advance to the next level. 
Each level must be complete in less than 3 strokes. 
When the screen turns green you have beat the game.

