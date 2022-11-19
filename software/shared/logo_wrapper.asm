; LOGO_START = 0x60
#define LOGO_START FONTS_END + 1

UploadLogo:
	ld de, LOGO
	ld b, 255
	ld hl, TILES_BASE + LOGO_START * 8
	call BulkCopyToVDP ; 256

	ld de, LOGO + 256 * 1
	ld b, 255
	ld hl, TILES_BASE + LOGO_START * 8 + 256 * 1
	call BulkCopyToVDP ; 512

	ld de, LOGO + 256 * 2
	ld b, 255
	ld hl, TILES_BASE + LOGO_START * 8 + 256 * 2
	call BulkCopyToVDP ; 768

	ld de, LOGO + 256 * 3
	ld b, 255
	ld hl, TILES_BASE + LOGO_START * 8 + 256 * 3
	call BulkCopyToVDP ; 1024

	ld de, LOGO + 256 * 4
	ld b, 255
	ld hl, TILES_BASE + LOGO_START * 8 + 256 * 4
	call BulkCopyToVDP ; 1280

	ld de, LOGO + 256 * 5
	ld b, 255
	ld hl, TILES_BASE + LOGO_START * 8 + 256 * 5
	call BulkCopyToVDP ; 1536

	ld de, LOGO + 256 * 6
	ld b, 255
	ld hl, TILES_BASE + LOGO_START * 8 + 256 * 6
	call BulkCopyToVDP ; 1792

	ld de, LOGO + 256 * 7
	ld b, 255
	ld hl, TILES_BASE + LOGO_START * 8 + 256 * 7
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
	ld a, d ; HACK for testing
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
