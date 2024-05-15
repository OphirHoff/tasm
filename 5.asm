IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
array1 db 1,2,3,4
array2 db 4,3,2,1
array3 db ?,?,?,?
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov ah, [array1]
sub ah, [array2]
mov [array3], ah

mov ah, [array1+1]
sub ah, [array2+1]
mov [array3+1], ah

mov ah, [array1+2]
sub ah, [array2+2]
mov [array3+2], ah

mov ah, [array1+3]
sub ah, [array2+3]
mov [array3+3], ah

; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


