IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
a dw ?
b dw ?
saveOffset dw ?
LineDown db 10, 13, '$'

side1 dw ?
side2 dw ?
side3 dw ?
YesMessage db "Yes$"
NoMessage db "no$"

num1 db 10
num2 db 20
x db 3
y db 5

arr1 db 7,5,2,10,6,3,8
arr2 db 11,3,2,19,5
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; push 7
; push 6

; call Rect

; push 40
; push 30
; push 50

; call RightTriangle

; ;call Method on num1 & num2
; xor ax, ax
; mov al, [num1]
; call ShowAxDecimal
; xor ax, ax
; mov al, [num2]
; call ShowAxDecimal


; push offset num1
; push offset num2
; call SwapValues

; xor ax, ax
; mov al, [num1]
; call ShowAxDecimal
; xor ax, ax
; mov al, [num2]
; call ShowAxDecimal

; ;call method on x&y
; xor ax, ax
; mov al, [x]
; call ShowAxDecimal
; xor ax, ax
; mov al, [y]
; call ShowAxDecimal


; push offset x
; push offset y
; call SwapValues

; xor ax, ax
; mov al, [x]
; call ShowAxDecimal
; xor ax, ax
; mov al, [y]
; call ShowAxDecimal

push offset arr1
push 7
call MaxValue

push offset arr2
push 5
call MaxValue

; --------------------------

exit:

	mov ax, 4c00h
	int 21h
	

proc Rect
	
	pop [saveOffset]
	
	pop [a]
	pop [b]
	
	mov cx, [a]
	RectLoop:
	push cx
	mov cx, [b]
	RectInLoop:
	mov dl, '*'
	mov ah, 2
	int 21h
	loop RectInLoop
	pop cx
	mov dx, offset LineDown
	mov ah, 9
	int 21h
	loop RectLoop

	push [saveOffset]

	ret
endp Rect

;--------------------------------

proc RightTriangle

	pop [saveOffset]
	
	pop [side1]
	pop [side2]
	pop [side3]
	
	mov ax, [side1]
	mul [side1]
	mov bl, al
	mov ax, [side2]
	mul [side2]
	add bl, al
	mov ax, [side3]
	mul [side3]
	cmp al, bl
	je PrintYes
	
	mov ax, [side1]
	mul [side1]
	mov bl, al
	mov ax, [side3]
	mul [side3]
	add bl, al
	mov ax, [side2]
	mul [side2]
	cmp al, bl
	je PrintYes
	
	mov ax, [side2]
	mul [side2]
	mov bl, al
	mov ax, [side3]
	mul [side3]
	add bl, al
	mov ax, [side1]
	mul [side1]
	cmp al, bl
	je PrintYes
	
	jmp PrintNo
	
	PrintYes:
	mov dx, offset yesMessage
	mov ah, 9
	int 21h
	jmp CONT
	
	PrintNo:
	mov dx, offset NoMessage
	mov ah, 9
	int 21h
	CONT:
	
	push [saveOffset]

	ret
endp RightTriangle

;----------------

proc SwapValues

	pop [saveOffset]
	
	pop si
	pop bx
	
	mov ch, [si]
	mov dh, [bx]
	
	mov cl, ch
	mov ch, dh
	mov dh, cl
	
	mov [si], ch
	mov [bx], dh
	
	push [saveOffset]

	ret
endp SwapValues

;----------------------

proc MaxValue

	pop [saveOffset]
	
	pop cx ; length of array
	pop bx ; offset of array
	xor ax, ax
	mov al, 0 ; Max value
	mov si, 0 ; current index
	loop4:
	cmp [bx + si], al
	ja NewMax
	jmp CONT4
	
	NewMax:
	mov al, [bx + si]
	
	CONT4:
	inc si
	loop loop4
	
	call ShowAxDecimal
	
	push [saveOffset]

	ret
endp MaxValue



;-------------------------------------
proc ShowAxDecimal
   push ax
   push bx
   push cx
   push dx
   
   ; check if negative
   test ax,08000h
   jz PositiveAx
		
   ;  put '-' on the screen
   push ax
   mov dl,'-'
   mov ah,2
   int 21h
   pop ax

   neg ax ; make it positive
PositiveAx:
   mov cx,0   ; will count how many time we did push 
   mov bx,10  ; the divider

put_mode_to_stack:
   xor dx,dx
   div bx
   add dl,30h
   ; dl is the current LSB digit 
   ; we cant push only dl so we push all dx
   push dx    
   inc cx
   cmp ax,9   ; check if it is the last time to div
   jg put_mode_to_stack

   cmp ax,0
   jz pop_next  ; jump if ax was totally 0
   add al,30h  
   mov dl, al    
   mov ah, 2h
   int 21h        ; show first digit MSB
	   
pop_next: 
   pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
   mov dl, al
   mov ah, 2h
   int 21h        ; show all rest digits
   loop pop_next
	
   mov dl, ' '
   mov ah, 2h
   int 21h

   pop dx
   pop cx
   pop bx
   pop ax
	   
   ret
endp ShowAxDecimal

END start


