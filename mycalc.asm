IDEAL
MODEL small
STACK 100h


MACRO SHOW_STR  SomeStr
	mov dx, offset SomeStr
	mov ah,9
	int 21h
ENDM


DATASEG
 
	insNum1 db 10,13,"Pls enter first num $"
	insNum2 db 10,13,"Pls enter second num $"
	theRes db  10,13,"The Result is:$"
	NewLine db  10,13,'$'
	PressKey db  10,13,'Press Key To Continue ... $'

	num1 dw ?
	num2 dw ?
	result dw ?

	select dw ?

	input db "12345678"

	menu  db 10,10,10,13
		  db "0 add",10,13
		  db "1 sub",10,13
		  db "2 mul",10,13
		  db "3 div",10,13
		  db "4 mod",10,13
		  db "9 for exit",10,13
		  db "Pls Select Operation ... > ",'$'
	  
	Funcs dw add2Num, sub2Num, mul2Num, div2Num, mod2Num

	
CODESEG
 
start:                          
	    mov ax,@data			 
		mov ds,ax				 
		
		SHOW_STR insNum1
		call InputWord
		mov [num1],ax
		
		SHOW_STR insNum2
		call InputWord
		mov [num2],ax
		
ag:	
		SHOW_STR menu
		 
        call InputWord
		mov [select],ax
		
		cmp [word select],4
		ja exit
		
		
		mov si,[select]
		shl si,1 ; each func pointer is word
		
		
		mov bx, offset Funcs
		add bx , si
		call [word bx]  ; execute function pointer
		
		
		SHOW_STR theRes
		mov ax, [result]
		call ShowAxDecimal
		
		
		SHOW_STR PressKey
		mov ah,00h ; press any key
        int 16h
		
		jmp ag
		
		
	 
	 
 

 
exit:	
	mov ax,4C00h
    int 21h

	
	
; input None
; output ax with word from keyboard
proc InputWord
stop:
	mov ah,0ah
	mov dx, offset input
	mov [byte input], 6
	int 21h
	
	mov si, offset input + 2
	call ConvertStringToNum
	
	
	ret
endp	InputWord
	
	
	
proc add2Num
	push ax
	
	mov ax,[num1]
	add ax,[num2]
	mov [Result],ax
		
	
	pop ax
	ret
endp add2Num


proc sub2Num
	push ax
	
	mov ax,[num1]
	sub ax, [num2]
	mov [Result],ax
		
	
	pop ax
	ret
endp sub2Num


proc mul2Num
	push ax
	
	mov ax,[num1]
	mul [num2]
	mov [Result],ax
		
	
	pop ax
	ret
endp mul2Num
 


proc div2Num
	push ax
	push dx
	cmp [num2],0
	je @@ret
	
	mov dx,0
	mov ax,[num1]
	div [num2]
	mov [Result],ax

@@ret:	
	pop dx
	pop ax
	ret
endp div2Num


proc mod2Num
	push ax
	push dx
	cmp [num2],0
	je @@ret
	
	mov dx,0
	mov ax,[num1]
	div [num2]
	mov [Result],dx
	
@@ret:			
	pop dx
	pop ax
	ret
endp mod2Num




;================================================
; Description - Convert String to Integer16 Unsigned
;             - Any number from 0 - 64k -1 
; INPUT:  si string offset
; OUTPUT: ax number 
; Register Usage: AX 
;================================================
 proc ConvertStringToNum 
    push si
    push di
	push dx
	push bx
	
	 
	mov di,10
	xor ax, ax
	mov bx ,0
	
@@NextDigit:
    mov bl, [si]   ; read next ascii byte
	cmp bl,13  ; stop condition
	je @@ret
	mul di
	sub bl, '0'
	add ax , bx
	jc @@ret

	inc si
	jmp @@NextDigit
	 
@@ret:
	pop bx
	pop dx
	pop di
	pop si
	
	ret
endp ConvertStringToNum 




proc ShowAxDecimal
       push ax
	   push bx
	   push cx
	   push dx
	   jmp PositiveAx
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