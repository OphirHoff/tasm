IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
numbers db 1,2,3,4
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov ah, [byte numbers]
add ah, [byte numbers+1]
add ah, [byte numbers+2]
add ah, [byte numbers+3]
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


