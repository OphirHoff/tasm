IDEAL
MODEL small
BMP_WIDTH = 320
BMP_HEIGHT = 200
XonDS = 4
YonDS = 6
IsActive = 0
BmpOffsetOnDs = 8
Direction = 2
IsBomb = 10
speed = 5
FruitsNum = 5 ; number of fruits exist in DS
offsetsDifference = 12
STACK 100h
DATASEG
; --------------------------
playerName    db    'xx123456x'
score         db    0
EndGame       db    0
life          db    3
LifeM         db    "Life: $"
ScoreM        db    "Score: $"
showMouse     db    1
FileName      db    "scores.txt", 0
FileHandle    dw    ?
digit         db    ?
colons        db    ": "
LineDown      db    10, 13, '$'
EnterScores   db    0
ReadNameScore db    12 dup ('$')
cnt           dw    0

saveMouseX    dw    ?
saveMouseY    dw    ?
;==========================
;==== Fruits Data Area ====
;==========================
; All fruits' offsets are equally apart from each other.
; By that, every procedure can "reach" and change all fruits at once

; Every fruit has it's own "API" with "properties"

		      ;X   ;Y
pri1 dw 0, 0, 15, 160, 0, 0
       ;0. Is Active?
	   ;1. Where is it moving? (up = 0 / down = 1)
	   ;2. X position
	   ;3. Y position
	   ;4. Current Bmp Picture offset
	   ;5. Is it a Bomb?
	 
		      ;X   ;Y
pri2 dw 0, 0, 65, 160, 0, 0
       ; 0. Is Active?
	   ; 1. Where is it moving? (up = 0 / down = 1)
	   ; 2. X position
	   ; 3. Y position
	   ; 4. Current Bmp Picture offset
	   ; 5. Is it a Bomb?
	   
		      ; X   ;Y
pri3 dw 0, 0, 115, 160, 0, 0
		; 0. Is Active?
		; 1. Where is it moving? (up = 0 / down = 1)
		; 2. X position
		; 3. Y position
		; 4. Current Bmp Picture offset
		; 5. Is it a Bomb?
		
		      ; X   ;Y
pri4 dw 0, 0, 165, 160, 0, 0
		; 0. Is Active?
		; 1. Where is it moving? (up = 0 / down = 1)
		; 2. X position
		; 3. Y position
		; 4. Current Bmp Picture offset
		; 5. Is it a Bomb?
			
		      ; X   ;Y
pri5 dw 0, 0, 215, 160, 0, 0
		; 0. Is Active?
		; 1. Where is it moving? (up = 0 / down = 1)
		; 2. X position
		; 3. Y position
		; 4. Current Bmp Picture offset
		; 5. Is it a Bomb?
		
matrix1 db 1560 dup (?)
matrix2 db 1560 dup (?)
matrix3 db 1560 dup (?)
matrix4 db 1560 dup (?)
matrix5 db 1560 dup (?)

matrixArr dw offset matrix1, offset matrix2, offset matrix3, offset matrix4, offset matrix5

; Fruits dw pri1, pri2, pri3, pri4

		
activeFruits db 0 ; This Variable hols the number of active fruits on the screen
addNewFruits db 0 ; This variable holds the number of fruits needed to be activated
activateDelay db 0 ; This variable holds the number of cycles from the last time a fruit was activated
;==========================
;===== Bmp Data Area ======
;==========================
	OneBmpLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer
    ScrLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer

	;BMP File data
	EnterNameScreen db    'name.bmp', 0
	startPic        db    'start.bmp', 0
	GameOverPage    db    'gg.bmp', 0
	ExitPage        db    'exit.bmp', 0
	scoresPage      db    'scores.bmp', 0
	cursor          db    'cursor.bmp', 0
	ApplePic 	    db    'apple.bmp', 0
	bananaPic       db    'banana.bmp', 0
	BombPic         db    'bomb.bmp', 0
	backgroundPic   db    'back.bmp', 0
	Header 	        db 54 dup(0)
	Palette 	    db 400h dup (0)
	
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
call Open_Page

cmp [EndGame], 1
je exit

call Get_Name

call DrawBackground


mov ax, 1h
int 33h ; Show mouse

call Set_Game

mov si, 0
; mov [pri1+si+BmpOffsetOnDs], offset bananaPic
; call DrawSpecFruit

