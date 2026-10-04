# Example: the full StreamKanban feature set as a Vexillum pipeline

This is the kitchen-sink example: every pipeline feature of the reference
implementation (StreamKanban v0.2.0), expressed in one `.vexillum/`
directory. A real pipeline would be smaller — start from this and delete.

The pipeline it defines: ideas become rated issues (Planner) → **Dev**
implements in an isolated worktree → **Test** exercises the same branch →
**Review** reads the diff → **Merge** runs a merge-verify-cleanup script,
with an Integrator agent that only wakes when the script fails → **Done**
releases any issues that were waiting on this one.

## Feature map

| StreamKanban feature | Where it lives here |
|---|---|
| Columns / board shape | `pipeline.yml` → `columns` (stable `id`, display `label`) |
| Agent per column, name derived from the live column label | a `columns` entry's `agent` key + `agents/<name>.md` |
| Planner (board-level idea → issues agent) | `planner` key + `agents/planner.md` (`role: planner`, no column) |
| Integration column + auto-Integrator | `merge_column` + the `arrival`/`run_script` rule with `run_agent_on_failure: true` + `agents/merge.md` |
| Done column (dependency release: B waits until A lands) | `done_column` |
| Two-tier model routing (pinned vs by-rating, difficulty table) | `models` table + each agent's `model` / `model_by_rating` |
| Difficulty vocabulary | `mechanical` / `routine` / `involved` / `design-heavy` — a property of the work |
| Per-column triggers | `rules` → `trigger: arrival \| agent_start \| cleared` |
| Script on trigger (library or repo file) | `rules` → `run: scripts/<name>` (platform pair in `scripts/`) or `run_file: <repo path>` |
| Move card on script success | a rule's `target_column` |
| Worktree parallelism | `run.max_parallel` + `scripts/setup.*` on `agent_start` |
| Worktree cleanup inside the merge | `scripts/merge.*` — cleanup on every success path, never a separate rule |
| Universal branch rule (continue the issue's latest branch) | runner behavior — nothing to configure, so nothing to commit |
| Rate-limit handling (park the queue vs fail) | `run.on_rate_limit` |
| Job timeout, agent CLI command, base branch | `run.timeout_minutes`, `run.command`, `run.base_branch` |
| Per-project prompt overrides | gone as a concept: the directory IS per-repository, so the prompt file is already the override |
| Rules ship disarmed until a human arms them | a rule's `enabled: false` |

## Deliberately absent

Per the spec's principles — these are state or machine-local, and never
belong in the directory:

- issues, comments, notes, run history, job transcripts, integration stamps
- absolute paths, credentials, API keys, user identity
- the runner's own registration/bookkeeping (MCP config, database location)
