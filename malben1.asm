IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
LineDown db 10, 13, '$'
addition db 1
EnterHeight db "Enter height: $"
EnterWidth db "Enter Width: $"

side1 db ?
side2 db ?
side3 db ?
yesM db "Yes$"
NoM db "No$"
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
	


; --------------------------
; call EightBySix
; call LuahKefel

; mov ah, 9
; mov dx, offset EnterHeight
; int 21h

; mov ah, 1
; int 21h
; mov bh, al

; mov dx, offset LineDown
; mov ah, 9
; int 21h

; mov dx, offset EnterWidth
; int 21h

; mov ah, 1
; int 21h
; mov bl, al

; mov ah, 9
; mov dx, offset LineDown
; int 21h

; mov ah, bh
; mov al, bl

; sub al, '0'
; sub ah, '0'



; call PrintRectStar

mov [side1], 30
mov [side2], 40
mov [side3], 50
call PythTriple
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
	
proc EightBySix
	
	mov cx, 6
	MainLoop:
	push cx
	mov cx, 8
	InnerLoop:
	mov dl, '*'
	mov ah, 2
	int 21h
	loop InnerLoop
	mov dx, offset LineDown
	mov ah, 9
	int 21h
	pop cx
	loop MainLoop

	ret
endp EightBySix
;-------------------------------

proc LuahKefel
	
	mov cx, 10
	IncAddition:
	push cx
	mov cx, 10
	mov ax, 0
	PrintSer:
	add al, [addition]
	call ShowAxDecimal
	loop PrintSer
	mov dx, offset LineDown
	mov ah, 9
	int 21h
	pop cx
	inc [addition]
	loop IncAddition
	
	ret
endp LuahKefel

;------------------------------------
proc PrintRectStar
	
	mov bl, al
	mov bh, ah
	
	mov cl, bh
	Mloop:
	push cx
	mov cl, bl
	PrintLoop:
	mov dl, '*'
	mov ah, 2
	int 21h
	loop PrintLoop
	mov dx, offset LineDown
	mov ah, 9
	int 21h
	pop cx
	loop Mloop
	
	ret
endp PrintRectStar

;------------------------------------------
proc PythTriple

	mov al, [side1]
	mul [side1]
	mov bl, al
	mov al, [side2]
	mul [side2]
	add bl, al
	mov al, [side3]
	mul [side3]
	cmp al, bl
	je PrintYes
	
	mov al, [side1]
	mul [side1]
	mov bl, al
	mov al, [side3]
	mul [side3]
	add bl, al
	mov al, [side2]
	mul [side2]
	cmp al, bl
	je PrintYes
	
	mov al, [side2]
	mul [side2]
	mov bl, al
	mov al, [side3]
	mul [side3]
	add bl, al
	mov al, [side1]
	mul [side1]
	cmp al, bl
	je PrintYes
	
	jmp PrintNo
	
	PrintYes:
	mov dx, offset yesM
	mov ah, 9
	int 21h
	jmp cont
	
	PrintNo:
	mov dx, offset NoM
	mov ah, 9
	int 21h
	cont:

	ret
endp PythTriple



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


