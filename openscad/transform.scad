// File: transform.scad
//   Lightweight, domain-independent transform convenience modules.
//
// FileSummary: Plain-OpenSCAD placement, rotation, reflection and frame helpers.
//
// These helpers keep common placement operations readable without introducing
// a geometry framework dependency. See transform/manual.md for the mental
// model, coordinate-frame rules and the boundary with native OpenSCAD.



// Function: xf_create()
// Synopsis: Creates a reusable position/rotation transform object.
// Arguments:
//   pos_mm = Translation vector in millimetres.
//   rot_deg = Euler rotation vector in degrees.
function xf_create(
    pos_mm = [0, 0, 0],
    rot_deg = [0, 0, 0]
) =
    assert(is_list(pos_mm) && len(pos_mm) == 3,
        "xf_create pos_mm must contain three values")
    assert(is_list(rot_deg) && len(rot_deg) == 3,
        "xf_create rot_deg must contain three values")
    object(
        kind = "pose",
        pos_mm = pos_mm,
        rot_deg = rot_deg
    );



// Function: xf_frame_create()
// Synopsis: Creates an orthogonal coordinate-frame transform object.
// Description:
//   Supply any two orthogonal destination axes. The missing third axis is
//   derived to preserve a right-handed coordinate system. Supplying all three
//   axes is allowed when they are mutually orthogonal and right-handed.
// Arguments:
//   pos_mm = Destination origin in millimetres.
//   x_axis = Destination direction of local +X.
//   y_axis = Destination direction of local +Y.
//   z_axis = Destination direction of local +Z.
function xf_frame_create(
    pos_mm = [0, 0, 0],
    x_axis = undef,
    y_axis = undef,
    z_axis = undef
) =
    assert(is_list(pos_mm) && len(pos_mm) == 3,
        "xf_frame_create pos_mm must contain three values")
    assert(_xf_defined_axis_count(x_axis, y_axis, z_axis) >= 2,
        "xf_frame_create requires at least two axes")
    assert(_xf_axis_is_valid(x_axis),
        "xf_frame_create x_axis must be undef or a non-zero vec3")
    assert(_xf_axis_is_valid(y_axis),
        "xf_frame_create y_axis must be undef or a non-zero vec3")
    assert(_xf_axis_is_valid(z_axis),
        "xf_frame_create z_axis must be undef or a non-zero vec3")
    let(
        _x = is_undef(x_axis) ? undef : _xf_unit(x_axis),
        _y = is_undef(y_axis) ? undef : _xf_unit(y_axis),
        _z = is_undef(z_axis) ? undef : _xf_unit(z_axis),
        _resolved_x =
            is_undef(_x)
                ? _xf_unit(cross(_y, _z))
                : _x,
        _resolved_y =
            is_undef(_y)
                ? _xf_unit(cross(_z, _x))
                : _y,
        _resolved_z =
            is_undef(_z)
                ? _xf_unit(cross(_x, _y))
                : _z
    )
    assert(_xf_axes_are_orthogonal(
        _resolved_x,
        _resolved_y,
        _resolved_z
    ), "xf_frame_create axes must be mutually orthogonal")
    assert(
        _xf_dot(
            _xf_unit(cross(_resolved_x, _resolved_y)),
            _resolved_z
        ) > 0.999999,
        "xf_frame_create axes must form a right-handed frame"
    )
    object(
        kind = "frame",
        pos_mm = pos_mm,
        x_axis = _resolved_x,
        y_axis = _resolved_y,
        z_axis = _resolved_z
    );


// Module: xf_frame()
// Synopsis: Remaps child geometry into an orthogonal destination frame.
module xf_frame(
    pos_mm = [0, 0, 0],
    x_axis = undef,
    y_axis = undef,
    z_axis = undef
) {
    xf_apply(
        xf_frame_create(
            pos_mm = pos_mm,
            x_axis = x_axis,
            y_axis = y_axis,
            z_axis = z_axis
        )
    )
        children();
}


// Function: xf_pos_mm()
// Synopsis: Returns the translation vector from a transform object.
function xf_pos_mm(obj) =
    obj.pos_mm;


// Function: xf_rot_deg()
// Synopsis: Returns the Euler rotation vector from a transform object.
function xf_rot_deg(obj) =
    obj.rot_deg;


// Module: xf_apply()
// Synopsis: Applies a transform object to child geometry.
// Arguments:
//   obj = Pose or frame transform object created by xf_create() or
//         xf_frame_create().
module xf_apply(obj) {
    if (obj.kind == "pose")
        translate(xf_pos_mm(obj))
            rotate(xf_rot_deg(obj))
                children();
    else if (obj.kind == "frame")
        multmatrix(_xf_frame_matrix(obj))
            children();
    else
        assert(false, str("Unsupported transform kind: ", obj.kind));
}


