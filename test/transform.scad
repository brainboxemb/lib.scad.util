use <../openscad/transform.scad>

test_transform = "move"; // [move,xmove,ymove,zmove,rot,xrot,yrot,zrot,object]

module fixture() {
    cube([2, 3, 4]);
}

if (test_transform == "move")
    xf_move([5, 6, 7])
        fixture();
else if (test_transform == "xmove")
    xf_xmove(5)
        fixture();
else if (test_transform == "ymove")
    xf_ymove(6)
        fixture();
else if (test_transform == "zmove")
    xf_zmove(7)
        fixture();
else if (test_transform == "rot")
    xf_rot([15, 25, 35])
        fixture();
else if (test_transform == "xrot")
    xf_xrot(30)
        fixture();
else if (test_transform == "yrot")
    xf_yrot(40)
        fixture();
else if (test_transform == "zrot")
    xf_zrot(50)
        fixture();
else if (test_transform == "object")
    xf_apply(
        xf_create(
            pos_mm = [5, 6, 7],
            rot_deg = [15, 25, 35]
        )
    )
        fixture();
