; UBER256 - a 256-byte DOS demo: a rotozoomer. An XOR texture, rotated and zoomed
; about the screen centre, with a rainbow palette that rolls over time.
; NASM: nasm -f bin src/uber256.asm -o UBER256.COM      Target: DOS/DOSBox, VGA, 386+
;
; The rotation uses no sine table: (rc, rs) is a vector rotated a little every frame
; by Minsky's trick (rc -= rs>>5; rs += rc>>5), which traces a near-perfect circle.
; The zoom is a triangle wave. Palette: three phase-shifted triangle waves. The hue
; also drifts with the squared distance from the centre.
BITS 16
ORG 100h

    mov al,13h
    int 10h
    push word 0A000h
    pop es

    mov dx,3C8h                   ; palette: seamless rainbow loop
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
    jnz .pal

frame:
    mov ax,[rs]                   ; Minsky rotation of the (rc, rs) vector
    sar ax,5
    sub [rc],ax
    mov ax,[rc]
    sar ax,5
    add [rs],ax

    mov al,[t]                    ; zoom z = 32 + tri(t/2)  (32..95)
    shr al,1
    call tri
    add al,32
    xor ah,ah
    mov bp,ax
    mov ax,[rc]
    imul ax,bp
    sar ax,5
    mov [rcz],ax
    mov ax,[rs]
    imul ax,bp
    sar ax,5
    mov [rsz],ax

    xor di,di
    mov dx,200
.y:
    mov cx,320
.x:
    mov si,cx
    sub si,160                    ; x' (from the centre)
    mov bp,dx
    sub bp,100                    ; y'
    mov ax,si
    imul ax,[rcz]
    mov bx,bp
    imul bx,[rsz]
    sub ax,bx                     ; u = x'*c - y'*s
    push ax
    mov ax,si
    imul ax,[rsz]
    mov bx,bp
    imul bx,[rcz]
    add ax,bx                     ; v = x'*s + y'*c
    pop bx
    xor ax,bx                     ; the XOR texture
    shr ax,7
    add al,[t]                    ; colours roll with time
    mov bx,si
    imul bx,bx
    shr bx,10
    add al,bl                     ; and drift with the squared distance from the
    mov bx,bp                     ; centre, so the edges shade differently
    imul bx,bx
    shr bx,10
    add al,bl
    stosb
    loop .x
    dec dx
    jnz .y

.vs:                              ; wait for vertical retrace: no tearing, 70 fps
    mov dx,3DAh
.w1:
    in al,dx
    test al,8
    jnz .w1
.w2:
    in al,dx
    test al,8
    jz .w2

    inc byte [t]
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

rc dw 64                          ; rotation vector, |v| = 64
rs dw 0
t db 0
rcz dw 0
rsz dw 0
