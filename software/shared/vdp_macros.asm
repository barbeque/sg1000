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
