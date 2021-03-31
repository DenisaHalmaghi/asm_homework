.model large
.stack 100h

.code
Old_08 label dword
Old_08_offset dw ? ;offsetul vechii rutine
Old_08_segment dw ? ;segmentul vechii rutine
count db ? ;contorul ce va fi afisat
sir_sunete  dw 65,6656, 4192, 700 , 4448, 6272, 6656,880, 7040, 7456
           
;*************************************************************************

start:
  mov di,0 ;initializarea contorului
  
  mov ax,3508h ;citirea vectorului initial al ?ntreruperii
  int 21h ;timer sistem
  mov cs:Old_08_offset,bx ;salvarea offsetului obtinut
  mov cs:Old_08_segment,es ;salvarea segmentului obtinut
  
  mov ax,cs ;setarea noului vector
  mov ds,ax
  
  mov dx,offset New_08 ;pe functia New_08
  mov ax,2508h  
  int 21h
  
  mov ah,0 ;aşteptarea unei taste
  int 16h
  
  mov ax,cs:Old_08_segment ;setarea vectorului ?napoi
  mov ds,ax ;pe vechea rutina
  mov dx,cs:Old_08_offset
  mov ax,2508h
  int 21h
  call cs:nosound
  mov ax,4c00h ;terminarea programului
  int 21h

;*************************************************************************
; Procedura: New_08
; Descriere: Noua ?ntrerupere de timer sistem.
; Parametri: nu are
;*************************************************************************
New_08 proc far
push ax
mov bx, cs:sir_sunete[di] ; se iau pe rand elementele din siruld e sunete
call cs:sound
cmp di, 18
JnE incrementeaza ;nu a ajuns la finalul sirului
mov di,0
incrementeaza: add di,2
mov dl, 'd'
mov ah,02h
int 21h
pop ax
pushf ;necesar pentru apelul vechii rutine
call cs:Old_08 ;apelul vechii rutine
iret ;revenirea din ?ntrerupere
New_08 endp

;*************************************************************************
; Procedura: sound
; Descriere: Generează un sunet de o anumită frecvenţă pe o perioadă
; nelimitată de timp.
; Parametri: Primeşte în registrul BX frecvenţa dorită.
;*************************************************************************
sound proc far
  mov ax, 34DDh ;încarcă în dx:ax valoarea hexa a frecvenţei tactului
  mov dx, 0012h ;aplicat canalului 2 al circuitului 8253
  div bx ;împarte la frecvenţa dorită pentru a obţine constanta
  mov bx,ax ;salvează constanta
  in al, 61h ;citeşte canal de date port B 8255
  test al, 03h ;verifică cei mai puţin semnificativi biţi
  jne sound1 ;dacă sunt pe 1 sare
  or al, 03h ;daca nu sunt pe 1 îi face 1
  out 61h, al ;dă drumul la sunet
  mov al, 0B6h ;cuvânt de comandă 8253: canal 2, mod 3, binar
  out 43h, al ;scriere cuvânt de comandă
  sound1: mov al, bl ;cel mai puţin semnificativ octet
  out 42h, al ;trimite octet canal 2
  mov al, bh ;cel mai semnificativ octet
  out 42h, al ;trimite octet canal 2
  ret ;ieşire din procedură
sound endp

nosound proc far
    in al, 61h ;cite?te canal de date port B 8255
    and al, 0FCh ;reseteaz? cei mai pu?in semnificativi 2 bi?i
    out 61h, al ;scrie ?napoi octet
    ret ;revenire
nosound endp


end start