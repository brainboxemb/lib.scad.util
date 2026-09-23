# Repository agent guidance

Start with [doc/00-plan.md](doc/00-plan.md).

For shared BrainboxEmb working conventions, read
[brainboxemb.meta/AGENTS.md](https://github.com/brainboxemb/brainboxemb.meta/blob/main/AGENTS.md).
That entrypoint owns current Git/commit/PR/CI workflow and routes to the shared
SCAD coding, documentation and source conventions.

Do not inherit `AGENTS.md` from pinned tools as working policy for this
library. Exact dependency behavior comes from this repository's config/gitlinks
plus the pinned dependency's README, docs, source and tests.

Keep this repository focused on small domain-independent utilities. Shared
modeling-language behavior such as transforms, tagged CSG and cutters belongs to
`lib.scad.forge`; do not reintroduce parallel `xf_*` or `fg_*` APIs here.
