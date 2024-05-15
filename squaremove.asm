IDEAL
MODEL small

BMP_WIDTH = 320
BMP_HEIGHT = 200

STACK 100h

FILE_NAME_IN  equ 'pikachu.bmp'

DATASEG
; --------------------------
Xpos dw ?
Ypos dw ?
direction db ?
isExit db ?
speed db ?
speedLevel db ? ; 0 low 1 high
gameOverM db "Game Over...$"

StartPicture db 'Start.bmp', 0
EndPicture db 'GameEnd.bmp', 0

UserRespond db 0 ; 1 yes 2 no

;Second Sqr variables
RndX dw ?
RndY dw ?
RndColor db ?
Points db ?
seconds db ?
RndCurrentPos dw 0
hit db ?

matrix1 db 3, 3, 3, 3, 3
		db 3, 4, 4, 4, 3
		db 3, 4, 5, 4, 3
		db 3, 4, 4, 4, 3
		db 3, 3, 3, 3, 3
		
matrix dw ?

OneBmpLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer

ScrLine db BMP_WIDTH dup (0)  ; One Color line read buffer

;bmp file data
FileName 	db FILE_NAME_IN ,0
FileHandle	dw ?
Header 	    db 54 dup(0)
Palette 	db 400h dup (0)

BmpFileErrorMsg    	db 'Error At Opening Bmp File ', FILE_NAME_IN, 0dh, 0ah,'$'
ErrorFile           db 0

BmpLeft dw ?
BmpTop dw ?
BmpColSize dw ?
BmpRowSize dw ?
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------

;graphic mode
mov ax, 13h
int 10h

mov ax, 2
int 33h

mov dx, offset StartPicture
mov [BmpLeft], 0
mov [BmpTop], 0
mov [BmpColSize], 320
mov [BmpRowSize], 200
call OpenShowBmp

call WaitForUserClick
;clear screen
push 0
push 0
push 200
push 320
push 0
call DrawFullRect




;איתחול
mov [Xpos], 150
mov [Ypos], 90
mov [speed], 1
mov [speedLevel], 0
mov [direction], 1
mov [hit], 0
mov [isExit], 0
mov [UserRespond], 0



call DrawSqr
call DrawRndSqr


Mainloop:

;check for keyboard input
mov ah, 1
int 16h
jz JMPToMoveLabel

mov ah, 0
int 16h
cmp ah, 1
jne noExit
mov [isExit], 1
jmp Move

noExit:
cmp ah, 4Bh
je moveLeft
cmp ah, 4Dh
je moveRight
cmp ah, 48h
je moveUp
cmp ah, 50h
je moveDown
cmp ah, 39h
je spaceBar

Cont:

;Change direction
moveLeft:
mov [direction], 3
jmp Move

moveRight:
mov [direction], 1
jmp Move

moveUp:
mov [direction], 0
jmp Move

moveDown:
mov [direction], 2
jmp Move

spaceBar:
cmp [speed], 1
je speedUp

;speed down
xor ax, ax
mov al, [speed]
mov bl, 3
div bl
mov [speed], al
mov [speedLevel], 0
JMPToMoveLabel:
jmp Move

JMPToStartLabel:
mov ax, 2
int 33h
jmp start

speedUp:
xor ax, ax
mov al, [speed]
mov bl, 3
mul bl
mov [speed], al
mov [speedLevel], 1

Move:
push [Xpos]
push [Ypos]
call MoveRect
call CheckBorders ; check if sqr hits borders
call CheckHit ; check if there was "touch" between squares
cmp [hit], 1
jne CheckGameOver
call DelRndSqr
call DrawRndSqr
mov [hit], 0

CheckGameOver:
;Check if game over
cmp [isExit], 0
jne GameOver

Delay:
call LoopDelay
jmp Mainloop

GameOver:

mov dx, offset EndPicture
mov [BmpLeft], 0
mov [BmpTop], 0
mov [BmpColSize], 320
mov [BmpRowSize], 200
call OpenShowBmp

call SetAsync



WaitForRespond:

mov ax, 1
int 33h

