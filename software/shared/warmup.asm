sg1000_cold_start:
    ; The VDP gets reset at system startup, but it takes a lot
    ; longer than the CPU to be ready for action. The BIOS on the
    ; ColecoVision/MSX/etc seems to take care of this problem for games.
    ; We could do a bunch of setup stuff here, but for now we'll just spin until
    ; we think the VDP should be willing to listen to us.
#local
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
#endlocal