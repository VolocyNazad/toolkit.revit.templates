# Repository guide

Paths in this document are relative to the repository root.
Read and follow the [development policy](policies/development.md) alongside this guide.

## About the project

`toolkit.revit.templates` is the source for the `VolocyNazad.Revit.Templates`
NuGet package: a collection of `dotnet new` templates for Autodesk Revit
plugins and libraries, built on the `VolocyNazad.Revit.*` family
(`Sdk`, `Async`, `Context`, `Events`, `MediatR`, `TransactionMemoryCache`).
An analogue of Nice3point/RevitTemplates, but with its own conventions
(see the AGENTS.md of the other repos in the `toolkit.revit.*` family).

This is NOT a library and not an addin - there's no code here that
compiles into a runtime assembly. The only real project is
`Toolkit.Revit.Templates.csproj`, which simply packages the contents of
`source/**` as `content` into the nupkg. Each folder under `source/*/`
is a self-contained template with its own `.template.config/template.json`;
it gets copied by `dotnet new` in full into the user's project/repository.

### Two kinds of templates, mirrored - don't confuse them

Each of the three "concepts" (minimal plugin, WPF plugin, library)
exists in two variants - as a project and as a solution. When adding a
new concept in the future - add both variants right away, not just one.

- **Project templates** (`source/projects/`, `"tags": {"type": "project"}`).
  Add a single project into an already existing repository/solution.
  They contain no `README`/`LICENSE`/CI - it's assumed those already
  exist in the repository the project is being added to.
  - `revit-addin` - minimal plugin (a single `IExternalCommand`)
  - `revit-addin-wpf` - plugin with a WPF panel, MVVM
  - `revit-lib` - library (`src/`+`tests/`, nupkg, MinVer)
- **Solution templates** (`source/solutions/`, `"tags": {"type": "solution"}`).
  Create a separate repository from scratch: besides `src/` (and, for
  libraries, `tests/`), they contain the full required set of repository
  files - `README.md`, `AGENTS.md`, `LICENSE.md`, `NuGet.config`,
  `.gitignore`, a CI workflow, `.slnx` - following the convention shared
  by all existing repos in the `toolkit.revit.*` family.
  - `revit-addin-repo` - repository with a minimal plugin
  - `revit-addin-wpf-repo` - repository with a WPF plugin
  - `revit-lib-repo` - repository-library (a full analogue of the
    existing `toolkit.revit.async`/`.events`/`.context`, etc.)

Within each pair, the solution variant physically contains the same code
as its project variant, just under `src/<Name>/` plus the repo skeleton -
changes to the plugin/library logic must be made in both places (or keep
the project variant as the source of truth and copy it into the solution,
as was done when they were created).

The type (`project`/`solution`) is not just an organizational folder -
it's also a real `tags.type` field in `template.json`, understood by
`dotnet new`/the IDE itself.

Rules common to all six templates:

- projects under `source/*/*` must not depend on the repository's root
  `Directory.Build.props`/`Directory.Packages.props` - the user only
  gets the contents of the template folder, without the parent files;
- each template must build on its own (open and build as a normal
  project/solution) - this is the only way to check it by hand before
  the templates are released; CI checks the same thing via smoke tests
  (see below);
- each template contains its own `NuGet.config` (nuget.org feed) - like
  any repository in the `toolkit.revit.*` family; don't add a new
  template without one;
- package versions (`VolocyNazad.Revit.Sdk`, `Revit_All_Main_Versions_API_x64`,
  `CommunityToolkit.Mvvm`, etc.) inside the templates are pinned
  manually and updated in a separate PR, in sync with releases of the
  corresponding `toolkit.revit.*` repositories.

## Repository and structure

```
.
├── source/
│   ├── projects/                        project templates (type: project)
│   │   ├── RevitAddin/                  "revit-addin"
│   │   ├── RevitAddin.Wpf/              "revit-addin-wpf"
│   │   └── Revit.Sample/                "revit-lib" (sourceName = "Revit.Sample")
│   │       ├── src/Revit.Sample/
│   │       └── tests/Revit.Sample.Tests/
│   └── solutions/                       solution templates (type: solution)
│       ├── RevitAddin/                  "revit-addin-repo"
│       │   ├── AGENTS.md, README.md, LICENSE.md, ...
│       │   ├── RevitAddin.slnx
│       │   ├── .github/workflows/
│       │   └── src/RevitAddin/
│       ├── RevitAddin.Wpf/              "revit-addin-wpf-repo"
│       │   └── ... (same layout, src/RevitAddin.Wpf/)
│       └── Revit.Sample/                "revit-lib-repo"
│           ├── AGENTS.md, README.md, LICENSE.md, ...
│           ├── Revit.Sample.slnx
│           ├── .github/workflows/
│           ├── src/Revit.Sample/
│           └── tests/Revit.Sample.Tests/
└── Toolkit.Revit.Templates.csproj       packages source/** into the nupkg (PackageType=Template)
```