cmp [UserRespond], 1
jne Cont2
jmp JMPToStartLabel
Cont2:
cmp [UserRespond], 2
jne WaitForRespond


mov ax, 2
int 10h


; --------------------------

exit:
	mov ax, 4c00h
	int 21h
	
;----------------------------
PROC MyMouseHandle far
	stop:
	; must show mouse before check cx,dx
	push ax
	mov ax,01h
	int 33h	
	pop ax
			
	shr cx, 1 ;the Mouse default is 640X200 So divide 640 by 2 
	cmp cx, 160
	ja NoClick
	
	;Yes Click
	mov [UserRespond], 1
	jmp ExitProc
	
	NoClick:
	mov [UserRespond], 2

	;hide mouse
	mov ax,02h
	int 33h

	ExitProc:	
	; show mouse
	mov ax,01h
	int 33h	
	
	retf
ENDP MyMouseHandle 


	
;----------------------------
proc SetAsync

	push ds
	pop es
	mov ax, seg MyMouseHandle 
	mov es, ax
	mov dx, offset MyMouseHandle   ; ES:DX ->Far routine
	mov ax,0Ch             ; interrupt number
	mov cx, 2              ; Left button Down
	int 33h  

	ret
endp SetAsync
	
;-----------------------------
proc WaitForUserClick
	
	MousePress:
	mov ax, 3
	int 33h
	
	cmp bx, 1
	jne MousePress

	ret
endp WaitForUserClick
	
;-----------------------------
proc PutMatrixInScreen

	cld ;sets direction of movsb to copy forward
		   mov si,[matrix] ; puts offset of the Matrix to si
	NextRow:	; loop of cx lines
		push cx ;saves cx of loop
		mov cx, dx ;sets cx for movsb
		rep movsb ; Copy whole line to the screen, si and di increases
		sub di,dx ; returns back to the begining of the line 
		add di, 320 ;go down one line in “screen” by adding 320
		pop cx  ;restores cx of loop
		loop NextRow
	
	ret
endp PutMatrixInScreen

	
;-------------------------
proc CheckHit

	push bx

	;check boreders' color of little sqr
	;Left border
	push [RndX]
	push [RndY]
	push 5
	call CheckVerticalLineColor
	cmp [hit], 1
	je @@Cont
	
	
	;upper border
	push [RndX]
	push [RndY]
	push 5
	call CheckHorizontalLineColor
	cmp [hit], 1
	je @@Cont
	
	;right side
	mov bx, [RndX]
	add bx, 4
	push bx
	push [RndY]
	push 5
	call CheckVerticalLineColor
	cmp [hit], 1
	je @@Cont
	
	;bottom
	mov bx, [RndY]
	add bx, 4
	push [RndX]
	push bx
	push 5
	call CheckHorizontalLineColor
	
	
	@@Cont:
	
	pop bx
	ret
endp CheckHit

;-------------------------
;procedure that check if a line is full in the same color
;This will determine if the moving sqr "touched" the little sqr
; By checking the borders of the little sqr

len equ [bp+4]
y equ [bp+6]
x equ [bp+8]

proc CheckHorizontalLineColor
	
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	mov cx, 5
	@@Search:
	push cx
	mov bh, 0
	mov cx, x
	mov dx, y
	mov ah, 0Dh
	int 10h
	
	pop cx
	cmp al, [RndColor]
	jne @@Found
	inc x
	loop @@Search
	jmp @@NotFound
	
	@@Found:
	mov [hit], 1
	
	@@NotFound:
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	
	ret 6
endp CheckHorizontalLineColor
;-----------------------------
; Same for Vertical Line
len equ [bp+4]
y equ [bp+6]
x equ [bp+8]

proc CheckVerticalLineColor
	
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	mov cx, 5
	@@Search:
	push cx
	mov bh, 0
	mov cx, x
	mov dx, y
	mov ah, 0Dh
	int 10h
	
	pop cx
	cmp al, [RndColor]
	jne @@Found
	inc y
	
	loop @@Search
	jmp @@NotFound
	
	@@Found:
	mov [hit], 1
	
	@@NotFound:
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	
	ret 6
endp CheckVerticalLineColor



