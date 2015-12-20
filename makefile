all: hantow test

test: test.o asm_io.o
	gcc -m32 -o test test.o driver.c asm_io.o
test.o: test.asm
	nasm -f elf32 -o test.o test.asm

hantow: hantow.o asm_io.o
	gcc -m32 -o hantow hantow.o driver.c asm_io.o
asm_io.o: asm_io.asm
	nasm -f elf32 -d ELF_TYPE asm_io.asm
hantow.o: hantow.asm
	nasm -f elf32 -o hantow.o hantow.asm
