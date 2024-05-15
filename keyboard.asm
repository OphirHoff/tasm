IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
rightM db "RIGHT$"
leftM db "LEFT $"
lineDown db 10, 13, '$'
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------

mov ax, 13h
int 10h

mov si, 0
Mainloop:

;print timer
mov ah, 2
mov bh, 0
mov dh, 0
mov dl, 0
int 10h

mov ax, si
call ShowAxDecimal
inc si

mov ah, 1
int 16h
jz Cont

mov ah, 0
int 16h
cmp ah, 4Dh
je Right
cmp ah, 4Bh
je Left
cmp ah, 1
je Exit

Right:
mov ah, 2
mov bh, 0
mov dh, 12
mov dl, 17
int 10h

mov ah, 9
mov dx, offset rightM
int 21h
jmp Cont

Left:
mov ah, 2
mov bh, 0
mov dh, 12
mov dl, 17
int 10h

mov ah, 9
mov dx, offset leftM
int 21h

Cont:
call LoopDelay1Sec
jmp mainLoop

Exit:

; --------------------------

exit:
	mov ax, 4c00h
	int 21h
	
	proc LoopDelay1Sec
	push cx
	mov cx ,1000 
	@@Self1:
	  push cx
	mov cx,3000
	@@Self2:	
	loop @@Self2
	pop cx
	loop @@Self1
	pop cx
	ret
endp LoopDelay1Sec


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
	
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal

	
END start


