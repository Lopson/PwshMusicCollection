function Set-MusicFileTrackCount {
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
        switch ($PSCmdlet.ParameterSetName) {
            "Path" {
                $totalTracks = $Path.Length;
            }
            "LiteralPath" {
                $totalTracks = $LiteralPath.Length;
            }
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            "Path" {
                $MusicFile = Get-MediaFile -Path $Path;
            }
            "LiteralPath" {
                $MusicFile = Get-MediaFile -LiteralPath $LiteralPath;
            }
        }

        Set-MediaFileTag -MediaFile $MusicFile -MediaTag "TrackCount" `
            -MediaTagValue $totalTracks;
    }
}
