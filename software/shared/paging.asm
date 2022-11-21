; Shorthand to change the upper 8K to a given page
; Obliterates:
;   A
.macro use_page page
    ld a, \page
    out (PAGE_REGISTER), a
.endm