MainLoop:
call CheckEndGame
; call MoveSpecFruit
call MoveFruit
call CheckBoundries
; call CheckSpecBoundries
call CheckMouseClick
call AddFruitsToScreen
call CheckAllFruitsSliced
call LoopDelay
inc [activateDelay]
cmp [EndGame], 1
je GameFinish

; cmp si, 60
; jne Good

; mov si, 0

Good:
; add si, offsetsDifference

	jmp MainLoop


GameFinish:

call After_Game

cmp [EnterScores], 1
je Scores_Page
cmp [EndGame], 1
je exit

Scores_Page:
call ShowScores
call WaitForClick


; --------------------------

exit:

	mov ax,2
	int 10h
	
	mov ax, 4c00h
	int 21h
;--------------------------
proc Set_Game

	call NewFruits
	call UpdateLife
	call UpdateScore
	call CopyMatrixAll

	ret
endp Set_Game
	
;--------------------------
proc Get_Name

	call ShowNamePage
	call GetName

	ret
endp Get_Name
	
;--------------------------
proc Open_Page

	call SetGraphic
	call ShowStartPage
	call WaitForClick

	ret
endp Open_Page

;--------------------------
proc After_Game

	mov ax, 2
	int 33h
	call ShowGameOver ; show "GAME OVER" Screen
	call LoopDelay3Sec
	
	; Update Scores File
	call OpenScoresFile
	call WriteNameScore
	call CloseScoresFile

	call ShowExitPage
	call WaitForClick
	
	ret
endp After_Game
	
;--------------------------
proc ShowScores

	mov dx, offset scoresPage
	mov [BmpLeft], 0
	mov [BmpTop], 0
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	call OpenShowBmp
	
	;Open File For Reading
	mov ah, 3Dh
	mov dx, offset FileName
	mov al, 0
	int 21h
	mov [FileHandle], ax
	
	; Set Writing coordinates
	mov ah, 2
	mov bh, 0
	mov dh, 4
	mov dl, 13
	int 10h
	
	mov cx, 10
	PrintNameScore:
	push cx
	push dx
	
	mov dx, offset ReadNameScore
	mov si, 0
	Read:
	mov ah, 3Fh
	mov bx, [FileHandle]
	mov cx, 1
	int 21h                     ; Read one char from line
	cmp [ReadNameScore+si], 10  ; If char is 10 (New Line) - stop reading
	je @@Cont
	inc si
	inc dx
	jmp Read
	
	@@Cont:
	mov [ReadNameScore+si], '$'   ;replace 10 (New Line) with '$' to stop reading there
	mov dx, offset ReadNameScore
	mov ah, 9
	int 21h ; Print name + score on Screen
	
	
	;Reset ReadNameScore buffer
	mov cx, 12
	mov si, 0
	Reset:
	mov [ReadNameScore+si], '$'
	inc si
	loop Reset
	
	; Move file pointer Line Down
	mov ah, 42h
	mov al, 1
	mov bx, [FileHandle]
	mov cx, 0
	mov dx, 1
	int 21h
	
	pop dx
	; Move line down on screen
	mov ah, 2
	mov bh, 0
	add dh, 2
	mov dl, 13
	int 10h
	
	pop cx
	loop PrintNameScore
	
	call CloseScoresFile

	ret
endp ShowScores
;--------------------------
; This procedure updates the scores in the scores txt file (scores.txt)

proc WriteNameScore

	; move writing pointer to the end of the file to start writing from the write spot
	mov ah, 42h
	mov al, 2
	mov bx, [FileHandle]
	mov cx, 0
	mov dx, 0
	int 21h
	
	; Write last player's name in file
	mov ah, 40h
	mov bx, [FileHandle]
	mov dx, offset playerName+2 ; player name start from 2nd because of 0Ah interrupt
	xor cx, cx
	mov cl, [playerName+1] ; number of chars in name (0Ah int)
	int 21h
	
	;Write colons for asthetics
	mov ah, 40h
	mov bx, [FileHandle]
	mov dx, offset colons
	mov cx, 2
	int 21h
	
	;This loop casts the value score into string and writes it into the file
	mov bl, 100 ; divider - in order to get hundreds, dozens, units
	mov cx, 3   ; repeat 3 times - byte can be up to 3 digits (255)
	WriteScore:
	push cx
	
	xor ax, ax
	mov al, [score]
	div bl ; find the biggest dig
	
	mov [score], ah ; store the rest of the number back in score variable
	
	; Write the Digit in the file
	push bx
	mov [digit], al
	add [digit], '0'
	mov ah, 40h
	mov bx, [FileHandle]
	mov dx, offset digit
	mov cx, 1
	int 21h
	pop bx
	
	; Divide the divider by 10 each time
	xor ax, ax
	mov al, bl
	mov bl, 10
	div bl
	mov bl, al
	
	pop cx
	loop WriteScore
	
	; move Line Down in File
	mov ah, 40h
	mov bx, [FileHandle]
	mov dx, offset LineDown
	mov cx, 2
	int 21h
	
	
	@@Cont:

	ret
