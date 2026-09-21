use <../openscad/forge.scad>

test_forge = "diff"; // [diff,box-object,box-direct,box-faces,cylinder-object,cylinder-direct,cylinder-faces]

module body_fixture() {
    cube([10, 10, 10]);
}

if (test_forge == "diff")
    fg_diff() {
        fg_body()
            body_fixture();

        fg_remove()
            fg_cut_box(
                size_mm = [4, 4, 12],
                pos_mm = [3, 3, -1],
                overlap_min = [false, false, false],
                overlap_max = [false, false, false]
            );

        fg_keep()
            translate([4, 4, 4])
                cube([2, 2, 2]);
    }
else if (test_forge == "box-object") {
    _cutter =
        fg_box_cutter_create(
            size_mm = [4, 5, 6],
            pos_mm = [1, 2, 3],
            rot_deg = [0, 0, 15]
        );

    fg_cutter_build(_cutter);
}
else if (test_forge == "box-direct")
    fg_cut_box(
        size_mm = [4, 5, 6],
        pos_mm = [1, 2, 3]
    );
else if (test_forge == "box-faces") {
    _cutter =
        fg_box_cutter_create(
            size_mm = [4, 5, 6],
            pos_mm = [1, 2, 3],
            overlap = [fg_left(), fg_right(), fg_back()]
        );

    assert(
        _cutter.overlap_min == [true, false, false],
        "named box overlap must preserve left independently"
    );
    assert(
        _cutter.overlap_max == [true, true, false],
        "named box overlap must preserve right and back independently"
    );

    fg_cutter_build(_cutter);
}
else if (test_forge == "cylinder-object") {
    _cutter =
        fg_cylinder_cutter_create(
            diameter_mm = 5,
            height_mm = 8,
            pos_mm = [2, 3, 1],
            rot_deg = [0, 25, 0]
        );

    fg_cutter_build(_cutter);
}
else if (test_forge == "cylinder-direct")
    fg_cut_cylinder(
        diameter_mm = 5,
        height_mm = 8,
        pos_mm = [2, 3, 1]
    );
else if (test_forge == "cylinder-faces") {
    _cutter =
        fg_cylinder_cutter_create(
            diameter_mm = 5,
            height_mm = 8,
            overlap = [fg_radial(), fg_top()]
        );

    assert(
        _cutter.has_radial_overlap,
        "named cylinder overlap must enable radial overlap"
    );
    assert(
        !_cutter.has_bottom_overlap,
        "named cylinder overlap must leave bottom nominal"
    );
    assert(
        _cutter.has_top_overlap,
        "named cylinder overlap must enable top overlap"
    );

    fg_cutter_build(_cutter);
}
