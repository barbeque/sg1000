#define RAM_BASE $c000
#define RAM_PAGED_BASE $e000
#define PAGE_REGISTER $10

#define TEST_LENGTH 8192 ; 8k - Soggy-1000 v3+ unpaged

#define PSG_REGISTERS $7f

#include "../shared/vdp_macros.asm"

#target rom
#data DATA, RAM_BASE, *
TEXT_BUFFER defs TEXT_BUFFER_LENGTH
TEXT_INSERTION_POINT defs 2
#code rom, 0x0000, *

startup:
    ld sp, $c3ff ; set stack pointer like Girl's Garden does
    im 1
    jp init

.org $0038
    ; reset handler
    reti

.org $0066
    ; pause button handler stub (return from NMI)
    retn

    ; The VDP gets reset at system startup, but it takes a lot
    ; longer than the CPU to be ready for action. We could do a
    ; bunch of setup stuff here, but instead we'll just spin until
    ; we think the VDP should be willing to listen to us.
BusyWait:
    ld d, $3 ; girls garden used $2 x $ffff
_busywait_outer:
    ld hl, $ffff
_busywait_inner:
    dec hl
    ld a,h
    or l
    jr nz, _busywait_inner
    dec d
    jr nz, _busywait_outer
    ret
init:
    call MutePSG
    call BusyWait

really_ready:
    di
    call ScreenInit
    call ClearVRAM
    call DefineFont
    call InitFontPalette
    call InitText

    ld a, 'A'
    call PutChar

loop_forever:
    jr loop_forever

#include "../shared/vdp.asm"
#include "../shared/font_8x8.asm"
#include "../shared/keyboard.asm"
#include "../shared/psg.asm"
#include "../shared/console.asm"
