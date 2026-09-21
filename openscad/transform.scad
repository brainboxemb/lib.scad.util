// File: transform.scad
//   Lightweight, domain-independent transform convenience modules.
//
// FileSummary: Small plain-OpenSCAD move/rotate wrappers with an xf_ prefix.
//
// These helpers intentionally remain thin wrappers around native OpenSCAD
// translate() and rotate().  They improve readability without introducing a
// geometry framework dependency such as BOSL2.


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
