IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------

; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov bx, 30h
mov dx, [bx]
add bx, 2h
mov cx, [bx]
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