endp WriteNameScore

;--------------------------
proc CloseScoresFile

	mov ah, 3Eh
	mov bx, [FileHandle]
	int 21h

	ret
endp CloseScoresFile
;--------------------------
proc OpenScoresFile

	mov al,2
	mov ah,3dh
	mov dx,offset FileName
	int 21h
	mov [FileHandle],ax

	ret
endp OpenScoresFile
	
;--------------------------
proc GetName

	; Set Coordinates on screen
	mov ah, 2
	mov bh, 0
	mov dh, 20
	mov dl, 18
	int 10h
	
	
	mov [byte playerName], 7
	mov dx, offset playerName
	mov ah, 0Ah
	int 21h

	ret
endp GetName
;--------------------------
proc WaitForClick

	WaitForData:
	mov ah, 1
	int 16h
	jz WaitForData
	
	; Check if clicked ENTER
	mov ah, 0
	int 16h
	cmp ah, 1Ch
	je @@Cont
	
	; Check if clicked ESC
	cmp ah, 1
	jne @@Check_Space
	mov [EndGame], 1
	jmp @@Cont
	
	@@Check_Space:
	; Check if clicked Spacebar
	cmp ah, 39h
	jne WaitForData
	mov [EnterScores], 1
	
	
	@@Cont:

	ret
endp WaitForClick
;--------------------------
proc ShowGameOver

	mov dx, offset GameOverPage
	mov [BmpLeft], 0
	mov [BmpTop], 0
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	call OpenShowBmp

	ret
endp ShowGameOver
;--------------------------
proc ShowExitPage

	mov dx, offset ExitPage
	mov [BmpLeft], 0
	mov [BmpTop], 0
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	call OpenShowBmp

	ret
endp ShowExitPage
;--------------------------
proc ShowNamePage

	mov dx, offset EnterNameScreen
	mov [BmpLeft], 0
	mov [BmpTop], 0
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	call OpenShowBmp

	ret
endp ShowNamePage
;--------------------------
proc ShowStartPage

	mov dx, offset startPic
	mov [BmpLeft], 0
	mov [BmpTop], 0
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	call OpenShowBmp

	ret
endp ShowStartPage
;--------------------------
; Update "Score" counter in the corner of the screen

proc UpdateScore

	push ax
	push bx
	push dx

	; Set Coordinates to write on screen 
	mov ah, 2
	mov bh, 0
	mov dh, 1
	mov dl, 0
	int 10h
	
	mov ah, 9
	mov dx, offset ScoreM
	int 21h
	
	xor ax, ax
	mov al, [score]
	call ShowAxDecimal
	
	pop dx
	pop bx
	pop ax

	ret
endp UpdateScore
	
;--------------------------
; Update "Lives" counter in the corner of the screen

proc UpdateLife

	push ax
	push bx
	push dx
	
	; Set Coordinates to write on screen 
	mov ah, 2
	mov bh, 0
	mov dh, 0
	mov dl, 0
	int 10h
	
	mov ah, 9
	mov dx, offset LifeM
	int 21h
	
	xor ax, ax
	mov al, [life]
	call ShowAxDecimal
	
	pop dx
	pop bx
	pop ax

	ret
endp UpdateLife
	
;--------------------------
proc CheckEndGame

	; Check if escape button was clicked
	mov ah, 1
	int 16h
	jz CheckLife
	
	mov ah, 0
	int 16h
	cmp ah, 1
	jne @@Cont
	mov [EndGame], 1
	jmp @@Cont
	
	; Check if there is no more "lives" remaining
	CheckLife:
	cmp [life], 0
	jne @@Cont
	mov [EndGame], 1
	
	@@Cont:

	ret
endp CheckEndGame

;==========================
;= Fruits Procedures Area =
;==========================

