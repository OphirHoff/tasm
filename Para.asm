IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
arr db 3,6,1,5,7,0,2
LineDown db 10, 13, '$'
trash dw ?
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; push offset arr
; push 7
; call Ex1


; push 3
; push 4
; push 5
; call Ex2
; pop ax
; call ShowAxDecimal

; push 7
; call Ex3A

; push 28
; call Ex3D

; push offset arr
; push 7
; call Ex4

; push offset arr
; push 7
; call Ex1

push offset arr
push 7
call Ex1
push 7
push offset arr
call Ex5
push offset arr
push 7
call Ex1
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
	
	proc Ex1
	
	push bp
	mov bp, sp
	push cx
	push si
	push ax
	push bx
	push dx
	
	mov dl, [bp+4]
	add dl, '0'
	mov ah, 2
	int 21h
	
	mov dx, offset LineDown
	mov ah, 9
	int 21h
	
	mov cx, [bp+4]
	mov bx, [bp+6]
	mov si, 0
	loop1:
	xor ax, ax
	mov al, [bx + si]
	call ShowAxDecimal
	inc si
	loop loop1
	
	pop dx
	pop bx
	pop ax
	pop si
	pop cx
	
	pop bp
	

	ret
	endp Ex1
	
;---------------------

Z equ [bp+4]
Y equ [bp+6]
X equ [bp+8]

Xsquared equ [bp-2]
Ysquared equ [bp-4]
Zsquared equ [bp-6]

proc Ex2

	push bp
	mov bp, sp
	sub sp, 6
	push ax
	
	xor ax, ax
	
	mov ax, X
	mul X
	mov Xsquared, ax
	
	mov ax, Y
	mul Y
	mov Ysquared, ax
	
	mov ax, Z
	mul Z
	mov Zsquared, ax
	
	mov ax, Ysquared
	add ax, Xsquared
	cmp ax, Zsquared
	je TRUE
	
	pop [trash]
	
	FALSE:
	mov ax, 0
	jmp CONT
	
	TRUE:
	mov ax, 1
	
	CONT:
	pop [trash]
	add sp, 6
	pop bp
	push ax

	ret 6
endp Ex2

;------------------------

num equ [bp+4]

proc Ex3A

	push bp
	mov bp, sp
	push ax
	push cx
	push dx

	
	mov bx, 2
	mov ax, num
	mov cl, 2
	div cl
	xor ah, ah
	mov cx, ax
	PrimeCheck:
	xor ax, ax
	mov ax, num
	div bx
	cmp dx, 0
	je @@CONT
	inc bx
	loop PrimeCheck
	
	mov ax, num
	call ShowAxDecimal
	
	@@CONT:
	pop dx
	pop cx
	pop ax
	pop bp

	ret
endp Ex3A

;--------------------

sum equ [bp-2]
num equ [bp+4]

proc Ex3B

	push bp
	
	mov bp, sp
	sub sp, 2
	
	push bx
	push cx
	push dx
	
	
	mov sum, 0
	mov bl, 1
	mov cx, num
	dec cx
	Devide:
	mov ax, num
	div bl
	cmp ah, 0
	jne @@CONT
	add sum, bx
	

	@@CONT:
	inc bx
	loop Devide

	mov ax, num
	cmp sum, ax
	jne finish
	
	call ShowAxDecimal


	finish:
	pop dx
	pop cx
	pop bx
	add sp, 2
	pop bp

	ret 2
endp Ex3B

;-----------------
num equ [bp+4]

proc Ex3C

	push bp
	mov bp, sp
	push si
	push cx
	
	mov si, 1
	mov cx, num
	GoOver:
	push si
	call Ex3A
	pop si
	inc si
	loop GoOver

	pop cx
	pop si
	pop bp

	ret
endp Ex3C
;----------------------
num equ [bp+4]

proc Ex3D

	push bp
	mov bp, sp
	sub bp, 2
	push si
	push cx
	
	mov si, 2
	mov cx, num
	FindPerfect:
	push si
	call Ex3B
	;pop si
	inc si
	loop FindPerfect

	pop cx
	pop si
	pop bp

	ret
endp Ex3D

;------------------------

arrOffset equ [bp+6]
len equ [bp+4]
minOffset equ [bp-2]

proc Ex4
	
	push bp
	mov bp, sp
	sub sp, 2
	push si
	push bx
	push cx
	push dx
	push di
	
	mov si, arrOffset
	mov bl, [si] ; min
	mov minOffset, si
	mov si, arrOffset ; arr index
	mov cx, len
	FindMin:
	inc si
	mov dl, [si]
	cmp dl, bl
	jnb @@CONT
	mov bl, dl
	mov minOffset, si
	
	@@CONT:
	loop FindMin
	
	mov si, arrOffset
	mov bl, [si]
	xor di, di
	mov di, minOffset
	mov cl, [di]
	mov [si], cl
	mov [di], bl
	
	pop di
	pop dx
	pop cx
	pop bx
	pop si
	add sp, 2
	pop bp
	
	ret 2
endp Ex4

;------------------------

arrOffset equ [bp+4]
len equ [bp+6]

proc Ex5

	push bp
	mov bp, sp
	push si
	push cx
	
	
	mov si, arrOffset
	mov cx, len
	Sort:
	push si
	push cx
	call Ex4
	pop si
	inc si
	loop Sort
	
	pop cx
	pop si
	pop bp
	

	ret
endp Ex5

;------------------------
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
		
	   mov dl, ','
       mov ah, 2h
	   int 21h
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal
	
END start


