function Test-MusicFileTags {
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
                [string]$MusicFilePath = $Path;
            }
            "LiteralPath" {
                $MusicFile = Get-MediaFile -LiteralPath $LiteralPath;
                [string]$MusicFilePath = $LiteralPath;
            }
        }

        # Test the Genre tag.
        $tagValue = Get-MediaFileTagStringArray -MediaFile $MusicFile `
            -MediaTag "Genres";
        if (-not $tagValue -or ($tagValue.Length -le 0)) {
            Write-Warning ("File $MusicFilePath, Genre tag is empty");
        }

        # Test the standard release year tag.
        $tagValue = Get-MediaFileTag -MediaFile $MusicFile -MediaTag "Year";
        [datetime]$yearTagDateTime = New-Object datetime;
        if ([string]::IsNullOrWhiteSpace($tagValue)) {
            Write-Warning ("File $MusicFilePath, release year tag is empty");
        }
        elseif (-not ([datetime]::TryParseExact(
                    $tagValue,
                    "yyyy",
                    [CultureInfo]::InvariantCulture,
                    [System.Globalization.DateTimeStyles]::None,
                    [ref]$yearTagDateTime))) {
            Write-Warning (
                "File $MusicFilePath, release year tag doesn't contain a " +
                "number or contains an invalid year number");
        }

        # If Xiph tags are present, test that release year tag too.
        if (Test-MediaFileTagType -MediaFile $MusicFile `
                -MediaTagType "Xiph") {
            $tagValue = Get-MediaFileCustomTag -MediaFile $musicFile `
                -MediaTag "DATE" -MediaTagType "Xiph";
            
            if ((-not [string]::IsNullOrWhiteSpace($tagValue)) -and
                (-not ([datetime]::TryParseExact(
                        $tagValue,
                        "yyyy",
                        [CultureInfo]::InvariantCulture,
                        [System.Globalization.DateTimeStyles]::None,
                        [ref]$yearTagDateTime)))) {
                Write-Warning (
                    "File $MusicFilePath, Xiph-specific release year tag " +
                    "is set and contains an invalid year number");
            }
        }

        # Test the release country tag.
        $tagValue = Get-MediaFileTag -MediaFile $MusicFile `
            -MediaTag "MusicBrainzReleaseCountry";
        if ([string]::IsNullOrWhiteSpace($tagValue)) {
            Write-Warning ("File $MusicFilePath, release country tag is empty");
        }
        elseif ($tagValue -notin [Valid3LetterCountryCodes]::new().GetValidValues()) {
            if (($tagValue -split ",").Length -eq 2) {
                Write-Warning ("File $MusicFilePath, possible old-format " +
                    "country tag found, consider replacing it with a " +
                    "3-letter country code");
            }
            else {
                Write-Warning ("File $MusicFilePath, release country tag is " +
                    "not a valid 3-letter code");
            }
        }

        # Test the album title tag.
        $tagValue = Get-MediaFileTag -MediaFile $MusicFile -MediaTag "Album";
        if ([string]::IsNullOrWhiteSpace($tagValue)) {
            Write-Warning ("File $MusicFilePath, album title tag is empty");
        }

        # Test the "Album Artists" and "Performers" tag.
        $tagValue = Get-MediaFileTagStringArray `
            -MediaFile $MusicFile -MediaTag "AlbumArtists";
        [bool]$artistsTagged = $false;
        if ($tagValue -and ($tagValue.Length -gt 0)) {
            $artistsTagged = $true;
        }

        $tagValue = Get-MediaFileTagStringArray `
            -MediaFile $MusicFile -MediaTag "Performers";
        if ($tagValue -and ($tagValue.Length -gt 0)) {
            $artistsTagged = $true;
        }

        if (-not $artistsTagged) {
            Write-Warning (
                "File $MusicFilePath, album performer tag is empty");
        }

        # Check for ReplayGain tags.
        [string[]]$replayTags = @();
        foreach ($replayTag in @("ReplayGainTrackGain", "ReplayGainTrackPeak",
                "ReplayGainAlbumGain", "ReplayGainAlbumPeak")) {
            $tagValue = Get-MediaFileTag -MediaFile $MusicFile `
                -MediaTag $replayTag;
            
            if (-not [string]::IsNullOrWhiteSpace($tagValue) -and `
                    -not [double]::IsNaN($tagValue)) {
                $replayTags += $replayTag;
            }
        }
        if ($replayTags -and $replayTags.Length -gt 0) {
            Write-Warning "File $MusicFilePath, ReplayGain tags detected: $(`
            $replayTags -join ", ")";
        }

        # Test the number of discs fields.
        $discCount = Get-MediaFileTag -MediaFile $MusicFile `
            -MediaTag "DiscCount";
        $discNumber = Get-MediaFileTag -MediaFile $MusicFile `
            -MediaTag "Disc";

        if ($discCount -and $discCount -le 0) {
            Write-Warning ("File $MusicFilePath, disc count field has " +
                "an invalid value of $discCount");
        }
        if ($discNumber -and $discNumber -le 0) {
            Write-Warning ("File $MusicFilePath, disc number field has " +
                "an invalid value of $discNumber");
        }
        if ($discNumber -and -not $discCount) {
            Write-Warning ("File $MusicFilePath, disc number set but " +
                "no disc count value present");
        }
        if ($discCount -and -not $discNumber) {
            Write-Warning ("File $MusicFilePath, disc count set but " +
                "no disc number present");
        }
        if ($discNumber -and $discCount -eq 1) {
            Write-Warning ("File $MusicFilePath, disc number and count " +
                "set but unnecessary as disc total is 1");
        }
        if (Test-MediaFileTagType -MediaFile $MusicFile `
                -MediaTagType "Xiph") {
            $xiphDiscCount = Get-MediaFileCustomTag -MediaFile $musicFile `
                -MediaTag "TOTALDISCS" -MediaTagType "Xiph";
            
            if (-not $discCount -and $xiphDiscCount) {
                Write-Warning ("File $MusicFilePath, disc count tag not set " +
                    "but corresponding Xiph tag is set to $xiphDiscCount");
            }
        }

        # Test the number of total tracks.
        $tagValue = Get-MediaFileTag -MediaFile $MusicFile -MediaTag "TrackCount";
        if (-not $tagValue) {
            Write-Warning "File $MusicFilePath, no track count value found";
        }
        elseif ($tagValue -le 0) {
            Write-Warning "File $MusicFilePath, track count value invalid ";
        }
    }
}
