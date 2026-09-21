//////////////////////////////////////////////////////////////////////
// LibFile: forge.scad
//   Small plain-OpenSCAD modeling helpers for tagged booleans and reliable
//   cutter overlap. See forge/manual.md for role and overlap semantics.
//////////////////////////////////////////////////////////////////////

use <transform.scad>

_FG_OVERLAP_MM = 0.001;


// Function: fg_overlap_mm()
// Synopsis: Returns the default boolean overlap used by Forge cutters.
function fg_overlap_mm() =
    _FG_OVERLAP_MM;



// Function: fg_left()
// Synopsis: Returns the local X-min box-overlap face token.
function fg_left() = "left";


// Function: fg_right()
// Synopsis: Returns the local X-max box-overlap face token.
function fg_right() = "right";


// Function: fg_front()
// Synopsis: Returns the local Y-min box-overlap face token.
function fg_front() = "front";


// Function: fg_back()
// Synopsis: Returns the local Y-max box-overlap face token.
function fg_back() = "back";


// Function: fg_bottom()
// Synopsis: Returns the local Z-min overlap token.
function fg_bottom() = "bottom";


// Function: fg_top()
// Synopsis: Returns the local Z-max overlap token.
function fg_top() = "top";


// Function: fg_radial()
// Synopsis: Returns the radial cylinder-overlap token.
function fg_radial() = "radial";


// Function: fg_box_cutter_create()
// Synopsis: Creates an overlap-aware box cutter specification.
// Arguments:
//   size_mm = Nominal [X,Y,Z] size before overlap is added.
//   pos_mm = Position of the nominal minimum corner.
//   rot_deg = Euler rotation applied after local overlap expansion.
//   overlap_min = Legacy per-axis booleans for extending negative faces.
//   overlap_max = Legacy per-axis booleans for extending positive faces.
//   overlap_mm = Boolean overlap amount.
//   overlap = Preferred local face tokens from fg_left(), fg_right(),
//             fg_front(), fg_back(), fg_bottom() and fg_top(). When provided,
//             this takes precedence over
//             overlap_min/overlap_max.
function fg_box_cutter_create(
    size_mm,
    pos_mm = [0, 0, 0],
    rot_deg = [0, 0, 0],
    overlap_min = [true, true, true],
    overlap_max = [true, true, true],
    overlap_mm = fg_overlap_mm(),
    overlap = undef
) =
    assert(is_list(size_mm) && len(size_mm) == 3,
        "fg_box_cutter_create size_mm must contain three values")
    assert(min(size_mm) > 0,
        "fg_box_cutter_create size_mm values must be > 0")
    assert(_fg_is_bool3(overlap_min),
        "fg_box_cutter_create overlap_min must contain three booleans")
    assert(_fg_is_bool3(overlap_max),
        "fg_box_cutter_create overlap_max must contain three booleans")
    assert(_fg_overlap_names_are_valid(
        overlap,
        [fg_left(), fg_right(), fg_front(), fg_back(), fg_bottom(), fg_top()]
    ), "fg_box_cutter_create overlap contains an unsupported face")
    assert(overlap_mm >= 0,
        "fg_box_cutter_create overlap_mm must be >= 0")
    let(
        _overlap_min =
            is_undef(overlap)
                ? overlap_min
                : [
                    _fg_has_overlap(overlap, fg_left()),
                    _fg_has_overlap(overlap, fg_front()),
                    _fg_has_overlap(overlap, fg_bottom())
                ],
        _overlap_max =
            is_undef(overlap)
                ? overlap_max
                : [
                    _fg_has_overlap(overlap, fg_right()),
                    _fg_has_overlap(overlap, fg_back()),
                    _fg_has_overlap(overlap, fg_top())
                ]
    )
    object(
        kind = "box",
        size_mm = size_mm,
        xf = xf_create(
            pos_mm = pos_mm,
            rot_deg = rot_deg
        ),
        overlap = overlap,
        overlap_min = _overlap_min,
        overlap_max = _overlap_max,
        overlap_mm = overlap_mm
    );