The `sourceName` for the "revit-lib"/"revit-lib-repo" pair is
`Revit.Sample`; it's invoked with a name of the form `Revit.<Feature>`
(e.g. `dotnet new revit-lib-repo -n Revit.Foo`), so that
`PackageId`/namespace/paths automatically become
`VolocyNazad.Revit.Foo`/`Revit.Foo`/`src/Revit.Foo`.
`PackageProjectUrl`/`RepositoryUrl`/`PackageReleaseNotes` are further
parameterized via the generated `nameLower`/`repoSlug` symbols in
`template.json` (casing + join): the literal `toolkit.revit.sample` in
the csproj automatically becomes `toolkit.revit.foo`. This only holds
if the resulting repository is named per the `toolkit.revit.*`
convention; if the name is different (or the project is being added to
someone else's existing repository via `revit-lib`) - fix the URL by
hand after generation.

## Technology stack

- The package format is a standard `dotnet new` template pack
  (`PackageType=Template`, `IncludeContentInPack=true`,
  `IncludeBuildOutput=false`, `ContentTargetFolders=content`).
  `Toolkit.Revit.Templates.csproj` additionally sets
  `EnableDefaultCompileItems=false`/`EnableDefaultEmbeddedResourceItems=false` -
  without this, the implicit SDK glob `**/*.cs` would try to compile the
  `.cs` files of each template directly into the packaging project.
- `revit-addin-wpf`/`revit-addin-wpf-repo`: `VolocyNazad.Revit.Sdk` + WPF +
  CommunityToolkit.Mvvm (MVVM without manual ViewModel code generation) -
  a minimal set. A heavier stack (DI, Serilog, MediatR) modeled on
  `impact.revit`/`revit.linter` is a candidate for a future template, but
  isn't set up yet.
- `revit-addin-repo`/`revit-addin-wpf-repo` - minimal repositories: one
  plugin, one Revit configuration, no `build/`/`installer/`/`tests/`. A
  full build pipeline on ModularPipelines + a WiX installer (as in
  `revit.linter`/`impact.revit`) is deliberately not reproduced here -
  that's a large separate chunk of work, not equivalent to
  "plugin + README".
- Versioning of the templates package itself uses MinVer. Publishing starts
  only through the manual `workflow_dispatch` workflow, and the selected commit
  must have a version tag. Pushing a tag alone does not publish the package.
- CI - GitHub Actions, `windows-latest` (building the individual
  templates as real Revit projects requires Windows plus the Revit SDK
  installed via NuGet), `dotnet pack` of the root project, and a separate manual publish workflow.
- There are no code tests in this repository and none are planned, since
  it has no logic of its own (see "About the project" above). Instead of
  unit tests - smoke tests in `build-and-test.yml`: for each of the six templates,
  `dotnet new <shortname> -n ... -o ...` followed by `dotnet build` of the
  result (for projects - the generated `.csproj`, for solutions - the
  generated `.slnx`). This catches broken
  `.csproj`/`template.json` (including the generated
  `casing`/`join`/`replaces` symbols) before the package is released.
  When adding a new template - add a matching step for it, plus an entry
  in `scripts/Test-Templates.ps1`. `scripts/test-templates.cmd` is a thin
  Windows wrapper that forwards all arguments to that PowerShell script,
  so the test matrix has one source of truth. The script packs, installs
  and builds the templates locally into `output/smoke-tests/`; no push is
  required. When templates or configurations change, update the PowerShell
  script.

## Documentation layout

- `AGENTS.md` links to the required repository guidance.
- `docs/policies/development.md` contains the development policy.
- `docs/repository.md` describes the project, repository structure, and technology stack.

The root solution exposes the documentation files under a `docs` solution folder in Visual Studio, preserving their subfolder structure. When adding documentation files, also add them as solution items; solution folders do not automatically include new files.

The root `global.json` selects stable .NET SDK 10.0 (minimum `10.0.103`, `rollForward: latestFeature`). CI and publishing install the SDK from this file. Additional SDK installations may provide older test runtimes. See the [SDK selection policy](policies/development.md#net-sdk-selection).

## Template alignment

Solution templates carry the same SDK selection and shared development rules
as the runtime repositories, plus docs and workflows as solution items.
Project templates inherit repository-wide SDK and policy files from their host.
WPF templates pin CommunityToolkit.Mvvm 8.4.2. Both library variants pin MinVer
8.0.0, use Revit-major package versions and the current xunit.v3 test stack.
The generated library has explicit CI configurations and a separate manual
publish workflow with tag, successful-CI, and package-version gates.

The library solution opts into Microsoft.Testing.Platform for xunit.v3 4.0 on SDK 10. Its empty starter test project is explicitly allowed to return no-tests exit code 8 until tests are added.

## Solution items

The root solution exposes repository-level documents and configuration under `solutionItems`, GitHub files and maintenance scripts in matching subfolders, and documentation under `docs/`. The list is explicit, not a filesystem glob; keep links up to date when files change. See the [solution items policy](policies/development.md#solution-items).
## Repository validation

`scripts/Validate-Repository.ps1` enforces the required repository documents,
their navigation links, and complete, valid Solution Items. The
`.github/workflows/repository-policy.yml` workflow runs it for pushes and pull
requests. See the [development policy](policies/development.md#repository-validation).

## Formatting

The root `.editorconfig` defines the portable formatting baseline. Existing repositories may add stricter C# or analyzer-specific settings. See the [development policy](policies/development.md#formatting-baseline).

## Versioning and release tags

The templates package uses MinVer 8 with stable tags in the `vMAJOR.MINOR.PATCH` format. The tag without its `v` prefix is the NuGet package version. Publishing remains manual; pushing a tag alone does not publish. The repository currently has no release-tag history, so the first publication must create its initial stable tag before running the workflow. The workflow verifies the package ID and version before pushing to NuGet.

Smoke tests share scripts/Test-Templates.ps1 between local runs and CI. Each run installs the packed templates into an isolated registry, builds both library variants for Revit 2021/2023/2025 (including test projects), and validates generated solution repositories. Outputs use unique subdirectories; existing installations and previous results are preserved.

Revit projects use VolocyNazad.Revit.Sdk 1.0.45.

The tagged commit must already contain the release section in `CHANGELOG.md` with an empty `Unreleased` section above it; the publish workflow stops otherwise. See the [release changelog policy](policies/development.md#release-changelog).
