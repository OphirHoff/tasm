;
; here write your ID. DOnt forget the name of the file should be your id . asm
; ID  = 217395094

; For tester:
; Tester name = 
; Tester Total Grade = 

 
;---------------------------------------------
; 
; Skelatone Solution for Chapter 8 Work
;  
;----------------------------------------------- 


IDEAL

MODEL small

	stack 256
DATASEG
		 
		 ; Ex1 Variables 
		  letters db 13 dup(?)

		  
		 ; Ex2 Variables 
		   numbers db 10 dup (?)
		 
		 
		 ; Ex3 Variables 
		   digits db 10 dup (?) ; 31ds

		 ; Ex4 variables
	       array4 db 101 dup (?) ;132

		 ; Ex5 variables
		   BufferFrom5 db 3, 5, 10, 40, 7, 23, 15, 19, 22, 50
		   BufferTo5 db 10 dup (?)
		 
		 ; Ex6 variables
		   BufferFrom6 db 10 dup (5), 10 dup (15), 10 dup (-7), 10 dup (20), 10 dup (5)
		   BufferTo6 db 50 dup (?)
		   BufferTo6Len db 0
		 
		 ; Ex7a variables
		   MyLine7 db 1, 3, 6, 10, 8, 12, 17, 0Dh
		   Line7Length db ?
		   
		 ; Ex7b variables
		   MyWords7 dw 0F7D8h, 0A32Bh, 0ABCDh, 042E5h, 0DDDEh, 0DDDDh
		   MyWords7Length db ?
		   
		 ; Ex8 variables
		   MyQ8 db 101, 130, 30, 201, 120, -3, 100, 255, 0
		   sum8 dw 0
		   
		 ; Ex9 variables
		   MySet9 dw 0F7D8h, 0A32Bh, 0ABCDh, 0, 0DDDEh, 0FFFFh
		   count1 db 0
		   count2 db 0
		   count3 db 0
		   
		 ; Ex11 variables
		    EndGates11 db 00011001b
			BothFalse db "Both 7 and 8 are false$"
			OneIsTrue db "at least one of the bits 7 , 8  - true$"
			LineDown db 10, 13, '$' ; 372d
		 
		 ; Ex13 Variables
		   String13 db "926!"
		   WordNum13 dw 0
		 
		 
CODESEG

start:
		mov ax, @data
		mov ds,ax

		; next 5 lines: example how to use ShowAxDecimal (you can delete them)
		; mov al, 73
		; mov ah,0
		; call ShowAxDecimal		 
		; mov ax, 0ffffh
		; call ShowAxDecimal

		

		; call ex1
	 
		; call ex2
	 
		; call ex3
	 
		; call ex4
	 
		; call ex5
	 
		; call ex6
	 
		; call ex7a
		
		; call ex7b
	 
		; call ex8
	 
		; call ex9
	 
		;call ex10
	 
		; call ex11
	 
		; call ex12
	 
		; call ex13
	    
		; call ex14a
		
		; call ex14b
		
		; call ex14c
	 
		 ;mov ax, 0F70Ch  
 		;call ex14c     ; this will call to ex14b and ex14a
	 
	 
	 
	 

exit:
		mov ax, 04C00h
		int 21h

		
		
;------------------------------------------------
;------------------------------------------------
;-- End of Main Program ... Start of Procedures 
;------------------------------------------------
;------------------------------------------------





;================================================
; Description -  Move 'a' -> 'm'  to variable at DSEG 
; INPUT: None
; OUTPUT: array on Dataseg name : letters
; Register Usage: bl, si, cx (for loop)
;================================================
proc ex1

    mov bl, 61h ; letter ascii counter (starts from 61h => a)
	mov si, 0 ; index on dataseg
	mov cx, 13 ; repeat 13 times
	@@lp:
		mov [letters + si], bl
		inc si
		inc bl
		loop @@lp

    ret
endp ex1
;================================================
; Description -  mov digits (ascii) 0=>9 to dataSeg
; INPUT:  None
; OUTPUT:  array on dataseg name: numbers
; Register Usage:  bl, si, cx
;================================================
proc ex2
    
	mov bl, 30h ; digits ascii counter (starts from 30h => 0)
	mov si, 0
	mov cx, 10
	@@lp:
		mov [numbers + si], bl
		inc si
		inc bl
		loop @@lp
	
    ret
