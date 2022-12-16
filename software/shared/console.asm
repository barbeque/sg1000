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
    ret

SetVDPWriteAddressFromInsertionPoint:
    ld hl, (TEXT_INSERTION_POINT)
    call SetVDPWriteAddress
    ret

PutChar:
    ; Puts the ASCII character defined in register A
    ; onto the screen at the current location
    ; Changes the VDP address. Used for single character and 
    ; slow printing.
    push af
    call SetVDPWriteAddressFromInsertionPoint
    pop af
PutChar_Append:
    ; Puts the ASCII character defined in register A
    ; into the VDP without changing the VDP address.
    ; Used for loops
    sub $20 ; change into tile number
    ; TODO: handle newline and other positionals
    out (VDP_DATA), a
    nop_fudge
    ld hl, (TEXT_INSERTION_POINT)
    inc hl
    ld (TEXT_INSERTION_POINT), hl
