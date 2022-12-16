ZASM_FLAGS := --labels
local_path = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

TEST_SYSTEM = "sg1000"
#TEST_SYSTEM = "sc3000"

all: condemo.sc

condemo.sc: condemo.asm ../shared/*.asm
	zasm ${ZASM_FLAGS} condemo.asm condemo.sc

run: condemo.sc
	cd ${MAME_PATH} && ./mame64 ${TEST_SYSTEM} -cart ${local_path}condemo.sc

debug: condemo.sc
	cd ${MAME_PATH} && ./mame64 ${TEST_SYSTEM} -debug -cart ${local_path}condemo.sc

openshots:
	open ${MAME_PATH}/snap/sc3000

pad: condemo.sc
	python3 ./prepare.py -s 256 condemo.sc

burn: pad condemo.padded.bin
	minipro -p MX27C256@DIP28 -w condemo.padded.bin

clean:
	rm -rf condemo.sc
	rm -rf condemo.lst
	rm -rf condemo.padded.bin
