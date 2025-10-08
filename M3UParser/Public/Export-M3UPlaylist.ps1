function Export-M3UPlaylist {
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [PlaylistsNET.Models.M3uPlaylist]$M3UPlaylist
    )

    return ([PlaylistsNET.Content.M3uContent]::new()).ToText($M3UPlaylist);
}