endp ex2




;================================================
; Description: store values 0-9 in dataSeg
; INPUT: none
; OUTPUT:  array on dataSeg name: digits
; Register Usage: 
;================================================
proc ex3
	  mov si, 0
	  mov bl, 0
	  mov cx, 10
	loop3:
		mov [digits + si], bl
		inc si
		inc bl
		loop loop3

	  
    ret
endp ex3




;================================================
; Description: mov 0CCh to every odd or divisible by 7 place in array4
; INPUT:  none
; OUTPUT:  array4 on dataseg
; Register Usage: si (index), cx(loop), ax, bx, ah
;================================================
proc ex4
	
	mov si, 0 ; dataSeg index
	mov cx, 100 ; repeat 100 times
	loop4:
		mov bl, 2
		xor ax, ax
		mov ax, si
		div bl ; check if divisible by 2
		cmp ah, 0
		jne MovData
		mov bl, 7
		div bl
		cmp ah, 0
		je MovData
		inc si
		loop loop4
		jmp @@CONT
		
		MovData:
			mov [array4 + si], 0cch
			inc si
			loop loop4

@@CONT:
    ret
endp ex4




;================================================
; Description: mov all values in bufferFrom to BufferTo in dataSeg
; INPUT:  BufferFrom5
; OUTPUT:  array in dataSeg name: bufferTo5
; Register Usage: si (index), cx (loop), bl
;================================================
proc ex5
      
	  mov si, 0
	  mov cx, 10
	  @@lp:
	  mov bl, [BufferFrom5 + si]
	  mov [BufferTo5 + si], bl
	  inc si
	  loop @@lp
	  
    ret
endp ex5




;================================================
; Description: move all values bigger than 12 from one array to another
; INPUT:  none
; OUTPUT: array on dataSeg name: BufferTo6
; Register Usage: si (index), di (index), cx (loop), bl
;================================================
proc ex6
      
	  mov si, 0 ; bufferFrom index
	  mov di, 0 ; bufferTo index
	  mov cx, 50
	  @@lp:
	  cmp [BufferFrom6 + si], 12
	  jg Above12
	  jng Below12
	  
	  Above12:
	  mov bl, [BufferFrom6 + si]
	  mov [BufferTo6 + di], bl
	  inc di
	  inc [BufferTo6Len]
	  
	  Below12:
	  inc si
	  loop @@lp

    ret
endp ex6




;================================================
; Description: find array length
; INPUT:  none
; OUTPUT: variable on dataSeg name: Line7Length
; Register Usage: si, cl - counter
;================================================
proc ex7a
      
	  mov si, 0 ; index
	  mov cl, 0 ; counter
	  
	  @@lp:
	  cmp [MyLine7 + si], 0Dh
	  je @@CONT
	  inc cl
	  inc si
	  jmp @@lp
	  
	  @@CONT:
	  mov [Line7Length], cl ; mov cl (counter) to Length variable
	  
    ret
endp ex7a




;================================================
; Description: find array length
; INPUT:  none
; OUTPUT: variable on dataSeg name: MyWords7Length
; Register Usage: si, cl - counter
;================================================
proc ex7b
      
	  mov si, 0 ; index
	  mov cl, 0 ; counter
	  
	  @@lp:
	  cmp [MyWords7 + si], 0DDDDh
	  je @@CONT
	  inc cl
	  add si, 2 ; jumps of 2 because its words
	  jmp @@lp
	  
	  @@CONT:
	  mov [MyWords7Length], cl ; mov cl (counter) to Length variable
	  
    ret
endp ex7b




;================================================
; Description: sums up all numbers bigger than 100 in array
; INPUT:  none
; OUTPUT:  variable sum in DS name: sum8 , printed on screen
; Register Usage: si, bx, ax (for ShowAxDecimal)
;================================================
proc ex8
      
	  mov si, 0
	  
	  @@lp:
	  cmp [MyQ8 + si], 0
	  je PRINT
	  cmp [MyQ8 + si], 100
	  jg AddToSum
	  jmp @@CONT
	  
	  AddToSum:
	  mov bl, [byte MyQ8 + si]
	  add [sum8], bx
	  
	  @@CONT:
	  inc si
	  jmp @@lp
	  
	  
	  PRINT:
	  mov ax, [sum8]
	  call ShowAxDecimal
	  
    ret
