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

    ld b, 0
    ld c, 0
    ld hl, STR_BANNER
    call print_string

    ld b, 0
    ld c, 1
    ld hl, STR_URL
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
    nop_fudge ; FIXME: OPTIM: not sure if we have to nop here, since our loop is so slow

    inc hl
    ld a, (hl)
    cp a, 0
    ; is next character null?
    jr nz, _print_string_inner
#endlocal

    ret

STR_BANNER: .asciz "Soggy-1000 RAM tester"
STR_URL: .asciz "https://www.leadedsolder.com"

#include "../shared/vdp.asm"
#include "../shared/font_8x8.asm"
