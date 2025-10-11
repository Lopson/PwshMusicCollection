[string[]]$FrameworkFallbackOrder = @("netstandard2.0", "net9.0", "net8.0", "net481");

function Get-NuGetPackageDLLs {
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrWhiteSpace()]
        [string]$OutputPath,
    
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrWhiteSpace()]
        [string]$PackageName,

        [ValidateNotNullOrWhiteSpace()]
        [string]$Version = "*",

        [ValidateNotNullOrWhiteSpace()]
        [string]$TargetFramework = "*"
    )
    
    # Determine which version of the package to download.
    Write-Verbose "Determining target version of package $PackageName.";

    if ($Version -eq "*") {
        $nugetPackage = Find-Package -Name $PackageName -Source "nuget.org";
        if ($null -eq $nugetPackage) {
            throw [System.MissingMemberException] (
                "Package $PackageName not found in NuGet");
        }
        $Version = $nugetPackage.Version;
    }

    Write-Verbose "Target version of package $PackageName calculated: $Version.";
    
    # Download package.
    Write-Verbose "Downloading $PackageName to $env:TEMP.";

    nuget install $PackageName -Version $Version -OutputDirectory `
        $env:TEMP -NoHttpCache > $null;
    if ($LASTEXITCODE -ne 0) {
        throw [System.ApplicationException] (
            "NuGet command has failed to download package $PackageName");
    }
    
    [string]$packagePath = Join-Path $env:TEMP "$PackageName.$Version";

    Write-Verbose "$PackageName downloaded to $packagePath.";
    
    # Determine which framework to target.
    Write-Verbose "Determining target framework of package $PackageName.";

    [string[]]$availableFrameworks = @(
        Get-ChildItem -LiteralPath (Join-Path $packagePath "lib") -Directory | `
            Select-Object -ExpandProperty BaseName);
    if ($TargetFramework -eq "*") {
        :outerLoop foreach ($framework in $FrameworkFallbackOrder) {
            foreach ($packageFrameworks in $availableFrameworks) {
                if ($TargetFramework -eq "*" -and $packageFrameworks -eq $framework) {
                    $TargetFramework = $framework;
                    break outerLoop;
                }
            }    
        }

        if ($TargetFramework -eq "*") {
            throw [System.MissingMemberException] (
                "Target framework $TargetFramework not found in package");
        }
    }
    elseif ($TargetFramework -notin $availableFrameworks) {
        throw [System.MissingMemberException] (
            "Target framework $TargetFramework not found in package");
    }

    Write-Verbose "Target framework of package $PackageName calculated: $TargetFramework.";
    
    # Copy the DLLs to the target output path.
    Write-Verbose "Copying DLLs of $PackageName to $OutputPath.";

    [string]$frameworkPath = Join-Path $packagePath "lib" $TargetFramework;
    Get-ChildItem -LiteralPath $frameworkPath -Filter "*.dll" | `
        Copy-Item -Destination $OutputPath -Force;
    
    # Cleanup.
    Write-Verbose "Deleting temporary files in $packagePath.";
    Remove-Item $packagePath -Recurse -Force;
}
