![The Soggy-1000 logo](/soggy1k.png)

Soggy-1000 is an open-source clone of the Sega SG-1000 home videogame system. The eventual goal of the project is to produce a copy of the SG-1000 main console, and the SK-1100 keyboard, so that the software made for the SC-3000 home computer can be preserved and enjoyed.

# License
The Soggy project is licensed under [the Creative Commons Attribution-NonCommercial 4.0 license](https://creativecommons.org/licenses/by-nc/4.0/).

## Programmer's Guide
The Soggy is basically identical to the existing SG-1000, with the addition (in v0.3 and onwards) of memory mapping hardware. This hardware allows programmers to take advantage of the full 32k of main RAM on the system.

TODO: Memory map diagram
TODO: Use IOW + $10 to set it

## Special Thanks
The following people helped me figure out some aspect of the SG-1000, fixed a bug in my hardware, or otherwise contributed.

 * Fabio Dalla Libera (sms power) helped with the M1 transistor
 * asynchronous (sms power) also helped with the M1 transistor

## Version History
# v0.3 (in development)
Many new features added on the base of the v0.2, and some bugs fixed. This is intended to be the first public release, but the feature list is not frozen.

 * /IORD and /IOWR signals (IORQ + WR/RD) synthesized and passed to cartridge port. This prevented the SF-7000 from working, as did an I/O map collision with the keyboard. Both problems are now fixed.
 * The full 62256 SRAM is wired up. The first 8K are accessible without touching the memory management unit; the second 8K can be switched between four "pages." This should allow Sega BASIC and many other titles relying on SC-3000 functions to work. A 2K mod, matching the SC-3000, was bodged on the previous board.

# v0.2
 * SK-1100 keyboard edge connector added.
 * Sound chip-induced lockup under /M1 fixed.
 * Extremely weak video signal fixed.
 * Backwards controller ports fixed.
 * Experimental debounce cap on "pause" button added.
 * Reset button added.
 * USB power connector shield grounded.
 * Several problems with sporadic interrupts and waits fixed by adding pull-ups.

# v0.1
Initial release.
