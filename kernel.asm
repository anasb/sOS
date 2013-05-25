

;-----------------
; HANGMAN        : 
;-----------------

;---video mode                              
call os_go_graphics 
;call os_draw_window

mov di, 0h ; keeps track of hanging steps         
mov es, 0h ; keeps track of winning steps
 
hangman:
mov al, 0fh
mov dh, 05h
mov dl, 013h
mov bh, 00h
call os_set_cursor
;---"Enter a letter: "
lea si, quest
call os_print_string

;---Getting char from user
call os_get_char

;---Printing only letters discovered 
lea si, mot     
mov bl, al

;---Setting cursor to row 2, col 0
mov dh, 07h
mov dl, 013h
call os_set_cursor
;---Prints word with only discovered letters
call os_print_char_string

cmp bh, 0000h   ; checks if no letters were found
je .compare   ; advances one step of hanging

inc es          ; otherwise increments winning step
cmp es, 07h
je .win

;-- Setting cursor to row 3, col 0
mov dh, 08h
mov dl, 013h
mov bh, 00h
call os_set_cursor
;-- Printing line of dashes
lea si, dash
call os_print_string

jmp hangman

.compare:
 cmp di, 00h
 je hang1
 cmp di, 01h
 je hang2
 cmp di, 02h
 je hang3
 cmp di, 03h
 je hang4
 cmp di, 04h
 je hang5
 cmp di, 05h
 je hang6
 cmp di, 06h
 je hang7
 cmp di, 07h
 je hang8
 cmp di, 08h
 je hang9
 cmp di, 09h
 je hang10 
 cmp di, 0Ah
 je .lost

.lost:
 call os_clear_screen 
 mov dh, 04h
 mov dl, 05h
 mov bh, 00h
 call os_set_cursor
 lea si, loser
 call os_print_string

 
.win:
 call os_clear_screen 
 mov dh, 04h
 mov dl, 05h
 mov bh, 00h
 call os_set_cursor
 lea si, winner
 call os_print_string
 ret  


;----------------------------
;DRAWING HANGMAN STEP BY STEP
;----------------------------

hang1:
pusha
 mov al, 0fh            ; bottom line
 mov cx, 010h
 mov dx, 090h
 mov bx, 050h
 call os_draw_h_line
popa
 inc di
jmp hangman

hang2:             ; main vertical line
pusha
 mov al, 0fh
 mov cx, 020h
 mov dx, 020h
 mov bx, 090h
call os_draw_v_line  
popa
 inc di
jmp hangman

hang3:             ; upper line
pusha
 mov al, 0fh
 mov cx, 020h
 mov dx, 020h
 mov bx, 050h
call os_draw_h_line 
popa
 inc di
jmp hangman

hang4:             ; vertical hanger
pusha
 mov al, 0fh
 mov cx, 050h
 mov dx, 020h
 mov bx, 040h
call os_draw_v_line 
popa
 inc di
jmp hangman

hang5:             ; head
pusha
 mov al, 0fh
 mov cx, 045h
 mov dx, 040h
 mov bx, 055h
call os_draw_h_line ;top
 mov cx, 045h
 mov dx, 040h
 mov bx, 050h
call os_draw_v_line ;left
 mov cx, 045h
 mov dx, 050h
 mov bx, 055h
call os_draw_h_line ;bottom
 mov cx, 055h
 mov dx, 040h
 mov bx, 050h
call os_draw_v_line ;right
popa
 inc di
jmp hangman

hang6:             ; body
pusha
 mov al, 0fh
 mov cx, 050h
 mov dx, 050h
 mov bx, 070h
call os_draw_v_line  
popa
 inc di
jmp hangman

hang7:             ; left leg
pusha
 mov al, 0fh
 mov cx, 050h
 mov dx, 070h
 mov bx, 060h
call os_draw_d_line 
popa
 inc di
jmp hangman

hang8:             ; left arm
pusha
 mov al, 0fh
 mov cx, 050h
 mov dx, 050h
 mov bx, 060h
call os_draw_d_line  
popa
 inc di
jmp hangman

hang9:             ; right leg
pusha
 mov al, 0fh
 mov cx, 050h
 mov dx, 070h
 mov bx, 040h
call os_draw_dr_line
popa
 inc di
jmp hangman

hang10:             ; right arm
pusha
 mov al, 0fh
 mov cx, 050h
 mov dx, 050h
 mov bx, 040h
call os_draw_dr_line  
popa
 inc di
jmp hangman
 
 

