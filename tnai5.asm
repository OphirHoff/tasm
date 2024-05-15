IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
repsPelet db "Enter number of reps (1-9): $"
reps db ?
charPelet db "Enter a char: $"
char db ?
lineDown db 10, 13, '$'
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------

mov ah, 9
mov dx, offset repsPelet
int 21h

mov ah, 1
int 21h
sub al, '0'
mov [reps], al

mov ah, 9
mov dx, offset lineDown
int 21h

mov dx, offset charPelet
int 21h

mov ah, 1
int 21h
mov [char], al

mov ah, 9
mov dx, offset lineDown
int 21h

mov ah, 2
mov dl, [char]
mov cl, [reps]

MainLoop:
int 21h
loop MainLoop
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