; This procedure gets a fruit's offset and a fruit's matrix offset as a parameter and copys the specific fruit's destination's background

PriOnDs equ [bp+6]
matrix equ [bp+4]


proc CopySpecMatrix

	push bp
	mov bp, sp
	
	mov ax, matrix ;To di
	push ax

	mov si, PriOnDs
	call FindLocation
	push ax
	
	mov ax,39 ;To cx
	push ax
	
	mov ax,40
	push ax
	
	call Copy
	
	pop bp

	ret 4
endp CopySpecMatrix
;--------------------------
; This Procedure goes over all fruits and copys each one of their destinations' background to DS

proc CopyMatrixAll

	mov cx, FruitsNum
	mov si, 0 ; fruits' offset
	mov bx, 0 ; fruit's matrix offset in Matrixes Array
	CopyMatrix:

	mov ax, [matrixArr+bx] ;To di
	push ax

	call FindLocation ; find location on a0000 (1-64000)
	push ax
	
	mov ax,39 ; height
	push ax
	
	mov ax,40 ; width
	push ax
	
	call Copy
	
	@@Cont:
	add si, offsetsDifference
	add bx, 2
	loop CopyMatrix

	ret
endp CopyMatrixAll
;--------------------------
; This procedure checks if there are fruits needed to be added to screen

proc AddFruitsToScreen

	cmp [addNewFruits], 0
	je @@Cont
	
	call ActivateFruits
	
	@@Cont:
	
	ret
endp AddFruitsToScreen
;--------------------------
; This procedure Checks if all fruits were sliced.
; If indeed all fruits were sliced, make new fruits.

proc CheckAllFruitsSliced

	
	cmp [activeFruits], 0 ; check number of active fruits on screen
	jne @@Cont
	
	cmp [addNewFruits], 0
	jne @@Cont            ; Check if there are no more fruits to activate/add add
	
	;Make new Fruits
	call NewFruits
	
	@@Cont:

	ret
	
endp CheckAllFruitsSliced

;--------------------------
proc NewFruits

	mov bl, 1
	mov bh, FruitsNum
	call RandomByCs ; grill random quantity of fruits
	mov [addNewFruits], al
	call CopyMatrixAll ; save background for all
	mov [activateDelay], 225 ; Make a 50 cycles delay before starting to activate new fruits (225+50=20 in one byte)

	ret
endp NewFruits
;--------------------------
; This procedure grills a random fruit on DS
; Fruits offset (relatively to pri1) stored in si

proc GrillFruit

	push ax
	push bx
	push cx

	xor ax, ax
	xor cx, cx

	mov bl, 0
	mov bh, FruitsNum-1
	call RandomByCs ; grill number

	mov cl, al
	mov si, 0
	FindFruit:
	add si, offsetsDifference
	loop FindFruit ; Get to fruits' offset on DS relatively to pri1

	pop cx
	pop bx
	pop ax

	ret
endp GrillFruit
;--------------------------
; This procedure is responsible for activating a random fruit that isnt already active
; according to the number grilled

proc ActivateFruits
	
	push ax
	push cx
	push si
	
	cmp [activateDelay], 20; check if it is time to activate another fruit (every x cycles)
	jne @@NotYet
	
	Grill:
	call GrillFruit ; grill a random fruit from DS

	cmp [pri1+si+IsActive], 1 ; check if fruit is already active
	je Grill
	
	; Determine if the fruit is a bomb or not
	mov bl, 1
	mov bh, 5
	call RandomByCs
	cmp al, 3 ; if grilled number is 3 - fruit is a bomb
	jne NotBomb
	; If reached here the fruit is a bomb
	mov [pri1+si+IsBomb], 1 ; set bomb
	mov [pri1+si+BmpOffsetOnDs], offset BombPic ; set bmp pic bomb
	jmp @@Cont
	
	NotBomb:
	mov [pri1+si+IsBomb], 0
	call GrillBmp ; Grill the fruit a random bmp fruit picture
	
	@@Cont:
	mov [pri1+si+IsActive], 1 ; activate fruit
	mov [pri1+si+Direction], 0 ; set direction: up
	add [activeFruits], 1 ; increment number of active fruits on screen
	dec [addNewFruits] ; decrement number of fruits needed to be added to screen
	mov [activateDelay], 0 ; reset cycles delay counter
	
	push si
	mov ax, si
	mov bl, offsetsDifference
	div bl
	mov bx, ax
	push [matrixArr+bx]
	call CopySpecMatrix
	
	@@NotYet:

	pop si
	pop cx
	pop ax
	
	ret
