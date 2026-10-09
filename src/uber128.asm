; UBER128 - a 128-byte DOS demo: rainbow rings that flow out of an orbiting centre.
; NASM: nasm -f bin src/uber128.asm -o UBER128.COM      Target: DOS/DOSBox, VGA, 386+
BITS 16
ORG 100h

    mov al,13h
    int 10h
    push word 0A000h
    pop es

    ; palette: three phase-shifted triangle waves = a seamless rainbow loop
    mov dx,3C8h
    xor ax,ax
    out dx,al
    inc dx
    xor bx,bx
.pal:
    mov al,bl
    call tri
    out dx,al
    mov al,bl
    add al,85
    call tri
    out dx,al
    mov al,bl
    add al,170
    call tri
    out dx,al
    inc bl
    jnz .pal                      ; BX = 0: also the frame counter

frame:
    mov al,bl                     ; the ring centre swings left and right:
    call tri                      ; x = 160 + (tri(t) - 32) * 4
    sub al,32
    cbw
    shl ax,2
    add ax,160
    mov si,ax
    xor di,di
    mov dx,200
.y:
    mov cx,320
.x:
    mov ax,cx
    sub ax,si
    imul ax,ax
    mov bp,ax
    mov ax,dx
    sub ax,100
    imul ax,ax
    add ax,bp
    shr ax,6
    add al,bl
    stosb
    loop .x
    dec dx
    jnz .y
    inc bx
    in al,60h
    dec al
    jnz frame
    mov ax,3
    int 10h
    ret

tri:                              ; AL = triangle(AL): 0..63
    sub al,128
    cbw
    xor al,ah
    shr al,1
    ret
