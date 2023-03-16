; model_macros.asm
; ---
; Macros to identify hardware, before the stack is set up.

#define SG1000_RAM_BASE $c000
#define SEGA_SG1000_RAM_TOP $c3ff
#define SEGA_SC3000_RAM_TOP $c7ff
#define SOGGY_V3_FIXED_PAGE_TOP $dfff ; 64k - 8k
#define SOGGY_V3_RAM_TOP $ffff

; The I/O register to write to for page switching control.
#define SOGGY_PAGE_REGISTER $10

.macro is_soggy_v3
; Identify if the system is a page-switched/32K Soggy-1000,
; or at least has 8k of RAM
    ld hl, SG1000_RAM_BASE
    ld (hl), $55 ; store some bytes here
    ld hl, SOGGY_V3_FIXED_PAGE_TOP
    ld (hl), $aa ; The opposite pattern
    ld hl, SG1000_RAM_BASE
    ld a, (hl) ; Load it back and see if it mirrored
    cp a, $55
#local
    jr z, _yes
_no:
    ld a, $00 ; no
    jr _exit
_yes:
    ld a, $ff
    jr _exit
_exit:
#endlocal
.endm

.macro is_sc3000
; Identify if the system is a 2K SC-3000 or Othello Multivision
    ld hl, SG1000_RAM_BASE
    ld (hl), $55
    ld hl, SEGA_SC3000_RAM_TOP
    ld (hl), $aa
    ld hl, SG1000_RAM_BASE
    ld a, (hl)
    cp a, $55 ; was it wiped out by a mirrored write?
#local
    jr z, _yes
_no:
    ld a, $00 ; it was corrupted, it's not an SC-3000 (likely original model)
    jr _exit
_yes:
    ld a, $ff
    jr _exit
_exit:
#endlocal
.endm

.macro is_sg1000
; Identify if the system is a 1K SG-1000 or SG-1000 II
    is_soggy_v3
    cp a, $ff
#local
    jr z, _no

    is_sc3000
    cp a, $ff
    jr z, _no

_yes:
    ; Not Soggy or SC-3000, must be an original model
    ld a, $ff
    jr _exit
_no:
    ld a, $00
    jr _exit
_exit:
#endlocal
.endm

.macro set_soggy_page_register page
    ; Change Soggy-1000 paging register to \page
    ld a, \page
    out (SOGGY_PAGE_REGISTER), a
.endm
