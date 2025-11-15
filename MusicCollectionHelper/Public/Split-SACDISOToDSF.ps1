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

    # SACD Extract's page.
    # https://www.videohelp.com/software/sacd-extract
    if ($null -eq (Get-Command "sacd_extract" -ErrorAction SilentlyContinue)) {
        throw [System.Management.Automation.CommandNotFoundException] (
            "Unable to find `"sacd_extract`" in user's Path");
    }
    
    switch ($TrackType) {
        "Stereo" {
            sacd_extract -2 -s -c -C -i $ISOPath;
        }
        "Multi" {
            sacd_extract -m -s -c -C -i $ISOPath;
        }
        Default {
            sacd_extract -2 -s -c -C -i $ISOPath;
        }
    }
}