endp ActivateFruits

;--------------------------
; Check if mouse click occured
proc CheckMouseClick

	push ax
	push bx

	mov ax, 3
	int 33h ; mouse input

	cmp bx, 1 ; check if click occured
	; jne @@Cont

	shr cx, 1
	sub dx, 1
	
	call CheckSlice
	
	@@Cont:

	pop bx
	pop ax

	ret
endp CheckMouseClick
;--------------------------
proc CheckSpecSlice

	push bx
	push cx
	push dx
	push si
	
	mov bx, cx ; bx holds fruit's x position

	cmp [pri1+si+IsActive], 1 ; check if fruit is "active"
	jne @@Cont
	
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
	call DelFruit ; Delete Fruit from screen
	mov [pri1+si+IsActive], 0 ; deactivate fruit
	mov [pri1+si+YonDS], 160 ; set y position back to starting point
	dec [activeFruits] ; decrement number of active fruits on screen
	
	;------Might be useless------
	push si
	mov ax, si
	mov bl, offsetsDifference
	div bl ; find index of matrix on MatrixArr
	mov bx, ax
	push [matrixArr+bx]
	call CopySpecMatrix
	;----------------------------
	
	cmp [pri1+si+IsBomb], 1 ; check if object is a bomb
	jne @@NotBomb
	
	; If a bomb was sliced - game ends
	mov [EndGame], 1
	jmp @@Cont
	
	@@NotBomb:
	add [score], 5
	call UpdateScore
	
	@@Cont:
	
	pop si
	pop dx
	pop cx
	pop bx

	ret
endp CheckSpecSlice
;--------------------------
; This procedure goes over all ACTIVE fruits and checks if it was sliced
; If the fruit was sliced - it deactivates it

proc CheckSlice
	
	push bx
	push cx
	push dx
	push si
	
	mov [saveMouseX], cx
	mov [saveMouseY], dx
	
	mov bx, cx ; bx holds fruit's x position
	mov si, 0 ; Fruits' offset
	xor cx, cx
	mov cx, FruitsNum
	CheckSliceAll:
	
	cmp [pri1+si+IsActive], 1 ; check if fruit is "active"
	jne @@Cont
	
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

	; mov ah, 2
	; mov bh, 0
	; mov dh, 12
	; mov dl, 20
	; int 10h

	; mov ax, [cnt]
	; call ShowAxDecimal
	; inc [cnt]

	call DelFruit ; Delete Fruit from screen
	mov [pri1+si+IsActive], 0 ; deactivate fruit
	mov [pri1+si+YonDS], 160 ; set y position back to starting point
	dec [activeFruits] ; decrement number of active fruits on screen
	
	;------Might be useless------
	; push si
	; mov ax, si
	; mov bl, offsetsDifference
	; div bl ; find index of matrix on MatrixArr
	; mov bx, ax
	; push [matrixArr+bx]
	; call CopySpecMatrix
	;----------------------------
	
	cmp [pri1+si+IsBomb], 1 ; check if object is a bomb
	jne @@NotBomb
	
	; If a bomb was sliced - game ends
	mov [EndGame], 1
	jmp NotActive
	
	@@NotBomb:
	add [score], 5
	call UpdateScore
	jmp NotActive
	
	@@Cont:
	mov bx, [saveMouseX]
	mov dx, [saveMouseY]

	add si, offsetsDifference ; Move on to Next Fruit on DS
		loop CheckSliceAll
	
	NotActive:
	
	pop si
	pop dx
	pop cx
	pop bx

	ret
endp CheckSlice

;--------------------------

; fruitOffset equ [bp+4]

proc MoveSpecFruit

	push si

	cmp [pri1+si+IsActive], 1 ; Check if fruit is currently "active" 
	jne @@Cont

	call DelSpecFruit ; Delete fruit
	
	cmp [Pri1+si+Direction], 0 ; check if moving up/down
	je @@UP
	
	;Moving Down
	add [pri1+si+YonDS], speed
	jmp @@Cont
	
	@@UP:
	sub [pri1+si+YonDS], speed
	
	@@Cont:
	
	call DrawSpecFruit
	
	pop si

	ret