endp ex8




;================================================
; Description: count negative, positive and zeros in array
; INPUT:  none
; OUTPUT:  counters in dataSeg
; Register Usage: si for index
;================================================
proc ex9
      
	  mov si, 0
	  
	  @@lp:
	  cmp [MySet9 + si], 0FFFFh
	  je @@CONT
	  
	  cmp [MySet9 + si], 0
	  jg AddPos
	  jl AddNeg
	  
	  ; equals 0
	  inc [count3]
	  add si, 2
	  jmp @@lp
	  
	  AddNeg:
	  inc [count2]
	  add si, 2
	  jmp @@lp
	  
	  AddPos:
	  inc [count1]
	  add si, 2
	  jmp @@lp
	  
	  @@CONT:
	  
    ret
endp ex9




;================================================
; Description: print value of al in binary
; INPUT:  none
; OUTPUT:  byte printed on screen (0 & 1)
; Register Usage: al ("input"), bl for saving al before int21h, dl (for int 21h)
;================================================
proc ex10
      
	  mov al, 49
	  @@lp:
	  shl al, 1
	  jc PRINTONE
	  
	  ;Print Zero
	  mov bl, al ; save al
	  mov ah, 2
	  mov dl, '0'
	  int 21h
	  mov al, bl
	  jmp @@CONT
	  
	  PRINTONE:
	  mov bl, al ; save al
	  mov ah, 2
	  mov dl, '1'
	  int 21h
	  mov al, bl

	  @@CONT:
	  cmp al, 0
	  je PROGEND
	  loop @@lp
	  
	  PROGEND:
	  
    ret
endp ex10



;================================================
; Description: check if 7&8 bits of EndGate11 are 0 or 1
; INPUT:  none
; OUTPUT:  message on screen - both 0 , or one is 1
; Register Usage: bl (save number), ah dx - int 21h
;================================================
proc ex11
      
	  mov bl, [EndGates11]
	  shl bl, 1
	  jc PrintTrue
	  
	  shl bl, 1
	  jc PrintTrue
	  
	  Printfalse:
	  mov ah, 9
	  mov dx, offset BothFalse
	  int 21h
	  jmp @@CONT
	  
	  PrintTrue:
	  mov ah, 9
	  mov dx, offset OneIsTrue
	  int 21h
	  
	  @@CONT:
	  
    ret
endp ex11




;================================================
; Description: check address 0A000h in DS and mov value to 0B000h if between 10=>70
; INPUT:  none
; OUTPUT:  if condition is met - address 0B000h on DS
; Register Usage: bl for transfer
;================================================
proc ex12
      
	  cmp [byte ds:0A000h], 10
	  jae ABOVE10
	  jmp @@CONT
	  
	  ABOVE10:
	  cmp [byte ds:0A000h], 70
	  jbe UNDER70
	  jmp @@CONT
	  
	  UNDER70:
	  mov bl, [0A000h]
	  mov [0B000h], bl
	  
	  @@CONT:
	  
    ret
endp ex12




;================================================
; Description: mov value of string to variable on DATASEG
; INPUT:  none
; OUTPUT:  variable on dataSeg name: WordNum13
; Register Usage: si, bl, cx, ax, bx
;================================================
proc ex13
      
	  ;find index of "!"
	  mov si, 0
	  @@lp:
	  cmp [String13 + si], "!"
	  je @@CONT
	  inc si
	  jmp @@lp

	  @@CONT:
	  mov bl, 1 ; power of 10
	  mov cx, si
	  INSERT:
	  xor ax, ax
	  mov al, [String13 + si - 1]
	  sub al, '0'
	  mul bx
	  add [WordNum13], ax
	  xor ax, ax
	  mov al, 10
	  mul bx
	  mov bx, ax
	  dec si
	  loop INSERT

    ret
endp ex13