;-------------------------
proc DelRndSqr
	
	push [RndX]
	push [RndY]
	push 5
	push 5
	push 0
	call DrawFullRect

	ret
endp DelRndSqr
	
;-------------------------
proc DrawRndSqr

	mov [RndColor], 3 

	push 0A000h
	pop es

	;random x pos
    mov bx, 0
    mov dx, 309
    call RandomByCsWord
    mov [RndX], ax
    
    ;random y pos
    mov bl, 0
    mov bh, 189
    call RandomByCs
    mov [byte RndY], al
	
	mov ax, [RndY]
	mov bx, 320
	mul bx ; y position * 320 + x position = location at 0A000h
	mov di, ax
	add di, [RndX]

	mov cx, 5
	mov dx, 5
	mov bx, offset matrix1
	mov [matrix], bx

	call putMatrixInScreen

	ret
endp DrawRndSqr
	
;-------------------------
	
proc LoopDelay
	push cx
	mov cx ,500
	@@Self1:
	  push cx
	mov cx,500
	@@Self2:	
	loop @@Self2
	pop cx
	loop @@Self1
	pop cx
	ret
endp LoopDelay
;----------------------------
proc CheckBorders

	cmp [direction], 0
	je CheckUp
	cmp [direction], 1
	je CheckRight
	cmp [direction], 2
	je CheckDown

	;check left
	cmp [Xpos], 5
	jnbe @@Cont
	mov [direction], 1
	jmp @@Cont
	
	CheckUp:
	cmp [Ypos], 5
	jnbe @@Cont
	mov [direction], 2
	jmp @@Cont
	
	CheckRight:
	cmp [Xpos], 304
	jnae @@Cont
	mov [direction], 3
	jmp @@Cont
	
	CheckDown:
	cmp [Ypos], 185
	jnae @@Cont
	mov [direction], 0
	
	@@Cont:

	ret
endp CheckBorders


;----------------------------
y equ [bp+4]
x equ [bp+6]

proc MoveRect

	push bp
	mov bp, sp
	push ax 

	; delete square
	call DelSqr

	xor ax, ax

	;increase x/y
	cmp [direction], 0
	je UP
	cmp [direction], 1
	je RIGHT
	cmp [direction], 2
	je DOWN

	;LEFT
	mov al, [speed]
	sub [Xpos], ax
	jmp @@Cont

	UP:
	mov al, [speed]
	sub [Ypos], ax
	jmp @@Cont

	RIGHT:
	mov al, [speed]
	add [Xpos], ax
	jmp @@Cont

	DOWN:
	mov al, [speed]
	add [Ypos], ax
	

	@@Cont:
	call DrawSqr

	pop ax
	pop bp
	ret 4
endp MoveRect

;-----------------
proc DrawSqr

	
	push ax
	push bx
	push dx
	
	mov dx, offset FileName
	mov bx, [Xpos]
	mov [BmpLeft], bx
	mov bx, [Ypos]
	mov [BmpTop], bx
	mov [BmpColSize], 10
	mov [BmpRowSize] ,10
	
	
	mov dx, offset FileName
	call OpenShowBmp
	cmp [ErrorFile],1
	jne @@cont 
	jmp exitError
@@cont:

	
    jmp @@exit
	
exitError:
	mov ax,2
	int 10h
	
    mov dx, offset BmpFileErrorMsg
	mov ah,9
	int 21h
	
@@exit:
	

	pop dx
	pop bx
	pop ax

	ret
endp DrawSqr

;------------------

proc DelSqr

	push [Xpos]
	push [Ypos]
	push 11
	push 11
	push 0
	call DrawFullRect

	ret
endp DelSqr

;------------------

color equ [bp+4]
len equ [bp+6]
y equ [bp+8]
x equ [bp+10]



proc DrawHorizontalLine

	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	

	
	mov bh, 0
	mov cx, len
	DrawLine:
	push cx
	mov cx, x
	mov dx, y
	mov al, color
	mov ah, 0ch
	int 10h
	pop cx
	inc x
	loop DrawLine
	

	pop cx
	pop bx
	pop ax
	pop bp
	
	ret 8
endp DrawHorizontalLine

;-------------------------

