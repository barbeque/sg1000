#define VDP_DATA $be
#define VDP_REGISTERS $bf

#define TILES_BASE $0000
#define COLOURS_BASE $0340
#define PATTERNS_BASE $0800
#define TILEMAP_WIDTH 32
#define TILEMAP_HEIGHT 24

#define NOP_FUDGE_FACTOR 2

.macro nop_fudge
    .rept NOP_FUDGE_FACTOR
    nop
    .endm
.endm

.macro set_tile tile_x, tile_y, tile_value
    ld hl, TILES_BASE + (\tile_y * TILEMAP_WIDTH + \tile_x)
    call SetVDPWriteAddress
    ld a, \tile_value
    out (VDP_DATA),a
    nop_fudge
.endm

; Set the flags on a VDP writeable configuration register
.macro write_vdp_register vdp_register, vdp_value
    ld a, \vdp_value
    out (VDP_REGISTERS), a
    ld a, \vdp_register + 128 ; bit 7 must be set to indicate "write to register"
    out (VDP_REGISTERS), a
.endm

; Use the value of HL to set the read/write address.
; Obliterates A,C
SetVDPReadAddress:
    ld c, 0
    jr _SetVDPAddress
SetVDPWriteAddress:
    ld c, 64
_SetVDPAddress:
    ; set vdp read/write address from HL
    ld a, l
    out (VDP_REGISTERS), a
    ld a, h
    or c ; set 0x40 'write' bit potentially
    out (VDP_REGISTERS), a
    ret

ScreenInit:
    di
    ; no mode 2, no extvid
    write_vdp_register 0, %00000000
    ; 16K, graphics mode 0, enable display, no retrace interrupt
    ; mode 0 (32x24, 768 element pattern name table)
    write_vdp_register 1, %11000000
    ; set pattern name (tilemap) table to $0000
    write_vdp_register 2, %00000000
    ; set colour table to come right after PN table; $0340
    write_vdp_register 3, %00001101
    ; set pattern generator to $0800
    write_vdp_register 4, %00000001
    write_vdp_register 5, %00001111
    ; sprite generator table address
    write_vdp_register 6, %00000111 ; FIXME: don't know where to put this, cram it high up
    ; low nibble = background colour
    write_vdp_register 7, %00000000

    ; ...now clear VRAM
#local
_ClearVRAM: ; SLOW
    ; just count from 0 to 3fff and write the VDP
    ld hl, 0x0
    call SetVDPWriteAddress
    ld hl, 0x3fff
_ClearVRAM_Inner:
    ld a, 0 ; value to write
    out (VDP_DATA), a
    nop_fudge
    ; world's slowest 16-bit loop (ref: http://map.grauw.nl/articles/fast_loops.php)
    dec hl
    ld a,h
    or l
    jr nz, _ClearVRAM_Inner
    ei
#endlocal
    ret