// Function: fg_cylinder_cutter_create()
// Synopsis: Creates an overlap-aware Z-axis cylinder cutter specification.
// Arguments:
//   diameter_mm = Nominal cylinder diameter.
//   height_mm = Nominal cylinder height.
//   pos_mm = Position of the nominal bottom-center.
//   rot_deg = Euler rotation applied after local overlap expansion.
//   has_radial_overlap = Legacy radial-overlap boolean.
//   has_bottom_overlap = Legacy bottom-overlap boolean.
//   has_top_overlap = Legacy top-overlap boolean.
//   overlap_mm = Boolean overlap amount.
//   overlap = Preferred tokens from fg_radial(), fg_bottom() and fg_top().
//             When provided, this takes precedence over the legacy booleans.
function fg_cylinder_cutter_create(
    diameter_mm,
    height_mm,
    pos_mm = [0, 0, 0],
    rot_deg = [0, 0, 0],
    has_radial_overlap = true,
    has_bottom_overlap = true,
    has_top_overlap = true,
    overlap_mm = fg_overlap_mm(),
    overlap = undef
) =
    assert(diameter_mm > 0,
        "fg_cylinder_cutter_create diameter_mm must be > 0")
    assert(height_mm > 0,
        "fg_cylinder_cutter_create height_mm must be > 0")
    assert(is_bool(has_radial_overlap),
        "fg_cylinder_cutter_create has_radial_overlap must be boolean")
    assert(is_bool(has_bottom_overlap),
        "fg_cylinder_cutter_create has_bottom_overlap must be boolean")
    assert(is_bool(has_top_overlap),
        "fg_cylinder_cutter_create has_top_overlap must be boolean")
    assert(_fg_overlap_names_are_valid(
        overlap,
        [fg_radial(), fg_bottom(), fg_top()]
    ), "fg_cylinder_cutter_create overlap contains an unsupported region")
    assert(overlap_mm >= 0,
        "fg_cylinder_cutter_create overlap_mm must be >= 0")
    let(
        _has_radial_overlap =
            is_undef(overlap)
                ? has_radial_overlap
                : _fg_has_overlap(overlap, fg_radial()),
        _has_bottom_overlap =
            is_undef(overlap)
                ? has_bottom_overlap
                : _fg_has_overlap(overlap, fg_bottom()),
        _has_top_overlap =
            is_undef(overlap)
                ? has_top_overlap
                : _fg_has_overlap(overlap, fg_top())
    )
    object(
        kind = "cylinder",
        diameter_mm = diameter_mm,
        height_mm = height_mm,
        xf = xf_create(
            pos_mm = pos_mm,
            rot_deg = rot_deg
        ),
        overlap = overlap,
        has_radial_overlap = _has_radial_overlap,
        has_bottom_overlap = _has_bottom_overlap,
        has_top_overlap = _has_top_overlap,
        overlap_mm = overlap_mm
    );


// Module: fg_cutter_build()
// Synopsis: Builds a Forge cutter specification.
// Arguments:
//   obj = Cutter object created by a Forge cutter constructor.
module fg_cutter_build(obj) {
    if (obj.kind == "box")
        _fg_box_cutter_build(obj);
    else if (obj.kind == "cylinder")
        _fg_cylinder_cutter_build(obj);
    else
        assert(false, str("Unsupported Forge cutter kind: ", obj.kind));
}


// Module: fg_cut_box()
// Synopsis: Builds an overlap-aware box cutter without storing the object.
module fg_cut_box(
    size_mm,
    pos_mm = [0, 0, 0],
    rot_deg = [0, 0, 0],
    overlap_min = [true, true, true],
    overlap_max = [true, true, true],
    overlap_mm = fg_overlap_mm(),
    overlap = undef
) {
    fg_cutter_build(
        fg_box_cutter_create(
            size_mm = size_mm,
            pos_mm = pos_mm,
            rot_deg = rot_deg,
            overlap_min = overlap_min,
            overlap_max = overlap_max,
            overlap_mm = overlap_mm,
            overlap = overlap
        )
    );
}


