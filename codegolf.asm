[ORG 0x7c00]

ball_x: equ 0
ball_y: equ 2
ball_xs: equ 4
ball_ys: equ 6

;SETUP STACK
xor ax, ax
mov ss, ax
mov sp, 0x9c00
mov bp, sp

;point es to video memory
mov ax, 0xA000
mov es, ax
mov ah, 0x01
;switch to video mode 0x13
mov ah, 0x00
mov al, 0x13
int 0x10

;hidetext cursor
mov ah, 1
mov ch, 0x20
mov cl, 0x00
int 0x10

start:
	mov ax, 0x00
	call clear_screen
	mov word [bp+ball_x], 60
	mov word [bp+ball_y], 40
	mov word [bp+ball_xs], 3
	mov word [bp+ball_ys], 3

mov al, 0x02
mov bx, 0
mov di, [points]
mov si, lens
call draw_series_hstart
mov di, [points]
call draw_series_vstart

add bx, 1
mov di, [points]
mov si, lens
sub di, 319
call draw_series_hstart
mov di, [points]
sub di, 319
call draw_series_vstart

add bx, 2
mov di, [points]
mov si, lens
sub di, 638
call draw_series_hstart
mov di, [points]
sub di, 638
call draw_series_vstart

call draw_hole 

call draw_ball
jmp exit

draw_series_hstart:
	movzx cx, [si]
	jcxz return
	mov al, 0x30
	call draw_horizontal_line
	inc si
draw_series_vstart:
	movzx cx, [si]
	jcxz return
	mov al, 0x2f
	call draw_vertical_line
	inc si
	jmp draw_series_hstart

return:
	inc si
	ret
	
draw_horizontal_line: ;di=start, cx=len
	rep stosb
	ret
	
draw_vertical_line: ;di=start, cx=len
	mov [es:di], al
	dec cx
	add di, 320
	cmp cx, 0
	jne draw_vertical_line
	ret

draw_ball: ;al=color, bx=y, cx=x
	mov cx, [bp+ball_x]
	mov bx, [bp+ball_y]
	add cx, [bp+ball_xs]
	add bx, [bp+ball_ys] 
	mov [bp+ball_x], cx
	mov [bp+ball_y], bx
	mov al, 0x0f
	mov di, 320
	imul di, bx
	add di, cx
	mov ah, [es:di]
	cmp ah, 0x2f ;if new position collides x then reverse xs
	jne y_check
	neg word [bp+ball_xs]
	jmp draw_ball
y_check: ;if new position collides y then reverse ys
	cmp ah, 0x30
	jne no_collision
	neg word [bp+ball_ys]
	jmp draw_ball
no_collision: ;if no collision draw the ball	
	push cx 
	mov [es:di], al
	mov cx, [0x046c]
	inc cx
	call delay
	mov al, 0x00
	mov [es:di], al
	jmp draw_ball	
	
delay:
	cmp [0x046c], cx
	jb delay
	ret

draw_hole:
	mov cx, 5
	mov al, 0x28
	mov di, [holes]
draw_hole_loop:
	push cx
	mov cx, 5
	call draw_horizontal_line
	add di, 315
	pop cx 
	loop draw_hole_loop
	ret
	
clear_screen:
	mov cx, 320*200
	mov di, 0
	rep stosb
	cmp al, 0x07
	ret
		
exit:
	jmp exit

points:
	dw 20*320+50, 20*320+50
	
lens:
	db 140,120,80,40,0,40,100,120,120,0

holes:
	dw 160*320+250
times 510-($-$$) db 0
dw 0xAA55
	
