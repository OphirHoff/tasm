IDEAL
MODEL small
 
BMP_WIDTH = 320
BMP_HEIGHT = 320

STACK 100h

DATASEG



    OneBmpLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer
   
    ScrLine 	db BMP_WIDTH+4 dup (0)  ; One Color line read buffer

	;BMP File data
	applePic 	db 'apple.bmp' ,0
	background  db 'back.bmp', 0
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	
	SmallPicName db 'Pic48X78.bmp',0
	
	
	BmpFileErrorMsg    	db 'Error At Opening Bmp File ', 0dh, 0ah,'$'
	ErrorFile           db 0
			  
			  			  
	; see http://cs.nyu.edu/~yap/classes/machineOrg/info/mouse.htm
	
	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ?
	
matrix dw offset matrix1
matrix1 db 1560 dup (?)

x dw 320
y dw 200


	
CODESEG
 
start:
	mov ax, @data
	mov ds, ax
	
	call SetGraphic
	
	mov dx, offset background
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] ,200
	call OpenShowBmp
	
	mov ax,offset matrix1 ;To di
	push ax
	
	mov ax,31840 ;To si
	push ax
	
	mov ax,39 ;To cx
	push ax
	
	mov ax,40
	push ax
	call Copy
	
	
	
	;di=The offset you want to copy to
	;si=The location in 0a000h segment
	;cx=row
	;dx=col
	
	call LoopDelay3Sec
	
	mov dx, offset applePic
	mov [BmpLeft], 160
	mov [BmpTop], 100
	mov [BmpColSize], 40
	mov [BmpRowSize], 39
	call OpenShowBmp
	
	call LoopDelay3Sec
	
	mov dx, 40
	mov cx, 39
	mov di, 32480
	call PutMatrixInScreen
	
	; in dx how many cols 
	; in cx how many rows
	; in matrix - the bytes
	; in di start byte in screen (0 64000 -1)
	
	; cmp [ErrorFile],1
	; jne cont 
	; jmp exitError
; cont:

	
    ; jmp exit
	
; exitError:
	; mov ax,2
	; int 10h
	
    ; mov dx, offset BmpFileErrorMsg
	; mov ah,9
	; int 21h

	
	
	; mov dx, 40
	; mov cx, 41
	; mov di, 0
	; call PutMatrixInScreen

	
	

exit:
	
	mov ax, 4c00h
	int 21h
	

	
;==========================
;==========================
;===== Procedures  Area ===
;==========================
;==========================
proc LoopDelay3Sec
	push cx
	mov cx ,3000
@@Self1:
	  push cx
	mov cx,3000 
@@Self2:	
	loop @@Self2
	pop cx
	loop @@Self1
	pop cx
	ret
endp LoopDelay3Sec
;--------------------------
proc PutMatrixInScreen

	cld ;sets direction of movsb to copy forward
	mov si,[matrix] ; puts offset of the Matrix to si
	NextRow:	; loop of cx lines
		push cx ;saves cx of loop
		mov cx, dx ;sets cx for movsb
		shr cx, 1
		rep movsw ; Copy whole line to the screen, si and di increases
		sub di,dx ; returns back to the begining of the line 
		add di, 320 ;go down one line in “screen” by adding 320
		pop cx  ;restores cx of loop
		loop NextRow
	
	ret
endp PutMatrixInScreen
;--------------------------
proc Copy
	push bp
	mov bp,sp
	
	mov di,[bp+10] ;di=The offset you want to copy to
	mov si,[bp+8] ;si=The location in 0a000h segment
	mov cx,[bp+6] ;cx=row
	mov dx,[bp+4] ;dx=col
@@LOOP:
	push cx
	
	mov cx,dx
	shr cx,1
	
	push ds ;We swap between ds and es so we can move from the segment 0a000h to the data segement
	push es
	pop ds
	pop es
	
	cld
	rep movsw ;dx must be even so we can move it in words, if its an odd number use rep movsb

	push ds
	push es
	pop ds
	pop es
	
	sub si,dx
	add si,320
	pop cx
