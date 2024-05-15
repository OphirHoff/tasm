IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
matrix1 db 3, 0, 0, 0, 3
		db 0, 3, 3, 3, 0
		db 0, 3, 3, 3, 0
		db 0, 3, 3, 3, 0
		db 3, 0, 0, 0, 3
		
matrix dw ?
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov ax, 13h
int 10h

push 0A000h
pop es

mov cx, 5
mov dx, 5
mov di,160 + 320 * 3
mov bx, offset matrix1
mov [matrix], bx

call putMatrixInScreen
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
	

	
	proc PutMatrixInScreen

	cld ;sets direction of movsb to copy forward
	mov si,[matrix] ; puts offset of the Matrix to si
	NextRow:	; loop of cx lines
		push cx ;saves cx of loop
		mov cx, dx ;sets cx for movsb
		rep movsb ; Copy whole line to the screen, si and di increases
		sub di,dx ; returns back to the begining of the line 
		add di, 320 ;go down one line in “screen” by adding 320
		pop cx  ;restores cx of loop
		loop NextRow
	
	ret
endp PutMatrixInScreen
	
	
END start


