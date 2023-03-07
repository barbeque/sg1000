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
