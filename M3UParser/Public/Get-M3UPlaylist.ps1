function Get-M3UPlaylist {
    [OutputType([PlaylistsNET.Models.M3uPlaylist])]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Path")]
        [ValidateScript({
                Test-Path -Path $_ -PathType "Leaf"; },
            ErrorMessage = "Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $true, ParameterSetName = "LiteralPath")]
        [ValidateScript({
                Test-Path -LiteralPath $_ -PathType "Leaf"; },
            ErrorMessage = "Literal Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrEmpty()]
        [string]$LiteralPath
    )

    $M3UPlaylistPath = $null;
    switch ($PSCmdlet.ParameterSetName) {
        "Path" {
            $M3UPlaylistPath = Get-Item -Path $Path;
        }
        "LiteralPath" {
            $M3UPlaylistPath = Get-Item -LiteralPath $LiteralPath;
        }
    }

    [PlaylistsNET.Models.M3uPlaylist]$playlist = `
        [PlaylistsNET.Content.M3uContent]::new().GetFromString(
        (Get-Content -LiteralPath $M3UPlaylistPath.FullName -Raw));
    
    # Normalize comments by removing the hashtag and whitespace following it.
    [string[]]$normalizedComments = @();
    foreach ($comment in $playlist.Comments) {
        [string]$normalizedComment = $comment;
        if ($comment -match "^#\s?") {
            $normalizedComment = $comment -replace "^#\s?", "";
        }
        $normalizedComments += $normalizedComment;
    }
    $playlist.Comments = $normalizedComments;
    $playlist.Path = $M3UPlaylistPath.DirectoryName;
    $playlist.FileName = $M3UPlaylistPath.Name;

    return $playlist;
}
