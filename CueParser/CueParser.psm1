foreach ($private in (
    Get-ChildItem "$PSScriptRoot\Private" -ErrorAction SilentlyContinue)
) {
    . $private.FullName;
}

foreach ($public in (
    Get-ChildItem "$PSScriptRoot\Public" -ErrorAction SilentlyContinue)
) {
    . $public.FullName;
    Export-ModuleMember -Function $public.BaseName;
}

# Declare the types via Type Accelerators so that public functions can rely on them.
# NOTE Classes must be imported in this specific order due to intra-dependencies.
# Source: https://synedgy.com/powershell-modules-exporting-classes/
$ExportableClasses = @(
    'CueIndex',
    'CueTrack',
    'CueFile',
    'CueSheet',
    'ValidTextEncodings'
)

foreach ($className in $ExportableClasses) {
    [string]$ClassPath = Join-Path $PSScriptRoot "Classes" "$className.ps1";
    if (Test-Path $ClassPath) {
        . $ClassPath;
    } else {
        throw [System.IO.FileNotFoundException] "File $ClassPath not found.";
    }
}

# Export the classes using .NET Type Accelerators.
$typeAcceleratorsClass = [PSObject].Assembly.GetType(
    'System.Management.Automation.TypeAccelerators'
);
[void]$typeAcceleratorsClass::Get;

foreach ($typeToExport in $ExportableClasses) {
    $type = $TypeToExport -as [System.Type];
    
    if (-not $type) {
        throw [System.TypeLoadException] "Type $typeToExport not found.";
    }
    else {
        [void]$TypeAcceleratorsClass::Add($TypeToExport, $Type);
    }
}
