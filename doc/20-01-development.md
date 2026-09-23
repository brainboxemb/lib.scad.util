# lib.scad.util development manual

## Start

1. read [../AGENTS.md](../AGENTS.md);
2. read [10-00-plan.md](10-00-plan.md);
3. use [README.md](README.md) to locate specification, design and verification;
4. inspect `openscad/inspection.scad`, its component-local design and matching
   verification before changing behavior.

## Repository entrypoints

Managed root repository entrypoints are:

```text
bootstrap.ps1 / bootstrap.sh
update.ps1 / update.sh
```

`tools/tool.git-project` is the bootstrap gitlink. `project.yml` selects the
released `tool.scad-project` ref and the committed gitlink records the exact
resolved revision.

Repository-owned workflows are:

```text
.github/workflows/self-ci.yml
.github/workflows/self-release.yml
.github/workflows/self-pr-cleanup.yml
```

They are thin self-entry callers. Shared orchestration stays in the released
reusable workflows owned by `tool.scad-project` and `tool.git-project`.

## Edit and verify

The public library source is intentionally narrow. Normal changes should keep
`openscad/inspection.scad` and the managed consumer-control scripts coherent.

Verification runs through the SCAD project workflow and
`scripts/run-verification.sh`. Generated evidence belongs under `vrf/out`;
build output belongs under `bld/`.

## Dependencies and updates

Dependency/version selection points are `project.yml`, committed gitlinks and
the workflow callers. Use the managed root update launcher rather than copying
dependency-update logic into this repository.

## Release

A release is created only from an exact qualified main commit through
`self-release.yml`. Check exact-main CI plus `prod/bld` and `prod/vrf`
provenance first, then use the repository release-request lifecycle.

Current cross-project release/version-selection policy is coordinated from
`brainboxemb.meta`; repository-local release notes remain in
[../CHANGELOG.md](../CHANGELOG.md).
