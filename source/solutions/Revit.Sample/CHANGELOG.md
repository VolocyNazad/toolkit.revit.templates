# Changelog

## [Unreleased]

### Fixed

- Resolve starter-code analyzer warnings and keep template build configuration aligned with repository checks.

### Added

- Branching policy: `main` holds the released state, `dev` integrates the next release, and changes arrive through feature, fix, release and hotfix branches.
- Validate required repository files, navigation links, and Solution Items in CI.

### Changed

- Move the commit message policy to `docs/policies/commits.md` and require it in the repository validator.

- Document the commit message policy: the Conventional Commits type set, breaking-change markers and subject rules.

- Update VolocyNazad.Revit.Sdk from 1.0.44 to 1.0.45.

- Establish a shared EditorConfig baseline and use the repository-policy validator as the single structural CI check.

- Complete solution items for repository documents, configuration, workflows and maintenance scripts; document the shared layout.

### Added

- Initial repository with shared development conventions.
