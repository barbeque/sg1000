#!/bin/bash

# Look at a bunch of *.sg ROMs to figure out where they set
# their stack pointer. Primarily used to determine which ROMs
# might be abusing the SG-1000's RAM mirroring, so I know
# who to look out for when I'm doing the page-switching logic
# in my Soggy-1000 clone.

# "Safe" stack pointers should be something like $c3ff, like we can
# see in Girl's Garden:
#	ld sp, $c3ff

# -e is there because:
# Stop disassembling relatively early since we assume they'll set
# up SP by then. Otherwise disassembler thinks some of the ROM data
# is also ld sp, xxx
DISASSEMBLER="z88dk-dis -mz80 -e 0x0200"

for rom in "$@"
do
    base_name=$(basename "${rom}")
    echo "$base_name"
    ${DISASSEMBLER} "$rom" | grep "ld\s*sp"
done