color equ [bp+4]
len equ [bp+6]
y equ [bp+8]
x equ [bp+10]

proc DrawVerticalLine

	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	
	
	mov bh, 0
	mov cx, len
	DrawVertLine:
	push cx
	mov cx, x
	mov dx, y
	mov al, color
	mov ah, 0ch
	int 10h
	pop cx
	inc y
	loop DrawVertLine
	
	;mov ax, 2
	;int 10h

	pop cx
	pop bx
	pop ax
	pop bp

	ret 8
endp DrawVerticalLine

;------------------------
color equ [bp+4]
wid equ [bp+6]
len equ [bp+8]
y equ [bp+10]
x equ [bp+12]

proc DrawRect

	push bp
	mov bp, sp
	push bx
	
	;left side
	push x
	push y
	push len
	push color
	call DrawVerticalLine
	
	;upper side
	push x
	push y
	push wid
	push color
	call DrawHorizontalLine
	
	;right side
	push x
	mov bx, wid
	add x, bx
	push x
	push y
	push len
	push color
	call DrawVerticalLine
	pop x
	
	;bottom
	mov bx, len
	add y, bx
	push x
	push y
	inc wid
	push wid
	push color
	call DrawHorizontalLine
	
	pop bx
	pop bp
	ret 10

	ret
endp DrawRect


;------------------------
color equ [bp+4]
wid equ [bp+6]
len equ [bp+8]
y equ [bp+10]
x equ [bp+12]

proc DrawFullRect

	push bp
	mov bp, sp
	push cx
	
	mov cx, wid
	DrawR:
	push x
	push y
	push len
	push color
	call DrawVerticalLine
	add x, 1
	loop DrawR

	pop cx
	pop bp
	
	ret 10
endp DrawFullRect

;------------------------

proc RandomByCs
    push es
	push si
	push di
	
	mov ax, 40h
	mov	es, ax
	
	sub bh,bl  ; we will make rnd number between 0 to the delta between bl and bh
			   ; Now bh holds only the delta
	cmp bh,0
	jz @@ExitP
 
	mov di, [word RndCurrentPos]
	call MakeMask ; will put in si the right mask according the delta (bh) (example for 28 will put 31)
	
RandLoop: ;  generate random number 
	mov ax, [es:06ch] ; read timer counter
	mov ah, [byte cs:di] ; read one byte from memory (from semi random byte at cs)
	xor al, ah ; xor memory and counter
	
	; Now inc di in order to get a different number next time
	inc di
	cmp di,(EndOfCsLbl - start - 1)
	jb @@Continue
	mov di, offset start
@@Continue:
	mov [word RndCurrentPos], di
	
	and ax, si ; filter result between 0 and si (the nask)
	cmp al,bh    ;do again if  above the delta
	ja RandLoop
	
	add al,bl  ; add the lower limit to the rnd num
		 
@@ExitP:	
	pop di
	pop si
	pop es
	ret
endp RandomByCs


; Description  : get RND between any bl and bh includs (max 0 - 65535)
; Input        : 1. BX = min (from 0) , DX, Max (till 64k -1)
; 			     2. RndCurrentPos a  word variable,   help to get good rnd number
; 				 	Declre it at DATASEG :  RndCurrentPos dw ,0
;				 3. EndOfCsLbl: is label at the end of the program one line above END start		
; Output:        AX - rnd num from bx to dx  (example 50 - 1550)
; More Info:
; 	BX  must be less than DX 
; 	in order to get good random value again and again the Code segment size should be 
; 	at least the number of times the procedure called at the same second ... 
; 	for example - if you call to this proc 50 times at the same second  - 
; 	Make sure the cs size is 50 bytes or more 
; 	(if not, make it to be more) 
proc RandomByCsWord
    push es
	push si
	push di
 
	
	mov ax, 40h
	mov	es, ax
	
	sub dx,bx  ; we will make rnd number between 0 to the delta between bx and dx
			   ; Now dx holds only the delta
	cmp dx,0
	jz @@ExitP
	
	push bx
	
	mov di, [word RndCurrentPos]
	call MakeMaskWord ; will put in si the right mask according the delta (bh) (example for 28 will put 31)
	
