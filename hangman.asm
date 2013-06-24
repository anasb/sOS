title "hangman"
                              
; Use this part only for debbugging
; As graphics mode will be set when the OS starts
 mov ah,00
 mov al,13h			;set graphic mode
 int 10h			;enter graphic mode


; How to use the Methods
; Set CX -starting x coordinate
; Set DX -starting y coordinate
; Set BX - ending coordinate

; draw h(orizontal) line will stop when cx==bx
; draw v(ertical) line will stop when dx==bx
; draw d(iagonal) line will stop when cx==bx && dx==bx



hang1:             ; bottom line
 mov cx, 010h
 mov dx, 090h
 mov bx, 050h
call draw_h_line

hang2:             ; main vertical line
 mov cx, 020h
 mov dx, 020h
 mov bx, 090h
call draw_v_line  

hang3:             ; upper line
 mov cx, 020h
 mov dx, 020h
 mov bx, 050h
call draw_h_line 

hang4:             ; vertical hanger
 mov cx, 050h
 mov dx, 020h
 mov bx, 040h
call draw_v_line 

hang5:             ; head
 mov cx, 045h
 mov dx, 040h
 mov bx, 055h
call draw_h_line ;top
 mov cx, 045h
 mov dx, 040h
 mov bx, 050h
call draw_v_line ;left
 mov cx, 045h
 mov dx, 050h
 mov bx, 055h
call draw_h_line ;bottom
 mov cx, 058h
 mov dx, 040h
 mov bx, 050h
call draw_v_line ;right

hang6:             ; body
 mov cx, 050h
 mov dx, 050h
 mov bx, 070h
call draw_v_line  

hang7:             ; left leg
 mov cx, 050h
 mov dx, 070h
 mov bx, 060h
call draw_d_line 

hang8:             ; left arm
 mov cx, 050h
 mov dx, 050h
 mov bx, 060h
call draw_d_line  

hang9:             ; right leg
 mov cx, 050h
 mov dx, 070h
 mov bx, 040h
call draw_dr_line

hang10:             ; right arm
 mov cx, 050h
 mov dx, 050h
 mov bx, 040h
call draw_dr_line  






 ret

draw_h_line:
 mov ah,0Ch		    
 mov al,0fh			
 int 10h
 inc cx
 inc cx
 inc cx
 inc cx
 inc cx
 cmp cx,bx
 jb draw_h_line
 ret 
 
draw_v_line:
 mov ah,0Ch		    
 mov al,0fh
 int 10h
 inc dx
 inc dx
 inc dx
 inc dx
 inc dx
 cmp dx,bx
 jb draw_v_line
 ret
 
 
draw_d_line:
 mov ah,0Ch		    
 mov al,0fh
 int 10h
 inc dx
 inc dx
 inc dx
 inc dx
 inc dx
 inc cx
 inc cx
 inc cx
 inc cx
 inc cx
 cmp dx,bx
 jb draw_d_line
 cmp cx,bx
 jb draw_d_line
 ret
  
 draw_dr_line:
 mov ah,0Ch		    
 mov al,0fh
 int 10h
 inc dx
 inc dx
 inc dx
 inc dx
 inc dx
 dec cx
 dec cx
 dec cx
 dec cx
 dec cx
 cmp cx, bx
 ja draw_dr_line
 call print_string
 ret  
 
     

print_string:
lea si, msg ;Passing the message pointer into the SI registrar
    pusha   ;Storing Registers
    
    mov ah, 0Eh
    
.repeat:
    lodsb   ;Get Char from string
    cmp al, 0
    je .done
    
    int 10h
    jmp .repeat

.done:
    popa
    ret  
    
msg db 'Enjoy', 0
 
  
  num_quest db "enter a number between 0 and 10: ", 0
  word db "stojanov", 0
