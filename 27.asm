IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
msg db 'Hello World!$'
key db 0B8h
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov ah, [key]
mov bx, 0
mov cx, 13
;הצפנה
encode:
	xor [bx], ah
	inc bx
	loop encode

; print msg
mov	dx, offset msg
mov	ah, 9h
int	21h
mov	ah, 2	
; new line
mov	dl, 10	
int	21h	
mov	dl, 13
int	21h

;פענוח
mov bx, 0
mov ah, [key]
mov cx, 13
decode:
	xor [bx], ah 
	inc bx
	loop decode

; print msg
mov	dx, offset msg
mov	ah, 9h
int	21h
mov	ah, 2	
; new line
mov	dl, 10	
int	21h	
mov	dl, 13
int	21h

; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