endp MoveSpecFruit
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
	add si, offsetsDifference
	loop MoveAll
	
	call DrawFruit
	
	pop cx
	pop si
	ret
endp MoveFruit
;--------------------------
y equ [pri1+si+YonDS]

proc CheckSpecBoundries

	push cx
	push si
	
	cmp [pri1+si+IsActive], 1
	jne @@Cont
	
	cmp y, 3
	jbe @@ReachedTop ;check if fruit hit the top
	cmp y, 160
	jnae @@Cont ;check if fruit reached bottom
	
	;Reached Bottom:
	call DelFruit
	mov [pri1+si+IsActive], 0 ; Deactivate fruit
	mov [pri1+si+YonDS], 160
	sub [activeFruits], 1
	
	cmp [pri1+si+IsBomb], 1
	je @@Bomb ; if fruit is a bomb - do not dec life
	
	dec [life]
	call UpdateLife
	jmp @@Cont
	
	@@ReachedTop:
	push si
	call ChangeDirection ; make fruit go down
	
	@@Bomb:
	; mov [pri1+si+IsBomb], 0 ; reset IsBomb property
	
	@@Cont:
	
	pop si
	pop cx

	ret
endp CheckSpecBoundries
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
	
	cmp y, 3
	jbe ReachedTop ;check if fruit hit the top
	cmp y, 160
	jnae @@Cont ;check if fruit reached bottom
	
	;Reached Bottom:
	call DelFruit
	mov [pri1+si+IsActive], 0 ; Deactivate fruit
	mov [pri1+si+YonDS], 160
	sub [activeFruits], 1
	
	cmp [pri1+si+IsBomb], 1
	je Bomb ; if fruit is a bomb - do not dec life
	
	dec [life]
	call UpdateLife
	jmp @@Cont
	
	ReachedTop:
	push si
	call ChangeDirection ; make fruit go down
	
	Bomb:
	; mov [pri1+si+IsBomb], 0 ; reset IsBomb property
	
	@@Cont:
	add si, offsetsDifference
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
proc DelSpecFruit

	push ax
	push cx
	push dx
	push si
	
	mov dx, 40
	mov cx, 39
	call FindLocation
	mov di, ax
	mov dx, 40
	mov cx, 39
	
	mov ax, si
	mov bl, offsetsDifference
	div bl
	mov bx, ax
	push [matrixArr+bx]
	call PutMatrixInScreen
	
	pop si
	pop dx
	pop cx
	pop ax

	ret
endp DelSpecFruit
;--------------------------
; this procedure goes over all fruits and deletes them

y equ [pri1+si+YonDS]
x equ [pri1+si+XonDS]


proc DelFruit
	
	push bp
	mov bp, sp
	
	push si
	push cx
	
	mov ax, 2
	int 33h
	
	mov bx, 0 ; bx holds fruit's matrix index in MatrixArr
	mov si, 0 ; si holds the fruit's offset
	; mov matrixCnt, 0 ; matrixCnt holds the fruit's matrix
	mov cx, FruitsNum
	DelAll:
	
	cmp [pri1+si+IsActive], 1 ; Check if fruit is active
	jne @@Cont
	
	; in dx how many cols 
	; in cx how many rows
	; in matrix - the bytes
	; in di start byte in screen (0 64000 -1)
	push si
	push cx
	
	mov dx, 40
	mov cx, 39
	call FindLocation
	mov di, ax
	mov dx, 40
	mov cx, 39
	push [matrixArr+bx]
	
	call PutMatrixInScreen
	
	pop cx

	pop si
	
	@@Cont:
	add si, offsetsDifference ; move to next fruit offset
	add bx, 2 ; next fruit's matrix
		loop DelAll
		
	mov ax, 1
	int 33h
		
	pop cx
	pop si
	pop bp
	

	ret
endp DelFruit
;--------------------------
;==========================
matrix equ [bp+4]

proc PutMatrixInScreen

	push bp
	mov bp, sp

	cld ;sets direction of movsb to copy forward
	mov si, matrix ; puts offset of the Matrix to si
	NextRow:	; loop of cx lines
		push cx ;saves cx of loop
		mov cx, dx ;sets cx for movsb
		rep movsb ; Copy whole line to the screen, si and di increases
		sub di,dx ; returns back to the begining of the line 
		add di, 320 ;go down one line in “screen” by adding 320
		pop cx  ;restores cx of loop
		loop NextRow
	
	pop bp

	ret 2
