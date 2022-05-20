def to_bin(h):
    return format(h, '016b')

def walk_map(m):
    for (start_offset, identifier) in sorted(m, key=lambda p: p[0]):
        print(to_bin(start_offset) + ' ' + identifier)

        # identify set bits
        set_bits = []

        address = 0
        while address <= 15:
            if(start_offset) & 1 != 0:
                set_bits.append(address)
            address += 1 # increment address line
            start_offset = start_offset >> 1 # shift out the lowest bit

        formatted_addresses = map(lambda a: f'A{a}', set_bits)
        print(' bits set:', ', '.join(formatted_addresses))

memory_map = [
    ( 0, '/EXM2 (cartridge)' ),
    ( 0xc000, 'internal RAM (SG-1000)' ),
    ( 0xc400, 'extra internal RAM (SG-1000 II)' ),
    ( 0xc800, 'end of 2K of RAM' ),
#    ( 0xdfff, 'end of fixed 8K' ),
    ( 0xe000, 'second pageable 8K (Soggy-1000 v3+)' ),
    ( 0x8000, '/EXM1' ),
]
"""
memory_map = [ # PV7
    (0x8000, 'slot 0-2, first 8k'),
    (0xa000, 'slot 0-2, second 8k'),
    (0xc000, 'slot 0-3, first 8k'),
    (0xe000, 'slot 0-2, second 8k'),
    (0xffff, 'memory top')
]
"""

io_map = [
    ( 0x10, 'memory mapper (canonical; all $00-3f is available)'),
    ( 0x40, 'psg sn76489' ),
    ( 0x80, 'video tms9918' ),
    ( 0xc0, 'keyboard + joystick' ),
    ( 0xe0, 'sf-7000' ) 
]

print('Memory Map:')
walk_map(memory_map)

print('I/O Map:')
walk_map(io_map)
