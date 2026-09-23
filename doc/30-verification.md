# lib.scad.util verification

## Strategy

Verification is executable and deliberately small. It exercises every meaningful
branch of the current public helper surfaces and the managed consumer controls.

## Inspection coverage

`test/section_inspection.scad` verifies:

- X / Positive and Negative;
- Y / Positive and Negative;
- Z / Positive and Negative;
- `None` pass-through mode.

Axis slices use the minimum supported retained depth of 0.1 mm.

## Existing transform coverage

`test/transform.scad` verifies the existing move, rotation, flip, transform
object and orthogonal frame APIs.

This coverage remains required while those public APIs remain supported here.

## Existing fg helper coverage

`test/forge.scad` verifies the existing tagged difference and cutter helper
surfaces, including named overlap faces/regions.

This is compatibility verification for the API this repository still publishes;
it does not assign new Forge modeling-language ownership to util.

## Consumer-sync coverage

The verification script creates a temporary consumer fixture, inserts the managed
section-inspection block, validates key contents, reruns synchronization and
requires the file hash to remain unchanged.

## Evidence and publication

Generated STL/evidence output lives under `vrf/out` and is published under the
technical `vrf` namespace.

The generated snapshot includes a copy of this strategy document. For current
tool/runtime health, inspect live Actions and publication provenance rather than
freezing version text here.
