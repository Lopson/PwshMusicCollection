[string[]]$FrameworkFallbackOrder = @(
    "netstandard2.0", "netstandard20", "net10.0", "net9.0", "net8.0", "net481");

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
        [string]$TargetFramework = "*",

        # See https://learn.microsoft.com/en-us/dotnet/core/rid-catalog
        # for the full list of Runtime Identifiers.
        [ValidateSet('win-x64', 'win-x86', 'win-arm64', 'linux-x64',
            'linux-musl-x64', 'linux-musl-arm64', 'linux-arm', 'linux-arm64',
            'linux-bionic-arm64', 'linux-loongarch64', 'osx', 'osx-x64',
            'osx-arm64', '*', '', $null)]
        [string]$RuntimeId
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

    nuget install $PackageName -Version $Version -OutputDirectory $env:TEMP > $null;
        # $env:TEMP -NoHttpCache > $null;
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
    Write-Verbose "Copying framework DLLs of $PackageName to $OutputPath.";

    [string]$frameworkPath = Join-Path $packagePath "lib" $TargetFramework;
    Get-ChildItem -LiteralPath $frameworkPath -Filter "*.dll" | `
        Copy-Item -Destination $OutputPath -Force;

    # If runtime-specific DLLs are required by the dependency, copy them.
    if ($RuntimeId) {
        # Figure out what runtime identifier we want to use.
        [string]$TargetRuntime = $null;
        if ($RuntimeId -eq "*") {
            $TargetRuntime = (
                [System.Runtime.InteropServices.RuntimeInformation]::RuntimeIdentifier);
        }
        else {
            $TargetRuntime = $RuntimeId;
        }

        Write-Verbose "Target runtime of package $PackageName calculated: $TargetRuntime.";

        # Check if the runtime we need is available in the NuGet package.
        # NOTE This may be a naive approach, unsure.
        if (-not ($TargetRuntime -in (
                Get-ChildItem -LiteralPath (Join-Path $packagePath "runtimes")).BaseName)) {
            throw [System.MissingMemberException] (
                "Target runtime $TargetRuntime not found in package");
        }

        # Copy the DLLs to the target output path.
        Write-Verbose "Copying runtime DLLs of $PackageName to $OutputPath.";

        [string]$runtimePath = Join-Path $packagePath "runtimes" $TargetRuntime "native";
        Get-ChildItem -LiteralPath $runtimePath | `
            Copy-Item -Destination $OutputPath -Force;
    }
    
    # Cleanup.
    Write-Verbose "Deleting temporary files in $packagePath.";
    Remove-Item $packagePath -Recurse -Force;
}
