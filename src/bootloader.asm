[BITS 16]
[ORG 0x7C00]
xor ax, ax
mov ds, ax ;this is for labels
mov ax, 0x07E0
mov es, ax ;setting [es : bx] buffer


;preparing stack
cli
xor ax, ax
mov ss, ax
mov sp, 0x7C00
sti

mov cl, 2 ;number of first sector
mov ch, 0 ;number of first cilinder
mov dh, 0 ;number of first head
mov bx, 0x0 ;setting [es : bx]

cnt: dd 0 ;counter of bytes

load:
  mov ah, 0x02
  mov al, 1

  int 0x13 ;reading of chs
  jc print_error ;error if carry

  mov ax, es
  add ax, 0x20 ;increasing [es:bx] by 512
  mov es, ax

  add dword[cnt], 512 ;increasing counter of read bytes
  cmp dword[cnt], N ;comparing with N and finishing if >=
  jae loop
  inc cl ;changing coordinates
  cmp cl, 19
  jne .same_head
    mov cl, 1
    inc dh
    cmp dh, 2
    jne .same_cilinder
      inc ch
      mov dh, 0
    .same_cilinder:
  .same_head:
  jmp load



print_error:
  mov bx, msg
  .print_loop:
    mov al, byte[bx]
    mov ah, 0x0E
    int 0x10
    inc bx
    cmp al, 0
    jne .print_loop



loop:
  jmp loop

msg: db "Error", 0x0A, 0x0D, 0

times 510-($-$$) db 0
dw 0xAA55