; String variables
quest db "Letter: ", 0
mot db "stojanov", 0
dash db "--------", 0
loser db "Sorry, you lost that game!", 0
winner db "Good job, you won!", 0


;------------
;END HANGMAN:
;------------



; ------------------------------------------------------------------
; os_seed_random -- Seed the random number generator based on clock
; IN: Nothing; OUT: Nothing (registers preserved)

call os_seed_random
mov ax, 0
mov bx, 10        
call os_get_random
mov si, cx
call os_print_string

os_seed_random:
	push bx
	push ax

	mov bx, 0
	mov al, 002h			; Minute
	out 070h, al
	in al, 071h

	mov bl, al
	shl bx, 8
	mov al, 0			; Second
	out 070h, al
	in al, 071h
	mov bl, al

	mov [os_random_seed], bx	; Seed will be something like 0x4435 (if it
					; were 44 minutes and 35 seconds after the hour)
	pop ax
	pop bx
	ret


	os_random_seed	dw 0
	word db "a", 0


; ------------------------------------------------------------------
; os_get_random -- Return a random integer between low and high (inclusive)
; IN: AX = low integer, BX = high integer
; OUT: CX = random integer

os_get_random:
	push dx
	push bx
	push ax

	sub bx, ax			; We want a number between 0 and (high-low)
	call .generate_random
	mov dx, bx
	add dx, 1
	mul dx
	mov cx, dx

	pop ax
	pop bx
	pop dx
	add cx, ax			; Add the low offset back
	ret


.generate_random:
	push dx
	push bx

	mov ax, [os_random_seed]
	mov dx, 07383h			; The magic number (random.org)
	mul dx				; DX:AX = AX * DX
	mov [os_random_seed], ax

	pop bx
 	pop dx
	ret



;KERNEL (DONT FUCKING TOUCH )
;STRING MANIPULATION FUNCTIONS

; Prints char in AL
;INPUT:
; AL - char to print
;OUTPUT:
; none
os_put_char:
 mov ah, 0eh
 mov bl, 0fh
 int 10h
 ret 

; Get char input
os_get_char:
 mov ah, 0fh
 int 10h
 cmp al, 13h
 jne os_exit
 mov ah, 0h
 int 16h
 call os_put_char
 ret
 
;Get string from user
;INPUT:
; none
;OUTPUT:
; DI - Pointer to string
os_get_string:     
 pusha
 mov cx, 0                   ; char counter.
 cmp dx, 1                   ; buffer too small?
 jbe .empty_buffer            ;
 dec dx                      ; reserve space for last zero.

 .wait_for_key:
  mov ah, 0                   ; get pressed key.
  int 16h
  cmp al, 0Dh                  ; 'return' pressed?
  jz .exit
  cmp al, 8                   ; 'backspace' pressed?
  jne .add_to_buffer
  jcxz .wait_for_key            ; nothing to remove!
  dec cx
  dec di
  call os_add_backspace
  jmp .wait_for_key

 .add_to_buffer:
  cmp cx, dx          ; buffer is full?
  jae .wait_for_key    ; if so wait for 'backspace' or 'return'...
  mov [di], al
  inc di
  inc cx        
  mov ah, 0eh         ; print the key:
  int 10h
  jmp .wait_for_key

 .exit:
  mov [di], 0         ; terminate String by null:

 .empty_buffer:
  popa
  
  ret   
  
;Print String value
;INPUT:
; SI - pointer to String
;OUTPUT:
; NONE - String printed on screen 
os_print_string:
 push cs
 pop ds
 .repeat:
 mov ah, 0eh
 mov bl, 0fh
 lodsb
 cmp al, 0h
 je os_exit
 
 int 10h
 jmp .repeat

;Compare Strings
;INPUT:
; SI - Pointer to 1 string
; DI - Pointer to 2 string
;OUTPUT:
; BX - 01h -> equal; 00h-> nn equal
;NOTE: Length based on string in SI  
os_cmp_string:

 comp:
 lodsb
 cmp al, di[00h]
 jne .not_equal
 cmp al, 0
 jae .equal
 inc di
 jmp comp
 
 .not_equal:
 mov bx, 00h 
 ret
 
 .equal:
 mov bx, 01h
 ret 

;Adds a backspace to buffer and Screen
;INPUT:
; none
;OUTPUTL
; none
os_add_backspace: 
  push ax
      
  mov al, 8
  mov ah, 0eh
  int 10h
  
  mov al, ' '
  mov ah, 0eh
  int 10h
   
  mov al, 8
  mov ah, 0eh
  int 10h
  pop ax
  
  ret

