function Clear-MediaFileTag {
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [TagLib.File[]]$MediaFile,
        
        [Parameter(Mandatory = $true, ParameterSetName = "Path")]
        [Parameter(Mandatory = $true, ParameterSetName = "LiteralPath")]
        [ValidateSet([ValidTags])]
        [ValidateNotNullOrEmpty()]
        [string]$MediaTag
    )

    process {
        Set-MediaFileTag -MediaFile $MusicFile -MediaTag $MusicTag `
            -MediaTagValue "";
    }
}
