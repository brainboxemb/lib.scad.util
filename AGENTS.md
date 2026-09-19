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

Public modules and functions use the `util_` prefix to avoid collisions in
OpenSCAD's shared namespace.

Private implementation helpers use a leading underscore.

Keep dependencies minimal. A utility should use plain OpenSCAD when practical;
do not add BOSL2 or another geometry dependency merely for convenience.

## Units and geometry

Public dimensional parameters are millimetres unless explicitly documented
otherwise.

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
