%include "asm_io.inc"

SECTION .data:

	range dd 2,3,4,5,6,7,8

SECTION .bss:

SECTION .text
	global asm_main

asm_main:
	enter 0,0
	pusha

	;mov eax, 'A' times 4
	;call print_string 

	popa
	leave
	ret
