# Changelog

Pushing a `vX.Y.Z` tag runs `.github/workflows/release.yml`, which builds, tests and
attaches the three `.COM` files using that version's section below.

## [1.0.0] - 2026-10-09

First release.

- **UBER8.COM** (8 bytes): a storm of every CP437 glyph with sound.
- **UBER128.COM** (118 bytes): rainbow rings flowing from a swinging centre.
- **UBER256.COM** (237 bytes): an XOR rotozoomer with a rolling rainbow palette.
- `build.sh` enforces each size limit; `tests/run_tests.sh` runs all three in an emulated
  16-bit CPU; CI and tag-driven releases on GitHub Actions.
