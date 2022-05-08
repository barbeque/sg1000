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

busy_loop:
    jr busy_loop

#include "../shared/vdp.asm"
#include "../shared/font_8x8.asm"
