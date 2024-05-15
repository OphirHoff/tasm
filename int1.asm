IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
num1 db ?
num2 db ?
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov ah, 1
int 21h
sub al, '0'
mov [num1], al

mov ah, 1
int 21h
sub al, '0'
mov [num2], al


mov al, [num2]
mul [num1]
add ax, '0'
mov dl, al
mov ah, 2
int 21h
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


