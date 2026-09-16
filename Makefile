# =============================================================================
# Variables

# Build tools
NASM = nasm -f bin -dN=0x78200


# =============================================================================
# Tasks

all: clean build test

.tmp/boot.bin: src/bootloader.asm
	$(NASM) src/bootloader.asm -o .tmp/boot.bin

boot.img: .tmp/boot.bin
	dd if=/dev/zero of=boot.img bs=512 count=2880
	dd if=.tmp/boot.bin of=boot.img conv=notrunc
	dd if=./krivie_vtorogo_poryadka.txt of=boot.img conv=notrunc seek=1

build: boot.img

clean:
	rm -f *.img
	rm -rf .tmp
	mkdir .tmp

test: build
	qemu-system-i386 -cpu pentium2 -m 1g -fda boot.img -monitor stdio -device VGA

debug: build
	qemu-system-i386 -cpu pentium2 -m 1g -fda boot.img -monitor stdio -device VGA -s -S &
	gdb

.PHONY: all build clean test debug
