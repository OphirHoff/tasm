IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
FileName db "score.txt", 0
FileHandle dw ?
letter db ?
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov al, 2
mov ah, 3dh
mov dx, offset FileName
int 21h
jc ErrorM
mov [FileHandle], ax

ReadName:
mov bx, [FileHandle]
mov cx, 10
mov dx, offset letter
int 21h
mov ah, 2
mov dl, [letter]
int 21h
loop ReadName


ErrorM:
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


