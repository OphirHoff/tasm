IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
;תרגיל רשות ניקוי מסך
mov ax, 0B800h
mov es, ax
mov cx, 2000
mov ah, 00000000b
mov al, ' '
mov di, 0

clear:
	mov [es:di], ax
	add di, 2
	loop clear

;תרגיל 1
mov ax, 0B800h
mov es, ax
mov di, 1990
mov ah, 10000100b

mov al, 'O'
mov [es:di], ax

mov al, 'p'
add di, 2
mov ah, 10000001b
mov [es:di], ax

mov al, 'h'
add di, 2
mov ah, 10000101b
mov [es:di], ax

mov al, 'i'
add di, 2
mov ah, 10001011b
mov [es:di], ax

mov al, 'r'
add di, 2
mov ah, 10000111b
mov [es:di], ax

;תרגיל 2
mov al, 'I'
mov di, 3970
mov ah, 00110001b
mov [es:di], ax

mov al, "'"
add di, 2
mov [es:di], ax

mov al, 'm'
add di, 2
mov [es:di], ax

mov al, ' '
add di, 2
mov [es:di], ax

mov al, 'u'
add di, 2
mov [es:di], ax

mov al, 's'
add di, 2
mov [es:di], ax

mov al, 'i'
add di, 2
mov [es:di], ax

mov al, 'n'
add di, 2
mov [es:di], ax

mov al, 'g'
add di, 2
mov [es:di], ax

mov al, ' '
add di, 2
mov [es:di], ax

mov al, 'B'
add di, 2
mov [es:di], ax

mov al, '8'
add di, 2
mov [es:di], ax

mov al, '0'
add di, 2
mov [es:di], ax

mov al, '0'
add di, 2
mov [es:di], ax

mov al, '0'
add di, 2
mov [es:di], ax

;תרגיל 3
mov al, 'A'
mov di, 3840
mov [es:di], ax

mov al, 't'
add di, 2
mov [es:di], ax

mov al, 't'
add di, 2
mov [es:di], ax

mov al, 'a'
add di, 2
mov [es:di], ax

mov al, 'c'
add di, 2
mov [es:di], ax

mov al, 'k'
add di, 2
mov [es:di], ax


; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


