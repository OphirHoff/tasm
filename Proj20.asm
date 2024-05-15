IDEAL
MODEL small
BMP_WIDTH = 40
BMP_HEIGHT = 40
XonDS = 4
YonDS = 6
IsActive = 0
Direction = 2
speed = 1
FruitsNum = 4 ; number of fruits exist in DS
STACK 100h
DATASEG
; --------------------------

;==========================
;==== Fruits Data Area ====
;==========================
; All fruits are equally apart from each other.
; By that, every procedure can "reach" and change all fruits at once

; Every fruit has it's own "API" with "properties"
pri1 dw 0, 0, 260, 160, 0
       ;0. Is Active?
	   ;1. Where is it moving? (up = 0 / down = 1)
	   ;2. X position
	   ;3. Y position
	   ;4. Was it cut?
	   
pri2 dw 0, 0, 200, 160, 0
       ;0. Is Active?
	   ;1. Where is it moving? (up = 0 / down = 1)
	   ;2. X position
	   ;3. Y position
	   ;4. Was it cut?
	   
pri3 dw 0, 0, 100, 160, 0
		;0. Is Active?
		;1. Where is it moving? (up = 0 / down = 1)
		;2. X position
		;3. Y position
		;4. Was it cut?
		
pri4 dw 0, 0, 40, 160, 0
		;0. Is Active?
		;1. Where is it moving? (up = 0 / down = 1)
		;2. X position
		;3. Y position
		;4. Was it cut?
		
activeFruits db 0
newFruits db 0 ; This variable holds the number of fruits needed to be activated
	   

;==========================
;===== Bmp Data Area ======
;==========================
	OneBmpLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer
    ScrLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer

	;BMP File data
	ApplePic 	db 'apple.bmp', 0
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	
	SmallPicName db 'Pic48X78.bmp',0
	
	
	BmpFileErrorMsg    	db 'Error At Opening Bmp File ', 0dh, 0ah,'$'
	ErrorFile           db 0

	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ?
	
;Random numbers Variables area
RndCurrentPos dw  0

; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov ax, 13h
int 10h

mov ax, 1h
int 33h

call NewFruits

loop1:
call MoveFruit
call CheckBoundries
call CheckMouseClick
call CheckAllFruitsSliced 
call LoopDelay
jmp loop1


; --------------------------

exit:
	mov ax, 4c00h
	int 21h
	
;==========================
;= Fruits Procedures Area =
;==========================
;--------------------------
; This procedure Checks if all fruits were sliced.
; If indeed all fruits were sliced, make new fruits.

proc CheckAllFruitsSliced

	cmp [activeFruits], 0 ; check number of active fruits on screen
	jne @@Cont
	
	;Make new Fruits
	call NewFruits
	
	@@Cont:

	ret
	
endp CheckAllFruitsSliced

;--------------------------
proc NewFruits

	mov bl, 1
	mov bh, FruitsNum
	mov [howManyNewFruits], al
	call RandomByCs
	
	call ActivateFruits

	ret
endp NewFruits
;--------------------------
; This procedure goes over fruits and activates them
; according to the number grilled

proc ActivateFruits

	push ax
	push cx
	push si

	xor cx, cx
	mov cl, al
	mov si, 0

	Activate:
	
	cmp [pri1+si+IsActive], 1
	
	
	mov [pri1+si+IsActive], 1
	mov [pri1+si+Direction], 0
	mov [pri1+si+YonDS], 160
	
	add [activeFruits], 1
	
	NextFruit:
	push cx
	mov cx, 30
	Attempt:
	call MoveFruit
	; call CheckMouseClick
	call LoopDelay
	loop Attempt
	pop cx
	add si, 10 ; Move on to the Next Fruit
	
	; cmp si, 40
	; je @@Cont
	loop Activate
	
	@@Cont:

	pop si
	pop cx
	pop ax
	
	ret
endp ActivateFruits

;--------------------------

proc CheckMouseClick

	push ax
	push bx

	mov ax, 3
	int 33h

	cmp bx, 1
	jne @@Cont
	
	call CheckSlice
	
	@@Cont:

	pop bx
	pop ax

	ret
endp CheckMouseClick
;--------------------------
; This procedure goes over all ACTIVE fruits and checks if it was sliced
; If the fruit was sliced - it deactivates it

