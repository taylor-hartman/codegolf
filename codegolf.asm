[ORG 0x7c00]

;SETUP STACK
mov ax, 0x9000
mov ss, ax
mov ax, 0xFFFF
mov sp, ax

;point es to video memory
mov ax, 0xA000
mov es, ax

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
	mov al, 0x07
	call clear_screen

call sign_handler
;mov al, 0x03
;mov di, [points]
;movzx cx, [lens]
;call draw_horizontal_line_negative
;mov di, [points + 2]
;mov cx, [lens + 1]
;call draw_vertical_line_negative
jmp exit

sign_handler: ;cx=sign
	mov al, 0x03
	mov di, [points]
	movzx cx, [signs]
	jcxz positive  ;jmp if cx==0
	negative:
	movzx cx, [lens] 
	call draw_horizontal_line_negative
	ret
	positive:
	movzx cx, [lens]
	call draw_horizontal_line
	ret
	
draw_horizontal_line: ;di=start, cx=len
	mov al, 0x03
	rep stosb
	ret

draw_horizontal_line_negative:
	mov [es:di], al
	dec di
	loop draw_horizontal_line_negative
	ret
	
draw_vertical_line: ;di=start, cx=len
	mov [es:di], al
	dec cx
	add di, 320
	cmp cx, 0
	jne draw_vertical_line
	ret

draw_vertical_line_negative:
	mov [es:di], al
	dec cx
	add di, 320
	cmp cx, 0
	jne draw_vertical_line_negative
	ret

draw_pixel: ;al=color, bx=y, cx=x
	mov di, 320
	imul di, bx
	add di, cx	
	mov [es:di], al
	
clear_screen:
	mov cx, 320*200
	mov di, 0
	rep stosb
	cmp al, 0x07
	ret
	
exit:
	jmp exit

points:
	dw 50*320+190, 50*320+190

lens:
	db 140, 40

signs: 
	db 1,0

times 510-($-$$) db 0
dw 0xAA55
	
