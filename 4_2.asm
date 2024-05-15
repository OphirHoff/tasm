IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
var1 db 30
var2 db 20
sum db ?
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov ah, [var1]
add ah, [var2]
mov [sum], ah
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


