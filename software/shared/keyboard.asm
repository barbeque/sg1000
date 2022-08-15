InitializeKeyboard:
    ld a, $92
    out ($df), a
    ret

IsKeyboardAttached:
    ; As per Enri (https://web.archive.org/web/20090213004805/http://www2.odn.ne.jp/~haf09260/Mark3/Sk1100.htm):
    ; Determination of SK-1100 connection
    ; 　The connection is determined using the latches of the ports A to C of the 8255.
    ; 　In SK-1100, the mode is set and port C is output, so use here.
    ; 　As a simple method, output 000H to port C and read port C.

    ; 　0FFH because it is an unused port only on the main body of MARK III/SG-1000
    ; 　When the SK-1100 is connected, the port C latch holds the written value of 000H.
#local
#define TEST_BYTE $cc
#define KEYBOARD_LATCH_PORT $de
    ld a, TEST_BYTE
    out (KEYBOARD_LATCH_PORT), a
    nop
    nop
    in a, (KEYBOARD_LATCH_PORT)
_DEBUG:
    cp a, TEST_BYTE
    jp z, _YesKeyboard
    ld a, $00 ; no keyboard found
    ret
_YesKeyboard:
    ld a, $ff ; yes, keyboard found
#endlocal
    ret