// Module: fg_cut_cylinder()
// Synopsis: Builds an overlap-aware cylinder cutter without storing the object.
module fg_cut_cylinder(
    diameter_mm,
    height_mm,
    pos_mm = [0, 0, 0],
    rot_deg = [0, 0, 0],
    has_radial_overlap = true,
    has_bottom_overlap = true,
    has_top_overlap = true,
    overlap_mm = fg_overlap_mm(),
    overlap = undef
) {
    fg_cutter_build(
        fg_cylinder_cutter_create(
            diameter_mm = diameter_mm,
            height_mm = height_mm,
            pos_mm = pos_mm,
            rot_deg = rot_deg,
            has_radial_overlap = has_radial_overlap,
            has_bottom_overlap = has_bottom_overlap,
            has_top_overlap = has_top_overlap,
            overlap_mm = overlap_mm,
            overlap = overlap
        )
    );
}


// Module: fg_tag()
// Synopsis: Marks one direct Forge boolean branch with a role.
// Description:
//   Within fg_diff(), every direct geometry branch must be wrapped in
//   fg_body(), fg_remove(), fg_keep() or fg_tag(). Outside fg_diff(), tags
//   pass their child geometry through unchanged.
// Arguments:
//   tag = One of "body", "remove" or "keep".
module fg_tag(tag) {
    assert(
        tag == "body"
            || tag == "remove"
            || tag == "keep",
        str("Unsupported Forge tag: ", tag)
    );

    if (
        is_undef($fg_role)
        || $fg_role == "all"
        || $fg_role == tag
    )
        children();
}


// Module: fg_body()
// Synopsis: Marks the positive/base branch of fg_diff().
module fg_body() {
    fg_tag("body")
        children();
}


// Module: fg_remove()
// Synopsis: Marks geometry subtracted by fg_diff().
module fg_remove() {
    fg_tag("remove")
        children();
}


// Module: fg_keep()
// Synopsis: Marks geometry unioned back after fg_diff().
module fg_keep() {
    fg_tag("keep")
        children();
}


// Module: fg_diff()
// Synopsis: Performs an explicit body/remove/keep tagged difference.
// Description:
//   The result is (body - remove) + keep. All participating geometry should
//   pass through an fg_body(), fg_remove(), fg_keep() or fg_tag() role. Forge
//   works with ordinary OpenSCAD geometry without an attachment framework or
//   selector parser.
module fg_diff() {
    union() {
        difference() {
            let($fg_role = "body")
                children();

            let($fg_role = "remove")
                children();
        }

        let($fg_role = "keep")
            children();
    }
}


function _fg_has_overlap(overlap, name) =
    len([
        for (_name = overlap)
            if (_name == name)
                true
    ]) > 0;


function _fg_overlap_names_are_valid(overlap, allowed) =
    is_undef(overlap)
    || (
        is_list(overlap)
        && len([
            for (_name = overlap)
                if (!_fg_has_overlap(allowed, _name))
                    _name
        ]) == 0
    );


function _fg_is_bool3(v) =
    is_list(v)
    && len(v) == 3
    && is_bool(v[0])
    && is_bool(v[1])
    && is_bool(v[2]);


function _fg_overlap_vector(flags, overlap_mm) =
    [
        for (i = [0 : 2])
            flags[i] ? overlap_mm : 0
    ];


module _fg_box_cutter_build(obj) {
    _overlap_min_mm =
        _fg_overlap_vector(
            obj.overlap_min,
            obj.overlap_mm
        );
    _overlap_max_mm =
        _fg_overlap_vector(
            obj.overlap_max,
            obj.overlap_mm
        );

    xf_apply(obj.xf)
        xf_move(-_overlap_min_mm)
            cube(
                obj.size_mm
                + _overlap_min_mm
                + _overlap_max_mm
            );
}


module _fg_cylinder_cutter_build(obj) {
    _radial_overlap_mm =
        obj.has_radial_overlap
            ? obj.overlap_mm
            : 0;
    _bottom_overlap_mm =
        obj.has_bottom_overlap
            ? obj.overlap_mm
            : 0;
    _top_overlap_mm =
        obj.has_top_overlap
            ? obj.overlap_mm
            : 0;

    xf_apply(obj.xf)
        xf_zmove(-_bottom_overlap_mm)
            cylinder(
                d =
                    obj.diameter_mm
                    + 2 * _radial_overlap_mm,
                h =
                    obj.height_mm
                    + _bottom_overlap_mm
                    + _top_overlap_mm
            );
}
