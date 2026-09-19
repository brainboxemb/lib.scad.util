// BEGIN lib.scad.util: section-inspection
/* [Section inspection] */
section_axis = "None"; // [None,X,Y,Z]
section_position_mm = 0; // [-100:0.5:100]
section_depth_mm = 10; // [0.1:0.1:200]
section_direction = "Positive"; // [Positive,Negative]

module util_section_inspect_configured() {
    util_section_inspect(
        axis = section_axis,
        position = section_position_mm,
        depth = section_depth_mm,
        direction = section_direction
    )
        children();
}
// END lib.scad.util: section-inspection