loop @@LOOP

	pop bp
	ret 8
endp Copy
;--------------------------

proc savebackroundmario
	push ax
	push bx
	push cx
	push dx

	mov bx,0a000h
	mov es,bx
	mov cx,41;; the rows
	mov si,0
	call xymarioToNum
	mov di,ax
@@loopbig:
	push cx
	mov cx,41;;
@@loopsmall:
	push cx
	
	mov al,[es:di]
	mov [matrix1+si],al
	inc si
	inc di
	pop cx
	loop @@loopsmall
	add di,310
	pop cx
	loop @@loopbig


	pop dx
	pop cx
	pop bx
	pop ax


	ret 
endp savebackroundmario

	
	
	
proc xymarioToNum; changes mario xy cooardinates to a 1-64000
	push bx
	mov bx,[x]
	mov ax,320
	mul bx
	add ax,[y]
	pop bx
	ret
endp


;--------------------------
proc OpenShowBmp near
	
	 
	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call  ShowBmp
	
	 
	call CloseBmpFile

@@ExitProc:
	ret
endp OpenShowBmp

 

; input dx filename to open
proc OpenBmpFile	near						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc
	
@@ErrorAtOpen:
	mov [ErrorFile],1
@@ExitProc:	
	ret
endp OpenBmpFile

	
; output file dx filename to open
proc CreateBmpFile	near						 
	 
	
CreateNewFile:
	mov ah, 3Ch 
	mov cx, 0 
	int 21h
	
	jnc Success
@@ErrorAtOpen:
	mov [ErrorFile],1
	jmp @@ExitProc
	
Success:
	mov [ErrorFile],0
	mov [FileHandle], ax
@@ExitProc:
	ret
endp CreateBmpFile





proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile




; Read 54 bytes the Header
proc ReadBmpHeader	near					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader



proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette		near					
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette

 
proc ShowBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
	mov cx,[BmpRowSize]
	
 
	mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	cmp dx,0
	mov bp,0
	jz @@row_ok
	mov bp,4
	sub bp,dx

@@row_ok:	
	mov dx,[BmpLeft]
	
@@NextLine:
	push cx
	push dx
	
	mov di,cx  ; Current Row at the small bmp (each time -1)
	add di,[BmpTop] ; add the Y on entire screen
	
 
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx
	 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpColSize]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,[BmpColSize]  
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
	
	pop dx
	pop cx
	 
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMP 

	

; Read 54 bytes the Header
proc PutBmpHeader	near					
	mov ah,40h
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
endp PutBmpHeader
 



proc PutBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	mov ah,40h
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp PutBmpPalette


 
proc PutBmpDataIntoFile near
			
    mov dx,offset OneBmpLine  ; read 320 bytes (line) from file to buffer
	
	mov ax, 0A000h ; graphic mode address for es
	mov es, ax
	
	mov cx,BMP_HEIGHT
	
	cld 		; forward direction for movsb
@@GetNextLine:
	push cx
	dec cx
										 
	mov si,cx    ; set si at the end of the cx line (cx * 320) 
	shl cx,6	 ; multiply line number twice by 64 and by 256 and add them (=320) 
	shl si,8
	add si,cx
	
	mov cx,BMP_WIDTH    ; line size
	mov di,dx
    
	 push ds 
     push es
	 pop ds
	 pop es
	 rep movsb
	 push ds 
     push es
	 pop ds
	 pop es
 
	
	
	 mov ah,40h
	 mov cx,BMP_WIDTH
	 int 21h
	
	 pop cx ; pop for next line
	 loop @@GetNextLine
	
	
	
	 ret 
endp PutBmpDataIntoFile

   
proc  SetGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp 	SetGraphic
 
END start


