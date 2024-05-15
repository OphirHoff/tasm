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
mov al, 0FFh
mov ah, 01h
add al, ah
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


