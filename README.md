# Vexillum

**An open standard for agent pipelines that live in the repository.**

> *A vexillation was a detachment of a Roman legion, dispatched under its own
> banner — the vexillum — to carry out a task. This standard dispatches your
> team's agent pipeline into any repository that carries the banner.*

Vexillum defines a `.vexillum/` directory, committed next to your code, that
describes how AI coding agents work on that repository: the stages work moves
through, the agent at each stage, the scripts that run between stages, and the
models that power them. Clone the repo, and you've inherited the pipeline —
the same way you inherit its CI.

**Status: draft.** The format is being extracted from a working
implementation and will change. Nothing here is stable until this notice says
otherwise.

- **Specification:** [SPEC.md](SPEC.md)
- **Website:** [vexillum.io](https://vexillum.io)
- **Reference implementation:** [StreamKanban](https://github.com/Forgebotica/StreamKanban)

## Why

Teams treat AI coding agents as personal tools — every developer prompts
alone, nothing standardizes, nothing is reviewed. Vexillum treats the agent
pipeline as a **team artifact**, like CI configuration: defined as code,
versioned in the repository, improved through pull requests, and inherited by
every developer (and every machine) that clones it.

## What goes in, what stays out

The directory contains only what a stranger needs to run your pipeline:
stages, agent prompts, rules, scripts, model routing. It never contains
issues, notes, comments, run history, secrets, or machine-specific paths —
work product and runtime state stay in the tool that executes the pipeline.
Commit the factory, never the inventory.

## License

[MIT](LICENSE).
