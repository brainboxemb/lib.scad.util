# lib.scad.util design

## Repository structure

The current public source surface is intentionally small:

```text
openscad/
└── inspection.scad
```

Detailed inspection guidance lives beside source:

```text
openscad/inspection/design/design.md
```

## Inspection

`inspection.scad` is the util-owned general geometry helper.

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

## Modeling-language boundary

Transforms, coordinate frames, tagged CSG and reusable cutters are deliberately
absent from this repository. Their shared implementation and API belong to
`lib.scad.forge`.

## Dependencies

The utility source remains plain OpenSCAD and should avoid geometry dependencies
that are unnecessary for small generic helpers.

Build/project orchestration belongs to the shared tooling repositories, not to
the utility API.
