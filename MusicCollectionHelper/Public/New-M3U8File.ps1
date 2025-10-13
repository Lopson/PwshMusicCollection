function New-M3U8File {
    # NOTE This function doesn't use parameter sets on purpose as if we were to
    # do that we wouldn't be able to invoke it with no arguments.

    [OutputType([void])]
    param (
        [ValidateScript({ if (-not [string]::IsNullOrWhiteSpace($_)) {
                    Test-Path -Path (Get-Location).Path -PathType "Container";
                } },
            ErrorMessage = "Folder of path `"{0}`" doesn't seem to exist."
        )]
        [string]$Path,
        
        [ValidateScript({ if (-not [string]::IsNullOrWhiteSpace($_)) {
                    Test-Path -LiteralPath (Split-Path -LiteralPath $_) -PathType "Container"; 
                } },
            ErrorMessage = "Folder of literal path `"{0}`" doesn't seem to exist."
        )]
        [string]$LiteralPath,

        [string[]]$Genre,

        [string]$ReleaseYear,

        [ValidateSet([Valid3LetterCountryCodes])]
        [string]$ReleaseCountry,

        [string[]]$Performer,

        [string]$Title,
        
        [ValidateSet($true, $false)]
        [bool]$UseTags = $true,
        
        [ValidateSet([ValidAudioExtensions])]
        [ValidateNotNullOrEmpty()]
        [string]$Extension = "flac",

        [ValidateSet($true, $false)]
        [bool]$UpdateTags = $false
    )

    # Make sure we're not passing too many arguments.
    if (-not [string]::IsNullOrWhiteSpace($Path) -and `
            -not [string]::IsNullOrWhiteSpace($LiteralPath)) {
        throw [System.ArgumentException] "You can't pass both Path and LiteralPath";
    }
    
    # TODO Calculate the folder first here, then calculate the filename at the end.
    # that way, we can set the name of the playlist to album artist plus album title.
    #
    # Define the path we want for our M3U8 file.
    [string]$M3U8Path = "";
    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        $M3U8Path = Join-Path (Get-Location).Path (Split-Path -Path $Path -Leaf);
    }
    elseif (-not [string]::IsNullOrWhiteSpace($LiteralPath)) {
        $M3U8Path = $LiteralPath;
    }
    else {
        if (-not [string]::IsNullOrWhiteSpace($Performer) -and `
                -not [string]::IsNullOrWhiteSpace($Title)) {
            $M3U8Path = Join-Path (Get-Location).Path "$Performer - $Title.m3u8";
        }
        else {
            [string]$CurrentFolderName = Split-Path -Path (Get-Location).Path -Leaf;
            $M3U8Path = Join-Path (Get-Location).Path "$CurrentFolderName.m3u8";
        }
    }

    # Define the folder that's going to contain the M3U8 file.
    [string]$M3U8Folder = Split-Path $M3U8Path -Parent;
    Test-FolderExists -FolderPath $M3U8Folder;

    # Get list of files in M3U8 folder.
    [string[]]$ExtFiles = @(Get-ChildItem -LiteralPath $M3U8Folder -Filter "*.$Extension" |
        Select-Object -ExpandProperty "Name");
    if (-not $ExtFiles) {
        throw [System.IO.FileNotFoundException] `
            "No .$Extension files found in folder $M3U8Folder";
    }

    # Check if the tag arguments are empty and, if so, try to get them from
    # the first audio file found in the folder.
    if ($UseTags) {
        # Go over the various parameters passed onto this function that are empty.
        foreach ($param in (`
                @("Genre", "ReleaseYear", "ReleaseCountry", "Performer", "Title") | Where-Object {
                    -not (Get-Variable -Name $_ -ValueOnly) -or `
                        [string]::IsNullOrWhiteSpace($(Get-Variable -Name $_ -ValueOnly)) })) {
            [string]$value = Get-Variable -Name $param -ValueOnly;
            
            if ([string]::IsNullOrWhiteSpace($value)) {
                # Get the tags of the first audio file of the folder.
                $MusicFile = Get-MediaFile -LiteralPath (
                    Join-Path $M3U8Folder $ExtFiles[0]);

                # Populate the function arguments.
                switch ($param) {
                    "Genre" {
                        [string[]]$tagValue = Get-MediaFileTagStringArray `
                            -MediaFile $MusicFile -MediaTag "Genres";
                        if ($tagValue -and $tagValue.Length -gt 0) {
                            $Genre = $tagValue;
                        }
                    }

                    "ReleaseYear" {
                        [string]$tagValue = Get-MediaFileTag -MediaFile $MusicFile `
                            -MediaTag "Year";
                        if (-not [string]::IsNullOrWhiteSpace($tagValue)) {
                            $ReleaseYear = $tagValue.Trim();
                        }
                    }

                    "ReleaseCountry" {
                        [string]$tagValue = Get-MediaFileTag -MediaFile $MusicFile `
                            -MediaTag "MusicBrainzReleaseCountry";
                        if (-not [string]::IsNullOrWhiteSpace($tagValue)) {
                            $ReleaseCountry = $tagValue.Trim();
                        }
                    }

                    "Performer" {
                        [string[]]$albumArtistsValue = Get-MediaFileTagStringArray `
                            -MediaFile $MusicFile -MediaTag "AlbumArtists";
                        [string[]]$performersValue = Get-MediaFileTagStringArray `
                            -MediaFile $MusicFile -MediaTag "Performers";

                        if ($albumArtistsValue -and $albumArtistsValue.Length -gt 0) {
                            $Performer = $albumArtistsValue;
                        }
                        elseif ($performersValue -and $performersValue.Length -gt 0) {
                            $Performer = $performersValue;
                        }
                    }

                    "Title" {
                        [string]$tagValue = Get-MediaFileTag -MediaFile $MusicFile `
                            -MediaTag "Album";
                        if (-not [string]::IsNullOrWhiteSpace($tagValue)) {
                            $Title = $tagValue.Trim();
                        }
                    }
                }
            }
        }
    }

    # Check if the album metadata values aren't empty.
    foreach ($MetadataValue in @(
            "Genre", "ReleaseYear", "ReleaseCountry", "Performer", "Title")) {
        if (-not (Get-Variable -Name $MetadataValue -ValueOnly) -or `
                [string]::IsNullOrWhiteSpace(
                (Get-Variable -Name $MetadataValue -ValueOnly))) {
            Write-Warning "Tag $($MetadataValue) is empty";
        }
    }

    # Initialize the M3U playlist object.
    [PlaylistsNET.Models.M3uPlaylist]$M3U8Playlist = (
        New-M3UPlaylist -LiteralPath (Split-Path $M3U8Path -Parent) `
            -Filename (Split-Path $M3U8Path -Leaf))
    
    # Insert entries and metadata into the playlist.
    for ($i = 0; $i -lt $ExtFiles.Length; $i++) {
        $ExtFile = $ExtFiles[$i];
        # Get the file's tags so we can get track title and duration.
        $MusicFile = Get-MediaFile -LiteralPath (
            Join-Path $M3U8Folder $ExtFile);

        # We need track title and track length for the EXTINF M3U extension.
        [string]$TrackTitle = Get-MediaFileTag -MediaFile $MusicFile `
            -MediaTag "Title";
        if ([string]::IsNullOrWhiteSpace($TrackTitle)) {
            Write-Warning "Track `"$ExtFile`" has no title track in its tags";
        }
        [timespan]$TrackLength = $MusicFile.Properties.Duration;

        [PlaylistsNET.Models.M3uPlaylistEntry]$ExtFileEntry = $null;
        if ($i -eq 0) {
            $ExtFileEntry = New-M3UPlaylistEntry `
                -Path $ExtFile `
                -TrackTitle "$($Performer -join ", ") - $TrackTitle" `
                -TrackLength $TrackLength `
                -TrackArtist ($Performer -join ", ") `
                -AlbumTitle $Title `
                -CustomProperties @{
                "EXTGENRE"   = ($Genre -join ", ")
                "EXTCOUNTRY" = $ReleaseCountry
                "EXTDATE"    = $ReleaseYear
            };
        }
        else {
            $ExtFileEntry = New-M3UPlaylistEntry `
                -LiteralPath $ExtFile `
                -TrackTitle "$($Performer -join ", ") - $TrackTitle" `
                -TrackLength $TrackLength
        }
        
        $M3U8Playlist.PlaylistEntries.Add($ExtFileEntry);
    }

    # Write the M3U8 file.
    Set-Content -Value (Export-M3UPlaylist -M3UPlaylist $M3U8Playlist) `
        -Encoding "utf8BOM" -LiteralPath $M3U8Path;
    
    # Update all of the tags in our music files if argument $UpdateTags is $true.
    if ($UpdateTags) {
        Update-AlbumTags;
    }
}
