#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop";
$PSNativeCommandUseErrorActionPreference = $true;

. (Join-Path "." "requirements.ps1");
. (Join-Path "." "Get-NuGetPackageDLLs.ps1");

[string[]]$MODULE_NAMES = @(
    "CueParser",
    "M3UParser",
    "MediaTagHandler",
    "MusicCollectionHelper"
)

# NOTE WRT PlaylistsNET's dependencies:
# https://stackoverflow.com/questions/47365136/why-does-my-net-standard-nuget-package-trigger-so-many-dependencies

function Publish-Modules {
    [OutputType([void])]
    [CmdletBinding(DefaultParameterSetName = "Path")]
    param (
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "Path",
            Position = 0)]
        [ValidateScript({
                Test-Path -Path $_ -PathType Container; },
            ErrorMessage = "Path `"{0}`" doesn't seem to exist."
        )]
        [string]$Path,

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "LiteralPath",
            Position = 0)]
        [ValidateScript({
                Test-Path -LiteralPath $_ -PathType Container; },
            ErrorMessage = "Literal Path `"{0}`" doesn't seem to exist."
        )]
        [string]$LiteralPath,

        [switch]$DryRun
    )

    [string]$PwshProfilePath = Join-Path (Split-Path $PROFILE.CurrentUserCurrentHost `
            -Parent) "Modules";
    switch ($PSCmdlet.ParameterSetName) {
        "Path" {
            if ($Path -and -not [string]::IsNullOrWhiteSpace($Path)) {
                $PwshProfilePath = Get-Item -Path $Path;
            }
        }
        "LiteralPath" {
            if ($LiteralPath -and -not [string]::IsNullOrWhiteSpace($LiteralPath)) {
                $PwshProfilePath = Get-Item -LiteralPath $LiteralPath;
            }
        }
    }

    Write-Verbose "Publishing path set to $PwshProfilePath";

    # Check if NuGet is currently installed.
    if (-not (Get-Command -Name "nuget" -ErrorAction SilentlyContinue)) {
        throw [System.IO.FileNotFoundException] (
            "NuGet executable not found in system");       
    }

    Write-Verbose "NuGet command found in system";

    # Check if NuGet is one of the available package providers in the system.
    if (-not (Get-PackageProvider -ListAvailable -Name "NuGet" `
                -ErrorAction SilentlyContinue)) {
        throw [System.Management.Automation.ProviderNotFoundException] (
            "Unable to find NuGet in the list of package providers"
        )
    }

    Write-Verbose "NuGet is one of the package providers";

    # Copy the modules over to the user's Powershell profile.
    foreach ($moduleName in $MODULE_NAMES) {
        [string]$modulePath = (Join-Path $PwshProfilePath $moduleName);
        [bool]$moduleExists = (Test-Path -LiteralPath $modulePath);
        if ($moduleExists) {
            Write-Warning "Module $moduleName already exists, will be overwritten!";
        }

        Write-Verbose "Copying module $moduleName";
        if (-not $DryRun) {
            if ($moduleExists) {
                Write-Verbose "Deleting existing copy of module $moduleName";
                
                # Delete all scripting files.
                Get-ChildItem -LiteralPath $modulePath -Filter "*.$Extension" -Recurse | `
                    Where-Object { $_.Name -match "\.(ps1|psd1|psm1|dll)$" } | `
                    Remove-Item -Confirm:$false;

                # Delete all empty folders.
                Get-ChildItem -LiteralPath $modulePath -Directory -Recurse | `
                    Where-Object { $_.GetFileSystemInfos().Count -lt 1 } | `
                    Remove-Item -Confirm:$false;

                Write-Verbose "Deleted existing copy of module $moduleName";
            }
            
            # Copy over the Powershell files.
            Copy-Item -Force -Recurse -LiteralPath ".\$moduleName" -Destination `
                $PwshProfilePath -Confirm:$false;

            # Download and place the .NET DLLs in the appropriate folders.
            foreach ($requirement in ($Requirements | Where-Object {
                        $_.Modules -contains $moduleName })) {
                Write-Verbose ("Downloading dependency $($requirement.PackageName) " +
                    "of module $moduleName");
                
                [string]$dllPath = Join-Path $modulePath "Assemblies";
                if (-not (Test-Path -LiteralPath $dllPath -PathType Container)) {
                    [void](New-Item -ItemType Directory -Path $dllPath);
                }
                Get-NuGetPackageDLLs -OutputPath $dllPath -PackageName `
                    $requirement.PackageName -Version $requirement.Version `
                    -TargetFramework $requirement.TargetFramework;

                Write-Verbose ("Downloaded dependency $($requirement.PackageName) " + 
                "of module $moduleName");
            }
        }
        Write-Verbose "Done copying module $moduleName";
    }

    Write-Verbose "Modules have been installed on local system";
}

Publish-Modules -Verbose;
