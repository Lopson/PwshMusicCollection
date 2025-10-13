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

        # Test the release year tag.
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
    }
}
