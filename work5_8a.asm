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
mov [cs:05], 0fec4h
mov [cs:01], 0fec4h
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