;================================================
; Description: print HexaDecimal value of low 4 bits of al
; INPUT:  none
; OUTPUT:  HexaDecimal letter printed on screen
; Register Usage: al, dl
;================================================
proc ex14a
      
	  and al, 00001111b
	  cmp al, 9
	  jnbe @@HexLetter
	  add al, '0'
	  jmp @@PRINT
	  
	  @@HexLetter:
	  sub al, 10
	  add al, 'A'
	  
	  @@PRINT:
	  mov ah, 2
	  mov dl, al
	  int 21h
	  
	  
    ret
endp ex14a




;================================================
; Description: print HexaDecimal value of al
; INPUT:  none
; OUTPUT:  2 HexaDecimal letters printed on screen
; Register Usage: ax, dx, bl
;================================================
proc ex14b
      
	  mov al, 0F3h

      xor ah, ah
	  mov bl, al
	  mov dh, 16
	  
	  and al, 11110000b
	  div dh
	  cmp al, 9
	  jnbe @@HexLetter
	  add al, '0'
	  mov ah, 2
	  mov dl, al
	  int 21h
	  jmp @@SecDig
	  
	  @@HexLetter:
	  sub al, 10
	  add al, 'A'
	  mov ah, 2
	  mov dl, al
	  int 21h
	  
	  @@SecDig:
	  and bl, 00001111b
	  cmp bl, 9
	  jnbe @@HexLetter2
	  add bl, '0'
	  mov ah, 2
	  mov dl, bl
	  int 21h
	  jmp @@CONT
	  
	  @@HexLetter2:
	  sub bl, 10
	  add bl, 'A'
	  mov ah, 2
	  mov dl, bl
	  int 21h
	  
	  @@CONT:
	  
	  
    ret
endp ex14b




;================================================
; Description:
; INPUT:  
; OUTPUT:  
; Register Usage: 
;================================================
proc ex14c

	  mov ax, 0ABCDh
	  
	  mov bh, ah
	  mov ch, ah
	  mov cl, al
	  mov dh, 0Ch
	  
	  ; AH
	  
	  and bh, 11110000b
	  xor ax, ax
	  shr bx, 12
	  cmp bl, 9
	  jnbe @@AhHexLetter
	  add bh, '0'
	  mov ah, 2
	  mov dl, bh
	  int 21h
	  jmp @@AhSecDig
	  
	  @@AhHexLetter:
	  sub bl, 10
	  add bl, 'A'
	  mov ah, 2
	  mov dl, bl
	  int 21h
	  
	  @@AhSecDig:
	  and ch, 00001111b
	  cmp ch, 9
	  jnbe @@AhHexLetter2
	  add ch, '0'
	  mov ah, 2
	  mov dl, ch
	  int 21h
	  jmp @@CONT
	  
	  @@AhHexLetter2:
	  sub ch, 10
	  add ch, 'A'
	  mov ah, 2
	  mov dl, ch
	  int 21h
	  
	  @@CONT:
	  
	  ; AL

      xor ah, ah
	  mov bl, cl
	  
	  and cl, 11110000b
	  mov al, cl
	  shr cl, 4
	  ;mov cl, al
	  cmp cl, 9
	  jnbe @@AlHexLetter
	  add cl, '0'
	  mov ah, 2
	  mov dl, cl
	  int 21h
	  jmp @@AlSecDig
	  
	  @@AlHexLetter:
	  sub cl, 10
	  add cl, 'A'
	  mov ah, 2
	  mov dl, cl
	  int 21h
	  
	  @@AlSecDig:
	  and bl, 00001111b
	  cmp bl, 9
	  jnbe @@AlHexLetter2
	  add bl, '0'
	  mov ah, 2
	  mov dl, bl
	  int 21h
	  jmp @@CONT2
	  
	  @@AlHexLetter2:
	  sub bl, 10
	  add bl, 'A'
	  mov ah, 2
	  mov dl, bl
	  int 21h
	  
	  @@CONT2:
	  
    ret
endp ex14c












;================================================
; Description - Write on screen the value of ax (decimal)
;               the practice :  
;				Divide AX by 10 and put the Mod on stack 
;               Repeat Until AX smaller than 10 then print AX (MSB) 
;           	then pop from the stack all what we kept there and show it. 
; INPUT: AX
; OUTPUT: Screen 
; Register Usage: AX  
;================================================
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
