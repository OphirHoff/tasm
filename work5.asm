IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
firstName db "Ophir"
age db 15
age2 dw 15
lastName db "Hoffman"

myArray dw 40 dup(0A504h)
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov bx, 0bfddh

mov al, bh
mov ah, bl
mov bx, ax

mov ch, [16h]
mov [6], ch

mov dh, [05]
mov dl, [03]
mov [03], dh
mov [05], dl

mov [byte ds:01], 41h

mov [byte 16], 11110000b

mov [byte ptr 0ah], 240

mov [byte ptr 0bh], -16

mov al, [byte ds:100h]

mov [byte ds:101h], 0AAh

mov al, [ds:50h]
mov ch, [ds:50h]

mov bx, 30h
mov dx, bx

mov al, [lastName]
mov [30h], al
mov al, [lastName+1]
mov [31h], al
mov al, [lastName+2]
mov [32h], al
mov al, [lastName+3]
mov [33h], al
mov al, [lastName+4]
mov [34h], al
mov al, [lastName+5]
mov [35h], al
mov al, [lastName+6]
mov [36h], al

; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


