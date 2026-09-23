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

<!-- scad-project-evidence-navigation -->
## Producer execution evidence

These files describe the SCAD producer executions that actually created the retained output.
They remain unchanged when equivalent output is later hydrated from cache.

- [scad-verify execution](evidence/executions/scad-verify/execution.json) — capability, producer source revision, exact owner revision, result and producer timing when available.
  - [scad-verify log](evidence/executions/scad-verify/execution.log) — concise human-readable producer summary.

## Domain evidence

Structured SCAD/SCons reports contain the detailed target-level build and cache decisions.
They are richer domain evidence, not alternate producer logs.

- No structured domain reports are present for this output.

## Orchestration/materialization evidence

Current-run orchestration evidence explains why capabilities were selected, whether Moon executed or hydrated them, and how long current materialization and snapshot preparation took.
Producer execution evidence above remains the authority for the work that originally created cached output.

- Current orchestration evidence is attached by the publication layer.
- A later cache hydration may therefore have a current materialization revision that differs from the retained producer `source_revision`.

## Publication context

`publication-info.txt` records generated-branch context plus source, tooling and runtime provenance.
Publication/finalization consumes prepared output and must not rewrite producer execution evidence.
