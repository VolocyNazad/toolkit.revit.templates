# Benchmark policy

Paths mentioned in this policy are relative to the repository root unless a Markdown link specifies otherwise.

Read when: someone proposes a benchmark, or a pull request claims a speed or memory improvement.

The repository ships templates, not a runtime library. It has no hot path of its own, so it carries no
benchmark project and enforces no performance threshold.

## Where performance is measured

- Performance of the generated code belongs to the library repository that owns the code, for example
  `toolkit.revit.async` or `toolkit.revit.context`; measure it there, with that repository's benchmark
  policy.
- The time `scripts/Test-Templates.ps1` takes is a build duration, not a benchmark: it depends on the
  machine, the package cache and the network. Do not report it as a performance result and do not gate
  a change on it.
- A template that adds a hot path to the generated project does not make this repository a benchmark
  host: add the benchmark to the owning library instead.

## If a benchmark is ever added here

- It lives in `benchmarks/<Project>.Benchmarks`, uses
  [BenchmarkDotNet](https://benchmarkdotnet.org/) and runs locally, never in CI.
- It compares against the current `main`/`dev` baseline in the same session, on an otherwise idle
  machine, in `Release`; a number from another machine or day is not a comparison.
- The `perf:` commit carries the before and after numbers and the environment in its body; the results
  are reported in the pull request and not committed.

The rest of the workflow is defined by the [development policy](development.md); what must be
tested is in the [testing policy](testing.md).
