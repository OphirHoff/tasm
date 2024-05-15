IDEAL
MODEL small
STACK 100h
DATASEG

; INSTRUCTIONS
; ------------
; 1) Put the BMP file name in IMG_FILE_NAME
; 2) Put the output txt file path(Where we'll save the matrix) in OUTPUT_FILE_NAME
; 3) Put the color palette txt file path(Where we'll save the palette of the BMP) in COLOR_FILE_NAME
; 4) Put the relevant dimensions in IMG_WIDTH and IMG_HEIGHT
; 5) Run

; *** IMPORTANT ***
; After getting the matrix and color palette, you will have to put the color palette in a "Palette" variable in order to set the color palette in your project via Emil's CopyBmpPalette function, OTHERWISE THE COLORS WILL BE WRONG

; Made by Maxim Prokhorov :)

IMG_WIDTH=16
IMG_HEIGHT=16
IMG_FILE_NAME equ "cursor.bmp"
OUTPUT_FILE_NAME equ "matrix.txt"
COLOR_FILE_NAME equ "palette.txt"
macro PUSH_ALL_BP
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push di
	push si
endm

macro POP_ALL_BP
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
endm

macro PUSH_ALL
	push ax
	push bx
	push cx
	push dx
endm

macro POP_ALL
	pop dx
	pop cx
	pop bx
	pop ax
endm
; --------------------------
colorTable db 256*4 dup (?)
erase_pixels db IMG_WIDTH*IMG_HEIGHT dup (0)
bmpHeader db 54 dup (?)
fileHandle dw ?
pixels db IMG_WIDTH*IMG_HEIGHT dup (0)
ImageFileName db IMG_FILE_NAME, 0
ColorFileName db COLOR_FILE_NAME, 0
OutputFileName db OUTPUT_FILE_NAME, 0
finalPixels db '0',?,?,'h',','
paddingBytes db (4-(IMG_WIDTH mod 4) mod 4) dup(?)
matrix dw ?
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
	mov ax, 13h
	int 10h
	
	; OPEN File
	mov ah, 3dh ; Set interrupt to file opening
	lea dx, [ImageFileName] ; What file to open
	mov al, 0 ; Access mode: 0 - read
	int 21h
	mov [fileHandle], ax ; Save the file handler

	; READ Header
	mov ah, 3fh ; Set interrupt to file reading
	xor al, al ; Clear unneeded values in AL
	mov bx, [fileHandle] ; Provide the interrupt with the needed file handler
	mov cx, 54
	lea dx, [bmpHeader]
	int 21h
	
	; READ Color Palette
	mov ah, 3fh
	xor al, al
	mov bx, [fileHandle]
	lea dx, [colorTable]
	mov cx, 256*4
	int 21h
	
	
	; READ pixels
	mov cx, IMG_HEIGHT
	@@RowLoop:
	push cx
	
	mov ax, cx ; Start from the last row
	dec ax ; -1 because the counting should start from 0
	xor dx, dx 
	; mov bx, IMG_WIDTH+2 ; Move down the needed amount of rows
	mov bx, IMG_WIDTH
	mul bx
	mov dx, ax
	
	add dx, offset pixels
	mov cx, IMG_WIDTH
	mov ah, 3fh
	xor al, al
	mov bx, [fileHandle]
	int 21h
	; READ padding
	xor dx,dx
	xor ax, ax
	xor bx, bx
	mov ax, IMG_WIDTH
	mov bx, 4
	div bx
	cmp dx,0
	je @@cont
	mov ah, 3fh
	xor al, al
	mov bx, [fileHandle]
	lea dx, [paddingBytes]
	mov cx, 4-(IMG_WIDTH mod 4) mod 4
	int 21h
	@@cont:
	pop cx
	loop @@RowLoop
	
	; CLOSE file
	mov ah, 3eh			
	mov bx, [fileHandle]
	int 21h
	
	; OPEN File
	mov ah, 3dh ; Set interrupt to file opening
	lea dx, [OutputFileName] ; What file to open
	mov al, 2 ; Access mode: 2 - read+write
	int 21h
	mov [fileHandle], ax ; Save the file handler
	
	mov cx, IMG_WIDTH*IMG_HEIGHT
	mov si, 0
	@@CopyLoop:
	lea bx, [pixels]
	add bx, si ; now BX points => current character to read from [pixels]
	; mov ax, 3 ; in order to get si*3
	; mul si ; in order to get si*3
	xor dx, dx ; just in case - prevents problems usually
	lea di, [finalPixels]
	inc di
	; add di, ax ; now DI points => where to put the
	mov al, [bx]
	xor ah, ah
	push ax
	push di
	call NumberToAscii
	
	PUSH_ALL
	; WRITE to file
	mov ah, 040h ; write to file
	mov bx, [fileHandle] ; filehandle
	mov cx, 5 ; number of bytes to write 
	mov dx, offset finalPixels; data to write
	int 21h
	POP_ALL
	inc si
	loop @@CopyLoop	
	
	; CLOSE file
	mov ah, 3eh
	mov bx, [fileHandle]
	int 21h
	
	; -----------------------------
	
	; OPEN File
	mov ah, 3dh ; Set interrupt to file opening
	lea dx, [ColorFileName] ; What file to open
	mov al, 2 ; Access mode: 2 - read+write
	int 21h
	mov [fileHandle], ax ; Save the file handler
	
	mov cx, 1024
	mov si, 0
	CopyLoop:
	lea bx, [colorTable]
	add bx, si ; now BX points => current character to read from [pixels]
	; mov ax, 3 ; in order to get si*3
	; mul si ; in order to get si*3
	xor dx, dx ; just in case - prevents problems usually
	lea di, [finalPixels]
	inc di
	; add di, ax ; now DI points => where to put the
	mov al, [bx]
	xor ah, ah
	push ax
	push di
	call NumberToAscii
	
	PUSH_ALL
	; WRITE to file
	mov ah, 040h ; write to file
	mov bx, [fileHandle] ; filehandle
	mov cx, 5 ; number of bytes to write 
	lea dx, [finalPixels]; data to write
	int 21h
	POP_ALL
	inc si
	loop CopyLoop	
	
	; CLOSE file
	mov ah, 3eh
	mov bx, [fileHandle]
	int 21h
	
	; -----------------------------------
	
	
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
	
