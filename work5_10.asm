IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
num1 db 10
num2 db 20
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
xor ax, ax
mov al, [num1]
add al, [num2]
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


