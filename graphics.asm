IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------

; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
mov ax, 13h
int 10h

; פ
push 255
push 20
push 5
push 45
push 1
call DrawFullRect

push 300
push 20
push 50
push 5
push 1
call DrawFullRect

push 255
push 65
push 5
push 45
push 1
call DrawFullRect

push 255
push 25
push 15
push 5
push 1
call DrawFullRect

push 255
push 40
push 5
push 15
push 1
call DrawFullRect

; האות ו

push 240
push 20
push 50
push 5
push 4
call DrawFullRect

;האות ר

push 180
push 20
push 5
push 45
push 4
call DrawFullRect

push 220
push 20
push 50
push 5
push 4
call DrawFullRect

; האות י

push 170
push 20
push 20
push 5
push 14
call DrawFullRect

;האות ם

push 115
push 20
push 5
push 45
push 14
call DrawFullRect

push 115
push 20
push 50
push 5
push 14
call DrawFullRect

push 160
push 20
push 50
push 5
push 14
call DrawFullRect

push 115
push 70
push 5
push 50
push 14
call DrawFullRect

; האות ש

push 155
push 100
push 45
push 5
push 15
call DrawFullRect

push 115
push 145
push 5
push 45
push 15
call DrawFullRect

push 115
push 100
push 45
push 5
push 15
call DrawFullRect

push 135
push 100
push 45
push 5
push 15
call DrawFullRect

; האות מ

push 60
push 145
push 5
push 45
push 1
call DrawFullRect

push 100
push 100
push 45
push 5
push 1
call DrawFullRect

push 60
push 100
push 5
push 45
push 1
call DrawFullRect

push 58
push 94
push 6
push 5
push 1
call DrawFullRect

; האות ח

push 50
push 100
push 50
push 5
push 4
call DrawFullRect

push 15
push 100
push 5
push 35
push 4
call DrawFullRect

push 15
push 100
push 50
push 5
push 4
call DrawFullRect

; --------------------------

exit:
	mov ax, 4c00h
	int 21h
	
	
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


END start


