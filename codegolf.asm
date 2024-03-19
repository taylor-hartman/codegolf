[ORG 0x7c00]

ball_x: equ 0
ball_y: equ 2
ball_xs: equ 4
ball_ys: equ 6
xs_hold: equ 8
ys_hold: equ 10

;irdk if this is necissary
;SETUP STACK
;xor ax, ax
;mov ss, ax
;mov sp, 0x9c00
;mov bp, sp

;point es to video memory
mov ax, 0xA000
mov es, ax
;switch to video mode 0x13
mov ah, 0x00
mov al, 0x13
int 0x10

start:
	mov word [bp+ball_x], 60
	mov word [bp+ball_y], 40
	mov word [bp+ball_xs], 0
	mov word [bp+ball_ys], 0
	mov word [bp+xs_hold], 0
	mov word [bp+ys_hold], 0

main_loop:
clear_screen:
	xor al, al
	mov cx, 320*200
	xor di, di ;idky exactly but this has to be here, ig there is no overflow
	rep stosb
	
draw_level:
	mov cx, 5
	xor bx, bx
draw_level_loop:
	push cx
	mov di, [points]
	mov si, lens
	sub di, bx
	call draw_series_hstart
	mov di, [points]
	sub di, bx
	call draw_series_vstart
	pop cx
	add bx, 319
	loop draw_level_loop

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

get_input:
	cmp word [bp+ball_xs], 0
	jne get_input_end
	cmp word [bp+ball_ys], 0
	jne get_input_end
	in al, 0x60
get_d:	cmp al, 0x20 ; D key
	jne get_a
    cmp word [bp+xs_hold], 3
	jge get_input_end
    inc word [bp+xs_hold]
get_a:	cmp al, 0x1e
	jne get_w
	cmp word [bp+xs_hold], -3
    jle get_input_end 
	dec word [bp+xs_hold]
get_w:	cmp al, 0x11
	jne get_s
	cmp word [bp+ys_hold], 3
	jge get_input_end
	inc word [bp+ys_hold]
get_s:  cmp al, 0x1f
	jne get_x
	cmp word [bp+ys_hold], -3
	jle get_input_end
	dec word [bp+ys_hold]	
get_x:	cmp al, 0x2d
	jne get_input_end
	mov word bx, [bp+xs_hold]
	mov [bp+ball_xs], bx
	mov word bx, [bp+ys_hold]
	mov [bp+ball_ys], bx
	xor dx, dx ;reset ball timer	
	get_input_end:

draw_velocity:
	cmp word [bp+ball_xs], 0
    jne draw_velocity_end
    cmp word [bp+ball_ys], 0
    jne draw_velocity_end
	mov cx, [bp+ball_x]
    mov bx, [bp+ball_y]
    call compute_di
    push di
    mov cx, [bp+xs_hold]
	cmp cx, 0
	jge pos_hor
	; draw negative velocity indicator horizontal
	neg cx
	imul cx, 5
	sub di, cx
	jmp draw_hor
	pos_hor: ;draw positive velocity indicator horizontal
	imul cx, 5
	draw_hor:
	mov al, 0x20
    call draw_horizontal_line
	pop di
	mov cx, [bp+ys_hold]
	cmp cx, 0
	je draw_velocity_end
	jl neg_vert
	; draw positive velocity indicator vertical
	imul cx, 5
	mov bx, 320
	imul bx, cx
	sub di, bx
	jmp draw_vert_vel
	neg_vert: ; draw negative velocity indicator vertical
	imul cx, -5
	draw_vert_vel:
	call draw_vertical_line
    draw_velocity_end:

draw_ball:
	mov cx, [bp+ball_x]
	mov bx, [bp+ball_y]
	add cx, word [bp+ball_xs]
	sub bx, word [bp+ball_ys] ;idfk y this is sub and not add, butt it werks 
	call compute_di
	mov ah, [es:di]
	cmp ah, 0x28 ;in hole
	je exit
x_check:
	cmp ah, 0x2f ;if new position collides x then reverse xs
	jne y_check
	neg word [bp+ball_xs]
	jmp end_draw_ball
y_check: ;if new position collides y then reverse ys
	cmp ah, 0x30
	jne no_collision
	neg word [bp+ball_ys]
	jmp end_draw_ball
no_collision: ;if no collision draw the ball	 
	mov word [bp+ball_x], cx
	mov word [bp+ball_y], bx
	mov al, 0x0f
	mov [es:di], al
    end_draw_ball:

slow_ball:
	cmp dx, 100
	jle delay
	mov word [bp+ball_xs], 0
	mov word [bp+ball_ys], 0
	
delay:
	mov cx, [0x046c]
    inc cx
    delay_loop:
	cmp [0x046c], cx
	jb delay_loop
	inc dx 
	
jmp main_loop

;---Helper Functions---

draw_series_hstart:
	movzx cx, [si]
	jcxz draw_series_end
	mov al, 0x30
	call draw_horizontal_line
	inc si
draw_series_vstart:
	movzx cx, [si]
	jcxz draw_series_end
	mov al, 0x2f
	call draw_vertical_line
	inc si
	jmp draw_series_hstart
draw_series_end:
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

compute_di: ; 
	mov di, 320
    imul di, bx
    add di, cx
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
	
