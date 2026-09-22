# RevitAddin.Wpf

[![Revit 2025](https://img.shields.io/badge/Revit-2025-green.svg)](https://www.autodesk.com/products/revit/overview)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)
[![VolocyNazad](https://img.shields.io/badge/VolocyNazad-blue.svg)](https://github.com/VolocyNazad)

TODO: short plugin description (one or two sentences - what it does and why).

## Build

```powershell
dotnet build RevitAddin.Wpf.slnx --configuration Release_2025 -p:Platform=x64
```

The `.addin` manifest is generated automatically during the build
(`GenerateAddinOnBuild`), see `src/RevitAddin.Wpf/RevitAddin.Wpf.csproj`.

## Debugging

`LaunchRevit=true` in `.csproj` - Revit is launched automatically along
with the debugger (see the `VolocyNazad.Revit.Sdk` README for details
and how to override the path/arguments).

## License

The project is distributed under the [MIT](LICENSE.md) license.

## Development documentation

- [Development policy](docs/policies/development.md)
- [Repository guide and technology stack](docs/repository.md)

## Contributing
 [CONTRIBUTING.md](CONTRIBUTING.md) before submitting changes.
