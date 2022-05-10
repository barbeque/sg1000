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

_MemTest_ReadbackFailed:
    ; Print value of HL, which still should
    ; be the last address tested
    ld b, 1
    ld c, 3
    call print_hex
    ; Print explanatory string
    ld b, 0
    ld c, 2
    ld hl, STR_READBACK_FAILED
    call print_string
    
    jr busy_loop

_MemTest_MirrorDetected:
    ; Print value of HL
    ld b, 1
    ld c, 3
    call print_hex

    ; Print explanatory string
    ld b, 0
    ld c, 2
    ld hl, STR_MIRRORED
    call print_string
    
    jr busy_loop

Test_Passed:
    ld b, 0
    ld c, 2
    ld hl, STR_PASSED
    call print_string

    jr busy_loop
busy_loop:
    jr busy_loop

get_hex_digit:
    ; arguments:
    ;   A - nibble (4-bit value, but we'll use the whole byte)
    and $f ; n & 0xf
    ld b, a
    cp a, 10
    jr c, _get_hex_digit_less_than_ten
; greater than or equal to ten
    ld a, $21 - 10 ; position of ascii 'A' in our font
    jr _get_hex_digit_finish
_get_hex_digit_less_than_ten:
    ld a, $10 ; position of ascii '0' in our font
    jr _get_hex_digit_finish
_get_hex_digit_finish:
    ;sub 10
    add b
    ret 

print_hex:
    ; arguments:
    ;   B - X
    ;   C - Y
    ;   HL - value
    push hl
    calculate_write_address_from_xy
    call SetVDPWriteAddress
    pop hl

    ; print the $ first, of course
    ld a, $04
    out (VDP_DATA), a
#local
_print_hex_inner:
    ; thanks to https://chilliant.com/z80shift.html
    ld de, hl
    ; first digit: shift right 12
    srl h
    srl h
    srl h
    srl h
    ld l, h
    ld h, 0
    ld a, l
    call get_hex_digit
    out (VDP_DATA), a
    ld hl, de ; restore saved value
    ; second digit: shift right 8
    ld l, h
    ld h, 0
    ld a, l
    call get_hex_digit
    out (VDP_DATA), a
    ld hl, de
    ; third digit: shift right 4
    srl h
    rr l
    srl h
    rr l
    srl h
    rr l
    srl h
    rr l
    ld a, l
    call get_hex_digit
    out (VDP_DATA), a
    ; fourth digit: the remainder
    ld hl, de
    ld a, l
    call get_hex_digit
    out (VDP_DATA), a
#endlocal
    ret

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
