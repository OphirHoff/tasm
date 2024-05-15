IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
colorG db 0
endGame db 0
Xpallete dw 0
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov ax, 13h
int 10h

; draw pallete
mov cx, 30
PalleteDraw:
push [Xpallete]
push 190
push 10
push 10
mov bl, [colorG]
xor bh, bh
push bx
call DrawFullRect
inc [colorG]
add [Xpallete], 10
loop PalleteDraw

;reset color to black
mov [colorG], 0

;show mouse
mov ax, 1
int 33h

Mainloop:

mov ax, 3
int 33h

cmp bx, 1
je Draw
cmp bx, 2
je ChangeColor

mov ah, 1
int 16h
jz Mainloop

mov ah, 0
int 16h
cmp ah, 1
jne Finish
mov [endGame], 1
jmp Finish

ChangeColor:
inc [colorG]
jmp Finish

Draw:
call DrawOnScreen

Finish:
cmp [endGame], 1
jne Mainloop
; --------------------------

exit:
	mov ax, 4c00h
	int 21h
	
	
proc ClickPallete

	shr cx, 1
	mov bh, 0
	sub dx, 1
	mov ah, 0Dh
	int 10h
	
	mov [colorG], al

	ret
endp ClickPallete
;---------------------
proc DrawOnScreen
	
	cmp dx, 190
	jnae @@Draw
	call ClickPallete
	jmp @@Cont
	
	@@Draw:
	mov bh, 0
	shr cx, 1
	sub dx, 1
	mov al, [colorG]
	mov ah, 0Ch
	int 10h
	
	@@Cont:

	ret
endp DrawOnScreen
	
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

	
	
END start


