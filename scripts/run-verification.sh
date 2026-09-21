#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$root/vrf/out"
mkdir -p "$out"

source_file="$root/test/section_inspection.scad"

for axis in X Y Z; do
  for direction in Positive Negative; do
    stem="section-${axis,,}-${direction,,}"
    openscad \
      --enable=object-function \
      --render \
      -D "test_axis=\"$axis\"" \
      -D "test_direction=\"$direction\"" \
      -D "test_position=0" \
      -D "test_depth=0.1" \
      -o "$out/$stem.stl" \
      "$source_file"
    test -s "$out/$stem.stl"
  done
done

openscad \
  --enable=object-function \
  --render \
  -D 'test_axis="None"' \
  -o "$out/section-none.stl" \
  "$source_file"
test -s "$out/section-none.stl"

transform_source="$root/test/transform.scad"
for transform in move xmove ymove zmove flip xflip yflip zflip rot xrot yrot zrot object frame frame-object; do
  openscad \
    --enable=object-function \
    --render \
    -D "test_transform=\"$transform\"" \
    -o "$out/transform-$transform.stl" \
    "$transform_source"
  test -s "$out/transform-$transform.stl"
done

forge_source="$root/test/forge.scad"
for forge in diff box-object box-direct box-faces cylinder-object cylinder-direct cylinder-faces; do
  openscad \
    --enable=object-function \
    --render \
    -D "test_forge=\"$forge\"" \
    -o "$out/forge-$forge.stl" \
    "$forge_source"
  test -s "$out/forge-$forge.stl"
done

sync_fixture="$out/sync-fixture.scad"
printf 'cube([1, 1, 1]);\n' > "$sync_fixture"
bash "$root/consumer/sync-section-inspection.sh" "$sync_fixture"
grep -Fqx '// BEGIN lib.scad.util: section-inspection' "$sync_fixture"
grep -Fq 'section_depth_mm = 10; // [0.1:0.1:200]' "$sync_fixture"
! grep -Fq 'module util_section_inspect_configured' "$sync_fixture"
first_sha="$(sha256sum "$sync_fixture" | awk '{print $1}')"
bash "$root/consumer/sync-section-inspection.sh" "$sync_fixture"
second_sha="$(sha256sum "$sync_fixture" | awk '{print $1}')"
test "$first_sha" = "$second_sha"

cat > "$out/README.md" <<'EOF'
# Verification

Verified:

- X / Positive and Negative section inspection;
- Y / Positive and Negative section inspection;
- Z / Positive and Negative section inspection;
- None / pass-through section inspection;
- xf_move();
- xf_flip(), xf_xflip(), xf_yflip() and xf_zflip();
- xf_xmove(), xf_ymove() and xf_zmove();
- xf_rot();
- xf_xrot(), xf_yrot() and xf_zrot();
- xf_create() / xf_apply() object transforms;
- xf_frame() / xf_frame_create() orthogonal frame mapping;
- fg_diff() body/remove/keep tagged booleans;
- object and direct box cutters with default boolean overlap;
- named box-face overlap, including simultaneous left + right faces;
- object and direct cylinder cutters with default boolean overlap;
- named cylinder-region overlap;
- consumer block insertion;
- idempotent consumer block re-synchronization.

Axis slices use the minimum supported retained depth of 0.1 mm.
EOF
