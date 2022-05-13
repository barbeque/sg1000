ZASM_FLAGS := --labels
local_path = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

all: ramtest.sc

ramtest.sc: ramtest.asm ../shared/*.asm
	zasm ${ZASM_FLAGS} ramtest.asm ramtest.sc

run: ramtest.sc
	cd ${MAME_PATH} && ./mame sc3000 -cart ${local_path}ramtest.sc

debug: ramtest.sc
	cd ${MAME_PATH} && ./mame sc3000 -debug -cart ${local_path}ramtest.sc

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
