<#
.SYNOPSIS
    Local check of all dotnet new templates without pushing to CI.

.DESCRIPTION
    Does the same thing as the smoke tests in .github/workflows/build-and-test.yml:
    for each of the 6 templates (revit-addin, revit-addin-wpf, revit-lib,
    revit-addin-repo, revit-addin-wpf-repo, revit-lib-repo) runs
    "dotnet new" and then "dotnet build" of the result. The generated
    projects/solutions stay in output/smoke-tests/<shortname>/ - you can
    open and inspect them by hand, nothing is removed automatically
    Each run uses a unique subdirectory and preserves previous results.

.PARAMETER SkipPack
    Don't rebuild the nupkg, instead install the templates directly from
    source/ (dotnet new install <path>). Faster for repeated runs while
    tweaking a single template, but doesn't verify the packaging itself
    (Toolkit.Revit.Templates.csproj).

.PARAMETER OutputRoot
    Where to put the generated projects. Defaults to output/smoke-tests
    at the repository root.

.EXAMPLE
    ./scripts/Test-Templates.ps1

.EXAMPLE
    ./scripts/Test-Templates.ps1 -SkipPack
#>
[CmdletBinding()]
param(
    [switch]$SkipPack,
    [string]$OutputRoot
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
if (-not $OutputRoot) {
    $OutputRoot = Join-Path $repoRoot "output\smoke-tests"
}

Push-Location $repoRoot
try {
    # Each run uses a fresh directory and isolated template registry.
    $OutputRoot = Join-Path $OutputRoot ([guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null
    $hive = Join-Path $OutputRoot 'template-hive'
    if ($SkipPack) {
        Write-Host "==> Installing templates directly from source/ (--force)" -ForegroundColor Cyan
        $sourceDirs = @(
            "source\projects\RevitAddin"
            "source\projects\RevitAddin.Wpf"
            "source\projects\Revit.Sample"
            "source\solutions\RevitAddin"
            "source\solutions\RevitAddin.Wpf"
            "source\solutions\Revit.Sample"
        )
        foreach ($dir in $sourceDirs) {
            dotnet new install (Join-Path $repoRoot $dir) --force --debug:custom-hive $hive
            if ($LASTEXITCODE -ne 0) { throw "dotnet new install '$dir' failed" }
        }
    }
    else {
        Write-Host "==> dotnet pack Toolkit.Revit.Templates.csproj" -ForegroundColor Cyan
        dotnet pack Toolkit.Revit.Templates.csproj --configuration Release /nologo
        if ($LASTEXITCODE -ne 0) { throw "dotnet pack failed" }

        $nupkg = Get-ChildItem (Join-Path $repoRoot "artifacts") -Filter "*.nupkg" |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if (-not $nupkg) { throw "No .nupkg found in artifacts/ after pack" }

        Write-Host "==> dotnet new install $($nupkg.Name) (--force)" -ForegroundColor Cyan
        dotnet new install $nupkg.FullName --force --debug:custom-hive $hive
        if ($LASTEXITCODE -ne 0) { throw "dotnet new install failed" }
    }

    # ShortName          - template name for "dotnet new"
    # Name                - value for -n (also verifies sourceName/symbols substitution)
    # Config              - configuration for "dotnet build" (must exist in the template's csproj)
    # BuildTarget         - relative path to .csproj/.slnx after substituting {0} -> Name
    # Stubs               - placeholder files to create at the root of $out before
    #                       building (relevant for "project" templates like revit-lib:
    #                       their csproj references README.md/LICENSE.md two levels
    #                       above src/, since in practice they get added into an
    #                       already existing repository where these files already exist)
    $templates = @(
        [pscustomobject]@{ ShortName = "revit-addin";          Name = "SmokeTestAddin";        Config = "Release_2025";     BuildTarget = "{0}.csproj";              Stubs = @() }
        [pscustomobject]@{ ShortName = "revit-addin-wpf";      Name = "SmokeTestAddinWpf";     Config = "Release_2025";     BuildTarget = "{0}.csproj";              Stubs = @() }
        [pscustomobject]@{ ShortName = "revit-lib";            Name = "Revit.SmokeTestProj";   Config = @("Release_2021.1.9", "Release_2023.0.0", "Release_2025.0.0"); BuildTarget = "src\{0}\{0}.csproj";     Stubs = @("README.md", "LICENSE.md") }
        [pscustomobject]@{ ShortName = "revit-addin-repo";     Name = "SmokeTestAddinRepo";    Config = "Release_2025";     BuildTarget = "{0}.slnx";                Stubs = @() }
        [pscustomobject]@{ ShortName = "revit-addin-wpf-repo"; Name = "SmokeTestAddinWpfRepo"; Config = "Release_2025";     BuildTarget = "{0}.slnx";                Stubs = @() }
        [pscustomobject]@{ ShortName = "revit-lib-repo";       Name = "Revit.SmokeTest";       Config = @("Release_2021.1.9", "Release_2023.0.0", "Release_2025.0.0"); BuildTarget = "{0}.slnx";                Stubs = @() }
    )

    $results = @()

    foreach ($t in $templates) {
        $out = Join-Path $OutputRoot $t.ShortName
        Write-Host ""
        Write-Host "==> [$($t.ShortName)] dotnet new -n $($t.Name) -o $out" -ForegroundColor Cyan

        $newOk = $true
        dotnet new $t.ShortName -n $t.Name -o $out --force --debug:custom-hive $hive
        if ($LASTEXITCODE -ne 0) { $newOk = $false }

        if ($newOk -and $t.Stubs) {
            foreach ($stub in $t.Stubs) {
                # NuGet (NU5040) rejects an empty README.md, so we write a
                # non-empty placeholder instead of just creating an empty file.
                Set-Content -Path (Join-Path $out $stub) -Value "# Stub" -Encoding utf8
            }
        }

        $buildOk = $false
        if ($newOk) {
            $buildTarget = Join-Path $out ($t.BuildTarget -f $t.Name)
            Write-Host "==> [$($t.ShortName)] dotnet build $buildTarget -c $($t.Config)" -ForegroundColor Cyan
            if (Test-Path $buildTarget) {
                $buildOk = $true
                foreach ($configuration in $t.Config) {
                    dotnet build $buildTarget --configuration $configuration -p:Platform=x64 /nologo
                    if ($LASTEXITCODE -ne 0) { $buildOk = $false }
                    if ($t.ShortName -eq 'revit-lib') {
                        $testProject = Join-Path $out ("tests\{0}.Tests\{0}.Tests.csproj" -f $t.Name)
                        dotnet build $testProject --configuration $configuration -p:Platform=x64 /nologo
                        if ($LASTEXITCODE -ne 0) { $buildOk = $false }
                    }
                }
                if ($t.ShortName -like '*-repo') {
                    & (Join-Path $out 'scripts/Validate-Repository.ps1') -RepositoryRoot $out
                }
            }
            else {
                Write-Host "Expected file not found: $buildTarget" -ForegroundColor Red
            }
        }

        $results += [pscustomobject]@{
            Template = $t.ShortName
            New      = $newOk
            Build    = $buildOk
            Path     = $out
        }
    }

    Write-Host ""
    Write-Host "=== Summary ===" -ForegroundColor Yellow
    $results | Format-Table -AutoSize

    $failed = $results | Where-Object { -not $_.New -or -not $_.Build }
    if ($failed) {
        Write-Host "Failed: $($failed.Template -join ', ')" -ForegroundColor Red
        Write-Host "Generated code kept at: $OutputRoot" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "All 6 templates generated and built successfully." -ForegroundColor Green
    Write-Host "Result at: $OutputRoot" -ForegroundColor Yellow
}
finally {
    Pop-Location
}
