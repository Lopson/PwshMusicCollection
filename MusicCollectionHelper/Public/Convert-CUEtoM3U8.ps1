function Convert-CUEtoM3U8 {
    [OutputType([void])]
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
        [string]$LiteralPath,
        
        [ValidateSet([ValidTextEncodings])]
        [ValidateNotNullOrWhiteSpace()]
        [string]$Encoding = "iso-8859-1"
    )

    switch ($PSCmdlet.ParameterSetName) {
        "Path" {
            [string]$CuePath = Get-Item -Path $Path;
        }
        "LiteralPath" {
            [string]$CuePath = Get-Item -LiteralPath $LiteralPath;
        }
    }

    # Get the cue sheet and test it against our criteria.
    [string]$CueFolder = Split-Path -Path $CuePath -Parent;
    [CueSheet]$CueSheet = Get-CueSheet -LiteralPath $CuePath -Encoding $Encoding;
    Test-CueSheet -CueSheet $CueSheet;

    # Create the M3U8 playlist object.
    [string]$M3U8Path = Join-Path $CueFolder `
        "$((Split-Path -Path $CuePath -LeafBase)).m3u8";
    [PlaylistsNET.Models.M3uPlaylist]$M3U8Playlist = New-M3UPlaylist `
        -LiteralPath $CueFolder `
        -Filename "$((Split-Path -Path $CuePath -LeafBase)).m3u8";
    
    # Populate the playlist.
    for ($i = 0; $i -lt $CueSheet.Files.Length; $i++) {
        [CueFile]$CueSheetFile = $CueSheet.Files[$i];
        [string]$TrackTitle = $CueSheetFile.GetCurrentTrack().Title;
        [string]$TrackPerformer = $CueSheetFile.GetCurrentTrack().Performer;
        
        # Get the file's tags so we can get track duration.
        $MusicFile = Get-MediaFile -LiteralPath (
            Join-Path $CueFolder $CueSheetFile.Name);
        [timespan]$TrackLength = $MusicFile.Properties.Duration;

        # Add a new entry to the M3U8 playlist.
        [PlaylistsNET.Models.M3uPlaylistEntry]$M3U8FileEntry = $null;
        if ($i -eq 0) {
            $M3U8FileEntry = New-M3UPlaylistEntry `
                -Path $CueSheetFile.Name `
                -TrackTitle "$TrackPerformer - $TrackTitle" `
                -TrackLength $TrackLength `
                -TrackArtist $CueSheet.Performer `
                -AlbumTitle $CueSheet.Title `
                -CustomProperties @{
                "EXTGENRE"   = $CueSheet.Genre
                "EXTCOUNTRY" = $CueSheet.Country
                "EXTDATE"    = $CueSheet.Date
            };
        }
        else {
            $M3U8FileEntry = New-M3UPlaylistEntry `
                -Path $CueSheetFile.Name `
                -TrackTitle "$TrackPerformer - $TrackTitle" `
                -TrackLength $TrackLength
        }
        
        [void]$M3U8Playlist.PlaylistEntries.Add($M3U8FileEntry);
    }

    # Write the M3U8 file.
    Set-Content -Value (Export-M3UPlaylist -M3UPlaylist $M3U8Playlist) `
        -Encoding "utf8BOM" -LiteralPath $M3U8Path;
}
