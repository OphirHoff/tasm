IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
enterNum db "Please enter a number 0-8", 10, 13, "$"
num db ?
enterName db "Please enter your name", 10, 13, "$"
nameInput db "xx12345x"
newLine db 10, 13, "$"
result db "Your grade is$"
space db " $"
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov dx, offset enterNum
mov ah, 9
int 21h

mov ah, 1
int 21h
inc al
mov [num], al

mov dx, offset newLine
mov ah, 9
int 21h

mov dx, offset enterName
mov ah, 9
int 21h

mov [byte nameInput], 6
mov dx, offset nameInput
mov ah, 0Ah
int 21h

mov [byte nameInput + 7], "$"

mov dx, offset newLine
mov ah, 9
int 21h

mov ah, 9
mov dx, offset nameInput+2
int 21h

mov ah, 2
mov dl, " "
int 21h

mov ah, 9
mov dx, offset result
int 21h

mov ah, 2
mov dl, " "
int 21h

mov ah, 2
mov dl, [num]
int 21h



; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


