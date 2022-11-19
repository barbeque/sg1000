; LOGO_START = 0x60
#define LOGO_START FONTS_END + 1

; TODO: OK, the LOGO array is wrong in memory... fix it

#define UPLOAD_CHUNK_SIZE 255
#define LOGO_COLOUR %01001101

UploadLogo:
	ld de, LOGO
	ld b, UPLOAD_CHUNK_SIZE
	ld hl, PATTERNS_BASE + LOGO_START * 8
	call BulkCopyToVDP ; 256

	ld de, LOGO + UPLOAD_CHUNK_SIZE * 1
	ld b, UPLOAD_CHUNK_SIZE
	ld hl, PATTERNS_BASE + LOGO_START * 8 + UPLOAD_CHUNK_SIZE * 1
	call BulkCopyToVDP ; 512

	ld de, LOGO + UPLOAD_CHUNK_SIZE * 2
	ld b, UPLOAD_CHUNK_SIZE
	ld hl, PATTERNS_BASE + LOGO_START * 8 + UPLOAD_CHUNK_SIZE * 2
	call BulkCopyToVDP ; 768

	ld de, LOGO + UPLOAD_CHUNK_SIZE * 3
	ld b, UPLOAD_CHUNK_SIZE
	ld hl, PATTERNS_BASE + LOGO_START * 8 + UPLOAD_CHUNK_SIZE * 3
	call BulkCopyToVDP ; 1024

    ; FIXME: Do something with a 16-bit counter here instead of this ugly hack
    ld de, LOGO + UPLOAD_CHUNK_SIZE * 4
	ld b, 4 ; HACK: the leftovers because we are only copying 255 out of 256 bytes per chunk
	ld hl, PATTERNS_BASE + LOGO_START * 8 + UPLOAD_CHUNK_SIZE * 4
	call BulkCopyToVDP ; 1024

	; Now define the palette for these blocks
	ld hl, COLOURS_BASE + (LOGO_START / 8)
	call SetVDPWriteAddress
	ld a, LOGO_COLOUR
	.rept (LOGO_LENGTH_TILES / 8); ehhh, should round up
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
