IDEAL
MODEL small
STACK 100h

DATASEG
	 
	 g    db 0dh,0ah ,72, 101, 108, 108, 111, 32, 72, 101
          db 114, 122, 111, 103, 32, 67, 121, 98
          db  101, 114, 32, 83, 116, 117, 100, 101
		  db 110, 116, 10, 89, 111, 117, 32
        
     
    bye1  db  121, 111, 117, 114, 32, 110, 97, 109
    bye2  db 101, 32, 115, 116, 97, 114, 116, 32
          db 119, 105, 116, 104, 32, 65, 76, 69
		  db 70, 32, 114, 105, 103, 104, 116, 32
          db 63, 10, 66, 121, 101, 32, 66, 121, 101, 10,13, 24h
		  
	 
	
   
CODESEG

start:

  
	mov ax, @data
	mov ds, ax
	
	mov dx, offset g
	mov ah,9
	int 21h
	
	
	mov ax, 0FFFFh
	add ax, 3
	
	; call ShowAxDecimal
	
    
exit:
	mov ax, 4c00h
	int 21h
	

	
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
