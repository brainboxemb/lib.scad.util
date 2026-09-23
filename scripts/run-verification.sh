#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$root/vrf/out"
mkdir -p "$out"
cp "$root/doc/50-00-verification.md" "$out/50-00-verification.md"

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

Repository-level strategy/status: [50-00-verification.md](50-00-verification.md).

Verified:

- X / Positive and Negative section inspection;
- Y / Positive and Negative section inspection;
- Z / Positive and Negative section inspection;
- None / pass-through section inspection;
- consumer block insertion;
- idempotent consumer block re-synchronization.

Axis slices use the minimum supported retained depth of 0.1 mm.
EOF
