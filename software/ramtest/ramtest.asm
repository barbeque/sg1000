#define RAM_BASE $c000
#define RAM_PAGED_BASE $e000
#define PAGE_REGISTER $10

#define TEST_LENGTH 8192 ; 8k - Soggy-1000 v3+ unpaged

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
    call MutePSG ; we know for sure we are getting to here
    call BusyWait
_really_ready_now:

    di

    call ScreenInit
    call ClearVRAM
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

_WipeMemory:
    ; We have no idea what state the RAM is in at startup,
    ; so we're going to zero it out up to TEST_LENGTH.
    ; Note that this will frag the stack, big-league
    ld hl, RAM_BASE
    ld de, TEST_LENGTH
_WipeMemory_Inner:
    ld (hl), $00
    inc hl
    dec de
    ld a, d
    or e
    jr nz, _WipeMemory_Inner

    ; Check for keyboard presence
    call InitializeKeyboard
    call IsKeyboardAttached
    cp a, $ff
    jr z, _YesKeyboard
_NoKeyboard:
    ld b, 0
    ld c, 23
    ld hl, STR_NO_KEYBOARD_FOUND
    call print_string
    jr MemTest
_YesKeyboard:
    ld b, 0
    ld c, 23
    ld hl, STR_KEYBOARD_FOUND
    call print_string
    jr MemTest
MemTest:
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
    
    jp done_testing

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
    
    jp done_testing

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

; Begin paging test
Paging_Test:
    ld a, 0 ; page 1 of 4
    out (PAGE_REGISTER), a
    ld a, $cc
    ld (RAM_PAGED_BASE), a
    ld a, (RAM_PAGED_BASE)
    cp a, $cc
    jr nz, Basic_Page_Write_Failed

    ld a, 1 ; page 2 of 4
    out (PAGE_REGISTER), a
    ld a, $aa
    ld (RAM_PAGED_BASE), a
    ld a, (RAM_PAGED_BASE)
    cp a, $aa
    jr nz, Basic_Page_Write_Failed

    ; Switch back to page 1 and make sure it's still the same
    ld a, 0
    out (PAGE_REGISTER), a
    ld a, (RAM_PAGED_BASE)
    cp a, $cc
    jr nz, Basic_Page_Read_Failed

    ; ...and then back again, and read again.
    ld a, 1
    out (PAGE_REGISTER), a
    ld a, (RAM_PAGED_BASE)
    cp a, $aa
    jr nz, Basic_Page_Read_Failed

    ld a, 2 ; page 3 of 4
    out (PAGE_REGISTER), a
    ld a, $de
    ld (RAM_PAGED_BASE), a
    ld a, (RAM_PAGED_BASE)
    cp a, $de
    jr nz, Basic_Page_Write_Failed

    ld a, 3 ; page 4 of 4
    out (PAGE_REGISTER), a
    ld a, $55
    ld (RAM_PAGED_BASE), a
    ld a, (RAM_PAGED_BASE)
    cp a, $55
    jr nz, Basic_Page_Write_Failed

Page_Test_Passed:
    ld b, 0
    ld c, 4
    ld hl, STR_PAGING_WORKS
    call print_string
    jr done_testing

Basic_Page_Write_Failed:
    ld b, 0
    ld c, 4
    ld hl, STR_READBACK_FAILED_PAGED
    call print_string
    jr done_testing

Basic_Page_Read_Failed:
    ld b, 0
    ld c, 4
    ld hl, STR_PAGE_SWITCH_FAILED
    call print_string
    jr done_testing

done_testing:
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

#include "../shared/psg.asm" ; MutePSG

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

STR_BANNER: .asciz "Soggy-1000 RAM tester +8K +Paged"
STR_URL: .asciz "v3 https://www.leadedsolder.com"
STR_MIRRORED: .asciz "Mirroring detected at:"
STR_READBACK_FAILED: .asciz "Readback didn't match!"
STR_PASSED: .asciz "Memory test passed."
STR_TESTED: .asciz "Tested up to address"
STR_READBACK_FAILED_PAGED: .asciz "Paged readback didn't match!"
STR_PAGING_WORKS: .asciz "Paging test passed."
STR_PAGE_SWITCH_FAILED: .asciz "Page switching didn't work?"
STR_KEYBOARD_FOUND: .asciz "Keyboard detected"
STR_NO_KEYBOARD_FOUND: .asciz "No keyboard!"

RAM_TEST_VALUES: .db $aa, $55, $cc, $00, $ff

#include "../shared/vdp.asm"
#include "../shared/font_8x8.asm"
#include "../shared/keyboard.asm"
