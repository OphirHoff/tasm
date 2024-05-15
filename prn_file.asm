IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
FileName db "a.txt", 0
FileHandle dw ?
Content db 10 dup (?)
ErrorM db "Error$"
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov al, 2
mov ah, 3Dh
mov dx, offset FileName
int 21h
jc Error
mov [FileHandle], ax


mov dx, offset Content
mov bx, [FileHandle]
mov si, 0
ReadLoop:
mov cx, 1
mov ah, 3Fh
int 21h
push dx
mov dl, [Content+si]
mov ah, 2
int 21h
pop dx
cmp [Content+si], '>'
je CONT
inc si
inc dx
jmp ReadLoop


Error:
mov ah, 9
mov dx, offset ErrorM
int 21h

CONT:


; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


