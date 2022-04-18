![The Soggy-1000 logo](/soggy1k.png)

Soggy-1000 is an open-source clone of the Sega SG-1000 home videogame system. The eventual goal of the project is to produce a copy of the SG-1000 main console, and the SK-1100 keyboard, so that the software made for the SC-3000 home computer can be preserved and enjoyed.

## Version History
# v0.3 (in development)
New features added on the base of the v0.2, and some bugs fixed. This is intended to be the first public release, but the feature list is not frozen.

 * /IORD and /IOWR signals (IORQ + WR/RD) synthesized and passed to cartridge port. This prevented the SF-7000 from working.
 * 2K out of the 32K of the 62256 SRAM are now wired up, allowing Sega BASIC and many other titles relying on SC-3000 functions to work. This was bodged on the previous board. WIP: adding memory mapping hardware to allow for the full 32K

# v0.2
 * SK-1100 keyboard edge connector added.
 * Sound chip-induced lockup under /M1 fixed.
 * Extremely weak video signal fixed.
 * Backwards controller ports fixed.
 * Experimental debounce cap on "pause" button added.
 * USB power connector shield grounded.
 * Several problems with sporadic interrupts and waits fixed by adding pull-ups.

# v0.1
Initial release.
