# codegolf

![preview](/gameplay.gif)

codegolf is a 3 hole mingolf game that fits in the boot sector (just 512 bytes!)

That means this small hex dump contains the entire game: input handling, level layout, physics, everything!

```
ed31 00b8 8ea0 98c0 13b0 10cd 46c7 ff0c
ffff 0c46 46c7 3700 c700 0246 001e 6e89
890e 046e 6e89 8906 086e 6e89 310a 30d2
b9c0 fa00 ff31 aaf3 b952 0005 db31 8b53
0c5e b60f fa97 5b7d be51 7df7 7603 0f0c
34b6 c681 7dcd 5be8 e801 0125 55e8 e801
012a c283 5302 5e8b 0f0c 9fb6 7dfb da39
755b 59e3 c381 013f c4e2 b95a 0007 28b0
49bf 51cf 07b9 e800 0111 c781 0139 e259
39f2 046e 850f 0092 6e39 0f06 8b85 e400
3c60 7520 8309 087e 7d03 ff40 0846 1e3c
0975 7e83 fd08 337e 4eff 3c08 7511 8309
0a7e 7d03 ff26 0a46 1f3c 0975 7e83 fd0a
197e 4eff 3c0a 752d 8b12 085e 5e89 8b04
0a5e 5e89 ff06 0e46 42e9 8bff 004e 5e8b
e802 00b7 8b57 084e e939 077d c96b 29fb
ebcf 6b03 05c9 20b0 90e8 5f00 4e8b 390a
74e9 7c15 6b0d 05c9 40bb 0f01 d9af df29
03eb c96b e8fb 0076 01eb 8b42 004e 5e8b
0302 044e 5e2b e806 0071 8a26 8025 28fc
840f fecd fc80 752f f705 045e 15eb fc80
7530 f705 065e 0beb 4e89 8900 025e 0fb0
8826 8305 69fa 0b7e 7e83 030e 8d0f fea4
aee9 8bfe 6c0e 4104 0e39 046c fa72 aee9
0ffe 0cb6 13e3 30b0 10e8 4600 b60f e30c
b008 e82f 0008 eb46 46e8 f3c3 c3aa 8826
4905 c781 0140 e939 f475 bfc3 0140 af0f
01fb c3cf 8953 8bd3 bfbf 5b7d df29 9ec3
a30c cb0c f30c 9e3e 480c 730d 7826 828c
0028 6c28 8e8c fa00 00b4 fab4 0000 828c
8200 008c 5a3c 5a00 508c 2800 8c32 00cd
b455 8c00 0000 00a0 1a0a 0200 0e08 aa55
```

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
