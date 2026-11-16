# Release policy

Paths mentioned in this policy are relative to the repository root unless a Markdown link specifies otherwise.

Read when: preparing a release tag or publishing the package.

A release turns a tagged commit into a NuGet template package on nuget.org. The workflow is
`.github/workflows/publish-nuget.yml`; it consumes the tag and the release section of
`CHANGELOG.md`. The [changelog policy](changelog.md) owns that section's format, the
[branching policy](branching.md) owns release and hotfix branches, and the
[testing policy](testing.md) owns what must be green before the tag.

## Release channels

- A **stable release** is a `vMAJOR.MINOR.PATCH` tag and the only channel the automation publishes.
  This repository uses the `v` prefix: `v1.2.3`, not `1.2.3`; the prefix is part of the tag and not
  of the package version.
- A **pre-release** is a `vMAJOR.MINOR.PATCH-<channel>.<number>` tag such as `v1.1.0-beta.1`. NuGet
  accepts it as a pre-release and package managers do not select it for a plain version range.
  Current automation publishes stable releases only: create a pre-release manually with
  `dotnet nuget push` after the same verification, or extend the workflow first.
- A package version that was published is never reused, not even for a pre-release with the same
  number. `--skip-duplicate` protects a retried workflow run; it is not permission to republish.

## Versioning

- `MinVer` 8 derives the version from the tag on the released commit, and `MinVerTagPrefix` is `v`.
  A stable tag is the package version without its prefix; commits after a tag receive a `dev.<count>`
  pre-release suffix and are not published.
- The package version is the tag, with no Revit year in it: one package serves every supported Revit
  version, because the templates pin their own Revit package versions. The tag is the single source
  of the version and is not coupled to another repository's version.
- Version by SemVer: a breaking change to a template's shape, name or generated layout ships in a
  major version, a new template or a new option in a minor version, and a defect fix in a patch
  version.
- A template change that forces the user to edit a generated project is breaking, even when the
  template short name stays the same.

## Preparing a release

Before creating the tag:

1. Confirm `build-and-test` and `repository-policy` are green on `dev` and on the release branch.
2. Compose the pending fragments with `./scripts/Update-Changelog.ps1 -Compose` and edit the collected
   entries under `## [Unreleased]`: merge related entries, drop what a consumer cannot observe and fix
   the wording. Commit the result.
3. Close the section with `./scripts/Update-Changelog.ps1 -Finalize <version>`, where `<version>` is
   the tag without its `v` prefix, and commit the result together with the deleted fragments.
4. Confirm `## [Unreleased]` is empty and `changelog.d/` holds no fragment.
5. Merge the release branch into `main` with a merge commit, create the tag on that merge commit and
   push the tag.

The tagged commit already contains the release section in `CHANGELOG.md` with an empty
`## [Unreleased]` above it and no pending fragment; the workflow refuses to publish otherwise.

## Release metadata rules

- Never mark a stable version as a pre-release, and never give a pre-release a stable version number.
- Never delete, move or force-push a pushed release tag. A pushed tag is immutable; publish the next
  version instead. If a mistake is found before the tag is pushed and nothing was published, fix the
  commit, move the local tag and push it once.
- A package that was already published with a wrong version stays published; correct the content in
  the next version and explain it in the changelog.

## Package artifacts

- `dotnet pack Toolkit.Revit.Templates.csproj` produces one
  `VolocyNazad.Revit.Templates.<version>.nupkg` in `artifacts/`, where `<version>` is the tag without
  its `v` prefix.
- The package carries `README.md`, `LICENSE.md` and the whole `source/**` tree as `content`; a
  template folder that is missing from the package is a release defect, not a packaging preference.
- The workflow verifies the `.nuspec` package id and the version against the tag before pushing; a
  mismatch fails the release.

## Publish automation

The workflow runs on `workflow_dispatch`; a tag push alone does not publish. It:

- checks out with full history, because `MinVer` reads the tags;
- runs `./scripts/Verify-Release.ps1 -FromHeadTag -AncestorOf main -TagPrefix v`: `HEAD` must carry
  exactly one stable tag, `CHANGELOG.md` must have an empty `## [Unreleased]` and exactly one
  `## [VERSION] - YYYY-MM-DD` section for the tag directly below it, and `HEAD` must be an ancestor
  of `origin/main`;
- packs the package and installs that package with `./scripts/Test-Templates.ps1`, so the release is
  one that generated a building project for each short name;
- verifies the package id and version, then pushes it to nuget.org.

After the pipeline, inspect the package on nuget.org: the version, the README and the template list.

The rest of the contributor workflow is defined by the [development policy](development.md).
