; LOGO_START = 0x60
#define LOGO_START FONTS_END + 1

; TODO: OK, the LOGO array is wrong in memory... fix it

UploadLogo:
	ld de, LOGO
	ld b, 255
	ld hl, PATTERNS_BASE + LOGO_START * 8
	call BulkCopyToVDP ; 256

	ld de, LOGO + 256 * 1
	ld b, 255
	ld hl, PATTERNS_BASE + LOGO_START * 8 + 256 * 1
	call BulkCopyToVDP ; 512

	ld de, LOGO + 256 * 2
	ld b, 255
	ld hl, PATTERNS_BASE + LOGO_START * 8 + 256 * 2
	call BulkCopyToVDP ; 768

	ld de, LOGO + 256 * 3
	ld b, 255
	ld hl, PATTERNS_BASE + LOGO_START * 8 + 256 * 3
	call BulkCopyToVDP ; 1024

	; Now define the palette for these blocks
	ld hl, COLOURS_BASE + (LOGO_START / 8)
	call SetVDPWriteAddress
	ld a, %11110000 ; white on black
	.rept (LOGO_LENGTH_TILES / 8) + 1; ehhh
	out (VDP_DATA), a
	.endm

	ret

DrawLogo:
	; index is LOGO + (y * LOGO_WIDTH + x)
	; basically sequentially pulling out of LOGO,
	; but incrementing Y position every LOGO_WIDTH
	ld c, 0 ; TODO: screen offsets here
	ld b, 0
	ld d, LOGO_START ; character index
_DrawLogo_NextRow:
	ld b, 0 ; reset x-position for new line
    push bc
	calculate_write_address_from_xy 
	call SetVDPWriteAddress
    pop bc
_DrawLogo_NextColumn:
	ld a, d
	out (VDP_DATA), a ; insert and increment to next column of VDP
    inc d ; get next logo character index (they're sequential)
	inc b ; next column of screen
	ld a, b
	cp a, LOGO_WIDTH
	jp nz, _DrawLogo_NextColumn

	inc c ; next row
    ld a, c
	cp a, LOGO_HEIGHT
	jp nz, _DrawLogo_NextRow

    ret
