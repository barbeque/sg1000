ZASM_FLAGS := --labels
local_path = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# change to test sk1100 vs. built in
TEST_SYSTEM = "sg1000"
#TEST_SYSTEM = "sc3000"

all: ramtest.sc

ramtest.sc: ramtest.asm ../shared/*.asm
	zasm ${ZASM_FLAGS} ramtest.asm ramtest.sc

run: ramtest.sc
	cd ${MAME_PATH} && ./mame64 ${TEST_SYSTEM} -cart ${local_path}ramtest.sc

debug: ramtest.sc
	cd ${MAME_PATH} && ./mame64 ${TEST_SYSTEM} -debug -cart ${local_path}ramtest.sc

openshots:
	open ${MAME_PATH}/snap/sc3000

pad: ramtest.sc
	python3 ./prepare.py -s 256 ramtest.sc

burn: pad ramtest.padded.bin
	minipro -p MX27C256@DIP28 -w ramtest.padded.bin

clean:
	rm -rf ramtest.sc
	rm -rf ramtest.lst
	rm -rf ramtest.padded.bin
