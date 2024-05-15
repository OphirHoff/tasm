IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
InputArea db "xx01234567890123456789x"
FileName db "names.txt$", 0
FileHandle dw ?
LineDown db 10, 13, '$'
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
mov [FileHandle], ax
mov [byte InputArea], 21

GetName:
MOV dx, offset InputArea
mov ah, 0Ah
int 21h
cmp [InputArea+2], "e"
jne Write
cmp [InputArea+3], "n"
jne Write
cmp [InputArea+4], "d"
je CONT

Write:
mov dx, offset InputArea+2
mov bx, [FileHandle]
xor cx, cx
mov cl, [InputArea+1]
mov ah, 40h
int 21h

; move line down in file
mov dx, offset LineDown
mov bx, [FileHandle]
mov cx, 2
mov ah, 40h
int 21h


mov dx, offset LineDown
mov ah, 9
int 21h

jmp GetName

CONT:
mov ah, 3Eh
mov bx, [FileHandle]
int 21h

; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


