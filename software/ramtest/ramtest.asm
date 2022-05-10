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

    ; begin the memory test - first 1k for check
    ld hl, RAM_BASE
    ld de, $0400 ; 1k
_MemTest_Inner:
    ld a, (hl)
    cp a, $aa ; TODO: Use the RAM_TEST_VALUE_* and do this in a loop
    jr z, _MemTest_MirrorDetected ; $aa was already in this byte

    ; Write
    ld a, $aa
    ld (hl), a
    nop
    ; Read
    ld a, (hl)
    cp a, $aa
    jr nz, _MemTest_ReadbackFailed ; We read back something that wasn't $aa

_MemTest_Inner_End:
    inc hl
    dec de
    ld a, d
    or e
    jr nz, _MemTest_Inner
    
    jr Test_Passed

    ; TODO: write an ASCII print routine (sub $20)
    ; TODO: write a routine to print out the failed address if any

_MemTest_ReadbackFailed:
    ld b, 0
    ld c, 2
    ld hl, STR_READBACK_FAILED
    call print_string
    ; TODO: Print failed address HL
    jr busy_loop

_MemTest_MirrorDetected:
    ; TODO: Print value of HL
    ld b, 0
    ld c, 2
    ld hl, STR_MIRRORED
    call print_string
    ; TODO: Print failed address HL
    jr busy_loop

Test_Passed:
    ld b, 0
    ld c, 2
    ld hl, STR_PASSED
    call print_string
    jr busy_loop

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
STR_MIRRORED: .asciz "Mirroring detected at:"
STR_READBACK_FAILED: .asciz "Readback didn't match!"
STR_PASSED: .asciz "Memory test passed."

RAM_TEST_VALUES: .db $aa, $55, $cc, $00, $ff

#include "../shared/vdp.asm"
#include "../shared/font_8x8.asm"
