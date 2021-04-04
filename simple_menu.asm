.model small
.stack 

.data 

element1 db 'F', 1EH, 'I', 1EH, 'L', 1EH, 'E', 1EH
element2 db 'E', 1EH, 'D', 1EH, 'I', 1EH, 'T', 1EH
element3 db 'E', 1EH, 'X', 1EH, 'I', 1EH, 'T', 1EH

element1_active db 'F', 3EH, 'I', 3EH, 'L', 3EH, 'E', 3EH
element2_active db 'E', 3EH, 'D', 3EH, 'I', 3EH, 'T', 3EH
element3_active db 'E', 3EH, 'X', 3EH, 'I', 3EH, 'T', 3EH
current_element db 0

.code
start:
  mov ax,@data
  mov ds, ax
  
  mov ax,0B800H 
  mov ES,ax 
    
  call render_menu
  
wait_for_input:       
  mov ah,0 
  int 16h
  
  jmp handle_input
  jmp wait_for_input
    
handle_input:
  cmp ah,50h
  jz keydown
  cmp ah,48h
  jz keyup
  cmp ah,1ch
  call cs:exit_program
  jmp wait_for_input
  
keydown:
  call cs:increment_counter
  call cs:rerender_cursor
  jmp rerender_menu
  
keyup:
  call cs:decrement_counter
  call cs:rerender_cursor
  
rerender_menu:
  call render_menu
  jmp wait_for_input
  
render_menu proc 
  mov di,0 
  lea si,element1 
  mov cx,8 
  rep movsb
  
  mov di,160 
  lea si,element2 
  mov cx,8 
  rep movsb

  mov di,320 
  lea si,element3 
  mov cx,8
  rep movsb
  
  call rerender_active_tab
  ret 
render_menu endp

rerender_cursor proc 
  mov ah,02h
  mov dh,current_element
  mov dl,0
  int 10h
  ret 
rerender_cursor endp

rerender_active_tab proc 
  cmp current_element,0
  jz is_0
  cmp current_element,1
  jz is_1
  jmp is_2
  
  is_0:
    mov di,0 
    lea si,element1_active 
    mov cx,8 
    rep movsb
    jmp exit_proc
    
  is_1:
    mov di,160 
    lea si,element2_active 
    mov cx,8 
    rep movsb
    jmp exit_proc
    
  is_2:
    mov di,320 
    lea si,element3_active 
    mov cx,8 
    rep movsb
    
  exit_proc:
    ret 
rerender_active_tab endp

increment_counter proc 
    cmp current_element,2
    jz reset_counter_to_start
    inc current_element
    jmp fin2
  reset_counter_to_start:
    mov current_element,0
  fin2:
    ret
increment_counter endp

decrement_counter proc 
  cmp current_element,0
  jz reset_counter_to_end
  dec current_element
  jmp fin
reset_counter_to_end:
  mov current_element,2
fin:
  ret
decrement_counter endp

exit_program proc 
  cmp current_element,2
  jnz return_from_proc
  mov ah, 4CH
  int 21H
return_from_proc:
  ret
exit_program endp
  
end start