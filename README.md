# Revit.Templates

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)
[![VolocyNazad](https://img.shields.io/badge/VolocyNazad-blue.svg)](https://github.com/VolocyNazad)

`dotnet new` templates for developing Autodesk Revit plugins and
libraries on the `VolocyNazad` stack (`VolocyNazad.Revit.Sdk`,
`VolocyNazad.Revit.Async/Context/Events/MediatR/TransactionMemoryCache`).

An analogue of [Nice3point/RevitTemplates](https://github.com/Nice3point/RevitTemplates),
but with its own conventions for the stack and packaging.

## Status

The repository is under development. The list of templates and their
short names will keep growing; the current list is in the tables below.

## Two kinds of templates

Each of the three "concepts" (minimal plugin, WPF plugin, library)
exists in two variants - as a **project** and as a **solution**:

- **Project templates** (`type: project`, `source/projects/`) - add a
  single project into an already existing repository/solution. They
  don't create a `README`/`LICENSE`/CI - it's assumed those already
  exist in the repository the project is being added to.
- **Solution templates** (`type: solution`, `source/solutions/`) -
  create a separate repository from scratch: `README.md`, `AGENTS.md`,
  `LICENSE.md`, `.gitignore`, a CI workflow, `.slnx`, etc., like any
  existing repository in the `toolkit.revit.*` family. Inside is the
  same project, just under `src/<Name>/`.

### Project templates

| Short name          | Description                                                 |
|----------------------|-----------------------------------------------------------|
| `revit-addin`      | Minimal plugin (a single `IExternalCommand`, no WPF)      |
| `revit-addin-wpf`  | Plugin with a WPF panel, MVVM (CommunityToolkit.Mvvm)         |
| `revit-lib`        | Library (`src/`+`tests/`, nupkg, MinVer), no repo skeleton |

### Solution templates

| Short name               | Description                                                          |
|-------------------------|----------------------------------------------------------------------|
| `revit-addin-repo`      | Repository with a minimal plugin (README/AGENTS/LICENSE/CI)         |
| `revit-addin-wpf-repo`  | Repository with a WPF plugin (README/AGENTS/LICENSE/CI)                 |
| `revit-lib-repo`        | Repository-library at the level of `toolkit.revit.*` (src+tests, nupkg, CI) |

`revit-lib`/`revit-lib-repo` use a name of the form `Revit.<Feature>`
(e.g. `Revit.Foo`) - that's how the package
(`VolocyNazad.Revit.Foo`), namespace, folders `src/Revit.Foo`/`tests/Revit.Foo.Tests`,
and (for `-repo`) the repository address (`github.com/VolocyNazad/toolkit.revit.foo`)
end up named, just like in the existing `toolkit.revit.*` libraries.

## Installation

Install the latest version from NuGet.org:

```powershell
dotnet new install VolocyNazad.Revit.Templates
```

Install a specific version:

```powershell
dotnet new install VolocyNazad.Revit.Templates::1.0.0
```

This is a `dotnet new` template package. Don't add it to a project with
`dotnet add package`.

### Updating

Check for and install updates to all installed template packages:

```powershell
dotnet new update
```

To install a specific version explicitly:

```powershell
dotnet new install VolocyNazad.Revit.Templates::1.0.1 --force
```

Updating the template package affects only projects generated afterward.
Projects already created from an earlier version are not modified.

### Installing a local package

Pack the repository and install the generated package while developing or
before the package is published:

```powershell
dotnet pack ./Toolkit.Revit.Templates.csproj --configuration Release
dotnet new install ./artifacts/VolocyNazad.Revit.Templates.0.0.0-dev.nupkg --force
```

List installed template packages and their versions:

```powershell
dotnet new uninstall
```

Remove this template package:

```powershell
dotnet new uninstall VolocyNazad.Revit.Templates
```

## Usage

```powershell
# add a project into an existing repository
dotnet new revit-addin -n MyPlugin
dotnet new revit-addin-wpf -n MyPlugin
dotnet new revit-lib -n Revit.Foo

# create a new repository from scratch
dotnet new revit-addin-repo -n MyPlugin
dotnet new revit-addin-wpf-repo -n MyPlugin
dotnet new revit-lib-repo -n Revit.Foo
```

## Development

Templates live in `source/projects/<TemplateName>` (project templates)
and `source/solutions/<TemplateName>` (solution templates), each with
its own `.template.config/template.json`. The templates package is
built by the root `Toolkit.Revit.Templates.csproj`
(`PackageType=Template`, the whole `source/**` is packaged as `content`).

### Testing all templates locally, without pushing

```powershell
./scripts/Test-Templates.ps1
```

If PowerShell isn't available (no `pwsh`/`powershell.exe`, or Execution
Policy blocks it) - the same script as a `.cmd` for plain `cmd.exe`:

```bat
scripts\test-templates.cmd
```

Both do the same thing as the smoke tests in CI
(`.github/workflows/build-and-test.yml`): pack the nupkg, install the templates,
generate a project/solution for each of the 6 templates, and build it.
The result stays in `output/smoke-tests/<shortname>/` (in
`.gitignore`) - you can open it and inspect the generated code by hand.
For a quick run without rebuilding the nupkg, when tweaking a single
template:

```powershell
./scripts/Test-Templates.ps1 -SkipPack
```
```bat
scripts\test-templates.cmd -SkipPack
```

Installing a single template from source by hand (the same thing the
script does, but for one template):

```powershell
dotnet new install ./source/projects/RevitAddin.Wpf
dotnet new install ./source/solutions/Revit.Sample
```

## License

The project is distributed under the [MIT](LICENSE.md) license.

## Development documentation

- [Development policy](docs/policies/development.md)
- [Repository guide and technology stack](docs/repository.md)

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting changes.