// Module: xf_move()
// Usage:
//   xf_move([10, 0, 5])
//       children();
// Description:
//   Moves child geometry by the supplied [X, Y, Z] vector.
// Arguments:
//   v = Translation vector in millimetres.
module xf_move(v) {
    translate(v)
        children();
}


// Module: xf_xmove()
// Usage:
//   xf_xmove(10)
//       children();
// Description:
//   Moves child geometry along X.
// Arguments:
//   distance = Translation distance in millimetres.
module xf_xmove(distance) {
    translate([distance, 0, 0])
        children();
}


// Module: xf_ymove()
// Usage:
//   xf_ymove(10)
//       children();
// Description:
//   Moves child geometry along Y.
// Arguments:
//   distance = Translation distance in millimetres.
module xf_ymove(distance) {
    translate([0, distance, 0])
        children();
}


// Module: xf_zmove()
// Usage:
//   xf_zmove(10)
//       children();
// Description:
//   Moves child geometry along Z.
// Arguments:
//   distance = Translation distance in millimetres.
module xf_zmove(distance) {
    translate([0, 0, distance])
        children();
}



// Module: xf_flip()
// Synopsis: Mirrors child geometry across the plane normal to v.
// Arguments:
//   v = Mirror-plane normal vector.
module xf_flip(v) {
    mirror(v)
        children();
}


// Module: xf_xflip()
// Synopsis: Mirrors child geometry across the YZ plane.
module xf_xflip() {
    xf_flip([1, 0, 0])
        children();
}


// Module: xf_yflip()
// Synopsis: Mirrors child geometry across the XZ plane.
module xf_yflip() {
    xf_flip([0, 1, 0])
        children();
}


// Module: xf_zflip()
// Synopsis: Mirrors child geometry across the XY plane.
module xf_zflip() {
    xf_flip([0, 0, 1])
        children();
}


// Module: xf_rot()
// Usage:
//   xf_rot([90, 0, 45])
//       children();
// Description:
//   Rotates child geometry by the supplied [X, Y, Z] Euler-angle vector.
// Arguments:
//   angles = Rotation angles in degrees.
module xf_rot(angles) {
    rotate(angles)
        children();
}


// Module: xf_xrot()
// Usage:
//   xf_xrot(90)
//       children();
// Description:
//   Rotates child geometry around X.
// Arguments:
//   angle = Rotation angle in degrees.
module xf_xrot(angle) {
    rotate([angle, 0, 0])
        children();
}


// Module: xf_yrot()
// Usage:
//   xf_yrot(90)
//       children();
// Description:
//   Rotates child geometry around Y.
// Arguments:
//   angle = Rotation angle in degrees.
module xf_yrot(angle) {
    rotate([0, angle, 0])
        children();
}


// Module: xf_zrot()
// Usage:
//   xf_zrot(90)
//       children();
// Description:
//   Rotates child geometry around Z.
// Arguments:
//   angle = Rotation angle in degrees.
module xf_zrot(angle) {
    rotate([0, 0, angle])
        children();
}


function _xf_defined_axis_count(x_axis, y_axis, z_axis) =
    (is_undef(x_axis) ? 0 : 1)
    + (is_undef(y_axis) ? 0 : 1)
    + (is_undef(z_axis) ? 0 : 1);


function _xf_axis_is_valid(axis) =
    is_undef(axis)
    || (
        is_list(axis)
        && len(axis) == 3
        && _xf_norm(axis) > 0
    );


function _xf_dot(a, b) =
    a[0] * b[0]
    + a[1] * b[1]
    + a[2] * b[2];


function _xf_norm(v) =
    sqrt(_xf_dot(v, v));


function _xf_unit(v) =
    v / _xf_norm(v);


function _xf_axes_are_orthogonal(x_axis, y_axis, z_axis) =
    abs(_xf_dot(x_axis, y_axis)) < 0.000001
    && abs(_xf_dot(x_axis, z_axis)) < 0.000001
    && abs(_xf_dot(y_axis, z_axis)) < 0.000001;


function _xf_frame_matrix(obj) =
    [
        [
            obj.x_axis[0],
            obj.y_axis[0],
            obj.z_axis[0],
            obj.pos_mm[0]
        ],
        [
            obj.x_axis[1],
            obj.y_axis[1],
            obj.z_axis[1],
            obj.pos_mm[1]
        ],
        [
            obj.x_axis[2],
            obj.y_axis[2],
            obj.z_axis[2],
            obj.pos_mm[2]
        ],
        [0, 0, 0, 1]
    ];
