function Compress-DSDFile {
    [OutputType([void])]
    [CmdletBinding(DefaultParameterSetName = "LiteralPath")]
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
        [string[]]$Path,

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
        [string[]]$LiteralPath
    )
    process {
        switch ($PSCmdlet.ParameterSetName) {
            "Path" {
                $MusicFilePath = Get-Item -Path $Path;
            }
            "LiteralPath" {
                $MusicFilePath = Get-Item -LiteralPath $LiteralPath;
            }
        }

        if ($MusicFilePath.Extension -notin @(".dsf", ".dff", ".dsdiff")) {
            throw [System.ArgumentException] (
                "Extension of file $MusicFilePath is not DSD-related, " +
                "check if the files given are actual DSD music files");
        }

        if ($null -eq (Get-Command "wavpack" -ErrorAction SilentlyContinue)) {
            throw [System.Management.Automation.CommandNotFoundException] (
                "Unable to find `"wavpack`" in user's Path");
        }
        
        wavpack -hmv "$MusicFilePath";
    }
}
