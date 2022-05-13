ZASM_FLAGS := --labels
local_path = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

all: ramtest.sc

ramtest.sc: ramtest.asm
	zasm ${ZASM_FLAGS} ramtest.asm ramtest.sc

run: ramtest.sc
	cd ${MAME_PATH} && ./mame64 sc3000 -cart ${local_path}ramtest.sc

debug: ramtest.sc
	cd ${MAME_PATH} && ./mame64 sc3000 -debug -cart ${local_path}ramtest.sc

openshots:
	open ${MAME_PATH}/snap/sc3000

clean:
	rm -rf ramtest.sc
	rm -rf ramtest.lst
