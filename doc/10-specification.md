# lib.scad.util specification

## Why this library exists

Some OpenSCAD helpers are useful across unrelated products but do not justify
being product libraries or part of a shared modeling language.

`lib.scad.util` owns those small domain-independent utilities.

## Inspection contract

`util_section_inspect()` exists to inspect a thin axis-aligned slab of child
geometry without modifying the underlying model.

Its intended semantics are:

- X, Y or Z chooses the slab normal;
- `position` is the first section plane;
- `depth` is the exact retained thickness;
- Positive/Negative selects the retained side;
- `axis="None"` passes children through unchanged.

Section depth means retained slab thickness, not removed depth.

## Consumer control synchronization

The library also owns one canonical Customizer-variable block for interactive
section inspection. The synchronization scripts must be idempotent and must not
silently duplicate or drift those controls in consuming projects.

## Ownership boundary

This library does not own a modeling language.

Shared transforms, coordinate frames, tagged CSG, cutters, overlap semantics and
similar modeling vocabulary belong to `lib.scad.forge`.

## Non-goals

This library does not own product-specific geometry, hardware semantics,
project/build tooling, or a parallel Forge-compatible API surface.
