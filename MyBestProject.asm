IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
Calc db "Calculator$"
EnterNum1 db "Enter First number:$"
EnterNum2 db "Enter second number:$"
result db "Result :$"
LineDown db 10, 13, '$'

num1 db ?
num2 db ?
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov dx, offset Calc
mov ah, 9
int 21h

mov dx, offset LineDown
mov ah, 9
int 21h

mov dx, offset EnterNum1
mov ah, 9
int 21h

mov ah, 1
int 21h
mov [num1], al

mov dx, offset LineDown
mov ah, 9
int 21h

mov dx, offset EnterNum2
mov ah, 9
int 21h

mov ah, 1
int 21h
mov [num2], al

mov dx, offset LineDown
mov ah, 9
int 21h

mov dx, offset result
mov ah, 9
int 21h

mov ah, 2
mov dl, [num1]
int 21h

mov ah, 2
mov dl, [num2]
int 21h
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


