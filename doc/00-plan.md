# lib.scad.util plan

## Purpose

This is the operational source for future work in the domain-independent utility
library. Completed functional history belongs in [../CHANGELOG.md](../CHANGELOG.md).

## Current position

The library is intentionally narrow: it owns section inspection plus the managed
consumer controls used to expose that inspection interactively.

Shared modeling-language behavior now belongs to `lib.scad.forge`. In
particular, transforms, tagged CSG and overlap-aware cutters are not util
responsibilities and should not be reintroduced here.

## Working method

1. inspect current source, open issues/PRs, live CI and generated evidence;
2. decide whether the proposed helper is truly domain-independent;
3. check whether modeling-language behavior belongs in `lib.scad.forge`;
4. keep the public utility surface small and concrete;
5. add a small executable verification case for each meaningful branch.

## Information sources

| Question | Authority |
| --- | --- |
| Current/future util work | this plan |
| Shared working conventions | `brainboxemb.meta/AGENTS.md` |
| Utility purpose/ownership | [10-specification.md](10-specification.md) |
| Repository architecture | [20-design.md](20-design.md) |
| Inspection detailed design | `openscad/inspection/design/design.md` |
| Verification strategy/status | [30-verification.md](30-verification.md) |
| Exact tool/runtime state | config, gitlinks, live Actions and provenance |
| Completed history | [../CHANGELOG.md](../CHANGELOG.md) |
