%include "asm_io.inc"

SECTION .data

peg2: dd 0,0,0,0,0,0,0,0,9					;the two initially empty arrays
peg3: dd 0,0,0,0,0,0,0,0,9


wrongArgs db "Need exactly 1 argument.",0
outRange db "The argument must be an integer from 2-8.",0	;different messages that could be printed
victory db "DONE.",0

space db " ",0
plus db "+",0
peg db "|",0
base db "XXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXX",0

SECTION .bss

peg1: resd 9 							;holds the initial peg which will be made according to the argument
currentPeg: resd 1
argument: resd 1						;holds the address of the peg we are printing.
count: resd 1

SECTION .text
	global asm_main

asm_main:
	enter 0,0		;setup
	pusha

	mov eax, [ebp+8]	;eax now holds # of args. 2 is reqd
	
	cmp eax, 2		;if the number of args is not 2, jump out.
	jne .tooManyArguments
	
	
	mov ebx, [ebp+12]
	mov ecx, [ebx+4] 	;al holds the argument, and only the one argument. we now check if it is in the range.
	mov al, byte [ecx]	

    	cmp al, '2'
	mov ebx, 2
	je .inRange

	cmp al, '3'
	mov ebx, 3
	je .inRange

	cmp al, '4'
	mov ebx, 4
	je .inRange

	cmp al, '5'
	mov ebx, 5
	je .inRange
				;in this block we check if the argument in is the range.
	cmp al, '6'
	mov ebx, 6
	je .inRange

	cmp al, '7'
	mov ebx, 7
	je .inRange

	cmp al, '8'
	mov ebx, 8
	je .inRange

	jmp .outOfRange		;if the arg is not in the range, jump to end section.

.inRange: ;if we get to this point, we are in range with the argument in ebx.
	
	mov [argument], ebx
	
	;1. Setup peg1 based off the value in bl
	mov eax, dword 32
	mov [peg1 + eax], dword 9
	.setupLoop:			;This loop sets up peg1.
		sub eax, dword 4
		mov [peg1 + eax], ebx
		sub ebx, dword 1
		cmp ebx, dword 0
		jne .setupLoop

;AFTER THIS POINT THE PROGRAM IS INITIALIZED, IF THE ARGS ARE CORRECT
	
	call .printTower
		
	
	push dword [argument]
	push peg1
	push peg2
	push peg3
	call .hanoi
	add esp, 16
	jmp .success

;***************************************************************************************************************************
	;2. Setup a loop that prompts for input. Each time the input is registered,we go through another iteration and print
	.printTower:
		mov [count], dword 1
		;PRINTING STARTS HERE
		;Here we write to the screen by creating strings and printing
		;ebx will hold which line we are on (ie start with the top of the array, add 4 each time)
		;edx will hold the disk size
		mov ebx, dword 0
		
		.printPeg:
			;we check our count variable and set currentPeg accordingly
			cmp [count], dword 1
			je .firstPegPrint

			cmp [count], dword 2
			je .secondPegPrint

			cmp [count], dword 3
			je .thirdPegPrint
		
			.firstPegPrint:
				mov [currentPeg], dword peg1
				jmp .allSet
			.secondPegPrint:
				mov [currentPeg], dword peg2
				jmp .allSet
			.thirdPegPrint:
				mov [currentPeg], dword peg3
		
		.allSet:				;with the peg set here, we load the disk number into ecx, 9-ecx into edx, print the string
			mov edx, dword [currentPeg]	;edx holds address of our desired arraY
			mov ecx, dword [edx + ebx]	;access array + offset to get value in ecx
			mov edx, dword 9
			sub edx, ecx			;edx holds # of spaces (9-ecx)
			
			mov eax, space
			.printSpacesLeft:
				cmp edx, dword 0
				je .doneSL
				call print_string
				sub edx, 1
				jmp .printSpacesLeft
					
			.doneSL:
				mov eax, plus

			.printCharsLeft:
				cmp ecx, 0
				je .peg
				call print_string
				sub ecx, 1
				jmp .printCharsLeft
	
			.peg:
				mov edx, dword [currentPeg]
				mov ecx, dword [edx + ebx]
				mov edx, 9
				sub edx, ecx
				mov eax, peg
				call print_string
				
				mov eax, plus	
			.printCharsRight:
				cmp ecx, 0
				je .doneCharsRight
				call print_string
				sub ecx, 1
				jmp .printCharsRight

			.doneCharsRight:
				mov eax, space

			.printSpacesRight:
				cmp edx, 0
				je .doneSR
				call print_string
				sub edx, 1
				jmp .printSpacesRight
			
			.doneSR:
				call print_string
				call print_string
				add [count], dword 1
				cmp [count], dword 4
				jne .printPeg
				jmp .nextLine

			.nextLine:
				call print_nl
				add ebx, 4
				mov ecx, dword [peg2 + ebx]
				cmp ecx, 9
				je .printBase
				mov [count], dword 1
				jmp .printPeg
								
		.printBase:
			mov eax, base
			call print_string
			call print_nl
			ret

		;PRINTING ENDS HERE
;**************************************************************************************

	.hanoi:			;expects EAX = n, EBX = source, ECX = dest, EDX = by
		enter 0,0
		pusha
		mov eax, dword [ebp+20]
		mov ebx, dword [ebp+16]
		mov ecx, dword[ebp+12]
		mov edx, dword [ebp+8]


		cmp eax, dword 1
		je .return

		sub eax, dword 1
		push eax
		push ebx
		push edx
		push ecx
		call .hanoi
		add esp, 16
			

		push ebx
		push ecx
		call .moveDisk		
		add esp, 8
				

		push eax
		push edx
		push ecx
		push ebx
		call .hanoi
		add esp, 16
	
		jmp .exitHanoi

		.return:
			push ebx
			push ecx
			call .moveDisk
			add esp, 8
			jmp .exitHanoi

		.exitHanoi:
			popa
			leave
			ret
;*************************************************************************************************************************
	.moveDisk:
		enter 0,0
		pusha
		mov ebx, dword [ebp+12]
		mov ecx, dword [ebp+8]

		;first we need to find the number in the list
		mov edx, dword 0
		.findFirst:
			cmp [ebx+edx], dword 0
			jne .foundFirst
			add edx, dword 4
			jmp .findFirst
		.foundFirst:
			mov eax, dword [ebx+edx]
			mov [ebx+edx], dword 0
		mov edx, dword 0
		.findSecond:
			cmp [ecx+edx], dword 0
			jne .foundSecond
			add edx, dword 4
			jmp .findSecond
		.foundSecond:
			mov [ecx+edx-4], eax
		
		call read_char
		call .printTower

		popa
		leave
		ret
;*****************************************************************************************************************************


.outOfRange:
	mov eax, outRange
	jmp .done

.tooManyArguments:

	;in here we set exit to the message indicating too many arguments
	mov eax, wrongArgs
	jmp .done

.success:
	mov eax, victory
	jmp .done
.done:
	call print_nl
	call print_nl
	call print_string
	call print_nl
	popa
	leave
	ret
