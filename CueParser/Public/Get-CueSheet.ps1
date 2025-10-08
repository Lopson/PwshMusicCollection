function Get-CueSheet {
    [OutputType([CueSheet])]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Path")]
        [ValidateScript({
                Test-Path -Path $_ -PathType "Leaf"; },
            ErrorMessage = "Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $true, ParameterSetName = "LiteralPath")]
        [ValidateScript({
                Test-Path -LiteralPath $_ -PathType "Leaf"; },
            ErrorMessage = "Literal Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrEmpty()]
        [string]$LiteralPath,

        [ValidateSet("iso-8859-1", "utf-8", "us-ascii", "utf-16", "unicodeFFFE", "utf-32", "utf-32BE", "utf-7")]
        [ValidateNotNullOrEmpty()]
        [string]$Encoding = "iso-8859-1"
    )

    $CueSheetPath = $null;
    switch ($PSCmdlet.ParameterSetName) {
        "Path" {
            $CueSheetPath = Get-Item -Path $Path;
        }
        "LiteralPath" {
            $CueSheetPath = Get-Item -LiteralPath $LiteralPath;
        }
    }

    return [CueSheet]::new($CueSheetPath.FullName, $Encoding);
}
