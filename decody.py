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
    ( 0, 'bios rom' ),
    ( 0x2000, 'expansion port' ),
    ( 0x4000, 'expansion port' ),
    ( 0x6000, 'start of RAM' ),
    ( 0x4000, 'cart ROM bank A' ),
    ( 0x6000, 'cart ROM bank B' ),
    ( 0x8000, 'cart ROM bank C' ),
    ( 0xa000, 'cart ROM bank D') ]
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
    ( 0x40, 'psg sn76489' ),
    ( 0x80, 'video tms9918' ),
    ( 0xc0, 'keyboard + joystick' ),
    ( 0xe0, 'sf-7000' ) 
]

print('Memory Map:')
walk_map(memory_map)

print('I/O Map:')
walk_map(io_map)