; Print only the selecter char in a string
; SI - offset of msg
; BL - char to look for
; Prints only chars BL found in string SI
; BH is set to 01h if the char in BL was found in the string,
; else it is 00h 
os_print_char_string:
 mov ah, 0Eh
 mov bh, 00h
    
 .pcs_repeat:
  lodsb   ;Get Char from string
  cmp al, 0
  je .pcs_done
  cmp al, bl
  je .pcs_do_it
  pusha 
  call os_cursor_right
  popa 
  jmp .pcs_repeat
  
 .pcs_do_it:
  mov bh, 01h
  push bx
  mov bl, 0fh
  int 10h
  pop bx
  jmp .pcs_repeat

 .pcs_done:
  ret
     
     
     
     
; DRAWING FUNCTIONS

;Finds the graphics mode and restores it
;clearing the screen
;INPUT:
; none
;OUTPUT:
; none
os_clear_screen:
 mov ah, 0fh
 int 10h
 cmp al, 13h
 je os_go_graphics
 jmp os_go_text



;OS Goes 320x200 graphics mode
;INPUT:
; none
;OUTPUT:
; none
os_go_graphics:
 mov ah,00h
 mov al,13h			;set graphic mode
 int 10h
 ret			
 
;OS Goes 80x25 text mode
;INPUT:
; none
;OUTPUT:
; none
os_go_text:
 mov ah,00h
 mov al,03h			;set text mode
 int 10h
 ret

;Draws Yes/No dialog
;Uses custom kernel draw functions
;INPUT: 
; SI - offset of desidered message
;OUTPUT: 
; BL - 01h for yes, 00h for no                           
os_show_yn_dialog: 
 mov ah, 02h
 mov bh, 0h
 mov dh, 13
 mov dl, 14
 int 10h
 call os_print_string
 
 pusha
 
 ;Drawing title bar
 mov al, 0011b
 mov cx, 100
 mov dx, 78
 mov bx, 220
 mov si, 12
 call os_draw_rectangle
 
 ;Writing title msg
 mov bh, 0h         ; page. 
 lea bp, conf       ; offset.
 mov bl, 0011b       ; default attribute. 
 mov cx, 9          ; char number. 
 mov dl, 13         ; col. 
 mov dh, 10         ; row. 
 mov ah, 13h        ; function. 
 mov al, 1          ; sub-function. 
 int 10h  
 
 ;Drawing buttom line of the dialog
 mov al, 0011b
 mov cx,100
 mov dx,150
 mov bx,220
 call os_draw_h_line
 
 ;Drawing vertila line L
 mov al, 0011b
 mov cx,100
 mov dx,78
 mov bx,150
 call os_draw_v_line
  
 ;Drawing vertila line V
 mov al, 0011b 
 mov cx,220
 mov dx,78
 mov bx,150
 call os_draw_v_line
 
 
 mov al, 1000b
 call .draw_yes
 
 mov al, 0011b
 call .draw_no
 
 mov bl, 01h
  .check_cng:
   call os_get_key
  
   cmp al, 009h
   je ..tab_pressed
  
   cmp al, 0dh
   jne .check_cng 
   jmp os_exit

    
  ..tab_pressed:
    cmp bl, 01h
    je ..no_select  
    
    mov al, 1000b
    call .draw_yes
    
    mov al, 0011b
    call .draw_no
     
    mov bl, 01h 
    jmp .check_cng
 
  ..no_select:
    
    mov al, 0011b
    call .draw_yes
 
    mov al, 1000b
    call .draw_no
    
    mov bl, 02h
    jmp .check_cng

 .draw_yes:    ;Drawing YES Button
 mov cx, 110
 mov dx, 133
 mov bx, 155
 mov si, 12
 call os_draw_rectangle 
 
 ;Writing YES msg
 mov bh, 0    ; page. 
 lea bp, yes  ; offset. 
 mov bl, al
 mov cx, 5    ; char number. 
 mov dl, 14   ; col. 
 mov dh, 17   ; row. 
 mov ah, 13h  ; function. 
 mov al, 1    ; sub-function. 
 int  10h
 
 ret 
 
 .draw_no:     ;Drawing NO Button 
 
 mov cx, 165
 mov dx, 133
 mov bx, 210
 mov si, 12
 call os_draw_rectangle
  
 ;Writing NO msg
 mov bh, 0    ; page. 
 lea bp, no   ; offset. 
 mov bl, al
 mov cx, 5    ; char number. 
 mov dl, 21   ; col. 
 mov dh, 17   ; row. 
 mov ah, 13h  ; function. 
 mov al, 1    ; sub-function. 
 int 10h 
 
 ret 

