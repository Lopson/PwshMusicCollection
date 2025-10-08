function New-M3UPlaylist {
    [CmdletBinding(DefaultParameterSetName="Path")]
    [OutputType([PlaylistsNET.Models.M3uPlaylist])]
    param(
        [Parameter(ParameterSetName = "Path")]
        [ValidateScript({ if (-not [string]::IsNullOrWhiteSpace($_)) {
                    Test-Path -Path $_ -PathType "Container";
                } },
            ErrorMessage = "Folder of path `"{0}`" doesn't seem to exist."
        )]
        [string]$Path,
        
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateScript({ if (-not [string]::IsNullOrWhiteSpace($_)) {
                    Test-Path -LiteralPath $_ -PathType "Container";
                } },
            ErrorMessage = "Folder of literal path `"{0}`" doesn't seem to exist."
        )]
        [string]$LiteralPath,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateScript({ $_ -is [bool] })]
        [bool]$IsExtended = $true,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateScript({
            (-not [string]::IsNullOrWhiteSpace($_)) -and $_.IndexOfAny(
            [System.IO.Path]::GetInvalidFileNameChars()) -eq -1 }
        )]
        [string]$Filename,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNull()]
        [array]$Comments
    )

    [PlaylistsNET.Models.M3uPlaylist]$playlist = `
        [PlaylistsNET.Models.M3uPlaylist]::new();

    $playlist.IsExtended = $IsExtended;

    switch ($PSCmdlet.ParameterSetName) {
        "Path" {
            if (-not [string]::IsNullOrWhiteSpace($Path)){
                $playlist.Path = $Path;
            }
        }
        "LiteralPath" {
            if (-not [string]::IsNullOrWhiteSpace($LiteralPath)){
                $playlist.Path = $LiteralPath;
            }
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($Filename)) {
        if (-not ($Filename -match "\.(m3u|m3u8)$")) {
            $Filename += ".m3u";
        }
        $playlist.FileName = $Filename;
    }
    if ($Comments -is [array] -and $Comments.Length -gt 0) {
        $playlist.Comments = $Comments;
    }

    return $playlist;
}
