characters = []

with open('font8x8_basic.h', 'r') as fp:
    lines = fp.readlines()

# find the opening line
start = 0
for line in lines:
    start += 1
    if line.find('{') > 0:
        break

# count to offset $20, then parse all the chunks
start += 0x20

def reverse_byte(byte):
    binary = format(byte, '08b')
    reversed_binary = binary[::-1]
    return int(reversed_binary, base = 2)

output = []
for i in range(0, 128 - 0x20 - 1):
    # should be the format { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},   // U+0020 (space)
    line = lines[start + i].strip()
    # change hex encoding to the style i like better
    line = line.replace('0x', '$')
    # remove brackets
    line = line.replace('{', '').replace('}', '')
    # remove trailing comma
    left, _, comment = line.rpartition('//')
    left, _, right = left.rpartition(',')

    # split up the left side and flip the bytes (this is dumb)
    left = ', '.join([hex(reverse_byte(int(t.replace('$',''), base=16))) for t in left.split(',')])

    # add the comment back on
    line = left + '//' + comment

    # each byte should be in reverse order


    # fix comments to assembler syntax
    line = line.replace('//', ';')
    # insert assembler declaration
    line = '.db ' + line + ' (offset $%02x)' % i
    output.append(line)

with open('font_8x8.asm', 'w') as fp:
    fp.write('FONT_HEAD: \n')
    fp.write('\n'.join(output)) # you would think 'writelines' would imply 'do a newline' but i guess not?

# finish with the };
