# lib.scad.util design

## Repository structure

The current public surfaces are concrete, separate entrypoints:

```text
openscad/
├── inspection.scad
├── transform.scad
└── forge.scad
```

Their detailed guidance lives beside source:

```text
openscad/inspection/design/design.md
openscad/transform/manual.md
openscad/forge/manual.md
```

## Inspection

`inspection.scad` is the current util-owned general geometry helper.

It builds one large axis-aligned retained slab around the requested section and
intersects child geometry with that slab. `axis="None"` bypasses that operation
and returns children unchanged.

The separate inspection design document explains the geometry in detail.

## Consumer synchronization

`consumer/section-inspection.scad` is the canonical managed Customizer block.
The shell and PowerShell synchronization scripts insert or replace only the
marked block and are required to be idempotent.

This keeps interactive controls consistent without moving consumer model logic
into the library.

## Existing transform and fg helpers

`transform.scad` and `forge.scad` remain real, verified public source in this
repository.

Their existing APIs stay supported by this repository until a separate
migration changes that contract.

The architectural distinction is about **future ownership**: the current shared
Forge modeling language now lives in `lib.scad.forge`, so new language-like
modeling behavior should not automatically be added to util.

## Dependencies

The utility source remains plain OpenSCAD and should avoid geometry dependencies
that are unnecessary for small generic helpers.

Build/project orchestration belongs to the shared tooling repositories, not to
the utility API.
