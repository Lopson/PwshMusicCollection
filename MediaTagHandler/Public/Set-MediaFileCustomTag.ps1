function Set-MediaFileCustomTag {
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        $MediaFile,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrWhiteSpace()]
        [string]$MediaTag,

        [Parameter(Mandatory = $true)]
        [TagLib.TagTypes]$MediaTagType,

        $MediaTagValue,

        [bool]$Save = $true,

        [bool]$Force = $false
    )

    process {
        Test-MediaFile -MediaFile $MediaFile;

        $CustomTags = $MediaFile.GetTag($MediaTagType);

        if ($Force -or ($CustomTags.GetField($MediaTag) -ne $MediaTagValue)) {
            $CustomTags.SetField($MediaTag, $MediaTagValue);

            if ($Save) {
                $Tags.Save();
            }
        }
    }
}
