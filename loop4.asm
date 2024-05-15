IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
lines db ?
columns db ?
lineDown db 10, 13, '$'
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov ah, 1
int 21h
sub al, '0'
mov [lines], al ;קליטת מס שורות

mov ah, 1
int 21h
sub al, '0'
mov [columns], al ; קליטת מס עמודות

mov ah, 9
mov dx, offset lineDown
int 21h

xor cx, cx
mov cl, [lines]
LinesLoop:
	mov bx, cx
	mov cl, [columns]
	ColumnsLoop:
		mov dl, 'X'
		mov ah, 2
		int 21h ; print x columns times
		loop ColumnsLoop
	
	mov ah, 9
		mov dx, offset lineDown
		int 21h ; line down
	
	mov cx, bx
	loop LinesLoop
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


