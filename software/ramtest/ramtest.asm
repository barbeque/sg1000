#define RAM_BASE $c000
#define RAM_PAGED_BASE $e000
#define PAGE_REGISTER $10

#include "../shared/vdp_macros.asm"

#target rom
#data DATA, RAM_BASE, *
#code rom, 0x0000, *
startup:
    call ScreenInit
    call DefineFont
    call InitFontPalette

    set_tile 0, 0, 0x28 ; 'H'
    set_tile 1, 0, 0x45 ; 'e'
    set_tile 2, 0, 0x4c ; 'l'
    set_tile 3, 0, 0x4c ; 'l'
    set_tile 4, 0, 0x4f ; 'o'
    set_tile 5, 0, 0x52 ; 'r'
    set_tile 6, 0, 0x4c ; 'l'
    set_tile 7, 0, 0x44 ; 'd'

    ld b, 0
    ld c, 1
    ld hl, STR_HELLO_WORLD
    call print_string

    ; TODO: write the tester (16-bit index, probably)
    ; TODO: write an ASCII print routine (sub $20)
    ; TODO: write a routine to print out the failed address if any
    ; TODO: detect mirroring

busy_loop:
    jr busy_loop

print_string:
    ; arguments:
    ;   B - X
    ;   C - Y
    ;   HL - pointer to null-terminated ASCII string
    push hl
    calculate_write_address_from_xy
    call SetVDPWriteAddress
    pop hl
#local
_print_string_inner:
    ld a, (hl)
    sub $20 ; our letter tiles start at 0, but that one is space (ascii 20)
    out (VDP_DATA), a
    nop_fudge ; FIXME: not sure if we have to nop here, since our loop is so slow

    inc hl
    ld a, (hl)
    cp a, 0
    ; is next character null?
    jr nz, _print_string_inner
#endlocal

    ret

STR_HELLO_WORLD: .asciz "Hello, World"

#include "../shared/vdp.asm"
#include "../shared/font_8x8.asm"
