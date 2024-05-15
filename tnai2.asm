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
mov ax, 0
cmp ax, 0
jge CONT

inc ax

CONT:
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


