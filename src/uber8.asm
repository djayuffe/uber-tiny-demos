; UBER8 - an 8-byte DOS demo: a storm of every CP437 glyph, with sound.
; NASM: nasm -f bin src/uber8.asm -o UBER8.COM      Target: DOS/DOSBox, any CPU
;
; DOS starts a .COM with AX = 0, so `int 10h` is "set video mode 0" (40x25 text,
; double-width glyphs). The loop then prints AL with int 29h (DOS "fast console
; output") and steps AL by 83. 83 is odd, so AL visits all 256 values before it
; repeats: smileys, card suits, box drawing, CR/LF scrolls, backspace, and BEL (07h),
; which beeps. The walk is pseudo-random, so the screen looks like a glyph rain.
; It never ends and never reads the keyboard (no bytes to spare): close DOSBox, or
; press Ctrl+F9 in it, to stop it.
BITS 16
ORG 100h
    int 10h           ; CD 10       AX = 0: video mode 0
.l: int 29h           ; CD 29       print AL
    add al,83         ; 04 53       next glyph (odd step: visits all 256)
    jmp short .l      ; EB FA
