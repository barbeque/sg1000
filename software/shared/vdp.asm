#define VDP_DATA $be
#define VDP_REGISTERS $bf

#define TILES_BASE $0000
#define COLOURS_BASE $0340
#define PATTERNS_BASE $0800
#define TILEMAP_WIDTH 32
#define TILEMAP_HEIGHT 24

#define FONTS_BASE  $00
#define FONTS_END   $5f

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
    ; interrupts should be disabled and the stack should be setup
    ; before calling this!

    ; no mode 2, no extvid
    write_vdp_register 0, %00000000
    ; 16K, graphics mode 0, DISABLE display, no retrace interrupt
    ; mode 0 (32x24, 768 element pattern name table w/o sprites)
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
    write_vdp_register 7, %00100101

    ; read the status register to clear any INT or C flag
    in a, (VDP_REGISTERS)

    ret

    ; ...now clear VRAM
ClearVRAM: ; SLOW
    ; just count from 0 to 3fff and write the VDP
    ld hl, $00
    call SetVDPWriteAddress
    ld hl, $3fff
_ClearVRAM_Inner:
    ld a, $00 ; value to write
    out (VDP_DATA), a
    nop_fudge
    ; world's slowest 16-bit loop (ref: http://map.grauw.nl/articles/fast_loops.php)
    dec hl
    ld a,h
    or l
    jr nz, _ClearVRAM_Inner
    ret

; Make a simple palette we can all follow
InitFontPalette:
    ld hl, COLOURS_BASE
    call SetVDPWriteAddress
    ld a, %11011010 ; the ugliest colour imaginable
    .rept (94 / 8) + 1 ; the number of palettes used for the alphabet tiles
    out (VDP_DATA),a
    nop_fudge
    .endm
    ret

; Place the font into video RAM, which will end up at $0800 <= x <= $085e (FONTS_BASE)
DefineFont:
; Start at FONT_HEAD
; Write a byte to VRAM and keep going, 94 * 8 times
    ld hl, PATTERNS_BASE + (FONTS_BASE * 8)
    call SetVDPWriteAddress
    ld hl, FONT_HEAD
    ld c, 94 ; 94 characters
_DefineFont_Inner:
    ld b, 8 ; 8 bytes per character
_DefineFont_Row_Inner:
    ld a, (hl)
    inc hl
    out (VDP_DATA), a
    nop_fudge

    ; are we done with this character or is there one more row?
    djnz _DefineFont_Row_Inner

    ; decrement outer counter to move onto next character
    dec c
    jp nz, _DefineFont_Inner

    ret

DumbMultiply:
    ; HL = D * E
    ;   OBLITERATES B
    ld hl, 0
    ld a, d
    or a
    ret z
    ld b, d
    ld d, h
#local
_DumbMultiplyLoop:
    add hl, de
    djnz _DumbMultiplyLoop
#endlocal
    ret
