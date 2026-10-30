# Revit.Sample

[![Revit 2021-2025](https://img.shields.io/badge/Revit-2021–2025-green.svg)](https://www.autodesk.com/products/revit/overview)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)
[![VolocyNazad](https://img.shields.io/badge/VolocyNazad-blue.svg)](https://github.com/VolocyNazad)

TODO: short library description (one or two sentences - what it does and why).

## Installation

```powershell
dotnet add package VolocyNazad.Revit.Sample
```

## Usage

TODO: minimal usage example.

## Build

```powershell
dotnet build Revit.Sample.slnx --configuration Release_2025.0.0 -p:Platform=x64
```

The NuGet package is created automatically in the `artifacts` folder.

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

## Contributing
 [CONTRIBUTING.md](CONTRIBUTING.md) before submitting changes.
