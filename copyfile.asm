IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
FileAName db "a.txt$", 0
FileAHandle dw ?
FileBName db "b.txt$", 0
FileBHandle dw ?

digit db ?
sign db '&'
ErrorM db "Error$"
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov ah, 3Dh
mov al, 2
mov dx, offset FileAName
int 21h
jc ERROR
mov [FileAHandle], ax

mov ah, 3Dh
mov al, 2
mov dx, offset FileBName
int 21h
jc ERROR
mov [FileBHandle], ax

mov ah, 42h
mov bx, [FileAHandle]
mov al, 2
mov cx, 0
mov dx, 0
int 21h
mov cx, ax

push cx
mov ah, 42h
mov bx, [FileAHandle]
mov al, 0
mov cx, 0
mov dx, 0
int 21h
pop cx

CopyLoop:
push cx

mov dx, offset digit
mov bx, [FileAHandle]
mov cx, 1
mov ah, 3Fh
int 21h

cmp [digit], '0'
jb WriteSign
cmp [digit], '9'
ja WriteSign

mov dx, offset digit
mov bx, [FileBHandle]
mov cx, 1
mov ah, 40h
int 21h

jmp CONT

WriteSign:
mov dx, offset sign
mov bx, [FileBHandle]
mov cx, 1
mov ah, 40h
int 21h
jmp CONT

ERROR:
mov dx, offset ErrorM
mov ah, 9
int 21h

CONT:

pop cx
loop CopyLoop






; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