@@RandLoop: ;  generate random number 
	mov bx, [es:06ch] ; read timer counter
	
	mov ax, [word cs:di] ; read one word from memory (from semi random bytes at cs)
	xor ax, bx ; xor memory and counter
	
	; Now inc di in order to get a different number next time
	inc di
	inc di
	cmp di,(EndOfCsLbl - start - 2)
	jb @@Continue
	mov di, offset start
@@Continue:
	mov [word RndCurrentPos], di
	
	and ax, si ; filter result between 0 and si (the nask)
	
	cmp ax,dx    ;do again if  above the delta
	ja @@RandLoop
	pop bx
	add ax,bx  ; add the lower limit to the rnd num
		 
@@ExitP:
	
	pop di
	pop si
	pop es
	ret
endp RandomByCsWord

; make mask acording to bh size 
; output Si = mask put 1 in all bh range
; example  if bh 4 or 5 or 6 or 7 si will be 7
; 		   if Bh 64 till 127 si will be 127
Proc MakeMask    
    push bx

	mov si,1
    
@@again:
	shr bh,1
	cmp bh,0
	jz @@EndProc
	
	shl si,1 ; add 1 to si at right
	inc si
	
	jmp @@again
	
@@EndProc:
    pop bx
	ret
endp  MakeMask


Proc MakeMaskWord    
    push dx
	
	mov si,1
    
@@again:
	shr dx,1
	cmp dx,0
	jz @@EndProc
	
	shl si,1 ; add 1 to si at right
	inc si
	
	jmp @@again
	
@@EndProc:
    pop dx
	ret
endp  MakeMaskWord



; get RND between bl and bh includs
; output al - rnd num from bl to bh
; the distance between bl and bh  can't be greater than 100 
; Bl must be less than Bh 
proc RndBlToBh  ; by Dos  with delay
	push  cx
	push dx
	push si 


	mov     cx, 1h
	mov     dx, 0C350h
	mov     ah, 86h
	int     15h   ; Delay of 50k micro sec
	
	sub bh,bl
	cmp bh,0
	jz @@EndProc
	
	call MakeMask ; will put in si the right mask (example for 28 will put 31)
RndAgain:
	mov ah, 2ch   
	int 21h      ; get time from MS-DOS
	mov ax, dx   ; DH=seconds, DL=hundredths of second
	and ax, si  ;  Mask for Highst num in range  
	cmp al,bh    ; we deal only with al (0  to 100 )
	ja RndAgain
 	
	add al,bl

@@EndProc:
	pop si
	pop dx
	pop cx
	
	ret
endp RndBlToBh



	 
proc printAxDec  
	   
       push bx
	   push dx
	   push cx
	           	   
       mov cx,0   ; will count how many time we did push 
       mov bx,10  ; the divider
   
put_next_to_stack:
       xor dx,dx
       div bx
       add dl,30h
	   ; dl is the current LSB digit 
	   ; we cant push only dl so we push all dx
       push dx    
       inc cx
       cmp ax,9   ; check if it is the last time to div
       jg put_next_to_stack

	   cmp ax,0
	   jz pop_next_from_stack  ; jump if ax was totally 0
       add al,30h  
	   mov dl, al    
  	   mov ah, 2h
	   int 21h        ; show first digit MSB
	       
pop_next_from_stack: 
       pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	   mov dl, al
       mov ah, 2h
	   int 21h        ; show all rest digits
       loop pop_next_from_stack

	   pop cx
	   pop dx
	   pop bx
	   
       ret
endp printAxDec    

  

 
; int 15h has known bug dont use it.
proc timeAx
    push  cx
	push dx
	
 	mov     cx, 0h
	mov     dx, 0C350h
	mov     ah, 86h
	int     15h   ; Delay of 50k micro sec

	
	
    mov ah, 2ch   
	int 21h      ; get time from MS-DOS
	mov ax, dx   ; DH=seconds, DL=hundredths of second
	
	pop dx
	pop cx
	
    ret	
endp timeAx
	
EndOfCsLbl:

;==========================
;==========================
;== bmp Procedures Area ===
;==========================
;==========================

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


