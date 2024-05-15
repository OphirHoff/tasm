IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
num1 db ?
num2 db ?
sign db ?
lineDown db 10, 13, '$'
errorMessage db "Error$"
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------

mov cx, 3
MainLoop:
	mov ah, 1 ;get first num and check if 1-3
	int 21h
	mov [num1], al
	sub [num1], '0'
	cmp [num1], 1
	jb ERRORM
	cmp [num1], 3
	ja ERRORM


	int 21h ;get operation
	mov [sign], al

	int 21h ; get second number
	mov [num2], al
	sub [num2], '0'
	cmp [num2], 1
	jb ERRORM
	cmp [num2], 3
	ja ERRORM


	cmp [sign], '+' ;check if add or mul
	je SUM

	cmp [sign], '*'
	jne ERRORM

	;multuply
	mov al, [num1]
	mov bl, [num2]
	mul bl
	mov bl, al
	add bl, '0'
	jmp PRINT

	JTM:
		jmp MainLoop ;code was too long so needed a support label for mainloop

	SUM: ;compute sum
		mov bl, [num1]
		add bl, [num2]
		add bl, '0'
		jmp PRINT

	ERRORM: ; error message
		mov ah, 9
		mov dx, offset lineDown
		int 21h
		mov dx, offset errorMessage
		int 21h
		mov dx, offset lineDown
		int 21h
		jmp MainLoop

	PRINT: ;print result
		mov ah, 2
		mov dl, '='
		int 21h
		mov dl, bl
		int 21h
		mov ah, 9
		mov dx, offset lineDown
		int 21h
		loop JTM
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


