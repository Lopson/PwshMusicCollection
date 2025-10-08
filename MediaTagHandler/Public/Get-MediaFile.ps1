function Get-MediaFile {
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
        [ValidateNotNullOrEmpty()]
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
        [ValidateNotNullOrEmpty()]
        [string]$LiteralPath
    )

    begin {
        $result = @();   
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            "Path" {
                $MediaFile = [TagLib.File]::Create((Get-Item -Path $Path | Resolve-Path).ProviderPath);
            }
            "LiteralPath" {
                $MediaFile = [TagLib.File]::Create($LiteralPath);
            }
        }

        $result += $MediaFile;
    }
    end {
        return $result;
    }
}
