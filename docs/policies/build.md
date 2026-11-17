# Build and toolchain policy

Paths mentioned in this policy are relative to the repository root unless a Markdown link specifies otherwise.

Read when: changing the SDK, a project, a package version, a warning rule or a Revit version.

A build is reproducible from a clean checkout with the SDK selected by the repository and the package
versions declared in the repository. It states rules, not build recipes: commands and stack facts
belong to the [repository guide](../repository.md).

## SDK selection

- Take the .NET SDK from the repository-root `global.json`; it is the only source of the SDK for
  local builds, CI and publishing.
- Keep `global.json` on a stable SDK `10.0.103` or later in the `10.0` major/minor line, with
  `rollForward: latestFeature` and `allowPrerelease: false`. Do not move to another major/minor line
  without changing this policy and `global.json` in the same change.
- Read the SDK in every GitHub Actions setup step with `global-json-file: global.json` after
  checkout. Do not install a floating or explicitly versioned SDK in the workflow instead.
- The packaging project targets `net8.0` because the template engine requires a runtime the SDK can
  load; a target-framework change follows this policy and updates the [repository guide](../repository.md).

## Projects

- `Toolkit.Revit.Templates.csproj` is the only project that compiles: a `Microsoft.NET.Sdk` project
  with `PackageType=Template` that packages `source/**` as `content` and produces no runtime
  assembly.
- Each folder under `source/projects/` and `source/solutions/` is a self-contained template with its
  own `.template.config/template.json`; the packaging project copies it into the package unchanged.
- A template must build on its own, without the repository-root `Directory.Build.props` or
  `Directory.Packages.props`: the user receives only the template folder. Give a template its own
  `NuGet.config` and the properties it needs.
- The packaging project keeps `EnableDefaultCompileItems=false` and
  `EnableDefaultEmbeddedResourceItems=false`, so the implicit `**/*.cs` glob cannot compile the
  templates' source into the packaging project. Do not remove them to make a file appear.
- A new template arrives with its entry in `source/`, its `.template.config/template.json`, its
  smoke-test step in `scripts/Test-Templates.ps1` and the matching CI change in one pull request.
- A new concept arrives in both variants, the project template and the solution template; they carry
  the same code, and a logic change is made in both.

## Revit versions

- The repository does not build per Revit version; each template pins the Revit API package version
  it needs, and the generated project selects its configuration the same way the `toolkit.revit.*`
  libraries do.
- A template's Revit configuration follows the shared naming, such as `Debug_2021.1.100` or
  `Release_2025.4.60`, so a generated repository is indistinguishable from a hand-written one.
- `MajorRevitVersion` selects the target framework in the generated project: `net48` for Revit
  2021-2024, `net8.0-windows` for 2025-2026 and `net10.0-windows` for 2027.
- Adding or dropping a supported Revit year touches the template files, the smoke-test matrix in
  `scripts/Test-Templates.ps1`, the supported version list in the [repository guide](../repository.md)
  and [README.md](../../README.md), and the [testing policy](testing.md) together.
- Package versions inside the templates are pinned by hand and updated in a separate pull request, in
  sync with the release of the package they reference.

## Central package management

- The templates do not use central package management: a generated project receives a plain
  `PackageReference` with an explicit version, because it has no repository-level props file.
- The packaging project pins its only dependency, `MinVer`, in the project file.
- Change a template package version in every template that references it, in one pull request; a
  half-updated set produces repositories on two different stacks.

## Warnings

- Treat compiler and analyzer warnings as delayed errors. Do not leave new warnings in code you
  touch; fix them in the same change.
- Suppress a deliberate false positive as narrowly as possible and add a nearby comment explaining
  why.
- Keep every build warning-free. `.github/workflows/build-and-test.yml` packs the package and builds
  the generated projects, and `.github/workflows/publish-nuget.yml` repeats the check, so a broken
  template fails both the pull request and the publish.
- Do not rely on a local build to find warnings; run `./scripts/Test-Templates.ps1` before opening
  the pull request.

## Analyzers

- The root `Directory.Build.props` enables `AnalysisMode=AllEnabledByDefault` for the packaging
  project. Treat the resulting diagnostics as part of the build contract, not as optional advice.
- A rule that is wrong for the packaging project is disabled in `.editorconfig` with a comment naming
  the reason, never with a file-wide `#pragma warning disable` in source.
- The generated projects carry the analyzer settings a `toolkit.revit.*` repository uses; a template
  that ships code is expected to build with the same warning discipline as the libraries.

## Public API documentation

The packaging project produces no public API and sets `GenerateDocumentationFile=false`; the strict
`CS1591` audit therefore does not apply to it. The code a template generates follows the
[documentation policy](documentation.md) as if it were hand-written.

The rest of the contributor workflow is defined by the [development policy](development.md).
