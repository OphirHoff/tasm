IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
FileName db "scores.txt" ,0
FileHandle dw ?

playerName db "75Ophirx"
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov al,2
mov ah,3dh
mov dx,offset FileName
int 21h
mov [FileHandle],ax

mov ah, 40h
mov bx, [FileHandle]
mov dx, offset playerName+2
xor cx, cx
mov cl, [playerName+1]
sub cl, '0'
int 21h
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


