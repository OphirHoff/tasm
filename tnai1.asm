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
mov ax, 51

cmp ax, 50
jb CONT

mov bl, 2
mul bl

CONT:


; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


