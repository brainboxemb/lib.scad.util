#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <consumer.scad>" >&2
  exit 2
fi

target="$1"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
snippet="$script_dir/section-inspection.scad"

[[ -f "$target" ]] || { echo "Target SCAD file not found: $target" >&2; exit 1; }
[[ -f "$snippet" ]] || { echo "Canonical snippet not found: $snippet" >&2; exit 1; }

start='// BEGIN lib.scad.util: section-inspection'
end='// END lib.scad.util: section-inspection'
start_count="$(grep -Fxc "$start" "$target" || true)"
end_count="$(grep -Fxc "$end" "$target" || true)"

if [[ "$start_count" -ne "$end_count" ]]; then
  echo "Managed section-inspection markers are incomplete in: $target" >&2
  exit 1
fi
if [[ "$start_count" -gt 1 ]]; then
  echo "Multiple managed section-inspection blocks found in: $target" >&2
  exit 1
fi

if [[ "$start_count" -eq 0 ]] && grep -Eq '^[[:space:]]*section_(axis|position_mm|depth_mm|direction)[[:space:]]*=' "$target"; then
  echo "Unmanaged section-inspection variables already exist in: $target" >&2
  echo "Remove or mark the old block before synchronizing to avoid duplicate parameters." >&2
  exit 1
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

if [[ "$start_count" -eq 1 ]]; then
  awk -v start="$start" -v end="$end" -v snippet_file="$snippet" '
    $0 == start {
      while ((getline line < snippet_file) > 0) print line
      close(snippet_file)
      managed = 1
      next
    }
    managed && $0 == end {
      managed = 0
      next
    }
    !managed { print }
  ' "$target" > "$tmp"
else
  awk -v snippet_file="$snippet" '
    !inserted && $0 ~ /^[[:space:]]*(module|function)[[:space:]]/ {
      while ((getline line < snippet_file) > 0) print line
      close(snippet_file)
      print ""
      inserted = 1
    }
    { print }
    END {
      if (!inserted) {
        print ""
        while ((getline line < snippet_file) > 0) print line
        close(snippet_file)
      }
    }
  ' "$target" > "$tmp"
fi

cat "$tmp" > "$target"
echo "Synchronized section-inspection Customizer block in $target"