; Get as input:
; CX - Starting x-coordinate
; DX - Starting y-coordinate
; BX - Ending x-coordinate
; SI - number of lines to draw
; AL - Color
; Return - nothing
os_draw_rectangle:
 
 mov di, cx
 .draw:			    
  mov ah, 0ch   
  int 10h 
  inc cx
  cmp cx, bx
  jb .draw
  cmp si, 0h
  je os_exit
  mov cx, di
  inc dx
  dec si
  jmp .draw

; Get as input:
; CX - Starting x-coordinate
; DX - Starting y-coordinate
; BX - Ending x-coordinate
; AL - Color
; Return - nothing  
os_draw_h_line: ; horizontal line
 mov ah,0Ch		    			
 int 10h
 inc cx
 cmp cx,bx
 jb os_draw_h_line
 ret
  
; Get as input:
; CX - Starting x-coordinate
; DX - Starting y-coordinate
; BX - Ending y-coordinate
; AL - Color
; Return - nothing   
os_draw_v_line:  ; vertical line
 mov ah,0Ch		    
 int 10h
 inc dx
 cmp dx,bx
 jb os_draw_v_line
 ret 
 
; Draws 45deg diagonal
os_draw_d_line:
 mov ah,0Ch		    
 mov al,0fh
 int 10h
 inc dx
 inc cx
 cmp dx,bx
 jb os_draw_d_line
 cmp cx,bx
 jb os_draw_d_line
 ret
 
; Draws -45deg diagonal  
os_draw_dr_line:
 mov ah,0Ch		    
 mov al,0fh
 int 10h
 inc dx
 dec cx
 cmp cx, bx
 ja os_draw_dr_line
 call os_print_string
 ret

;Draws a window on the screen
; Uses KERNEL custom draw functions
;INPUT:
; none
;OUTPUT:
; none - Windows printed on screen
os_draw_window:
 mov al, 0011b 
  
 ; bottom line
 mov cx, 15
 mov dx, 185
 mov bx, 305
 call os_draw_h_line
 
 ; top menubar
 mov cx, 15
 mov dx, 15
 mov bx, 305
 mov si, 8h
 call os_draw_rectangle

 ; left bar
 mov cx, 15
 mov dx, 23
 mov bx, 185
 call os_draw_v_line

 ; right bar
 mov cx, 304
 mov dx, 20
 mov bx, 185
 call os_draw_v_line


 ret




;Designed for graphics mode 13h or text mode 25x80
;Detects the mode and fill the screen
;Writing directly to video-memory
;INPUT: 
; AX - color
os_fill_screen:
 push ax
 
 mov ah, 0fh
 int 10h
 
 cmp al, 13h
 je .fill_screen_vm    
 
 .fill_screen_tm:
  mov ax, 0b800h             
  mov es, ax
  mov di, 0
  mov cx, 07d0h 
  pop ax
  jmp .fill
      
    
 .fill_screen_vm:
  mov ax, 0a000h             
  mov es, ax
  mov di, 0
  mov cx, 0fa00h 
  pop ax
  jmp .fill 
 
 .fill:   
  mov es:[di],ax          
  add di,1
  dec cx
  cmp cx, 0h
  jne .fill
  ret






;EXTRA

; Sets cursor position
;INPUT:
; DH - ROW
; DL - COLUMN  
;OUTPUT:
; none
os_set_cursor:
 mov bh, 0h
 mov ah, 02h             
 int 10h
 ret
    
; Shifts cursor right
os_cursor_right:
 call os_get_cursor
 inc dl
 call os_set_cursor
 ret                
 
; Shifts cursor left 
os_cursor_left:
 call os_get_cursor
 dec dl
 call os_set_cursor
 ret

; Gets cursor position
;INPUT:
; none
;OUTPUT:
; DH - ROW
; DL - COLUMN
os_get_cursor:
 mov bh, 0h
 mov ah, 03h             
 int 10h
 ret

;INPUT:
; None
;OUTPUT:
; Return - AL - ASCII of key pressed   
os_get_key:
 mov ah, 0                   ; get pressed key.
 int 16h
 ret  

;INPUT:
; BL - Key looking for
;OUTPUT:
; none - returns control if the requested key is pressed  
os_wait_key:
 mov ah, 0                   ; get pressed key.
 int 16h
 cmp al, bl
 je os_exit
 call os_wait_key

; Return control to OS
os_exit:
 ret
 

;OS Call - required Msg's   
 conf db ' Confirm ',0
 yes db ' Yes ', 0
 no db ' No  ', 0 
 tst db 'Test', 0

