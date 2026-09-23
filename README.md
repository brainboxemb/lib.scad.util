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

- [Workflow phase timings](orchestration/timings.json)
- [Run context and snapshot-preparation timing](orchestration/run-context.json)
- [Moon impact decision](orchestration/impact-decision.json)
- [Affected Moon task ids](orchestration/affected-task-ids.json)
- [SCAD execution/materialization plan](orchestration/scad-ci-plan.json)

### Current workflow timing

| Phase | Duration |
| --- | ---: |
| Preflight + execution plan | 11.997 s |
| Cache restore | 888 ms |
| Runtime pull | 15.037 s |
| Capability materialization | 7.138 s |
| Cache save | 1.026 s |
| Validation + finishing | 314 ms |
| Snapshot preparation | 3 ms |
| **Total to prepared snapshot** | **36.484 s** |

The table stops when this generated snapshot is ready. The remote branch push happens afterwards; detailed per-capability timings remain in the materialization files below.

- [consumer:scad.verify materialization](orchestration/moon-invocations/consumer_scad.verify/materialization.json) — current execute/cache/hydrate result and duration.
  - [consumer:scad.verify raw Moon/producer log](orchestration/moon-invocations/consumer_scad.verify/moon.log)

## Publication context

`publication-info.txt` records generated-branch context plus source, tooling and runtime provenance.
Publication/finalization consumes prepared output and must not rewrite producer execution evidence.
