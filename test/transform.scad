use <../openscad/transform.scad>

test_transform = "move"; // [move,xmove,ymove,zmove,flip,xflip,yflip,zflip,rot,xrot,yrot,zrot,object,frame,frame-object]

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
else if (test_transform == "flip")
    xf_flip([1, 1, 0])
        fixture();
else if (test_transform == "xflip")
    xf_xflip()
        fixture();
else if (test_transform == "yflip")
    xf_yflip()
        fixture();
else if (test_transform == "zflip")
    xf_zflip()
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
else if (test_transform == "frame")
    xf_frame(
        pos_mm = [5, 6, 7],
        x_axis = [0, 1, 0],
        y_axis = [0, 0, 1]
    )
        fixture();
else if (test_transform == "frame-object")
    xf_apply(
        xf_frame_create(
            pos_mm = [5, 6, 7],
            x_axis = [0, 1, 0],
            y_axis = [0, 0, 1]
        )
    )
        fixture();
