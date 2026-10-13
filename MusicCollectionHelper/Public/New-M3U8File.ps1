function New-M3U8File {
    [OutputType([void])]
    [CmdletBinding(DefaultParameterSetName = "NoPath")]
    param (
        [Parameter(ParameterSetName = "Path")]
        [ValidateScript({
                Test-Path -Path (Split-Path -Path $_) -PathType "Container"; },
            ErrorMessage = "Parent of path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrWhiteSpace()]
        [string]$Path,
        
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateScript({
                Test-Path -LiteralPath (Split-Path -LiteralPath $_) -PathType "Container"; },
            ErrorMessage = "Parent of Literal Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrWhiteSpace()]
        [string]$LiteralPath,
        
        [Parameter(ParameterSetName = "NoPath")]
        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateSet([ValidAudioExtensions])]
        [ValidateNotNullOrEmpty()]
        [string]$Extension = "flac",

        [switch]$Overwrite
    )

    # Get the M3U8 file's folder first.
    [string]$M3U8Folder = $null;
    switch ($PSCmdlet.ParameterSetName) {
        "Path"        { $M3U8Folder = (Split-Path -Path $Path); }
        "LiteralPath" { $M3U8Folder = (Split-Path -LiteralPath $LiteralPath); }
        "NoPath"      { $M3U8Folder = (Get-Location).Path; }
    }

    # Get list of files in M3U8 folder.
    [string[]]$M3U8Files = (
        Get-ChildItem -LiteralPath $M3U8Folder -Filter "*.$Extension" | Sort-Object).Name;
    if (-not $M3U8Files) {
        throw [System.IO.FileNotFoundException] `
            "No .$Extension files found in folder $M3U8Folder";
    }
    
    # Check that files follow naming convention.
    foreach ($file in $M3U8Files) {
        if ($file -notmatch "^\d\d\. ") {
            throw [System.ArgumentException] (
                "One of the music file names doesn't start with '\d\d. '," + 
                " which goes against our naming convention, aborting"
            );
        }
    }

    # Check that there are no gaps in file track numbers.
    for ($i = 0; $i -lt $M3U8Files.Count; $i++) {
        if (($i + 1) -ne [int]("$($M3U8Files[$i][0])$($M3U8Files[$i][1])")) {
            throw [System.ArgumentException] (
                "Possible gap in music file numbering detected, please " + 
                "check that all files are numbered sequentially"
            );
        }
    }

    # Get the album metadata from the music files.
    # The behavior is that it'll search for the fields across all music files.
    #
    # The only thing it needs is to populate all of the fields below, so that's
    # the only validation being performed: that at least one of the files has
    # one of the missing tags.
    #
    # Note that further down below, we do validate that all music files have a
    # track title tag, as we need that for the playlist.
    [string[]]$albumPerformer = $null;
    [string]$albumTitle = $null;
    [string[]]$albumGenre = $null;
    [string]$albumReleaseYear = $null;
    [string]$albumReleaseCountry = $null;
    foreach ($file in $M3U8Files) {
        if ($albumPerformer -and $albumTitle -and $albumGenre -and `
                $albumReleaseYear -and $albumReleaseCountry) {
            break;
        }

        $musicFile = Get-MediaFile -LiteralPath (Join-Path $M3U8Folder $file);
        
        if (-not $albumPerformer) {
            [string[]]$albumArtistsValue = Get-MediaFileTagStringArray `
                -MediaFile $musicFile -MediaTag "AlbumArtists";
            [string[]]$performersValue = Get-MediaFileTagStringArray `
                -MediaFile $musicFile -MediaTag "Performers";

            if ($albumArtistsValue -and $albumArtistsValue.Length -gt 0) {
                $albumPerformer = $albumArtistsValue.Trim();
            }
            elseif ($performersValue -and $performersValue.Length -gt 0) {
                $albumPerformer = $performersValue.Trim();
            }
        }
        
        if (-not $albumTitle) {
            [string]$titleValue = Get-MediaFileTag -MediaFile $musicFile `
               -MediaTag "Album";
            if (-not [string]::IsNullOrWhiteSpace($titleValue)) {
                $albumTitle = $titleValue.Trim();
            }
        }

        if (-not $albumGenre) {
            [string[]]$genreValue = Get-MediaFileTagStringArray `
                -MediaFile $musicFile -MediaTag "Genres";
            if ($genreValue -and $genreValue.Length -gt 0) {
                $albumGenre = $genreValue.Trim();
            }
        }

        if (-not $albumReleaseYear) {
            [string]$yearValue = Get-MediaFileTag -MediaFile $musicFile `
                -MediaTag "Year";
            if (-not [string]::IsNullOrWhiteSpace($yearValue)) {
                $albumReleaseYear = $yearValue.Trim();
            }
        }
        if (-not $albumReleaseCountry) {
            [string]$countryValue = Get-MediaFileTag -MediaFile $musicFile `
                -MediaTag "MusicBrainzReleaseCountry";
            if (-not [string]::IsNullOrWhiteSpace($countryValue)) {
                $albumReleaseCountry = $countryValue.Trim();
            }
        }
    }
    [bool]$throwTagException = $false;
    foreach ($metadataValue in @(
            "albumPerformer", "albumTitle", "albumGenre",
            "albumReleaseYear", "albumReleaseCountry")) {
        if (-not (Get-Variable -Name $metadataValue -ValueOnly) -or `
                [string]::IsNullOrWhiteSpace(
                (Get-Variable -Name $metadataValue -ValueOnly))) {
            Write-Error "No value found for tag $($metadataValue)";
            $throwTagException = $true;
        }
    }
    if ($throwTagException) {
        throw [System.ArgumentException] (
            "Unable to retrieve basic album-wide tags from any of " +
            "the music files.");
    }

    # Define the path we want for our M3U8 file.
    [string]$M3U8Path = $null;
    switch ($PSCmdlet.ParameterSetName) {
        "Path" {
            if ((Test-Path -Path $Path -PathType "Leaf") -and -not $Overwrite) {
                throw [System.IO.IOException] (
                    "File $Path already exists and overwrite flag not enabled"
                );
            }
            $M3U8Path = $Path;
        }
        "LiteralPath" {
            if ((Test-Path -LiteralPath $LiteralPath -PathType "Leaf") -and `
                    -not $Overwrite) {
                throw [System.IO.IOException] (
                    "File $LiteralPath already exists and overwrite flag not enabled"
                );
            }
            $M3U8Path = $LiteralPath;
        }
        "NoPath" {
            $M3U8Path = Join-Path $M3U8Folder "$albumPerformer - $albumTitle.m3u8";

            if ((Test-Path -LiteralPath $M3U8Path -PathType "Leaf") -and `
                    -not $Overwrite) {
                throw [System.IO.IOException] (
                    "File $M3U8Path already exists and overwrite flag not enabled"
                );
            }
        }
    }

    # Initialize the M3U8 playlist object.
    [PlaylistsNET.Models.M3uPlaylist]$M3U8Playlist = (
        New-M3UPlaylist -LiteralPath (Split-Path $M3U8Path -Parent) `
            -Filename (Split-Path $M3U8Path -Leaf));
    
    # Insert entries and metadata into the playlist.
    for ($i = 0; $i -lt $M3U8Files.Length; $i++) {
        $file = $M3U8Files[$i];
        # Get the file's tags so we can get track title and duration.
        $musicFile = Get-MediaFile -LiteralPath (
            Join-Path $M3U8Folder $file);

        # We need track title and track length for the EXTINF M3U extension.
        [string]$trackTitle = Get-MediaFileTag -MediaFile $musicFile `
            -MediaTag "Title";
        if (-not $trackTitle -or [string]::IsNullOrWhiteSpace($trackTitle)) {
            throw [System.ArgumentException] (
                "File `"$file`" has no title track in its tags");
        }
        [timespan]$trackLength = $musicFile.Properties.Duration;

        [PlaylistsNET.Models.M3uPlaylistEntry]$fileEntry = $null;
        if ($i -eq 0) {
            $fileEntry = New-M3UPlaylistEntry `
                -Path $file `
                -TrackTitle "$($albumPerformer -join ", ") - $trackTitle" `
                -TrackLength $trackLength `
                -TrackArtist ($albumPerformer -join ", ") `
                -AlbumTitle $albumTitle `
                -CustomProperties @{
                "EXTGENRE"   = ($albumGenre -join ", ")
                "EXTCOUNTRY" = $albumReleaseCountry
                "EXTDATE"    = $albumReleaseYear
            };
        }
        else {
            $fileEntry = New-M3UPlaylistEntry `
                -LiteralPath $file `
                -TrackTitle "$($albumPerformer -join ", ") - $trackTitle" `
                -TrackLength $trackLength
        }
        
        $M3U8Playlist.PlaylistEntries.Add($fileEntry);
    }

    # Write the M3U8 file.
    Set-Content -Value (Export-M3UPlaylist -M3UPlaylist $M3U8Playlist) `
        -Encoding "utf8BOM" -LiteralPath $M3U8Path;
}
