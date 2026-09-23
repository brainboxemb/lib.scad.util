# lib.scad.util

Small, reusable OpenSCAD utilities that do not belong to a product-specific
library or to the current Forge modeling language.

## Start here

- [Plan](doc/00-plan.md)
- [Specification](doc/10-specification.md)
- [Design](doc/20-design.md)
- [Verification](doc/30-verification.md)
- [Inspection design](openscad/inspection/design/design.md)
- [Transform manual](openscad/transform/manual.md)
- [Existing Forge-helper manual](openscad/forge/manual.md)
- [Changelog](CHANGELOG.md)

## What lives here

| Area | Public surface | Role |
| --- | --- | --- |
| Section inspection | `util_section_inspect()` | Current util-owned general inspection helper |
| Transform helpers | `xf_*` | Existing supported API retained in this library |
| Forge-style helpers | `fg_*` | Existing supported API retained here; new Forge modeling-language work belongs in `lib.scad.forge` |

That ownership split matters: this migration does **not** remove or deprecate the
existing `xf_*` / `fg_*` APIs. It only makes clear where new shared modeling
language work should go.

## Section inspection

`util_section_inspect()` keeps an exact slab of arbitrary child geometry:

```scad
use <openscad/inspection.scad>

util_section_inspect(
    axis = "Z",
    position = 0,
    depth = 0.1,
    direction = "Positive"
)
    my_model();
```

`axis="None"` is a deliberate no-op and passes children through unchanged.

The library also owns a canonical Customizer block for this inspection mode.
Consumer projects can synchronize that block with the scripts under
`consumer/`.

## Existing transform surface

```scad
use <openscad/transform.scad>

xf_zmove(10)
    xf_xrot(90)
        cylinder(d = 5, h = 20);
```

See the [Transform manual](openscad/transform/manual.md) for frames, transform
objects and the boundary with native OpenSCAD.

## Existing Forge-style surface

The repository still publishes and verifies its existing `fg_*` helpers.
See the [Forge-helper manual](openscad/forge/manual.md) for those exact APIs.

New shared Forge modeling-layer development belongs to
[`lib.scad.forge`](https://github.com/brainboxemb/lib.scad.forge), as defined
by the current SCAD library ownership model.

There is no useful generated overview image for this utility library today, so
the README stays concrete through real API examples rather than adding a
decorative visual.

Current tool/runtime versions are intentionally not copied here. Use
`project.yml`, committed gitlinks, live Actions and publication provenance for
the exact current state.
