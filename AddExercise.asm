IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
nums db 1,2,3,4
sum dw ?
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------

xor ah, ah ; make ah 0
mov al, [nums]
add [sum], ax
mov al, [nums+1]
add [sum], ax
add al, [nums+2]
add [sum], ax
add al, [nums+3]
add [sum], ax

; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


