IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
sum db 0
cnt db 0
LineDown db 10, 13, '$'
pelet db "Bigger than 5: ", '$'
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov cx, 10
lp:
	mov ah, 1
	int 21h
	sub al, '0'
	add [sum], al
	cmp al, 5
	ja IncCnt
	loop lp
	jmp CONT
	IncCnt:
		inc [cnt]
		loop lp
		
CONT:
mov bl, 10
xor ax, ax
mov al, [sum]
div bl

mov bh, ah
mov ah, 9
mov dx, offset LineDown
int 21h

mov ah, 2
add al, '0'
mov dl, al
int 21h

mov dl, '.'
int 21h

add bh, '0'
mov dl, bh
int 21h

mov ah, 9
mov dx, offset LineDown
int 21h

mov ah, 9
mov dx, offset pelet
int 21h

mov ah, 2
add [cnt], '0'
mov dl, [cnt]
int 21h

; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


