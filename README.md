# axm68k
Hacked version of asm68k with macros for Z80 instructions (and potentially other CPUs).

Macros for most Z80 instructions can be used with the regular asm68k, however a number of instructions are the same in both Z80 and 68000 (add, and, neg, nop, or & sub). In order to get these working in Z80, those instructions had to be hex-edited out of asm68k and then re-enabled for 68000 with some additional macros. The modified asm68k was renamed to prevent confusion.

## Usage
Replace asm68k.exe with axm68k.exe; remember to update your build file.

Insert the following lines at the start of your asm file:
```
include "Macros - More CPUs.asm"
cpu 68000
```

Insert the following line whenever you want to switch to Z80 instructions:
```
cpu z80
obj 0
```

And the following line at the end of Z80 instructions:
```
cpu 68000
objend
```
