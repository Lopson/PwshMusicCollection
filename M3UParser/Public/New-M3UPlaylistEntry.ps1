function New-M3UPlaylistEntry {
    [CmdletBinding(DefaultParameterSetName = "Path")]
    [OutputType([PlaylistsNET.Models.M3uPlaylistEntry])]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Path")]
        [ValidateScript({
                Test-Path -Path $_ -PathType "Leaf"; },
            ErrorMessage = "Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(Mandatory = $true, ParameterSetName = "LiteralPath")]
        [ValidateScript({
                Test-Path -LiteralPath $_ -PathType "Leaf"; },
            ErrorMessage = "Literal Path `"{0}`" doesn't seem to exist."
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$LiteralPath,

        [Parameter(Mandatory = $true, ParameterSetName = "Path")]
        [Parameter(Mandatory = $true, ParameterSetName = "LiteralPath")]
        [ValidateNotNull()]
        [timespan]$TrackLength,

        [Parameter(Mandatory = $true, ParameterSetName = "Path")]
        [Parameter(Mandatory = $true, ParameterSetName = "LiteralPath")]
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TrackTitle,
        
        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateNotNullOrEmpty()]
        [string]$TrackArtist,
        
        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [string]$AlbumTitle,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [ValidateScript({ $_ -is [hashtable] })]
        [hashtable]$CustomProperties,

        [Parameter(ParameterSetName = "Path")]
        [Parameter(ParameterSetName = "LiteralPath")]
        [string[]]$Comments
    )

    [string]$FilePath = "";
    switch ($PSCmdlet.ParameterSetName) {
        "Path" {
            $FilePath = $Path;
        }
        "LiteralPath" {
            $FilePath = (Split-Path $LiteralPath -Leaf);
        }
    }

    [PlaylistsNET.Models.M3uPlaylistEntry]$entry = New-Object `
        PlaylistsNET.Models.M3uPlaylistEntry -Property @{
        AlbumArtist      = $TrackArtist
        Duration         = $TrackLength
        Path             = $FilePath
        Title            = $TrackTitle
    };
    
    if (-not [string]::IsNullOrWhiteSpace($AlbumTitle)) {
        $entry.Album = $AlbumTitle;
    }
    if ($null -ne $CustomProperties) {
        $value = [Collections.Generic.Dictionary[string, string]]::new();
        foreach ($keyValuePair in $CustomProperties.GetEnumerator()) {
            $value.Add($keyValuePair.Key, $keyValuePair.Value);
        }

        $entry.CustomProperties = $value;
    }
    if ($null -ne $Comments -and $Comments.Length -gt 0) {
        $entry.Comments = $Comments;
    }

    return $entry;
}
