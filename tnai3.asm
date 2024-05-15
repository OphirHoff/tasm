IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
num1 db 7
num2 db 4
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov bl, [num1]
cmp bl, [num2]
ja ABOVE
mov dx, 0
mov bl, dl
jmp CONT

ABOVE:
	mov dx, 1
	mov bl, dl		
CONT:
	mov ah, 2
	mov dl, [num1]
	add dl, '0'
	int 21h
	mov dl, [num2]
	add dl, '0'
	int 21h
	mov dl, bl
	add dl, '0'
	int 21h
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


