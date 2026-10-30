# RevitAddin

[![Revit 2025](https://img.shields.io/badge/Revit-2025-green.svg)](https://www.autodesk.com/products/revit/overview)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)
[![VolocyNazad](https://img.shields.io/badge/VolocyNazad-blue.svg)](https://github.com/VolocyNazad)

TODO: short plugin description (one or two sentences - what it does and why).

## Build

```powershell
dotnet build RevitAddin.slnx --configuration Release_2025 -p:Platform=x64
```

The `.addin` manifest is generated automatically during the build
(`GenerateAddinOnBuild`), see `src/RevitAddin/RevitAddin.csproj`.

## Debugging

`LaunchRevit=true` in `.csproj` - Revit is launched automatically along
with the debugger (see the `VolocyNazad.Revit.Sdk` README for details
and how to override the path/arguments).

## License

The project is distributed under the [MIT](LICENSE.md) license.

## Development documentation

- [Development policy](docs/policies/development.md)
- [Repository guide and technology stack](docs/repository.md)
- [Branching policy](docs/policies/branching.md)
- [Commit message policy](docs/policies/commits.md)
- [Changelog policy](docs/policies/changelog.md)
- [Testing policy](docs/policies/testing.md)
- [Benchmark policy](docs/policies/benchmarks.md)

## Contributing
 [CONTRIBUTING.md](CONTRIBUTING.md) before submitting changes.
