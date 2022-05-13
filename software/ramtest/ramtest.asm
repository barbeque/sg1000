#define RAM_BASE $c000
#define RAM_PAGED_BASE $e000
#define PAGE_REGISTER $10

#define TEST_LENGTH 2048 ; 2k - SG-1000 II

#define PSG_REGISTERS $7f

#include "../shared/vdp_macros.asm"

#target rom
#data DATA, RAM_BASE, *
#code rom, 0x0000, *
startup:
    ld sp, $c3ff ; set stack pointer like Girl's Garden does
    im 1
    jr init

.org $0038
    ; reset handler
    reti

.org $0066
    ; pause button handler stub (return from NMI)
    retn

init:
    di

    .rept 1000
    nop
    .endm

    call ScreenInit
    call ClearVRAM
    call DefineFont
    call InitFontPalette
    call MutePSG ; we know for sure we are getting to here

    ld b, 0
    ld c, 0
    ld hl, STR_BANNER
    call print_string

    ld b, 0
    ld c, 1
    ld hl, STR_URL
    call print_string

_WipeMemory:
    ; We have no idea what state the RAM is in at startup,
    ; so we're going to zero it out up to TEST_LENGTH
    ld hl, RAM_BASE
    ld de, TEST_LENGTH
_WipeMemory_Inner:
    ld (hl), $00
    inc hl
    dec de
    ld a, d
    or e
    jr nz, _WipeMemory_Inner

    ; begin the memory test - basic unpaged region
    ld hl, RAM_BASE
    ld de, TEST_LENGTH
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
    ; Print the final address tested
    ld b, 21
    ld c, 3
    call print_hex

    ; Now the strings for the humans...
    ld b, 0
    ld c, 2
    ld hl, STR_PASSED
    call print_string

    ld b, 0
    ld c, 3
    ld hl, STR_TESTED
    call print_string

    ; fuck it
busy_loop:
    write_vdp_register 1, %11000000
busy_loop_inner:
    jr busy_loop_inner

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

MutePSG:
    ld a, %10011111; channel 00: volume full mute
    out (PSG_REGISTERS), a
    ld a, %10111111; channel 01: volume full mute
    out (PSG_REGISTERS), a
    ld a, %11011111; channel 10: volume full mute
    out (PSG_REGISTERS), a
    ld a, %11111111; channel 11: volume full mute
    out (PSG_REGISTERS), a
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
STR_TESTED: .asciz "Tested up to address"

RAM_TEST_VALUES: .db $aa, $55, $cc, $00, $ff

#include "../shared/vdp.asm"
#include "../shared/font_8x8.asm"
