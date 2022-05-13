import os, sys
import argparse
from io import BytesIO

"""
Expands binaries to work with an EPROM that is bigger than the binary.

First, it will pad the binary up to the closest power of two.
Then, it will duplicate the binary, important in case there are any floating high address lines.

leadedsolder.com 2022, good luck everyone else
"""

PADDING_BYTE = 0xff

def first_bigger_pow2(goal):
    i = 0
    while 2 ** i < goal:
        i += 1
    return 2 ** i

parser = argparse.ArgumentParser(
    description="Pad and mirror a binary for an EPROM of a given size"
)
parser.add_argument('-s', metavar='kilobits', type=int, nargs='?', default=256,
    help='The target EPROM size, in kilobits (e.g. 27c256 is 256)'
)
parser.add_argument('binary', type=argparse.FileType('rb'), help='The bin file to be formatted for the EPROM.')
parser.add_argument('-o', metavar='output', type=argparse.FileType('wb'), help='The resulting binary file, for writing to the EPROM', nargs='?', default=None)

args = parser.parse_args()
input_binary = BytesIO(args.binary.read())
input_size = len(input_binary.getvalue())
rom_size_in_bytes = (args.s * 1024) // 8
print(f"Padding {input_size}-byte binary to {rom_size_in_bytes}-byte EPROM...")

if input_size > rom_size_in_bytes:
    print(f"It is impossible to fit this binary into this EPROM (need { input_size - rom_size_in_bytes } more bytes of storage)")
    sys.exit(2)

closest_power_of_two = first_bigger_pow2(input_size)

source_buffer = input_binary.getvalue()
if closest_power_of_two < rom_size_in_bytes:
    # do pad
    padding_length = closest_power_of_two - input_size
    print(f"Padding {padding_length} byte(s) to achieve {closest_power_of_two}")
    source_buffer += bytes(PADDING_BYTE for _ in range(padding_length))
    assert(len(source_buffer) == closest_power_of_two)

# now keep adding it into the new buffer
output_buffer = bytes()
duplicate_times = rom_size_in_bytes // closest_power_of_two
print(f"Duplicating {duplicate_times} times to achieve {rom_size_in_bytes}")

for _ in range(duplicate_times):
    output_buffer += source_buffer

assert(len(output_buffer) == duplicate_times * len(source_buffer))

# write it out
output = None
if args.o != None:
    output = args.o
else:
    # original filename?
    original_filename = os.path.splitext(args.binary.name)[0]
    output = open(original_filename + '.padded.bin', 'wb')

with output:
    output.write(output_buffer)

print(f"Padded and duped binary output to {output.name}")
