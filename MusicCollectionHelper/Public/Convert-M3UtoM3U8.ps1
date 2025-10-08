function Convert-M3UtoM3U8 {
    [OutputType([void])]
    [CmdletBinding(DefaultParameterSetName = "Path")]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "Path",
            Position = 0)]
        [ValidateScript({
                Test-Path -Path $_ -PathType "Leaf";
                (Get-Item -Path $_).Extension -eq '.m3u'; },
            ErrorMessage = "Path `"{0}`" doesn't exist or doesn't have .m3u extension."
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "LiteralPath",
            Position = 0)]
        [ValidateScript({
                Test-Path -LiteralPath $_ -PathType "Leaf";
                (Get-Item -LiteralPath $_).Extension -eq '.m3u'; },
            ErrorMessage = "Literal Path `"{0}`" doesn't exist or doesn't have .m3u extension."
        )]
        [ValidateNotNullOrEmpty()]
        [string]$LiteralPath
    )

    switch ($PSCmdlet.ParameterSetName) {
        "Path" {
            [string]$M3UPath = Get-Item -Path $Path;
        }
        "LiteralPath" {
            [string]$M3UPath = Get-Item -LiteralPath $LiteralPath;
        }
    }
    
    Convert-ContentToUTF8BOM $M3UPath;
    Rename-Item -LiteralPath $M3UPath -NewName { $_.Name -replace '.m3u', '.m3u8' };
}
