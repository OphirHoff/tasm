IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
triple dw ?
double db ?
inputPlace db "xx123456x"
pelet db "Please enter:$"
lineDown db 10, 13, '$'
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov dx, offset pelet
mov ah, 9
int 21h

mov dx, offset lineDown
int 21h

mov ah, 0Ah
mov [byte inputPlace], 7
mov dx, offset inputPlace
int 21h

mov bl, [inputPlace+2]
sub bl, '0'
mov al, 100d
mul bl
mov bx, ax

xor cx, cx

mov cl, [inputPlace+3]
sub cl, '0'
mov al, 10d
mul cl
add bx, ax

mov cl, [inputPlace+4]
sub cl, '0'
add bx, cx

mov ax, bx
mov bl, [inputPlace+6]
sub bl, '0'
div bl

mov ah, 9
mov dx, offset lineDown
int 21h

mov ah, 9
mov [inputPlace+8], '$'
mov dx, offset inputPlace+2
int 21h

mov bl, 10d
div bl
mov cl, al
mov ch, ah

mov bl, 10
div bl

mov cl, ah
mov ah, 2
add cl, '0'
mov dl, cl
int 21h
add al ,'0'
mov dl, al
int 21h

; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


