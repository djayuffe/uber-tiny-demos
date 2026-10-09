# UBER tiny demos

**Three DOS demos in 5, 79 and 171 bytes of hand-written x86 assembly** (size classes 8, 128 and 256).

[![CI](https://github.com/djayuffe/uber-tiny-demos/actions/workflows/ci.yml/badge.svg)](https://github.com/djayuffe/uber-tiny-demos/actions/workflows/ci.yml)

| | Size | Class | What it does | Needs |
|---|---|---|---|---|
| **UBER8** | **5 bytes** | 8 | every CP437 glyph, scrolling, with sound | any CPU, text mode |
| **UBER128** | **79 bytes** | 128 | rainbow rings flowing out of the screen centre | VGA, 386+ |
| **UBER256** | **171 bytes** | 256 | an XOR rotozoomer rotating about the screen centre | VGA, 386+ |

No assets, no libraries. `build.sh` fails if a binary leaves its class or grows past the size
it has been shrunk to. v1.0.0 was 8 / 118 / 237 bytes.

| | | |
|---|---|---|
| ![UBER8](docs/uber8.jpg) | ![UBER128](docs/uber128.jpg) | ![UBER256](docs/uber256.jpg) |

## Run them

Download the `.COM` files from the [latest release](../../releases/latest) and run one in
DOSBox (`mount c .`, `c:`, `UBER256.COM`), or build and launch:

```sh
./build.sh              # NASM build + size limits
./run-dosbox.sh 256     # or 8 or 128
```

Needs [NASM](https://www.nasm.us/) and [DOSBox](https://www.dosbox.com/)
(macOS: `brew install nasm` and `brew install --cask dosbox`).

**Esc** exits UBER128 and UBER256. **UBER8 never exits** (there are no bytes left to read
the keyboard): close DOSBox, or press Ctrl+F9 in it.

## The size hacks

Shared by all three: DOS enters a `.COM` with `AX = 0` and `BX = 0`, so `mov al,13h` is a
complete mode set and `BL` is a ready-made palette index and frame counter. The VGA BIOS leaves
the DAC write index at 0 after a mode set, so a palette is just streamed to port `3C9h` with no
index setup. And the DAC keeps only 6 bits, so `R = i, G = 2i, B = 4i` (one running value, two
doublings) is a whole dense, saturated 256-colour palette in 12 bytes. Esc is read straight from
port `60h`, and the frame is paced by one short wait for vertical retrace.

### UBER8 - 5 bytes

```
.l: int 29h       ; CD 29     DOS "fast console output": print AL
    inc ax        ; 40        next code
    jmp short .l  ; EB FB
```

DOS starts a `.COM` with `AX = 0` in 80x25 text mode, so there is nothing to set up. The 256 codes
go by in order (smileys, card suits, punctuation, digits, letters, box drawing) with CR/LF, backspace
and BEL (07h, which beeps) doing their usual things. It never exits (no bytes to spare): close
DOSBox, or press Ctrl+F9 in it. It relies on the DOS entry convention `AX = 0`.

### UBER128 - 79 bytes

- **No loop nest**: `DI` runs over the whole 64 KB segment and wraps to 0 by itself, which ends the
  frame; x and y come from one `DIV` by 320 (`AX = y`, `DX = x`).
- **No square root**: `r^2 = dx^2 + dy^2`, shifted right by 6 and added to the frame counter, is
  the palette index. The counter is what makes the rings flow outwards.

### UBER256 - 171 bytes

An XOR texture (the top byte of `u ^ v`) rotating about the screen centre.

- **No multiplies, no sine table**: a vector `(c, s)` is rotated a little every frame by Minsky's
  trick (`c -= s>>5; s += c>>5`), which traces a near-perfect circle. The texture coordinates then
  just *accumulate*: `u += c`, `v += s` along a row, `u -= s`, `v += c` from row to row. Two
  `ADD`s per pixel replace four `IMUL`s.
- **Centre without arithmetic**: the top-left corner's coordinates are the centre offset rotated by
  the same angle, so they go through the same Minsky step in the same loop as `(c, s)`. The
  rotation centre stays within about 3 pixels of the screen centre (the test measures it).
- **16.16 fixed point in 32-bit registers**: with 16-bit values the truncation in the shifts made
  the circle spiral inwards within seconds (the first attempt at this hack did exactly that).
- **Data through `BX`**: `[bx]`, `[bx+4]`, ... are 2-3 byte operands. Only the initial vector is in
  the file; the row accumulators and the colour counter need no initial value and are not stored.

## Testing

`tests/run_tests.sh` runs all three in an emulated 16-bit CPU (Unicorn), entered the way DOS
enters a `.COM`. UBER8: within its class, sets no video mode, prints codes 0, 1, 2, ... wrapping at
256 (all 256 distinct, including BEL), touches no memory outside its segment. UBER128 and UBER256:
within their classes, enter mode 13h and restore text mode, program palette entry `i` as
`(i, 2i, 4i)` (6 bits) for all 256 entries from index 0, fill and animate a full 320x200 page every
frame, exit on Esc with a balanced stack, stay inside their segment. UBER256 additionally: the
`(c, s)` vector keeps a constant length (within 2%) over 300 frames, really rotates, and the
rotation centre stays within 4 pixels of the screen centre. CI runs it on every push and a
`vX.Y.Z` tag publishes a release.

## Related

[uber40k-dos-demo](https://github.com/djayuffe/uber40k-dos-demo): the 20-scene show with a 3D
engine and Sound Blaster music. [uber256-dos-intro](https://github.com/djayuffe/uber256-dos-intro):
a 196-byte rainbow moire.

## License

MIT
