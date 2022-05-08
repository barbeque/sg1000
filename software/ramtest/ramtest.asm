#define RAM_BASE $c000
#define RAM_PAGED_BASE $e000
#define PAGE_REGISTER $10

#target rom
#data DATA, RAM_BASE, *
#code rom, 0x0000, *
startup:
    call ScreenInit

#include "../shared/vdp.asm"
