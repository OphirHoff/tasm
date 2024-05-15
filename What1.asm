IDEAL
 
MODEL small
 
screen_RAM_Text     EQU 0B800h
 
STACK 256
  
DATASEG
   
   PrintLetter db "The Letter> " 
   AsciiLetter db 'A',13,10,"Press Key...$"       ; A is start value 
   
   Selection db ?
 
 ; The Intro below was made by on line tool 
 ; that was found at site:  http://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something
         
  intro  db "  ______   __  __   ______   ______   ______   ",13,10
		 db "/\  ___\ /\ \_\ \ /\  == \ /\  ___\ /\  == \   ",13,10
		 db "\ \ \____\ \____ \\ \  __< \ \  __\ \ \  __<   ",13,10
		 db " \ \_____\\/\_____\\ \_____\\ \_____\\ \_\ \_\ ",13,10
		 db "  \/_____/ \/_____/ \/_____/ \/_____/ \/_/ /_/ ",13,10
		      
		 db "",13,10                                                               
         db "",13,10                                                               
         db "",13,10
		 db " press any key to continue >",'$'
		 
;----------------------------------------------------
menu      db " MENU ",13,10
          db "------------------",13,10
          db " 1. - Add 1 to AsciiLetter    ",13,10
          db " 2. - Add 2 to AsciiLetter    ",13,10
	      db " 3. - Add 10 to AsciiLetter   ",13,10
	      db " 4. - Show AsciiLetter 	    ",13,10
          db " 5. - Exit                    ",13,10
presKey	  db "                      Select from the menu ..  ",13,10,"$"
	  

 
CODESEG

;----------------------------------------------------
Start:
    mov ax,@data   
	mov ds,ax

; Introduction
        mov ah,09h
        mov dx,offset intro
        int 21h
		
; Press any key to continue
        mov ah,00h
        int 16h
		
 		
;----------------------------------------------------	 	
 
menu_area:
        call ClearScreenText
		mov ah,0ch  ; remove Keyboard old buffer
		int 21h
		
		mov ah,09h
        mov dx,offset menu
        int 21h
		 
		mov ah,00h  
        int 16h    ; Special interrupt to get key at al and scan code at ah
        mov [Selection],al
		
		
		cmp [Selection],'5'
		Jz  exit
		Ja menu_area
        cmp ah,1       ; also check Escape key for exit (scan code)
		jz exit
		
		
		cmp [Selection],'4'
		jnz Continue_check
		call ClearScreenText   ; just clear the screen and change color
		mov dl,13     ; CR
		mov ah, 2
		int 21h
		mov dl,10    ; new line
		int 21h
		
		mov dx, offset PrintLetter   ; print the letter
		mov ah,09h
		int 21h
		
		
		
		mov ah,00h  
        int 16h    ; fake input just to show the output
		jmp menu_area

Continue_check:		
		cmp [Selection],'3'
		jz add_10
		
		cmp [Selection],'2'
		jz add_2

		cmp [Selection],'1'
		jz add_1
		jmp menu_area

add_10:
		add [AsciiLetter],8
add_2: 
		add [AsciiLetter],1
add_1: 
		add [AsciiLetter],1
		jmp menu_area
		
		
exit: 
 
	mov AH,04Ch
	INT 021h
;----------------------------------------------------
; End of  Main program











;----------------------------------------------------------
;  Procedure Clear Screen Text  Mode  
;----------------------------------------------------------
; Input:
;   	None
; Output:
;     Screen , and Cursor 
; Registers Used:
;	   AX ES DI CX DX BH
; Description:
;  
; Color Black all Screen 80 X 24 and bring Cursor to start
;    
;---------------------------------------------------------- 	


Proc ClearScreenText
    push ax
	push cx
	push bx
	push dx
	
	mov ax,screen_RAM_text
	mov es,ax          ; es:di - video memory
	xor di,di
    mov cx,80*24
    mov al,00d         ; ASCII
    mov ah,02h        ; color 2 is green
    ;mov es:[di],ax     ;add di,2  Stores a byte, word from the AL, AX
	rep stosw
	;move Cursor to top left  
    xor DX,DX
	mov dl, 0
	mov bh, 0
	mov ah, 2  ; change cursor position
	int 10h
    
	pop dx
	pop bx
	pop cx
	pop ax
	
	ret
endp ClearScreenText

 
	
 
END start

 
