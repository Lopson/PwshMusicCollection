function Remove-ReplayGainTags {
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
    process {
        switch ($PSCmdlet.ParameterSetName) {
            "Path" {
                $MusicFile = Get-MediaFile -Path $Path;
            }
            "LiteralPath" {
                $MusicFile = Get-MediaFile -LiteralPath $LiteralPath;
            }
        }

        [bool]$tagsChanged = $false;
        foreach ($replayTag in @("ReplayGainTrackGain", "ReplayGainTrackPeak",
                "ReplayGainAlbumGain", "ReplayGainAlbumPeak")) {
            $tagValue = Get-MediaFileTag -MediaFile $MusicFile `
                -MediaTag $replayTag;
            
            if ($tagValue) {
                Set-MediaFileTag -MediaFile $MusicFile -MediaTag $replayTag `
                    -MediaTagValue $null -Save $false;
                $tagsChanged = $true;
            }
        }
        
        if ($tagsChanged) {
            $MusicFile.Save();
        }
    }
}
