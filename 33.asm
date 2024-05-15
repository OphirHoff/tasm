IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov al, 3
shl al, 2

mov al, 120
shr al, 3

mov al, 10
shl al, 4
mov bl, al
mov al, 10
shl al, 2
add al, bl
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


