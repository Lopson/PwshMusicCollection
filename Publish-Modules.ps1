#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop";
$PSNativeCommandUseErrorActionPreference = $true;

[string[]]$MODULE_NAMES = @(
    "CueParser",
    "M3UParser",
    "MediaTagHandler",
    "MusicCollectionHelper"
)
[string[]]$DEPENDENCY_NAMES = @(
    "PlaylistsNET",
    "TagLibSharp"
)
# NOTE WRT PlaylistsNET: https://stackoverflow.com/questions/47365136/why-does-my-net-standard-nuget-package-trigger-so-many-dependencies
[string]$NUGET_EXECUTABLE = "nuget";

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
        [string]$LiteralPath
    )

    [string]$PwshProfilePath = Split-Path $PROFILE.CurrentUserCurrentHost -Parent;
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
    if (-not (Get-Command -Name $NUGET_EXECUTABLE -ErrorAction SilentlyContinue)) {
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

    # Check if the dependencies of the modules are installed.
    foreach ($dependency in $DEPENDENCY_NAMES) {
        if (-not (Get-Package -Name $dependency -ProviderName "NuGet" `
                    -ErrorAction SilentlyContinue)) {
            throw [System.DllNotFoundException] (
                "Dependency $dependency not installed, please run the " + 
                "following command to address this: `"Install-Package " +
                "$dependency -Verbose -ProviderName NuGet`"");
        }
    }

    Write-Verbose "All .NET dependencies accounted for";

    # Copy the modules over to the user's Powershell profile.
    foreach ($moduleName in $MODULE_NAMES) {
        Write-Verbose "Copying module $moduleName";
        Copy-Item -Force -Recurse -LiteralPath ".\$moduleName" -Destination `
            $PwshProfilePath
        Write-Verbose "Done copying module $moduleName";
    }

    Write-Verbose "Modules have been installed on local system";
}

Publish-Modules -Verbose;
