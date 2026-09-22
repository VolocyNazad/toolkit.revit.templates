# Repository guide

Paths in this document are relative to the repository root.
Read and follow the [development policy](policies/development.md) alongside this guide.

## About the project

TODO: what the `RevitAddin` plugin does for Autodesk Revit.

## Repository and structure

```
.
└── src/
    └── RevitAddin/         the plugin itself (IExternalApplication + commands)
```

A minimal setup with no `build/`/`installer/`/`tests/` - a single
plugin, a single Revit configuration. If you need to build against
multiple Revit versions, an MSI installer, or a CI pipeline building a
version matrix - look at `revit.linter`/`impact.revit` (its own build on
ModularPipelines + a WiX installer) as the next level up.

## Technology stack

- `VolocyNazad.Revit.Sdk` (custom MSBuild SDK) + `Revit_All_Main_Versions_API_x64`
- Central package management is not used

## Documentation layout

- `AGENTS.md` links to the required repository guidance.
- `docs/policies/development.md` contains the development policy.
- `docs/repository.md` describes the project, repository structure, and technology stack.

## Build conventions

Use stable .NET SDK 10.0 selected by `global.json` (minimum 10.0.103,
`latestFeature`, no prerelease SDKs). CI installs the SDK from that file.
Documentation appears under `docs` in Solution Explorer; add new documents
to the solution as solution items. Follow the shared development policy
for tests, changelog entries, commits, and SDK changes.

## Solution items

The root solution exposes repository-level documents and configuration under `solutionItems`, GitHub files and maintenance scripts in matching subfolders, and documentation under `docs/`. The list is explicit, not a filesystem glob; keep links up to date when files change. See the [solution items policy](policies/development.md#solution-items).
## Repository validation

`scripts/Validate-Repository.ps1` enforces the required repository documents,
their navigation links, and complete, valid Solution Items. The
`.github/workflows/repository-policy.yml` workflow runs it for pushes and pull
requests. See the [development policy](policies/development.md#repository-validation).

## Formatting

The root `.editorconfig` defines the portable formatting baseline. Existing repositories may add stricter C# or analyzer-specific settings. See the [development policy](policies/development.md#formatting-baseline).

Revit projects use VolocyNazad.Revit.Sdk 1.0.45.
