IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
bigStr db "xx1234x"
smallStr db "xxxx$"
lineDown db 10, 13, '$'
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov ah, 0Ah
mov [byte bigStr], 5
mov dx, offset bigStr
int 21h

mov ah, 9
mov dx, offset lineDown
int 21h

mov bl, [bigStr+2]
mov [smallStr], bl
or [smallStr], 100000b
mov bl, [bigStr+3]
mov [smallStr+1], bl
or [smallStr+1], 100000b
mov bl, [bigStr+4]
mov [smallStr+2], bl
or [smallStr+2], 100000b
mov bl, [bigStr+5]
mov [smallStr+3], bl
or [smallStr+3], 100000b

mov ah, 9
mov dx, offset smallStr
int 21h 	





; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


