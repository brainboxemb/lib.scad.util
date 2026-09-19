// File: inspection.scad
//   Domain-independent helpers for inspecting thin axis-aligned slices of
//   arbitrary OpenSCAD child geometry.
//
// FileSummary: Public X/Y/Z section-inspection utility for interactive CAD work.
//
// The utility is intended mainly for a project's main.scad / Customizer view.
// It keeps one exact slab of the child model without changing the model itself.
//
// Coordinate meaning:
// - axis = "X", "Y" or "Z" selects the normal of the retained slab;
// - position is the first section plane on that axis, in millimetres;
// - depth is the exact thickness that remains visible, in millimetres;
// - direction selects which side of position contains that retained thickness.
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


// Module: util_section_inspect()
// Usage:
//   util_section_inspect(axis="Z", position=0, depth=0.1, direction="Positive")
//       my_model();
// Description:
//   Retains one exact axis-aligned inspection slab of the child geometry.
//   Use axis="None" to disable inspection without changing the surrounding
//   consumer code.
// Arguments:
//   axis = "None", "X", "Y" or "Z". "None" passes children through unchanged.
//   position = First section plane on the selected axis, in millimetres.
//   depth = Retained slab thickness measured from position. Minimum 0.1 mm.
//   direction = "Positive" retains position..position+depth; "Negative"
//               retains position-depth..position.
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


// Private implementation: build the clipping slab used by
// util_section_inspect().  The slab is deliberately much larger than normal
// CAD models on the two non-section axes, so only the selected axis controls
// the retained thickness.
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
