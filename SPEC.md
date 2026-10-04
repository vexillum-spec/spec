# The Vexillum Specification

**Version: 0.1 (draft)** · schema version `1` · 2026-10-04

> **Draft notice.** This document is being extracted from a working
> implementation (StreamKanban). Field names, file layout and semantics may
> all change before 1.0. It is published now so the design can be read,
> criticized and tried — not so it can be relied upon.

## 1. Overview

A Vexillum pipeline is a `.vexillum/` directory at the root of a repository:

```
.vexillum/
  pipeline.yml      the pipeline: stages, agents, rules, models
  agents/           one markdown file per agent: frontmatter + system prompt
    dev.md
    review.md
    merge.md
  scripts/          lifecycle scripts, one file per platform variant
    setup.sh
    setup.cmd
    merge.sh
    merge.cmd
```

A **runner** (a desktop app, a CLI, a CI job) reads this directory and
executes the pipeline: when an issue reaches a stage that has an agent, the
runner starts that agent on the repository with the stage's configuration.

## 2. Principles

These bind every part of the format, present and future.

1. **Config, never state.** The directory describes how work is processed,
   never the work itself. Issues, comments, notes, run transcripts, job
   history and timestamps are runner state and MUST NOT appear in the
   directory. Test: *does a new team need this file for the pipeline to
   function?*
2. **Nothing machine-local, nothing secret.** No absolute paths, no
   credentials, no API keys, no user names. A directory that works on one
   machine works on all of them.
3. **Stable identity.** Stages, agents and rules carry stable `id`s so that a
   rename is recognized as a rename, never as a delete-plus-create. A runner
   diffing two versions of a pipeline MUST match entities by `id`, not by
   label.
4. **The file proposes; the runner applies.** A runner keeps its own runtime
   copy of the pipeline. A changed `.vexillum/` directory is a *proposal*:
   the runner MUST show the difference and apply it explicitly, and MUST NOT
   silently mutate running state. Destructive differences (a removed stage
   that still holds work) require a human decision at apply time.
5. **Both platforms or neither.** A script referenced by the pipeline ships
   as a POSIX variant (`.sh`) and a Windows variant (`.cmd`) with the same
   basename. A runner selects by platform.

## 3. `pipeline.yml`

```yaml
# The schema version. Integer. Runners refuse versions they don't know.
vexillum: 1

# The stages work moves through, in order. `id` is stable and never shown;
# `label` is the display name and free to change. A stage with an `agent`
# key is an agent station: the agent definition lives in agents/<name>.md.
columns:
  - id: todo
    label: To Do
  - id: dev
    label: Dev
    agent: dev
  - id: review
    label: Review
    agent: review
  - id: merge
    label: Merge
    agent: merge
  - id: done
    label: Done

# The stage whose agent integrates finished branches, and the stage that
# means "done" for dependency release. Both reference column ids.
merge_column: merge
done_column: done

# Difficulty → model routing. An agent whose definition opts into routing
# (model_by_rating) resolves the issue's difficulty through this table.
# The difficulty vocabulary is defined by the runner.
models:
  easy: claude-haiku-4-5
  involved: claude-sonnet-5-5
  hard: claude-fable-5-1

# Lifecycle rules. `trigger` is one of:
#   agent_start — before a stage's agent begins work
#   arrival     — an issue arrives in the stage
#   cleared     — an issue leaves the stage
# `run` names a script by basename; the runner picks the platform variant.
rules:
  - column: dev
    trigger: agent_start
    run: scripts/setup
  - column: merge
    trigger: arrival
    run: scripts/merge
```

## 4. `agents/<name>.md`

One file per agent. YAML frontmatter for configuration, markdown body as the
agent's system prompt.

```markdown
---
column: dev                      # the stage this agent is bound to
model: claude-sonnet-5-5         # pinned model, or omit for the CLI default
model_by_rating: true            # route through the models table when the
                                 # issue carries a difficulty; fall back to
                                 # `model` when it doesn't
---

You are the Dev agent. Implement the issue on its branch. Commit as you go.
When the work is complete and the tests pass, say so in a comment.
```

The agent's display name is derived from its stage's label by the runner; it
is not configured here. An agent IS its station.

## 5. `scripts/`

Scripts receive their context through environment variables set by the
runner (issue branch, base branch, worktree path, job id). The reference
implementation documents its `CC_*` set; the 1.0 spec will fix a `VEX_*`
set. Scripts MUST be written to run from the repository root and MUST NOT
assume any path outside the repository.

## 6. Import, export, drift

- **Export** writes the runner's current pipeline for one project into
  `.vexillum/`, excluding everything Principle 1 and 2 forbid.
- **Import** reads the directory into the runner. First import on a fresh
  clone is the inheritance moment: "this repository ships a pipeline."
- **Drift** is a difference between the directory and the runner's applied
  copy. Runners MUST surface drift and MUST NOT auto-apply it (Principle 4).

## 7. Versioning

`vexillum: 1` is the schema version. Additions that old runners can safely
ignore do not bump it; anything else does. A runner reading a higher version
than it knows MUST refuse with a clear message rather than guess.

## 8. Conformance (to be written)

A conformance checklist for runners — what MUST be supported to claim
"runs Vexillum pipelines" — will be added as the format stabilizes.

---

*Maintained at [github.com/vexillum-spec/spec](https://github.com/vexillum-spec/spec).
Reference implementation: [StreamKanban](https://github.com/Forgebotica/StreamKanban).*
