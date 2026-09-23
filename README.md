# lib.scad.util

Small, reusable OpenSCAD utilities that do not belong to a product-specific
library or to the Forge modeling language.

## Start here

- [Plan](doc/00-plan.md)
- [Specification](doc/10-specification.md)
- [Design](doc/20-design.md)
- [Verification](doc/30-verification.md)
- [Inspection design](openscad/inspection/design/design.md)
- [Changelog](CHANGELOG.md)

## What lives here

| Area | Public surface | Role |
| --- | --- | --- |
| Section inspection | `util_section_inspect()` | General interactive geometry inspection |
| Consumer controls | managed section-inspection Customizer block | Keeps inspection controls synchronized in consumers |

Transforms, tagged CSG, cutters and related shared modeling vocabulary belong to
[`lib.scad.forge`](https://github.com/brainboxemb/lib.scad.forge).

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

There is no useful generated overview image for this utility library today, so
the README stays concrete through the real API example rather than adding a
decorative visual.

Current tool/runtime versions are intentionally not copied here. Use
`project.yml`, committed gitlinks, live Actions and publication provenance for
the exact current state.