endp PutMatrixInScreen
;--------------------------
; This Procedure Copies a part of the background to the DS
; In order to "delete" the fruit on the same spot afterwards
proc Copy
	push bp
	mov bp,sp
	
	push di
	push si
	push cx
	push dx
	
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

	pop dx
	pop cx
	pop si
	pop di
	
	
	

	pop bp
	ret 8
endp Copy

;--------------------------
proc GrillBmp

	push bx
	push ax

	mov bl, 1
	mov bh, 2
	call RandomByCs
	
	cmp al, 1
	jne @@OtherBmp
	mov [pri1+si+BmpOffsetOnDs], offset ApplePic
	jmp @@Cont
	
	@@OtherBmp:
	mov [pri1+si+BmpOffsetOnDs], offset bananaPic
	
	@@Cont:
	
	pop ax
	pop bx

	ret
endp GrillBmp

;--------------------------
y equ [byte pri1+si+YonDS]
x equ [pri1+si+XonDS]

proc DrawSpecFruit

	push bp
	mov bp, sp
	push ax
	push bx
	push dx
	push si
	push cx
	
	mov ax, 2
	int 33h ; hide mouse

	mov ax, si
	mov bl, offsetsDifference
	div bl
	mov bx, ax

	cmp [pri1+si+IsActive], 1 ; check if fruit is "active"
	jne @@Cont
	
	push cx
	
	mov ax, [matrixArr+bx] ;To di
	push ax
	call FindLocation ; find fruit's location in a0000 (1-64000)
	push ax
	mov ax,39 ;To cx
	push ax
	mov ax,40
	push ax
	
	call Copy ; Save background
	
	pop cx
	
	
	push bx
	
	;Draw Fruit
	mov dx, [pri1+si+BmpOffsetOnDs]
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
	
	pop bx
	
	@@Cont:
	
	mov ax, 1
	int 33h ; Show Mouse
	
	pop cx
	pop si
	pop dx 
	pop bx
	pop ax
	pop bp

	ret
endp DrawSpecFruit
;--------------------------
;this procedure goes over all ACTIVE fruits and draws them
; Before drawing each fruit, it saves the background behind in the correct matrixes

y equ [byte pri1+si+YonDS]
x equ [pri1+si+XonDS]

proc DrawFruit

	push bp
	mov bp, sp
	push ax
	push bx
	push dx
	push si
	push cx
	
	mov ax, 2
	int 33h ; hide mouse
	
	mov si, 0
	mov bx, 0 ; Hold the fruits' offset matrix in Matrixes array
	mov cx, FruitsNum
	DrawAll:
	cmp [pri1+si+IsActive], 1 ; check if fruit is "active"
	jne @@Cont
	
	push cx
	
	mov ax, [matrixArr+bx] ;To di
	push ax
	call FindLocation ; find fruit's location in a0000 (1-64000)
	push ax
	mov ax,39 ;To cx
	push ax
	mov ax,40
	push ax
	
	call Copy ; Save background
	
	pop cx
	
	
	push bx
	
	;Draw Fruit
	mov dx, [pri1+si+BmpOffsetOnDs]
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
	
	pop bx

	
	@@Cont:
	add si, offsetsDifference ; move on to next fruit's offset
	add bx, 2                 ; next Fruit's matrix offset on MatrixArr
	loop DrawAll
	
	mov ax, 1
	int 33h
	
	pop cx
	pop si
	pop dx 
	pop bx
	pop ax
	pop bp
	
	ret 
endp DrawFruit
;--------------------------
y equ [byte pri1+si+YonDS]
x equ [pri1+si+XonDS]

proc FindLocation; changes xy cooardinates to a 1-64000
	push bx
	xor bx, bx
	mov bl,y
	dec bx
	mov ax,320
	mul bx
	add ax, x
	pop bx
	ret
endp FindLocation
;--------------------------
proc DrawBackground
	
	mov dx, offset backgroundPic
	mov [BmpLeft], 0
	mov [BmpTop], 0
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	call OpenShowBmp
	
	ret
endp DrawBackground
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
	@@draw_line:	; Copy line to the screen
	mov al, [byte ds:si]
	cmp al, 255 ; was 246
	je @@end ; if it is equal to one we need to skip it
	mov [byte es:di], al
	@@end:
	inc si
	inc di
	loop @@draw_line
	
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


