# Forge modeling helpers

`openscad/forge.scad` provides a small constructive-modeling layer for
patterns that otherwise create repetitive or error-prone OpenSCAD CSG code.

Forge is inspired by the readability of BOSL2 tagged booleans and
Relativity.scad class-based CSG, but it intentionally does **not** implement an
attachment framework, selector language or replacement geometry system.

Its scope is currently:

- readable body/remove/keep differences;
- centralized Boolean overlap;
- overlap-aware box and cylinder cutters;
- cutter specifications stored as OpenSCAD `object()` values;
- composition with the shared `xf_*` transform helpers.

## Mental model

A Forge difference describes intent directly:

```openscad
fg_diff() {
    fg_body()
        housing();

    fg_remove()
        cable_hole();

    fg_keep()
        bridge();
}
```

The result is:

```text
(body - remove) + keep
```

This is useful when the ordinary nesting:

```openscad
union() {
    difference() {
        housing();
        cable_hole();
    }

    bridge();
}
```

becomes hard to read because the positive and negative geometry is spread over
larger modules.

## Tagged difference roles

Forge has three roles:

| Role | Meaning |
| --- | --- |
| `fg_body()` | positive geometry that forms the difference body |
| `fg_remove()` | geometry subtracted from the body |
| `fg_keep()` | geometry unioned back after subtraction |

`fg_tag("body")`, `fg_tag("remove")` and `fg_tag("keep")` are the generic
forms. Prefer the named wrappers in normal model code.

### Role discipline

All geometry participating in `fg_diff()` should pass through one of the
three role wrappers. Do not place ordinary untagged geometry directly inside
`fg_diff()`: the child tree is evaluated for each role pass, so untagged
geometry does not have a well-defined Forge role.

The clearest style is explicit sibling branches:

```openscad
fg_diff() {
    fg_body() {
        shell();
        flange();
    }

    fg_remove() {
        bolt_hole();
        cable_slot();
    }

    fg_keep()
        local_reinforcement();
}
```

A role wrapper may contain multiple pieces of geometry. Role wrappers can also
live inside called modules; Forge uses dynamically scoped role state while
evaluating the child tree.

Outside `fg_diff()`, role wrappers pass their child geometry through. This
lets a tagged helper remain inspectable by itself.

## Boolean overlap

Coincident CSG faces can leave numerical artifacts or thin residual walls.
Forge owns one small default robustness overlap:

```openscad
fg_overlap_mm(); // 0.001 mm
```

This value is **not**:

- fit clearance;
- printer tolerance;
- material allowance;
- a nominal design dimension.

It exists only to make Boolean operations robust.

A consumer with a deliberate larger modeling overlap may supply
`overlap_mm` explicitly. Do not use Forge overlap to compensate for a fit
problem.

## Box cutters

The direct helper is convenient for a one-off cutter:

```openscad
fg_cut_box(
    size_mm = [10, 20, 5],
    pos_mm = [5, 0, 0]
);
```

`size_mm` is the nominal box size. `pos_mm` is the nominal minimum corner
before local overlap is added.

By default all six faces receive Boolean overlap.

For precise face control, prefer the named local faces:

```openscad
fg_cut_box(
    size_mm = [10, 20, 5],
    pos_mm = [5, 0, 0],
    overlap = [fg_left(), fg_right(), fg_back()]
);
```

The names refer to the cutter's **local** box faces:

| Name | Local face |
| --- | --- |
| `fg_left()` | X-min |
| `fg_right()` | X-max |
| `fg_front()` | Y-min |
| `fg_back()` | Y-max |
| `fg_bottom()` | Z-min |
| `fg_top()` | Z-max |

Opposite faces remain independent. For example, `[fg_left(), fg_right()]` extends
both X faces; the directions are not summed and therefore cannot cancel.

The public face tokens are functions deliberately. Normal consumers load Forge
with `use <forge.scad>`; OpenSCAD imports functions/modules through `use` but
not global variable constants. The token functions therefore remain available
without requiring consumers to switch to `include`.

Internally these functions return stable string tokens. Supplying the equivalent
string values remains accepted, but consumer code should prefer the functions
for discoverability and typo resistance.

`overlap = []` explicitly requests no Boolean overlap. If `overlap` is
omitted, the v0.3.0 `overlap_min` / `overlap_max` boolean inputs remain
supported for compatibility. The named list takes precedence when both forms
are supplied.

This lets a cutter cross the specific Boolean boundaries it must cross without
silently changing unrelated outer faces.

## Cylinder cutters

`fg_cut_cylinder()` creates a nominal Z-axis cylinder cutter:

```openscad
fg_cut_cylinder(
    diameter_mm = 5,
    height_mm = 12,
    pos_mm = [20, 10, 0]
);
```

The nominal position is the bottom-center of the cylinder.

Overlap uses the same named-list style:

```openscad
fg_cut_cylinder(
    diameter_mm = 5,
    height_mm = 12,
    overlap = [fg_radial(), fg_top()]
);
```

`fg_radial()` increases the diameter by twice `overlap_mm`; `fg_bottom()`
and `fg_top()` extend the cylinder along local Z.

The older `has_radial_overlap`, `has_bottom_overlap` and
`has_top_overlap` booleans remain accepted when `overlap` is omitted.

## Cutter objects

Use the `*_create()` form when the cutter itself should be stored as data:

```openscad
_access_cut =
    fg_box_cutter_create(
        size_mm = [10, 5, 3],
        pos_mm = [2, 0, 4],
        overlap = [fg_left(), fg_right(), fg_back()]
    );

fg_cutter_build(_access_cut);
```

Available constructors are:

```openscad
fg_box_cutter_create(...);
fg_cylinder_cutter_create(...);
```

Both return OpenSCAD objects. `fg_cutter_build(obj)` dispatches from the
object's cutter kind.

The direct helpers:

```openscad
fg_cut_box(...);
fg_cut_cylinder(...);
```

construct and build the same specification immediately.

Use an object when reuse, ownership or inspection of the cutter specification
matters. Prefer the direct form for simple local cuts.

## Forge and transforms

Forge cutter objects use the shared transform layer internally. Their
`pos_mm` and `rot_deg` arguments describe placement without requiring the
consumer to add a surrounding `translate()` / `rotate()` stack.

For other geometry, compose Forge with `xf_*` normally:

```openscad
fg_diff() {
    fg_body()
        housing();

    fg_remove()
        xf_zmove(8)
            bore_cutter();
}
```

See [Transform helpers](../transform/manual.md) for frames, transform objects
and reflection.

## Migration example

A typical native cutter:

```openscad
difference() {
    body();

    translate([
        x0 - 0.001,
        y0,
        z0
    ])
        cube([
            len + 0.002,
            depth + 0.001,
            width
        ]);
}
```

can become:

```openscad
fg_diff() {
    fg_body()
        body();

    fg_remove()
        fg_cut_box(
            size_mm = [len, depth, width],
            pos_mm = [x0, y0, z0],
            overlap = [fg_left(), fg_right(), fg_back()]
        );
}
```

The second version separates nominal geometry from Boolean robustness and makes
the cut direction visible.

## What Forge does not own

Forge should remain small. It does not own:

- domain geometry or mechanical dimensions;
- fit/clearance rules;
- attachments or anchor systems;
- a CSS-like selector language;
- replacements for every native OpenSCAD primitive;
- arbitrary coordinate-frame math;
- product-specific cutter semantics.

Mechanical/interface libraries should keep their actual design math. Forge
only removes generic CSG and transform boilerplate that is useful across
unrelated projects.
