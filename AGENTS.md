# Repository agent guidance

Persistent guidance for work in `lib.scad.util`.

## Repository role

This repository owns small, reusable, domain-independent OpenSCAD utilities.

A helper belongs here only when its meaning is independent of a particular
project, product or hardware family. Domain geometry remains in its owning
library or project. Shared build/project behaviour remains in
`tool.scad-project`.

## Generic workflow policy

Before branch, pull-request, publication or release work, read the pinned
`tools/tool.scad-project/AGENTS.md`.

Generic bootstrap and dependency handling belong to the pinned
`tools/tool.git-project`.

## Public API

General public modules and functions use the `util_` prefix to avoid collisions
in OpenSCAD's shared namespace.

The lightweight transform layer in `openscad/transform.scad` and the Forge
modeling layer in `openscad/forge.scad` are deliberate exceptions. Transform
helpers use the short `xf_` prefix; Forge modeling/boolean helpers use `fg_`.
Both prefixes are language-like APIs rather than domain geometry.

Private implementation helpers use a leading underscore.

Within a source file, place public modules/functions before their private
implementation helpers so the consumer-facing API is visible first.

Keep dependencies minimal. A utility should use plain OpenSCAD when practical;
do not add BOSL2 or another geometry dependency merely for convenience.

## Units and geometry

Public dimensional parameters are millimetres unless explicitly documented
otherwise.

Forge's default boolean overlap is a modeling robustness allowance, not design
clearance. Keep its library default small and centralized; a consumer that
needs a larger manufacturing/modeling overlap must request that explicitly.

Inspection helpers must not modify the source model outside the requested
inspection operation. `axis="None"` must pass child geometry through
unchanged.

Section depth means retained slab thickness, not removed depth.

## Verification

Each public helper needs a small executable verification case covering its
meaningful branches. For section inspection that includes X/Y/Z,
Positive/Negative and the no-op `None` mode.

Generated verification evidence belongs below `vrf/out/`, not on `main`.

## Dependencies

Direct tooling gitlinks are:

```text
tools/tool.git-project
tools/tool.scad-project
```

Do not recursively initialize tool-owned development dependencies.
