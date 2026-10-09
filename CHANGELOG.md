# Changelog

Pushing a `vX.Y.Z` tag runs `.github/workflows/release.yml`, which builds, tests and
attaches the three `.COM` files using that version's section below.

## [1.1.0] - 2026-10-09

### Changed
- **Much smaller**: UBER8 8 -> **5** bytes, UBER128 118 -> **79**, UBER256 237 -> **171**.
  - UBER8 drops the mode set (80x25 text is already the default) and counts up.
  - Both VGA demos stream a 12-byte palette (`R = i, G = 2i, B = 4i`) straight to the DAC
    instead of a 43-byte triangle-wave rainbow, and rely on DOS's entry state (`AX = BX = 0`).
  - UBER128 has no loop nest: `DI` wraps over the 64 KB segment and one `DIV` gives x and y.
  - UBER256 is rewritten around accumulators and a Minsky-rotated vector pair (no `IMUL`, no
    sine table, no zoom code), in 16.16 fixed point.
- The new palette is denser and more saturated, and UBER256 is about four times faster.
- `build.sh` gates each demo on both its size class and the size it has been shrunk to.

### Tests
- Palette contents are checked exactly; UBER256's rotation is checked (constant length,
  rotates, centre stays put).

## [1.0.0] - 2026-10-09

First release.

- **UBER8.COM** (8 bytes): a storm of every CP437 glyph with sound.
- **UBER128.COM** (118 bytes): rainbow rings flowing from a swinging centre.
- **UBER256.COM** (237 bytes): an XOR rotozoomer with a rolling rainbow palette.
- `build.sh` enforces each size limit; `tests/run_tests.sh` runs all three in an emulated
  16-bit CPU; CI and tag-driven releases on GitHub Actions.
