; Console.asm
; Defines console routines and functionality
; Required for use:
;   Define in RAM:
;   - TEXT_BUFFER 768 bytes long (32 x 24 characters)
;   - TEXT_INSERTION_POINT 2 bytes long
; Include vdp.asm, vdp_macros.asm
#define TEXT_BUFFER_LENGTH 768

InitText:
    ld hl, 0
    ld (TEXT_INSERTION_POINT), hl
    ld bc, TEXT_BUFFER_LENGTH
#local
    ld hl, TEXT_BUFFER
_InitText_ClearBuffer:
    ld (hl), 0
    inc hl

    dec bc
    ld a, b
    or c
    jp nz, _InitText_ClearBuffer
#endlocal
    ret

SetVDPWriteAddressFromInsertionPoint:
    ld hl, (TEXT_INSERTION_POINT)
    call SetVDPWriteAddress
    ret

PutChar:
    ; Puts the ASCII character defined in register A
    ; onto the screen at the current location
    ; Changes the VDP address. Used for single character and 
    ; slow printing. Will overflow back into position 0,0 if
    ; runs off the edge.
    push af
    call SetVDPWriteAddressFromInsertionPoint
    pop af
PutChar_Append:
    ; Puts the ASCII character defined in register A
    ; into the VDP without changing the VDP address.
    ; Used for loops
    ; Returns 1 in A if write address needs to be recalculated, 0 otherwise
    sub $20 ; change into tile number
    ; TODO: handle newline and other positionals
    out (VDP_DATA), a
    nop_fudge
    ld hl, (TEXT_INSERTION_POINT)
    inc hl
    ld (TEXT_INSERTION_POINT), hl

    push hl
    push de
    or a
    ld de, TEXT_BUFFER_LENGTH
    sbc hl, de
    add hl, de
    pop de
    pop hl
    ld a, 0
    jr nz, _PutChar_End

_PutChar_Wrap:
    ; Reached the end (insertion point >= 768,) start over
    ld hl, 0
    ld a, 1 ; Signal overflow

_PutChar_End:
    ld (TEXT_INSERTION_POINT), hl
    ret
