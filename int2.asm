IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
num1 db ?
num2 db ?
lineDown db 10, 13, "$"
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov ah, 1
int 21h
mov [num1], al

mov ah, 1
int 21h
mov [num2], al

mov ah, 9
mov dx, offset lineDown
int 21h

mov dl, [num1]
mov ah, 2
int 21h

mov dl, '*'
int 21h

mov dl, [num2]
int 21h

mov dl, '='
int 21h

sub [num1], '0'
sub [num2], '0'
mov al, [num2]
mul [num1]
add ax, '0'
mov dl, al
mov ah, 2
int 21h

mov dx, offset lineDown
mov ah, 9
int 21h
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


