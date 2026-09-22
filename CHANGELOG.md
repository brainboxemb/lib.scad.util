# Changelog

## Unreleased

### Changed

- Adopt released `tool.scad-project v0.15.6` with exact tool gitlink `8ea81a0c3483770bedda75ccf80fb72797097c0a` for Migration 009, preserving utility-library geometry/API while correcting production-branch run concurrency.

## v0.4.0

### Added

- Add preferred named overlap lists for Forge cutters, for example
  `overlap = [fg_left(), fg_right(), fg_back()]` on boxes and
  `overlap = [fg_radial(), fg_top()]` on cylinders. Token functions are imported through normal OpenSCAD `use` and resolve by
  membership so opposite faces remain independent; the v0.3.0 boolean overlap
  parameters remain supported for compatibility.


## v0.3.0

### Added

- Forge modeling helpers in `openscad/forge.scad`: explicit body/remove/keep
  tagged differences, object/direct box and cylinder cutters, and one
  library-owned 0.001 mm default boolean overlap.
- Object-based transforms through `xf_create()` and `xf_apply()`, while
  retaining the existing lightweight `xf_*` wrappers.
- Add `xf_frame()` / `xf_frame_create()` for readable orthogonal coordinate-frame
  remapping without exposing raw `multmatrix()` coefficients to consumers.
- Add `xf_flip()` plus axis-specific mirror helpers so reflected frame mappings
  remain readable without hand-written reflection matrices.


## v0.2.0

### Added

- Lightweight plain-OpenSCAD transform helpers with the `xf_` prefix:
  `xf_move()`, axis-specific move helpers, `xf_rot()` and axis-specific
  rotation helpers.

## v0.1.0

### Added

- Initial domain-independent utility-library structure.
- `util_section_inspect()` for retaining an exact X/Y/Z inspection slab.
- Verification coverage for all axes, both directions and no-op mode.
