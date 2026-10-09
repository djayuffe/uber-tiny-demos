# UBER tiny demos

**Three DOS demos in 8, 128 and 256 bytes of hand-written x86 assembly.**

[![CI](https://github.com/djayuffe/uber-tiny-demos/actions/workflows/ci.yml/badge.svg)](https://github.com/djayuffe/uber-tiny-demos/actions/workflows/ci.yml)

| | Size | What it does | Needs |
|---|---|---|---|
| **UBER8** | **8 bytes** | a storm of every CP437 glyph, with sound | any CPU, text mode |
| **UBER128** | **118 bytes** (limit 128) | rainbow rings flowing from a swinging centre | VGA, 386+ |
| **UBER256** | **237 bytes** (limit 256) | an XOR rotozoomer: rotating, zooming, colour-rolling | VGA, 386+ |

No assets, no libraries. `build.sh` fails if any binary goes over its limit.

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

## UBER8

```
int 10h           ; CD 10     AX = 0 at entry, so this sets video mode 0
.l: int 29h       ; CD 29     DOS "fast console output": print AL
add al,83         ; 04 53     next glyph
jmp short .l      ; EB FA
```

DOS starts a `.COM` with `AX = 0` (both FCB drive flags), so `int 10h` is "set video mode
0": 40x25 text with double-width glyphs. The loop prints `AL` with `int 29h` and steps it by
83. 83 is odd, so `AL` visits all 256 values before repeating: smileys, card suits, box
drawing, `CR`/`LF` scrolls, backspace and `BEL` (07h), which beeps. The walk looks
pseudo-random, so the screen is a glyph rain. This relies on the DOS entry convention
`AX = 0`, which DOS and DOSBox both follow.

## UBER128

A rainbow palette from three triangle waves (`tri(i)`, `tri(i+85)`, `tri(i+170)`: a seamless
loop with no table and no sine), then for every pixel `r^2 = dx^2 + dy^2` from a centre that
swings left and right on a triangle wave, shifted right by 6 and added to the frame counter.
Squared distance replaces a square root, and the rolling index is what makes the rings flow.

## UBER256

An XOR texture `(u ^ v) >> 7` sampled through a rotation and a zoom about the screen centre.

- **Rotation without a sine table**: a vector `(rc, rs)` is rotated a little each frame by
  Minsky's trick (`rc -= rs>>5; rs += rc>>5`), which traces a near-perfect circle.
- **Zoom**: a triangle wave, `z = 32 + tri(t/2)`, multiplied into the vector.
- **Colour**: the same rainbow palette, rolled by the frame counter and shifted by the squared
  distance from the centre, so the edges shade differently.
- **Smooth**: it waits for vertical retrace each frame (70 fps, no tearing).

## Testing

`tests/run_tests.sh` runs all three in an emulated 16-bit CPU (Unicorn), entered the way DOS
enters a `.COM`. It checks: UBER8 is exactly 8 bytes, sets mode 0, and prints
`previous + 83` forever, covering all 256 codes including BEL; UBER128 and UBER256 are within
their limits, enter mode 13h and restore text mode, program all 256 palette entries into a
seamless loop, fill and animate a full 320x200 page every frame, exit on Esc with a balanced
stack, and never touch memory outside their segment. CI runs it on every push and a `vX.Y.Z`
tag publishes a release.

## Related

[uber40k-dos-demo](https://github.com/djayuffe/uber40k-dos-demo): the 20-scene show with a 3D
engine and Sound Blaster music. [uber256-dos-intro](https://github.com/djayuffe/uber256-dos-intro):
a 196-byte rainbow moire.

## License

MIT
