IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
A db 40
B db 20
C db 30
t db ?
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
xor ax, ax
mov al, [A]
add al, [B]
sub al, [C]

mov [byte t], al

; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


