[ORG 0x7c00]

ball_x: equ 0
ball_y: equ 2
ball_xs: equ 4
ball_ys: equ 6
xs_hold: equ 8
ys_hold: equ 10
offset_thing: equ 319

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
	mov word [bp+ball_xs], 0
	mov word [bp+ball_ys], 0
	mov word [bp+xs_hold], -1
	mov word [bp+ys_hold], -1
	
call draw_level
call draw_hole 

main_loop:
	call draw_ball
	call get_input
	call draw_velocity
	jmp main_loop
;--------------------

draw_level:
	mov bx, 0
	mov cx, 5
	mov dx, 0
draw_level_loop:
	push cx
	mov di, [points]
	mov si, lens
	sub di, dx
	call draw_series_hstart
	mov di, [points]
	sub di, dx
	call draw_series_vstart
	inc bx ;add to the len
	pop cx
	add dx, 319
	loop draw_level_loop
	ret

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

draw_ball:
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
	cmp ah, 0x28 ;in hole
	jne x_check
	jmp exit
x_check:
	cmp ah, 0x2f ;if new position collides x then reverse xs
	jne y_check
	neg word [bp+ball_xs]
	ret
y_check: ;if new position collides y then reverse ys
	cmp ah, 0x30
	jne no_collision
	neg word [bp+ball_ys]
	ret
no_collision: ;if no collision draw the ball	 
	mov [es:di], al
	mov cx, [0x046c]
	inc cx
	call delay
	mov al, 0x00
	mov [es:di], al
	ret
	
delay:
	cmp [0x046c], cx
	jb delay
	ret

draw_hole:
	mov cx, 7
	mov al, 0x28
	mov di, [holes]
draw_hole_loop:
	push cx
	mov cx, 7
	call draw_horizontal_line
	add di, 313
	pop cx 
	loop draw_hole_loop
	ret

get_input:
	cmp word [bp+ball_xs], 0
	jne get_input_end
	cmp word [bp+ball_ys], 0
	jne get_input_end
	in al, 0x60
get_d:	cmp al, 0x20 ; D key
	jne get_a
	mov word bx, [bp+xs_hold]
	cmp bx, 3
	jge get_input_end
	inc bx
	mov word [bp+xs_hold], bx
get_a:	cmp al, 0x1e
	jne get_x
	mov word bx, [bp+xs_hold]
	cmp bx, -3 
	jle get_input_end 
	dec bx
	mov word [bp+xs_hold], bx 
; get_w:	cmp al, 0x11
; 	jne get_w
;         mov word bx, [bp+ys_hold]
;         cmp bx, 3
;         jge get_input_end
;         inc bx
;         mov word [bp+ys_hold], bx
; get_s:  cmp al, 0x1f
; 	jne get_x
;         mov word bx, [bp+ys_hold]
;         cmp bx, -3
;         jle get_input_end
;         dec bx
;         mov word [bp+ys_hold], bx	
get_x:	cmp al, 0x21
	jne get_input_end
	mov word bx, [bp+xs_hold]
	mov [bp+ball_xs], bx
	mov word bx, [bp+ys_hold]
	mov [bp+ball_ys], bx	
	get_input_end:
	ret

draw_velocity:
	mov cx, [bp+ball_x]
        mov bx, [bp+ball_y]
        mov di, 320
        imul di, bx
        add di, cx
	inc di
        mov cx, [bp+xs_hold]
	mov al, 5
	mul cx
	mov cx, ax ;TODO fix this shit and make velocities bytes 
	mov al, 0x20
        call draw_horizontal_line
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
	dw 155*320+250
times 510-($-$$) db 0
dw 0xAA55
	
