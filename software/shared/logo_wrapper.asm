; LOGO_START = 0x60
#define LOGO_START FONTS_END + 1

Upload_Logo:
	ld de, LOGO
	ld b, 255
	ld hl, LOGO_START * 8
	call BulkCopyToVDP ; 256

	ld de, LOGO + 256 * 1
	ld b, 255
	ld hl, LOGO_START * 8 + 256 * 1
	call BulkCopyToVDP ; 512

	ld de, LOGO + 256 * 2
	ld b, 255
	ld hl, LOGO_START * 8 + 256 * 2
	call BulkCopyToVDP ; 768

	ld de, LOGO + 256 * 3
	ld b, 255
	ld hl, LOGO_START * 8 + 256 * 3
	call BulkCopyToVDP ; 1024

	ld de, LOGO + 256 * 4
	ld b, 255
	ld hl, LOGO_START * 8 + 256 * 4
	call BulkCopyToVDP ; 1280

	ld de, LOGO + 256 * 5
	ld b, 255
	ld hl, LOGO_START * 8 + 256 * 5
	call BulkCopyToVDP ; 1536

	ld de, LOGO + 256 * 6
	ld b, 255
	ld hl, LOGO_START * 8 + 256 * 6
	call BulkCopyToVDP ; 1792

	ld de, LOGO + 256 * 7
	ld b, 255
	ld hl, LOGO_START * 8 + 256 * 7
	call BulkCopyToVDP ; 2048

	; Now define the palette for these blocks
	ld hl, COLOURS_BASE + LOGO_START
	call SetVDPWriteAddress
	ld a, %11110000 ; white on black
	.rept (LOGO_WIDTH * LOGO_HEIGHT) + 1; ehhh
	out (VDP_DATA), a
	.endm

	ret

DrawLogo:
	; index is LOGO + (y * LOGO_WIDTH + x)
	; basically sequentially pulling out of LOGO,
	; but incrementing Y position every LOGO_WIDTH
	ld c, 0
	ld b, 0
	ld hl, LOGO
_DrawLogo_NextRow:
	calculate_write_address_from_xy 
	call SetVDPWriteAddress
	ld b, 0
_DrawLogo_NextColumn:
	ld a, (hl)
	out (VDP_DATA), a
	inc b
	ld a, b
	cp a, LOGO_WIDTH
	jp nz, _DrawLogo_NextColumn
	inc c
	ld a, c
	cp a, LOGO_HEIGHT
	jp nz, _DrawLogo_NextRow