; push number
; push address for string

; result is in the string
proc NumberToAscii 
	PUSH_ALL_BP
	mov si, [bp+4]
	mov cx, 2
	mov bx, [bp+6]
	shl bx, 8
	@@ConvertToASCII:
	xor dh, dh
	mov dl, bh
	shr dl, 4
	add dl, 30h
	cmp dl, '9'
	jbe @@PrintDigit
	add dl, 7
	
	@@PrintDigit:
	mov [si], dl
	inc si
	shl bx, 4
	loop @@ConvertToASCII
	
	@@exit_func:
	mov [bp+6], si
	POP_ALL_BP
	ret 4
endp

; in dx how many cols (horizontal)
; in cx how many rows (vertical)
; in matrix - the offset of what to copy
; in di start byte in screen (where to paste)

proc putMatrixInScreen
    push es
    push ax
    push si
	push di

    mov ax, 0A000h
    mov es, ax
    cld ; for movsb playerDirection si --> di
	
    mov si,[matrix]
@@NextRow:
    push cx

    mov cx, dx
    rep movsb ; Copy whole line to the screen, si and di advances in movsb
    sub di,dx ; returns back to the begining of the line 
    add di, 320 ; go down one line by adding 320

    pop cx
    loop @@NextRow

	pop di
    pop si
    pop ax
    pop es
    ret
endp putMatrixInScreen


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette		near					
										
	push cx
	push dx
	
	mov si,offset colorTable
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

; DESCRIPTION: Delays the program for the inputed amount of Miliseconds
; ------------------------------------------
; SETUP:
; create a variable called timer, or dont and just erase the lines that use it
;
; HOW TO USE:
; push {amount of miliseconds}
; call TimeBasedDelay
; ------------------------------------------
proc TimeBasedDelay
	push bp 
	mov bp , sp 
    push ax
    push cx
	push dx
	mov cx, [bp+4]
	@@MyLoop:
	push cx
	mov cx, 0
	mov dx, 3D0h
	mov ah,86h
	int 15h
	; inc [timer]
	pop cx
	loop @@MyLoop
	pop dx
	pop cx
	pop ax
	pop bp
	ret 2
endp TimeBasedDelay
END start