# lib.scad.util plan

## Purpose

This is the operational source for future work in the domain-independent utility
library. Completed functional history belongs in [../CHANGELOG.md](../CHANGELOG.md).

## Current position

The current library provides section inspection plus existing transform and
Forge-style helper APIs.

Meta now assigns the shared Forge modeling language to `lib.scad.forge`.
Therefore:

- section inspection and other genuinely general utilities remain normal util
  work;
- the existing `xf_*` and `fg_*` APIs remain supported and verified here;
- new modeling-language features should not be added here by default;
- migration, deprecation or removal of existing APIs requires a separate API
  decision and consumer rollout.

There is no active feature issue or pull request after closing the completed
Migration-009 wrapper issue #12.

## Working method

1. inspect current source, open issues/PRs, live CI and generated evidence;
2. decide whether the proposed helper is truly domain-independent;
3. check whether it belongs in `lib.scad.forge` instead of this repository;
4. preserve existing public API behavior unless the scoped work explicitly
   changes it;
5. add a small executable verification case for each meaningful branch.

## Information sources

| Question | Authority |
| --- | --- |
| Current/future util work | this plan |
| Shared working conventions | `brainboxemb.meta/AGENTS.md` |
| Utility purpose/ownership | [10-specification.md](10-specification.md) |
| Repository architecture | [20-design.md](20-design.md) |
| Inspection detailed design | `openscad/inspection/design/design.md` |
| Transform reference | `openscad/transform/manual.md` |
| Existing fg helper reference | `openscad/forge/manual.md` |
| Verification strategy/status | [30-verification.md](30-verification.md) |
| Exact tool/runtime state | config, gitlinks, live Actions and provenance |
| Completed history | [../CHANGELOG.md](../CHANGELOG.md) |
