.model large
.stack 100h

.code
Old_08 label dword
Old_08_offset dw ?
Old_08_segment dw ?
count db ? ;contorul ce va fi afisat
sir_sunete  dw 65,6656, 4192, 700 , 4448, 6272, 6656,880, 7040, 7456

start:
  mov di,0 
  
  mov ax,3508h 
  int 21h 
  mov cs:Old_08_offset,bx 
  mov cs:Old_08_segment,es 
  
  mov ax,cs 
  mov ds,ax
  
  mov dx,offset New_08 ;pe functia New_08
  mov ax,2508h  
  int 21h
  
  mov ah,0 
  int 16h
  
  mov ax,cs:Old_08_segment 
  mov ds,ax 
  mov dx,cs:Old_08_offset
  mov ax,2508h
  int 21h
  call cs:nosound
  mov ax,4c00h 
  int 21h

New_08 proc far
  push ax
  mov bx, cs:sir_sunete[di] 
  call cs:sound
  cmp di, 18
  JnE incrementeaza 
  mov di,0
  incrementeaza: add di,2
  mov dl, 'd'
  mov ah,02h
  int 21h
  pop ax
  pushf 
  call cs:Old_08 
  iret 
New_08 endp

sound proc far
  mov ax, 34DDh 
  mov dx, 0012h 
  div bx 
  mov bx,ax 
  in al, 61h 
  test al, 03h 
  jne sound1 
  or al, 03h
  out 61h, al 
  mov al, 0B6h 
  out 43h, al 
  sound1: mov al, bl
  out 42h, al
  mov al, bh 
  out 42h, al 
  ret 
sound endp

nosound proc far
    in al, 61h 
    and al, 0FCh 
    out 61h, al
    ret 
nosound endp

end start