# Testing policy

Paths mentioned in this policy are relative to the repository root unless a Markdown link specifies otherwise.

Read when: changing a template, the packaging project or the smoke-test script.

The repository has no runtime code of its own, so it has no unit tests. The evidence that a change
works is a template that generates a project which builds, and that evidence is produced by the smoke
tests in `scripts/Test-Templates.ps1`, which CI runs unchanged.

## Test kinds

| Kind | Where | Runs in | Proves |
| --- | --- | --- | --- |
| Template smoke | `scripts/Test-Templates.ps1` | a normal process, including a hosted runner | the package installs, each short name generates, and the generated project or solution builds |
| Manual smoke | the generated project | Visual Studio and Revit, by a person | the add-in loads, the command runs and the panel shows |

The script is the only test entry point: a step that CI runs and a step a contributor runs locally are
the same code. Do not add a template to CI without adding it to the script, and do not duplicate the
matrix in the workflow.

## What needs a test

- A new template needs its generation and build step in `scripts/Test-Templates.ps1`, covering both
  variants when the concept has a project template and a solution template.
- A change to a `template.json` symbol, casing or replacement needs a smoke run that proves the
  generated names are correct: the short name, the project name, the namespace, the package id and the
  repository slug.
- A change to a generated `.csproj`, `global.json` or `NuGet.config` needs the generated project to
  build for each configuration the script covers.
- A documentation, formatting or dependency-only change needs no new step, but the smoke tests must
  still pass.

## Isolation and determinism

- The script writes only under `output/smoke-tests/`, which is ignored by Git, and installs the
  templates into an isolated template hive; it never touches the contributor's installed template
  package.
- A run must not require network access beyond the NuGet restore of the generated project, and must
  not depend on an installed Revit.
- A run leaves the previous results in place: the output uses a unique subdirectory per run, so a
  failing run can be inspected afterwards.

## Running the tests

```powershell
./scripts/Test-Templates.ps1
```

`scripts/test-templates.cmd` forwards to the same script for a `cmd.exe` session. `-SkipPack` reuses
the package already in `artifacts/` when a single template is being iterated on.

## Manual smoke check

Before a release, generate each solution template, open it in Visual Studio, build it, and load the
add-in in Revit: the ribbon entry appears, the command runs and the panel opens. The manual check
complements the smoke tests; it does not replace them.

## Flaky and skipped tests

A step that fails intermittently is fixed or removed with an issue and a date. A step that is skipped
has a reason in the script and an issue; an unexplained skip is a defect.

The workflow around tests - branches, commit messages and the changelog - is defined by the
[development policy](development.md).
