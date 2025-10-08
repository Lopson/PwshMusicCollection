[string]$SacdExtractBinary = "sacd_extract.exe";

function Split-SACDISOToDSF {
    [OutputType([void])]
    [CmdletBinding(DefaultParameterSetName = "Path")]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "Path",
            Position = 0)]
        [ValidateScript({
                Test-Path -Path $_ -PathType "Leaf"; },
            ErrorMessage = "Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrWhiteSpace()]
        [string]$Path,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "LiteralPath",
            Position = 0)]
        [ValidateScript({
                Test-Path -LiteralPath $_ -PathType "Leaf"; },
            ErrorMessage = "Literal Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrWhiteSpace()]
        [string]$LiteralPath,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateSet("Stereo", "Multi")]
        [string]$TrackType = "Stereo"
    )

    [string]$ISOPath = $null;
    switch ($PSCmdlet.ParameterSetName) {
        "Path" {
            [string]$ISOPath = Get-Item -Path $Path;
        }
        "LiteralPath" {
            [string]$ISOPath = Get-Item -LiteralPath $LiteralPath;
        }
    }

    if ([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform(
            [System.Runtime.InteropServices.OSPlatform]::Windows)) {
        if ($null -eq (Get-Command $SacdExtractBinary -ErrorAction SilentlyContinue)) {
            throw [System.IO.FileNotFoundException] (
                "Unable to find $SacdExtractBinary in PATH");
        }
    }
    else {
        throw [System.PlatformNotSupportedException] (
            "This function only works on Windows operating systems currently");
    }
    
    switch ($TrackType) {
        "Stereo" {
            sacd_extract.exe -2 -s -c -C -i $ISOPath;
        }
        "Multi" {
            sacd_extract.exe -m -s -c -C -i $ISOPath;
        }
        Default {
            sacd_extract.exe -2 -s -c -C -i $ISOPath;
        }
    }
}
