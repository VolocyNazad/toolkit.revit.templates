# Repository guide

Paths in this document are relative to the repository root.
Read and follow the [development policy](policies/development.md) alongside this guide.

## About the project

TODO: what `VolocyNazad.Revit.Sample` does and who/what uses it (other
repositories in the `toolkit.revit.*` family, if any).

## Repository and structure

```
.
├── src/
│   └── Revit.Sample/          the library itself
└── tests/
    └── Revit.Sample.Tests/    xunit.v3 tests
```

## Technology stack

- `VolocyNazad.Revit.Sdk` (custom MSBuild SDK) + `Revit_All_Main_Versions_API_x64`
- MinVer (git-tag-based versioning), PolySharp (polyfills)
- Tests: xunit.v3 + xunit.runner.visualstudio + coverlet.collector
- Central package management is not used - package versions are set
  inline in `<PackageReference>`

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

## Package versions and releases

The three library configurations target Revit 2021.1.9, 2023.0.0, and 2025.0.0.
MinVer 8.0.0 reads tags without a prefix. Release tags use `0.0.N`: for example,
`0.0.8` produces packages `2021.0.8`, `2023.0.8`, and `2025.0.8`.
Untagged builds have a development suffix. Increment N for each release;
do not use a minor/major tag bump to represent a package patch.

CI builds and runs headless tests for each configuration, saving artifacts
with configuration-specific names. The test stack matches the runtime libraries:
xunit.v3 4.0.1, Microsoft.NET.Test.Sdk 18.10.1, runner 4.0.0, coverlet 10.0.1.
Revit-hosted tests, if added, require their own project and execution environment.

To release, push the `0.0.N` tag, wait for CI to succeed, then manually run
`publish-nuget.yml` on that tag. Publishing requires one valid release tag on the
commit, a successful push CI run for the same SHA, and the expected package ID
and version. Tag pushes run CI but do not publish. Configure the repository
secret `NUGET_API_KEY` before the first release.


The solution uses Microsoft.Testing.Platform via the test.runner setting in global.json for xunit.v3 4.0. Run tests with dotnet test --project tests/Revit.Sample.Tests/Revit.Sample.Tests.csproj and an explicit Revit configuration. The starter project contains no executable tests; CI explicitly permits only the no-tests exit code 8. Remove --ignore-exit-code 8 from CI when real tests are added. Project-template users should enable the same test.runner in their host global.json or run the test executable directly. The retained Visual Studio adapter and coverlet.collector references are not an MTP coverage configuration.

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
