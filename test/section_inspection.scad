use <../openscad/inspection.scad>

test_axis = is_undef(test_axis) ? "Z" : test_axis;
test_position = is_undef(test_position) ? 0 : test_position;
test_depth = is_undef(test_depth) ? 0.1 : test_depth;
test_direction = is_undef(test_direction) ? "Positive" : test_direction;

util_section_inspect(
    axis = test_axis,
    position = test_position,
    depth = test_depth,
    direction = test_direction
)
    cube([20, 20, 20], center = true);
