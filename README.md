![The Soggy-1000 logo](/soggy1k.png)

Soggy-1000 is an open-source clone of the Sega SG-1000 home videogame system. The eventual goal of the project is to produce a copy of the SG-1000 main console, and the SK-1100 keyboard, so that the software made for the SC-3000 home computer can be preserved and enjoyed.

## License
The Soggy project is licensed under [the Creative Commons Attribution-NonCommercial 4.0 license](https://creativecommons.org/licenses/by-nc/4.0/).

## Sub-Projects
This repository contains multiple KiCad projects that are related to the overall Soggy project. These are:

 * `keyboard`: An implementation of the SK-1100 keyboard, using modern key switches (Under development)
 * `cartridges/romcart`: An implementation of a bare-bones (ROM-only) cartridge for SG-1000
 * `cartridges/basic-iiib`: An implementation of the SEGA BASIC Level IIIB cartridge, used for testing purposes in order to make sure cartridges can take over the entire memory map (Untested)

## Assembly Guide and BOM
TODO

## Programmer's Guide
The Soggy is basically identical to the existing SG-1000, with the addition (in v0.3 and onwards) of memory mapping hardware. This hardware allows programmers to take advantage of the full 32k of main RAM on the system.

TODO: Memory map diagram
TODO: Use IOW + $10 to set it

## Special Thanks
The following people helped me figure out some aspect of the SG-1000, fixed a bug in my hardware, or otherwise contributed.

 * Enri for providing [SC-3000 and SG-1000 schematics](http://www43.tok2.com/home/cmpslv/Sc3000/EnrSC.htm)
 * Chartreuse for spotting a bug with the latch responsible for page switching
 * Nick Hook from SC-3000 Survivors helped with providing diagrams, pictures, and SF-7000 information
 * Fabio Dalla Libera (sms power) helped with the M1 transistor
 * asynchronous (sms power) also helped with the M1 transistor

## Version History
# v0.4 (in testing)
This version is in active development and may not be suitable for testing yet.

 * /JOY_SEL signal connected to keyboard edge, allowing keyboard 8255 to force polling of joysticks when row 7 of matrix is requested.
 * Converted to DIP Z80 from PLCC, to allow cheaper AliExpress parts to be used rather than expensive new PLCC Z80 part. New DIP Z80s are also still available from Digi-Key, Mouser, etc.
 * Debounce circuit on NMI pin using a Schmitt trigger (design from [this Tynemouth Software blog entry](http://blog.tynemouthsoftware.co.uk/2022/07/how-the-mini-pet-works-debouncing.html), thank you)
 * Weird overpour onto expansion edge fixed, as were some missing silkscreens for '574 and '04
 * Rudimentary support for Sega Genesis/Mega Drive controllers. No mode switching, so it is a similar limitation to Master System games on the Genesis.
 * Trim pot for fine tuning of TMS9918 input clock (and therefore colourburst/Z80/sound clock.) Can be replaced with a simple wire link if you are feeling brave.

# v0.3
Many new features added on the base of the v0.2, and some bugs fixed. This was intended to be the first public release, and is recommended for most people.

 * /IORD and /IOWR signals (IORQ + WR/RD) synthesized and passed to cartridge port. This prevented the SF-7000 from working, as did an I/O map collision with the keyboard. Both problems are now fixed.
 * The full 62256 SRAM is wired up, providing 32K of work RAM to the system. The first 8K are accessible without touching the memory management unit; the second 8K can be switched between four "pages." This should allow Sega BASIC and many other titles relying on SC-3000 functions to work. Previous boards had a 2K mod, matching the SC-3000, but this was not tested.
 * An onboard BIOS ROM socket has been added, which runs when a cartridge is not inserted (detected through the "B2" pin on the cartridge slot, which is usually connected to B1 inside cartridges)

Known bugs:
 * /JOY_SEL is not connected to the keyboard edge
 * Load input on memory management 74ls573 is inverted and doesn't work

# v0.2
 * SK-1100 keyboard edge connector added.
 * Sound chip-induced lockup under /M1 fixed.
 * Extremely weak video signal fixed.
 * Backwards controller ports fixed.
 * Experimental debounce cap on "pause" button added.
 * Reset button added.
 * USB power connector shield grounded.
 * Several problems with sporadic interrupts and waits fixed by adding pull-ups.

Known bugs:
 * /JOY_SEL is not connected to the keyboard edge

# v0.1
Initial release.

Known bugs:
 * Too many to list.
