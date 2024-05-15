IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
myNums db 101, 130, 30, 201, 120, -3, 100, 255, 0
sum dw 0
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov si, 0

lp:
	cmp [myNums + si], 100
	jg AddSum
	jmp CONT
	
	AddSum:
		mov bl, [myNums + si]
		add [byte sum], bl
		
	CONT:
		inc si
		cmp [myNums + si], 0
		jne lp
	
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


