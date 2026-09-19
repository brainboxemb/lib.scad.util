// Domain-independent OpenSCAD inspection helpers.
//
// Public API:
//   util_section_inspect(axis, position, depth, direction)
//
// All dimensional values are millimetres.

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