proc CheckSlice
	
	push bx
	push cx
	push dx
	push si
	
	shr cx, 1
	mov bx, cx
	mov si, 0
	xor cx, cx
	mov cl, [activeFruits]
	CheckSliceAll:
	
	cmp [pri1+si+IsActive], 1 ; check if fruit is "active"
	jne @@NotActive
	
	; Check hit on X axis
	cmp bx, [pri1+si+XonDS]
	jnae @@Cont
	sub bx, 40
	cmp bx, [pri1+si+XonDS]
	jnbe @@Cont
	add bx, 40
	; Check hit on y axis
	cmp dx, [pri1+si+YonDS]
	jnae @@Cont
	sub dx, 40
	cmp dx, [pri1+si+YonDS]
	jnbe @@Cont
	add dx, 40
	
	;If Reached this part - fruit was "sliced"
	mov [pri1+si+IsActive], 0
	dec [activeFruits]
	call DelFruit
	jmp @@Cont
	
	@@NotActive:
	add cx, 1
	@@Cont:
	add si, 10 ; Move on to Next Fruit
	loop CheckSliceAll
	
	NotActive:
	
	pop si
	pop dx
	pop cx
	pop bx

	ret
endp CheckSlice


;--------------------------
; This procedure goes over all ACTIVE fruits and moves them to the right direction

proc MoveFruit

	push si
	push cx

	call DelFruit
	
	mov si, 0
	mov cx, FruitsNum
	MoveAll:
	
	cmp [pri1+si+IsActive], 1 ; Check if fruit is currently "active" 
	jne @@Cont
	
	cmp [Pri1+si+Direction], 0 ; check if moving up/down
	je UP
	
	;Moving Down
	add [pri1+si+YonDS], speed
	jmp @@Cont
	
	UP:
	sub [pri1+si+YonDS], speed
	
	@@Cont:
	add si, 10
	loop MoveAll
	
	call DrawFruit
	
	pop cx
	pop si
	ret
endp MoveFruit
;--------------------------
y equ [pri1+si+YonDS]

proc CheckBoundries

	push cx
	push si

	mov si, 0
	mov cx, FruitsNum
	CheckAll:
	
	cmp [pri1+si+IsActive], 1
	jne @@Cont
	
	cmp y, 5
	jbe ReachedTop ;check if fruit hit the top
	cmp y, 160
	jnae @@Cont ;check if fruit reached bottom
	
	;Reached Bottom:
	mov [pri1+si+IsActive], 0 ; make fruit disappear
	sub [activeFruits], 1
	jmp @@Cont
	
	
	ReachedTop:
	push si
	call ChangeDirection ; make fruit go down
	
	@@Cont:
	add si, 10
	loop CheckAll
	
	
	pop si
	pop cx
	
	ret
endp CheckBoundries
;--------------------------
; this procedure will make the fruit go down

priNum equ [bp+4]

proc ChangeDirection

	push bp
	mov bp, sp
	push bx
	
	mov bx, priNum
	mov [pri1+bx+Direction], 1
	
	pop bx
	pop bp
	
	ret 2
endp ChangeDirection
;--------------------------
; this procedure goes over all fruits and deletes them

y equ [pri1+si+YonDS]
x equ [pri1+si+XonDS]

proc DelFruit
	
	push si
	push cx
	
	mov si, 0 ; si holds the fruits' offset
	mov cx, FruitsNum
	DelAll:
	push x
	push y
	push BMP_HEIGHT
	push BMP_WIDTH
	push 0
	call DrawFullRect ; "delete"
	add si, 10 ; move to next fruit offset
		loop DelAll
		
	pop cx
	pop si

	ret
endp DelFruit


;--------------------------
;this procedure goes over all ACTIVE fruits and draws them

y equ [byte pri1+si+YonDS]
x equ [pri1+si+XonDS]

proc DrawFruit

	push bx
	push dx
	push si
	push cx
	
	mov si, 0
	mov cx, FruitsNum
	DrawAll:
	cmp [pri1+si+IsActive], 1 ; check if fruit is "active"
	jne @@Cont
	
	;Draw Fruit
	mov dx, offset ApplePic
	mov bx, x
	mov [BmpLeft], bx
	xor bx, bx
	mov bl, y
	mov [BmpTop], bx
	mov [BmpColSize], 40
	mov [BmpRowSize], 39
	push si
	call OpenShowBmp
	pop si

	
	@@Cont:
	add si, 10 ; move on to next fruit's offset
	loop DrawAll
	
	pop cx
	pop si
	pop dx 
	pop bx
	
	ret
endp DrawFruit

	
;==========================
;== graphics procedures ===
;==========================
;--------------------------
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
;Delay procedure

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

;-----------------

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
	
	;mov ax, 2
	;int 10h

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	
;==========================
;==========================
;== Bmp Procedures Area ===
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

;==========================
;==========================
;= Random Procedures Area =
;==========================
;==========================

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

END start


