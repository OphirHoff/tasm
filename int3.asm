IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
inputArea db 'xx1234x'
lineDown db 10, 13, '$'
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------


mov [byte inputArea], 5
mov dx, offset inputArea
mov ah, 0Ah
int 21h

mov ah, 9
mov dx, offset lineDown
int 21h

mov ah, 2
mov dl, [inputArea+5]
int 21h
mov dl, [inputArea+4]
int 21h
mov dl, [inputArea+3]
int 21h
mov dl, [inputArea+2]
int 21h
	
	
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


