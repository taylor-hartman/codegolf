[ORG 0x7c00]

;SETUP STACK
mov ax, 0x9000
mov ss, ax
mov ax, 0xFFFF
mov sp, ax

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

mov al, 0x02
mov di, [points]
mov si, lens
call draw_series_hstart
mov di, [points]
call draw_series_vstart
mov al, 0x0f
mov bx, 40
mov cx, 60
call draw_ball
jmp exit

draw_series_hstart:
	movzx cx, [si]
	jcxz return
	call draw_horizontal_line
	inc si
draw_series_vstart:
	movzx cx, [si]
	jcxz return 
	call draw_vertical_line
	inc si
	loop draw_series_hstart

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
	mov al, 0x0f
	mov di, 320
	imul di, bx
	add di, cx
	push cx	
	cmp di, [es:di]
	jne skip
	
skip:	mov [es:di], al
	mov cx, [0x046c]
	inc cx
	call delay
	pop cx
	mov al, 0x00
	mov [es:di], al
	inc cx
	jmp draw_ball	

mov_ball:
	mov ax, -4

delay:
	cmp [0x046c], cx
	jb delay
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

times 510-($-$$) db 0
dw 0xAA55
	
