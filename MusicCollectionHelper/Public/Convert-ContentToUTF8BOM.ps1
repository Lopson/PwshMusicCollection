function Convert-ContentToUTF8BOM {
    # List of supported encodings for .NET Core 3.1 (most recent at time of this writing).
    # https://docs.microsoft.com/en-us/dotnet/api/system.text.encoding?view=netcore-3.1

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
            ErrorMessage = "Path `"{0}`" doesn't exist."
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "LiteralPath",
            Position = 0)]
        [ValidateScript({
                Test-Path -LiteralPath $_ -PathType "Leaf"; },
            ErrorMessage = "Literal Path `"{0}`" doesn't exist."
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$LiteralPath,
        
        [ValidateSet("iso-8859-1", "utf-8", "us-ascii", "utf-16", "unicodeFFFE", "utf-32", "utf-32BE", "utf-7")]
        [ValidateNotNullOrEmpty()]
        [string]$FileEncoding = "iso-8859-1"
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            "Path" {
                [string]$FilePath = Get-Item -Path $Path;
            }
            "LiteralPath" {
                [string]$FilePath = Get-Item -LiteralPath $LiteralPath;
            }
        }

        $FileContents = Get-Content -LiteralPath $FilePath -Encoding $FileEncoding;
        $FileContents | Set-Content -LiteralPath $FilePath -Encoding "utf8BOM";
    }
}
