# Section inspection utility

## Purpose

`util_section_inspect()` is a model-independent inspection helper for looking
at a thin X, Y or Z slab of arbitrary child geometry.

It is intended for interactive OpenSCAD work where a designer wants to move a
section through a model with Customizer sliders.

## Geometry

The helper does not rebuild or reinterpret the child model. It intersects the
child geometry with one axis-aligned slab.

The parameters are:

```text
axis        None, X, Y or Z
position    first section plane, in mm
depth       retained slab thickness, in mm
direction   Positive or Negative from the first plane
```

For example:

```text
axis      Z
position  0.0 mm
depth     0.1 mm
Positive  -> retain Z =  0.0 .. +0.1 mm
Negative  -> retain Z = -0.1 ..  0.0 mm
```

The minimum supported depth is 0.1 mm. `axis="None"` is deliberately a no-op
so an interactive main entrypoint can wrap its normal selected view without a
separate conditional.

## Boundary

This utility is only an inspection operation. It must not encode dimensions,
camera settings or semantics from a consuming project.
