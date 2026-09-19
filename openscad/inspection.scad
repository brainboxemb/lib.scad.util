// Domain-independent OpenSCAD inspection helpers.
//
// Public API:
//   util_section_inspect(axis, position, depth, direction)
//
// This helper keeps a thin axis-aligned slice of arbitrary child geometry.
// It is intended mainly for interactive inspection from a project's
// main.scad / Customizer view.
//
// All dimensional values are millimetres.
//
// Example:
//   util_section_inspect(
//       axis = "Z",
//       position = 0,
//       depth = 0.1,
//       direction = "Positive"
//   )
//       my_model();
//
// The example keeps only Z = 0.0 .. +0.1 mm.
// With direction = "Negative" it keeps Z = -0.1 .. 0.0 mm.
// axis = "None" is a deliberate no-op and passes children through unchanged.


// Keep an exact inspection slice of child geometry.
//
// Parameters:
//   axis
//     "None", "X", "Y" or "Z".
//     "None" disables inspection and leaves the child geometry unchanged.
//
//   position
//     Position of the first section plane on the selected axis.
//
//   depth
//     Thickness of the material that remains visible, measured from position.
//     Minimum supported value: 0.1 mm.
//
//   direction
//     "Positive" keeps the slice from position to position + depth.
//     "Negative" keeps the slice from position - depth to position.
//
module util_section_inspect(
    axis = "None",
    position = 0,
    depth = 10,
    direction = "Positive"
) {
    assert(
        axis == "None" || axis == "X" || axis == "Y" || axis == "Z",
        str("util_section_inspect(): unsupported axis: ", axis)
    );

    if (axis == "None") {
        children();
    } else {
        assert(
            direction == "Positive" || direction == "Negative",
            str("util_section_inspect(): unsupported direction: ", direction)
        );
        assert(
            depth >= 0.1,
            str("util_section_inspect(): depth must be at least 0.1 mm, got ", depth)
        );

        intersection() {
            children();
            _util_section_slab(
                axis = axis,
                position = position,
                depth = depth,
                direction = direction
            );
        }
    }
}


// Internal slab used by util_section_inspect().
//
// The slab is deliberately much larger than normal CAD models on the two
// non-section axes, so only the selected axis controls the retained thickness.
module _util_section_slab(
    axis,
    position,
    depth,
    direction
) {
    span = 1000000;
    positive = direction == "Positive";

    if (axis == "X")
        translate([
            positive ? position : position - depth,
            -span / 2,
            -span / 2
        ])
            cube([depth, span, span]);
    else if (axis == "Y")
        translate([
            -span / 2,
            positive ? position : position - depth,
            -span / 2
        ])
            cube([span, depth, span]);
    else if (axis == "Z")
        translate([
            -span / 2,
            -span / 2,
            positive ? position : position - depth
        ])
            cube([span, span, depth]);
}
