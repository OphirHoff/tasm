IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
digPelet db "Enter dig: $"
lineDown db 10, 13,  '$'
num db ?
digMul db ?
equalM db "EQUAL$"
smallM db "SMALL$"
mediumM db "MEDIUM$"
bigM db "BIG$"
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov ah, 9
mov dx, offset digPelet
int 21h 
mov dx, offset lineDown
int 21h

xor ax, ax

mov ah, 1
int 21h ;Enter first digit
sub al, '0'
mov [digMul], al
mov bl, 10
mul bl
mov [num], al

mov ah, 9
mov dx, offset lineDown
int 21h
mov dx, offset digPelet
int 21h
mov dx, offset lineDown
int 21h

mov ah, 1
int 21h ;Entet second digit
sub al, '0'
add [num], al
mul [digMul]
mov [digMul], al

mov dx, offset lineDown
mov ah, 9
int 21h

cmp [num], 50
jbe SML
cmp [num], 75
jb MED
cmp [num], 75
je EQUAL

mov dx, offset bigM
mov ah, 9
int 21h ; BIG
jmp CONT

SML:
	mov dx, offset smallM
	mov ah, 9
	int 21h ; SMALL
	jmp CONT
	
MED:
	mov dx, offset mediumM
	mov ah, 9
	int 21h ;MEDIUM
	jmp CONT
	
EQUAL:
	mov dx, offset equalM
	mov ah, 9
	int 21h ;EQUAL
	

	
CONT: ;print multiplication of digits
mov dx, offset lineDown
mov ah, 9
int 21h

xor ax, ax
mov al, [digMul]
mov bl, 10
div bl

mov cl, al
add cl, '0'
mov ch, ah
add ch, '0'

cmp cl, 30h
je UNITS
mov ah, 2
mov dl, cl
int 21h

UNITS:
	mov ah, 2
	mov dl, ch
	int 21h
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
END start


