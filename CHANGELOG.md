# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed

- Move the changelog policy to `docs/policies/changelog.md` and require it in the repository validator.

- Move the commit message policy to `docs/policies/commits.md` and require it in the repository validator.

- Document the commit message policy: the Conventional Commits type set, breaking-change markers and subject rules.

### Added

- Add a testing policy: test kinds, configuration coverage, naming, isolation and the manual smoke check.
- Add a benchmark policy: when performance is measured, how, and how results are reported.

- Branching policy: `main` holds the released state, `dev` integrates the next release, and changes arrive through feature, fix, release and hotfix branches.

## [1.0.0] - 2026-09-22

### Added

- Project templates for a minimal Revit add-in, a WPF Revit add-in, and a reusable Revit library.
- Matching solution templates that generate complete repositories with documentation, policies, CI, and NuGet configuration.
- Smoke tests that pack, install, generate, and build every template in an isolated template registry.
- Revit library validation for the supported Revit 2021.1.9, 2023.0.0, and 2025.0.0 configurations.
- Repository-policy validation for generated solution templates.
- Manual NuGet publishing with stable-tag, package identity, and package version checks.
- Documentation for NuGet installation, updates, local package testing, and removal.
