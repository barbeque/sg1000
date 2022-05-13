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
    ;nop_fudge
    ld a, \vdp_register + $80 ; bit 7 must be set to indicate "write to register"
    out (VDP_REGISTERS), a
    ;nop_fudge
.endm

.macro calculate_write_address_from_xy
    ; Sets the write address based on a tile position on screen.
    ; assume that B, C are X, Y
    ; obliterates BC, HL
    push de
    push bc
    ld d, c ; row counter ("Y")
    ld e, TILEMAP_WIDTH
    call DumbMultiply ; FIXME: OPTIM: I suspect we don't really need this; we can bit-shift, because width is a power of 2, but who cares?
    pop bc
    ld c, b ; extend b to 16-bit bc so we can add to hl
    ld b, 0 ; is it faster to just do OR?
    add hl, bc ; have to add 16-bit...
    ld bc, TILES_BASE
    pop de
.endm
