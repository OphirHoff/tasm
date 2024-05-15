
%TITLE 	"Base Interrupts"
		IDEAL
		MODEL small
		STACK 256
		DATASEG
	
		InputArea  db   "XX0123456789X"  ; Place Holder for future input
	
		num1 db ?
        plsEnter1  db     0Dh,0Ah,"Please Enter one digit char>",'$'	
        Out1       db     0Dh,0Ah,"Your Char is>",'$'	
		plsEnter2  db     0Dh,0Ah,"Please Enter string max 10 characters and press Enter>",'$'	
		Out2       db     0Dh,0Ah,"Your String is>$"
                        
		
		
		  
CODESEG

Start:     
	    mov ax, @data
		mov ds ,ax
		
		; like Console.WriteLine(plsEnter1);
		mov dx, offset plsEnter1
      	mov ah, 9
		int 21h
	 
	    ;  Like k = Console.ReadKey();
		mov	ah, 1h
		int	21h	
		sub	al, '0'   ; convert one digit Ascii to number (Decimal one digit).  
		mov [byte num1],al
		
		;like Console.WriteLine(Out1);
		mov dx, offset Out1
      	mov ah, 9
		int 21h
		
		;like Console.Write(num1);
		mov dl,[num1]
		add dl,'0'
		mov	ah, 2h
		int	21h
		
		; like Console.WriteLine(plsEnter2);
		mov dx, offset plsEnter2
      	mov ah, 9
		int 21h
		 
		; like Console.ReadLine(); Read string till Enter  
		mov [byte InputArea],11   ; 10 + 1 define the max characters to read. must be at the first byte of input area 
		mov dx, offset InputArea
      	mov ah, 0Ah  ; this interrupt puts the string from third byte till the max and then put there \r = 13 = 0dh
        int 21h 
		
		; Now we have the input string from InputArea + 2 
		; at [byte InputArea + 0 ] we have:  maximum characters that the buffer can hold
		; at [byte InputArea + 1 ] we have:  actually_byte_read - number of characters actually read, excluding CR = 0Dh
		; at [byte InputArea + 2 +  actually_byte_read  ] we have: = 0Dh
		 
		
		;like Console.WriteLine(Out2);
		mov dx, offset Out2
      	mov ah, 9
		int 21h
		
				
		; next 5 lines - we want to put $ at the end of the Input string in order to print it using Int 21 09
		xor cx,cx
		mov cl,[byte InputArea+1] ; actual characters read, including the final carriage return
		mov bx,offset InputArea + 2 
		add bx,cx
		mov [byte bx],'$'
		
		;like Console.WriteLine(InputArea.Substring(2));
		mov dx, offset InputArea + 2 ; remember real input start at the third byte of input area
      	mov ah, 9
		int 21h
	
Exit:
        mov ax, 4C00h
        int 21h
END start

