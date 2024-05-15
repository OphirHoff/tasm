IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
BMPFileName db "ophir.bmp", 0
BmpLeft db 0
BmpTop db 0
BmpColSize dw 320
BmpRowSize dw 200

; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov dx, offset BMPFileName
call OpenShowBmp
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
	
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


; Read BMP file color palette, 256 colors * 4 bytes (400h)
; 4 bytes for each color BGR + null)		
proc ReadBmpPalette near 	
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
proc CopyBmpPalette	near						
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
	shr al,2 							
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 								
	loop CopyNextColor
	pop dx
	pop cx
	ret
endp CopyBmpPalette


proc ShowBMPFile
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	mov ax, 0A000h
	mov es, ax
	mov cx,[BmpRowSize]
	mov ax,[BmpColSize]
	xor dx,dx
	mov si,4
	div si
	cmp dx,0 ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	mov bp,0
	jz @@row_ok
	mov bp,4
	sub bp,dx
@@row_ok:	
	mov dx,[BmpLeft]
@@NextLine:
	push cx
	push dx
	mov di,cx  ; Current Row at the small bmp (each time decreases by 1)
	add di,[BmpTop] ; add the Y on entire screen



; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx
	 
	; Read one line from file
	mov ah,3fh
	mov cx,[BmpColSize]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine ; read one line from file
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
endp ShowBMPFile





	
END start


